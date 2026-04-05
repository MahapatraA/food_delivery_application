const Razorpay = require('razorpay');
const crypto = require('crypto');
const Order = require('../models/Order');
const { successResponse, errorResponse } = require('../utils/apiResponse');

// Initialize Razorpay instance
const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

// @desc    Create Razorpay order (initiate payment)
// @route   POST /api/payment/create-order
const createPaymentOrder = async (req, res) => {
  const { orderId } = req.body;

  const order = await Order.findOne({
    $or: [{ _id: orderId }, { orderId }],
    user: req.user._id,
  });

  if (!order) return errorResponse(res, 'Order not found', 404);
  if (order.payment.status === 'paid') {
    return errorResponse(res, 'Order already paid', 400);
  }
  if (order.payment.method !== 'razorpay') {
    return errorResponse(res, 'This order does not use Razorpay', 400);
  }

  // Amount in paise (multiply by 100)
  const razorpayOrder = await razorpay.orders.create({
    amount: Math.round(order.total * 100),
    currency: 'INR',
    receipt: order.orderId,
    notes: {
      orderId: order.orderId,
      userId: req.user._id.toString(),
    },
  });

  // Save razorpay order ID to our order
  order.payment.razorpayOrderId = razorpayOrder.id;
  await order.save();

  return successResponse(res, {
    razorpayOrderId: razorpayOrder.id,
    amount: razorpayOrder.amount,
    currency: razorpayOrder.currency,
    key: process.env.RAZORPAY_KEY_ID,
    orderDetails: {
      orderId: order.orderId,
      total: order.total,
    },
  }, 'Payment order created');
};

// @desc    Verify Razorpay payment signature
// @route   POST /api/payment/verify
const verifyPayment = async (req, res) => {
  const {
    razorpay_order_id,
    razorpay_payment_id,
    razorpay_signature,
    orderId,
  } = req.body;

  if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
    return errorResponse(res, 'Payment verification data missing', 400);
  }

  // Verify signature
  const expectedSignature = crypto
    .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
    .update(`${razorpay_order_id}|${razorpay_payment_id}`)
    .digest('hex');

  if (expectedSignature !== razorpay_signature) {
    return errorResponse(res, 'Payment verification failed. Invalid signature.', 400);
  }

  // Update order payment status
  const order = await Order.findOne({
    $or: [{ _id: orderId }, { orderId }],
    user: req.user._id,
  });

  if (!order) return errorResponse(res, 'Order not found', 404);

  order.payment.status = 'paid';
  order.payment.razorpayPaymentId = razorpay_payment_id;
  order.payment.razorpaySignature = razorpay_signature;
  order.payment.paidAt = new Date();

  // Auto-confirm order once payment is successful
  if (order.status === 'pending') {
    order.status = 'confirmed';
    order.statusHistory.push({ status: 'confirmed', note: 'Payment received' });
  }

  await order.save();

  // Emit real-time events
  const io = req.app.get('io');
  io.to(`order_${order._id}`).emit('payment_confirmed', {
    orderId: order.orderId,
    status: order.status,
  });
  io.to(`restaurant_${order.restaurant}`).emit('new_order_confirmed', {
    orderId: order.orderId,
    total: order.total,
  });

  return successResponse(res, {
    order: {
      orderId: order.orderId,
      status: order.status,
      paymentStatus: order.payment.status,
      paidAt: order.payment.paidAt,
    },
  }, 'Payment verified successfully');
};

// @desc    Handle Razorpay webhook (server-side event verification)
// @route   POST /api/payment/webhook
const handleWebhook = async (req, res) => {
  const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET;
  const signature = req.headers['x-razorpay-signature'];

  // Verify webhook signature
  const expectedSignature = crypto
    .createHmac('sha256', webhookSecret)
    .update(JSON.stringify(req.body))
    .digest('hex');

  if (signature !== expectedSignature) {
    return res.status(400).json({ success: false, message: 'Invalid webhook signature' });
  }

  const { event, payload } = req.body;

  if (event === 'payment.captured') {
    const paymentId = payload.payment.entity.id;
    const razorpayOrderId = payload.payment.entity.order_id;

    await Order.findOneAndUpdate(
      { 'payment.razorpayOrderId': razorpayOrderId },
      {
        'payment.status': 'paid',
        'payment.razorpayPaymentId': paymentId,
        'payment.paidAt': new Date(),
      }
    );
  }

  if (event === 'payment.failed') {
    const razorpayOrderId = payload.payment.entity.order_id;
    await Order.findOneAndUpdate(
      { 'payment.razorpayOrderId': razorpayOrderId },
      { 'payment.status': 'failed' }
    );
  }

  return res.status(200).json({ received: true });
};

// @desc    Get payment details for an order
// @route   GET /api/payment/:orderId
const getPaymentDetails = async (req, res) => {
  const order = await Order.findOne({
    $or: [{ _id: req.params.orderId }, { orderId: req.params.orderId }],
    user: req.user._id,
  }).select('orderId payment total status');

  if (!order) return errorResponse(res, 'Order not found', 404);
  return successResponse(res, { payment: order.payment, total: order.total, orderId: order.orderId });
};

module.exports = {
  createPaymentOrder,
  verifyPayment,
  handleWebhook,
  getPaymentDetails,
};
