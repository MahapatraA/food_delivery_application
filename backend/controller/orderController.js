const Order = require('../models/Order');
const Cart = require('../models/Cart');
const Restaurant = require('../models/Restaurant');
const { successResponse, errorResponse, paginatedResponse } = require('../utils/apiResponse');
const { v4: uuidv4 } = require('uuid');

// Generate short order ID
const generateOrderId = () => `ORD-${uuidv4().split('-')[0].toUpperCase()}`;

// @desc    Place order from cart
// @route   POST /api/orders
const placeOrder = async (req, res) => {
  const { deliveryAddress, paymentMethod, specialInstructions } = req.body;

  const cart = await Cart.findOne({ user: req.user._id }).populate('items.menuItem');
  if (!cart || cart.items.length === 0) {
    return errorResponse(res, 'Cart is empty', 400);
  }

  const restaurant = await Restaurant.findById(cart.restaurant);
  if (!restaurant || !restaurant.isOpen) {
    return errorResponse(res, 'Restaurant is not accepting orders', 400);
  }

  if (cart.subtotal < restaurant.minOrderAmount) {
    return errorResponse(
      res,
      `Minimum order amount is ₹${restaurant.minOrderAmount}`,
      400
    );
  }

  // Build order items from cart
  const orderItems = cart.items.map((item) => ({
    menuItem: item.menuItem._id,
    name: item.name,
    price: item.price,
    image: item.image,
    quantity: item.quantity,
    customizations: item.customizations,
    itemTotal: item.itemTotal,
  }));

  const order = await Order.create({
    orderId: generateOrderId(),
    user: req.user._id,
    restaurant: cart.restaurant,
    items: orderItems,
    deliveryAddress,
    subtotal: cart.subtotal,
    deliveryFee: cart.deliveryFee,
    taxes: cart.taxes,
    discount: cart.discount,
    total: cart.total,
    couponCode: cart.couponCode,
    specialInstructions,
    estimatedDeliveryTime: restaurant.deliveryTime || 30,
    payment: {
      method: paymentMethod,
      status: paymentMethod === 'cod' ? 'pending' : 'pending',
    },
    statusHistory: [{ status: 'pending', note: 'Order placed' }],
  });

  // Emit to restaurant's socket room
  const io = req.app.get('io');
  io.to(`restaurant_${cart.restaurant}`).emit('new_order', {
    orderId: order.orderId,
    total: order.total,
    items: order.items.length,
  });

  // Clear cart after placing order
  await Cart.findByIdAndDelete(cart._id);

  return successResponse(res, { order }, 'Order placed successfully', 201);
};

// @desc    Get user's orders
// @route   GET /api/orders/my
const getMyOrders = async (req, res) => {
  const { page = 1, limit = 10, status } = req.query;
  const filter = { user: req.user._id };
  if (status) filter.status = status;

  const skip = (page - 1) * limit;
  const [orders, total] = await Promise.all([
    Order.find(filter)
      .sort('-createdAt')
      .skip(skip)
      .limit(parseInt(limit))
      .populate('restaurant', 'name logo address'),
    Order.countDocuments(filter),
  ]);

  return paginatedResponse(res, orders, total, page, limit);
};

// @desc    Get single order
// @route   GET /api/orders/:id
const getOrder = async (req, res) => {
  const order = await Order.findOne({
    $or: [{ _id: req.params.id }, { orderId: req.params.id }],
    user: req.user._id,
  }).populate('restaurant', 'name logo phone address');

  if (!order) return errorResponse(res, 'Order not found', 404);
  return successResponse(res, { order });
};

// @desc    Get restaurant's incoming orders (owner)
// @route   GET /api/orders/restaurant
const getRestaurantOrders = async (req, res) => {
  const restaurant = await Restaurant.findOne({ owner: req.user._id });
  if (!restaurant) return errorResponse(res, 'No restaurant found', 404);

  const { page = 1, limit = 20, status } = req.query;
  const filter = { restaurant: restaurant._id };
  if (status) filter.status = status;

  const skip = (page - 1) * limit;
  const [orders, total] = await Promise.all([
    Order.find(filter)
      .sort('-createdAt')
      .skip(skip)
      .limit(parseInt(limit))
      .populate('user', 'name phone'),
    Order.countDocuments(filter),
  ]);

  return paginatedResponse(res, orders, total, page, limit);
};

// @desc    Update order status (restaurant owner)
// @route   PATCH /api/orders/:id/status
const updateOrderStatus = async (req, res) => {
  const { status, note } = req.body;

  const validTransitions = {
    pending: ['confirmed', 'cancelled'],
    confirmed: ['preparing', 'cancelled'],
    preparing: ['ready_for_pickup'],
    ready_for_pickup: ['out_for_delivery'],
    out_for_delivery: ['delivered'],
  };

  const order = await Order.findById(req.params.id);
  if (!order) return errorResponse(res, 'Order not found', 404);

  // Check restaurant ownership
  const restaurant = await Restaurant.findOne({ owner: req.user._id });
  if (!restaurant || order.restaurant.toString() !== restaurant._id.toString()) {
    return errorResponse(res, 'Unauthorized', 403);
  }

  const allowed = validTransitions[order.status];
  if (!allowed || !allowed.includes(status)) {
    return errorResponse(
      res,
      `Cannot transition from '${order.status}' to '${status}'`,
      400
    );
  }

  order.status = status;
  order.statusHistory.push({ status, note: note || '' });
  if (status === 'delivered') order.deliveredAt = new Date();

  await order.save();

  // Emit real-time update to user
  const io = req.app.get('io');
  io.to(`order_${order._id}`).emit('order_status_update', {
    orderId: order.orderId,
    status: order.status,
    timestamp: new Date(),
  });

  return successResponse(res, { order }, 'Order status updated');
};

// @desc    Cancel order (user)
// @route   PATCH /api/orders/:id/cancel
const cancelOrder = async (req, res) => {
  const order = await Order.findOne({ _id: req.params.id, user: req.user._id });
  if (!order) return errorResponse(res, 'Order not found', 404);

  const cancellableStatuses = ['pending', 'confirmed'];
  if (!cancellableStatuses.includes(order.status)) {
    return errorResponse(res, 'Order cannot be cancelled at this stage', 400);
  }

  order.status = 'cancelled';
  order.statusHistory.push({ status: 'cancelled', note: req.body.reason || 'Cancelled by user' });
  await order.save();

  // Notify restaurant
  const io = req.app.get('io');
  io.to(`restaurant_${order.restaurant}`).emit('order_cancelled', {
    orderId: order.orderId,
  });

  return successResponse(res, { order }, 'Order cancelled successfully');
};

// @desc    Admin: get all orders
// @route   GET /api/orders/admin/all
const getAllOrders = async (req, res) => {
  const { page = 1, limit = 20, status, restaurantId } = req.query;
  const filter = {};
  if (status) filter.status = status;
  if (restaurantId) filter.restaurant = restaurantId;

  const skip = (page - 1) * limit;
  const [orders, total] = await Promise.all([
    Order.find(filter)
      .sort('-createdAt')
      .skip(skip)
      .limit(parseInt(limit))
      .populate('user', 'name email')
      .populate('restaurant', 'name'),
    Order.countDocuments(filter),
  ]);

  return paginatedResponse(res, orders, total, page, limit);
};

module.exports = {
  placeOrder,
  getMyOrders,
  getOrder,
  getRestaurantOrders,
  updateOrderStatus,
  cancelOrder,
  getAllOrders,
};
