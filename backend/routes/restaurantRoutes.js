const express = require('express');
const router = express.Router();
const {
  createRestaurant, getRestaurants, getRestaurant,
  getMyRestaurant, updateRestaurant, toggleRestaurant,
  approveRestaurant, getNearbyRestaurants,
} = require('../controllers/restaurantController');
const { protect, authorize } = require('../middleware/auth');
const { validate, restaurantRules } = require('../middleware/validate');

// Public routes
router.get('/', getRestaurants);
router.get('/nearby', getNearbyRestaurants);

// Protected routes
router.use(protect);
router.get('/my', authorize('restaurant_owner'), getMyRestaurant);
router.post('/', authorize('restaurant_owner'), restaurantRules, validate, createRestaurant);
router.put('/:id', authorize('restaurant_owner'), updateRestaurant);
router.patch('/:id/toggle', authorize('restaurant_owner'), toggleRestaurant);

// Admin routes
router.patch('/:id/approve', authorize('admin'), approveRestaurant);

// Public (must be after /my and /nearby to avoid conflicts)
router.get('/:id', getRestaurant);

module.exports = router;
