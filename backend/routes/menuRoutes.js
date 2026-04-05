const express = require('express');
const router = express.Router();
const {
  createCategory, getCategories, updateCategory, deleteCategory,
  createMenuItem, getMenu, getMenuItem,
  updateMenuItem, deleteMenuItem, toggleItemAvailability,
} = require('../controllers/menuController');
const { protect, authorize } = require('../middleware/auth');
const { validate, menuItemRules } = require('../middleware/validate');

// Public routes
router.get('/:restaurantId', getMenu);
router.get('/items/:id', getMenuItem);
router.get('/categories/:restaurantId', getCategories);

// Protected routes (restaurant owners only)
router.use(protect, authorize('restaurant_owner'));

// Category CRUD
router.post('/categories', createCategory);
router.put('/categories/:id', updateCategory);
router.delete('/categories/:id', deleteCategory);

// Menu item CRUD
router.post('/items', menuItemRules, validate, createMenuItem);
router.put('/items/:id', updateMenuItem);
router.delete('/items/:id', deleteMenuItem);
router.patch('/items/:id/toggle', toggleItemAvailability);

module.exports = router;
