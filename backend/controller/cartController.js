const Cart = require('../models/Cart');
const MenuItem = require('../models/MenuItem');
const Restaurant = require('../models/Restaurant');
const { successResponse, errorResponse } = require('../utils/apiResponse');

// Helper: calculate item total including customizations
const calcItemTotal = (price, quantity, customizations = []) => {
  const customizationTotal = customizations.reduce(
    (sum, c) => sum + (c.additionalPrice || 0),
    0
  );
  return (price + customizationTotal) * quantity;
};

// @desc    Get cart
// @route   GET /api/cart
const getCart = async (req, res) => {
  const cart = await Cart.findOne({ user: req.user._id })
    .populate('restaurant', 'name logo deliveryFee minOrderAmount isOpen')
    .populate('items.menuItem', 'name price image isAvailable');

  if (!cart || cart.items.length === 0) {
    return successResponse(res, { cart: null, items: [], total: 0 }, 'Cart is empty');
  }

  return successResponse(res, { cart });
};

// @desc    Add item to cart
// @route   POST /api/cart/add
const addToCart = async (req, res) => {
  const { menuItemId, quantity = 1, customizations = [] } = req.body;

  const menuItem = await MenuItem.findById(menuItemId).populate('restaurant');
  if (!menuItem) return errorResponse(res, 'Menu item not found', 404);
  if (!menuItem.isAvailable) return errorResponse(res, 'Item is currently unavailable', 400);

  const restaurant = await Restaurant.findById(menuItem.restaurant);
  if (!restaurant.isOpen) return errorResponse(res, 'Restaurant is currently closed', 400);

  let cart = await Cart.findOne({ user: req.user._id });

  // If cart has items from a different restaurant, clear it
  if (cart && cart.restaurant && cart.restaurant.toString() !== menuItem.restaurant._id.toString()) {
    cart.items = [];
    cart.restaurant = menuItem.restaurant._id;
    cart.couponCode = null;
    cart.discount = 0;
  }

  if (!cart) {
    cart = new Cart({
      user: req.user._id,
      restaurant: menuItem.restaurant._id,
      items: [],
    });
  }

  // Check if same item with same customizations already in cart
  const existingItemIndex = cart.items.findIndex(
    (i) =>
      i.menuItem.toString() === menuItemId &&
      JSON.stringify(i.customizations) === JSON.stringify(customizations)
  );

  const price = menuItem.discountedPrice || menuItem.price;

  if (existingItemIndex > -1) {
    cart.items[existingItemIndex].quantity += quantity;
    cart.items[existingItemIndex].itemTotal = calcItemTotal(
      price,
      cart.items[existingItemIndex].quantity,
      customizations
    );
  } else {
    cart.items.push({
      menuItem: menuItemId,
      name: menuItem.name,
      price,
      image: menuItem.image,
      quantity,
      customizations,
      itemTotal: calcItemTotal(price, quantity, customizations),
    });
  }

  cart.deliveryFee = restaurant.deliveryFee || 0;
  await cart.save();

  return successResponse(res, { cart }, 'Item added to cart');
};

// @desc    Update item quantity in cart
// @route   PUT /api/cart/item/:itemId
const updateCartItem = async (req, res) => {
  const { quantity } = req.body;
  if (!quantity || quantity < 1) return errorResponse(res, 'Quantity must be at least 1', 400);

  const cart = await Cart.findOne({ user: req.user._id });
  if (!cart) return errorResponse(res, 'Cart not found', 404);

  const item = cart.items.id(req.params.itemId);
  if (!item) return errorResponse(res, 'Item not found in cart', 404);

  item.quantity = quantity;
  item.itemTotal = calcItemTotal(item.price, quantity, item.customizations);

  await cart.save();
  return successResponse(res, { cart }, 'Cart updated');
};

// @desc    Remove item from cart
// @route   DELETE /api/cart/item/:itemId
const removeCartItem = async (req, res) => {
  const cart = await Cart.findOne({ user: req.user._id });
  if (!cart) return errorResponse(res, 'Cart not found', 404);

  cart.items = cart.items.filter((i) => i._id.toString() !== req.params.itemId);

  if (cart.items.length === 0) {
    cart.restaurant = null;
    cart.deliveryFee = 0;
    cart.couponCode = null;
    cart.discount = 0;
  }

  await cart.save();
  return successResponse(res, { cart }, 'Item removed from cart');
};

// @desc    Clear entire cart
// @route   DELETE /api/cart
const clearCart = async (req, res) => {
  await Cart.findOneAndDelete({ user: req.user._id });
  return successResponse(res, {}, 'Cart cleared');
};

// @desc    Apply coupon code (basic implementation)
// @route   POST /api/cart/coupon
const applyCoupon = async (req, res) => {
  const { couponCode } = req.body;

  const cart = await Cart.findOne({ user: req.user._id });
  if (!cart || cart.items.length === 0) return errorResponse(res, 'Cart is empty', 400);

  // Basic coupon logic — replace with DB lookup for real coupons
  const coupons = {
    FIRST50: { discount: 50, minOrder: 200 },
    SAVE100: { discount: 100, minOrder: 500 },
    FLAT20: { discountPercent: 20, minOrder: 300, maxDiscount: 150 },
  };

  const coupon = coupons[couponCode?.toUpperCase()];
  if (!coupon) return errorResponse(res, 'Invalid coupon code', 400);
  if (cart.subtotal < coupon.minOrder) {
    return errorResponse(res, `Minimum order of ₹${coupon.minOrder} required`, 400);
  }

  let discount = coupon.discount || 0;
  if (coupon.discountPercent) {
    discount = Math.min(
      (cart.subtotal * coupon.discountPercent) / 100,
      coupon.maxDiscount || Infinity
    );
  }

  cart.couponCode = couponCode.toUpperCase();
  cart.discount = discount;
  await cart.save();

  return successResponse(res, { cart, discount }, `Coupon applied! You save ₹${discount}`);
};

// @desc    Remove coupon
// @route   DELETE /api/cart/coupon
const removeCoupon = async (req, res) => {
  const cart = await Cart.findOne({ user: req.user._id });
  if (!cart) return errorResponse(res, 'Cart not found', 404);

  cart.couponCode = null;
  cart.discount = 0;
  await cart.save();

  return successResponse(res, { cart }, 'Coupon removed');
};

module.exports = {
  getCart,
  addToCart,
  updateCartItem,
  removeCartItem,
  clearCart,
  applyCoupon,
  removeCoupon,
};
