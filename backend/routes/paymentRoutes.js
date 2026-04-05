const express = require('express');
const router = express.Router();
const {
  createPaymentOrder, verifyPayment, handleWebhook, getPaymentDetails,
} = require('../controllers/paymentController');
const { protect } = require('../middleware/auth');

// Webhook: no auth (raw body needed for signature verification)
router.post('/webhook', express.raw({ type: 'application/json' }), handleWebhook);

// Protected routes
router.use(protect);
router.post('/create-order', createPaymentOrder);
router.post('/verify', verifyPayment);
router.get('/:orderId', getPaymentDetails);

module.exports = router;
