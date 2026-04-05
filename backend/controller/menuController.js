const MenuItem = require('../models/MenuItem');
const MenuCategory = require('../models/MenuCategory');
const Restaurant = require('../models/Restaurant');
const { successResponse, errorResponse } = require('../utils/apiResponse');
const { getRedis } = require('../config/redis');

const CACHE_TTL = 300;

// ─── CATEGORY CONTROLLERS ────────────────────────────────────────

// @desc    Create menu category
// @route   POST /api/menu/categories
const createCategory = async (req, res) => {
  const restaurant = await Restaurant.findOne({ owner: req.user._id });
  if (!restaurant) return errorResponse(res, 'You have no restaurant', 404);

  const category = await MenuCategory.create({
    ...req.body,
    restaurant: restaurant._id,
  });

  await invalidateMenuCache(restaurant._id);
  return successResponse(res, { category }, 'Category created', 201);
};

// @desc    Get all categories for a restaurant
// @route   GET /api/menu/categories/:restaurantId
const getCategories = async (req, res) => {
  const categories = await MenuCategory.find({
    restaurant: req.params.restaurantId,
    isActive: true,
  }).sort('sortOrder');

  return successResponse(res, { categories });
};

// @desc    Update category
// @route   PUT /api/menu/categories/:id
const updateCategory = async (req, res) => {
  const restaurant = await Restaurant.findOne({ owner: req.user._id });
  if (!restaurant) return errorResponse(res, 'Unauthorized', 403);

  const category = await MenuCategory.findOneAndUpdate(
    { _id: req.params.id, restaurant: restaurant._id },
    req.body,
    { new: true, runValidators: true }
  );

  if (!category) return errorResponse(res, 'Category not found', 404);
  await invalidateMenuCache(restaurant._id);
  return successResponse(res, { category }, 'Category updated');
};

// @desc    Delete category
// @route   DELETE /api/menu/categories/:id
const deleteCategory = async (req, res) => {
  const restaurant = await Restaurant.findOne({ owner: req.user._id });
  if (!restaurant) return errorResponse(res, 'Unauthorized', 403);

  await MenuCategory.findOneAndDelete({ _id: req.params.id, restaurant: restaurant._id });
  await MenuItem.deleteMany({ category: req.params.id });
  await invalidateMenuCache(restaurant._id);
  return successResponse(res, {}, 'Category and its items deleted');
};

// ─── MENU ITEM CONTROLLERS ────────────────────────────────────────

// @desc    Create menu item
// @route   POST /api/menu/items
const createMenuItem = async (req, res) => {
  const restaurant = await Restaurant.findOne({ owner: req.user._id });
  if (!restaurant) return errorResponse(res, 'You have no restaurant', 404);

  // Validate category belongs to this restaurant
  const category = await MenuCategory.findOne({
    _id: req.body.category,
    restaurant: restaurant._id,
  });
  if (!category) return errorResponse(res, 'Category not found for this restaurant', 404);

  const item = await MenuItem.create({ ...req.body, restaurant: restaurant._id });
  await invalidateMenuCache(restaurant._id);
  return successResponse(res, { item }, 'Menu item created', 201);
};

// @desc    Get full menu for a restaurant (grouped by category)
// @route   GET /api/menu/:restaurantId
const getMenu = async (req, res) => {
  const cacheKey = `menu:${req.params.restaurantId}`;
  try {
    const redis = getRedis();
    const cached = await redis.get(cacheKey);
    if (cached) return res.status(200).json(JSON.parse(cached));
  } catch (_) {}

  const categories = await MenuCategory.find({
    restaurant: req.params.restaurantId,
    isActive: true,
  }).sort('sortOrder');

  const menuWithItems = await Promise.all(
    categories.map(async (cat) => {
      const items = await MenuItem.find({
        category: cat._id,
        restaurant: req.params.restaurantId,
        isAvailable: true,
      }).sort('sortOrder');
      return { category: cat, items };
    })
  );

  const result = { success: true, message: 'Success', data: { menu: menuWithItems } };

  try {
    const redis = getRedis();
    await redis.setex(cacheKey, CACHE_TTL, JSON.stringify(result));
  } catch (_) {}

  return res.status(200).json(result);
};

// @desc    Get single menu item
// @route   GET /api/menu/items/:id
const getMenuItem = async (req, res) => {
  const item = await MenuItem.findById(req.params.id).populate('category', 'name');
  if (!item) return errorResponse(res, 'Item not found', 404);
  return successResponse(res, { item });
};

// @desc    Update menu item
// @route   PUT /api/menu/items/:id
const updateMenuItem = async (req, res) => {
  const restaurant = await Restaurant.findOne({ owner: req.user._id });
  if (!restaurant) return errorResponse(res, 'Unauthorized', 403);

  const item = await MenuItem.findOneAndUpdate(
    { _id: req.params.id, restaurant: restaurant._id },
    req.body,
    { new: true, runValidators: true }
  );

  if (!item) return errorResponse(res, 'Item not found', 404);
  await invalidateMenuCache(restaurant._id);
  return successResponse(res, { item }, 'Menu item updated');
};

// @desc    Delete menu item
// @route   DELETE /api/menu/items/:id
const deleteMenuItem = async (req, res) => {
  const restaurant = await Restaurant.findOne({ owner: req.user._id });
  if (!restaurant) return errorResponse(res, 'Unauthorized', 403);

  const item = await MenuItem.findOneAndDelete({ _id: req.params.id, restaurant: restaurant._id });
  if (!item) return errorResponse(res, 'Item not found', 404);

  await invalidateMenuCache(restaurant._id);
  return successResponse(res, {}, 'Menu item deleted');
};

// @desc    Toggle item availability
// @route   PATCH /api/menu/items/:id/toggle
const toggleItemAvailability = async (req, res) => {
  const restaurant = await Restaurant.findOne({ owner: req.user._id });
  if (!restaurant) return errorResponse(res, 'Unauthorized', 403);

  const item = await MenuItem.findOne({ _id: req.params.id, restaurant: restaurant._id });
  if (!item) return errorResponse(res, 'Item not found', 404);

  item.isAvailable = !item.isAvailable;
  await item.save();
  await invalidateMenuCache(restaurant._id);

  return successResponse(res, { isAvailable: item.isAvailable }, `Item is now ${item.isAvailable ? 'available' : 'unavailable'}`);
};

// Helper to clear menu cache
const invalidateMenuCache = async (restaurantId) => {
  try {
    const redis = getRedis();
    await redis.del(`menu:${restaurantId}`);
  } catch (_) {}
};

module.exports = {
  createCategory,
  getCategories,
  updateCategory,
  deleteCategory,
  createMenuItem,
  getMenu,
  getMenuItem,
  updateMenuItem,
  deleteMenuItem,
  toggleItemAvailability,
};
