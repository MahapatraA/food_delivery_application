const express = require('express');
const router = express.Router();
const {
  placeOrder, getMyOrders, getOrder, getRestaurantOrders,
  updateOrderStatus, cancelOrder, getAllOrders,
} = require('../controllers/orderController');
const { protect, authorize } = require('../middleware/auth');

router.use(protect);

// User routes
router.post('/', placeOrder);
router.get('/my', getMyOrders);
router.get('/:id', getOrder);
router.patch('/:id/cancel', cancelOrder);

// Restaurant owner routes
router.get('/restaurant/all', authorize('restaurant_owner'), getRestaurantOrders);
router.patch('/:id/status', authorize('restaurant_owner'), updateOrderStatus);

// Admin routes
router.get('/admin/all', authorize('admin'), getAllOrders);

module.exports = router;
