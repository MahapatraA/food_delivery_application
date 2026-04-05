const Restaurant = require('../models/Restaurant');
const { successResponse, errorResponse, paginatedResponse } = require('../utils/apiResponse');
const { getRedis } = require('../config/redis');

const CACHE_TTL = 300; // 5 minutes

// @desc    Create restaurant
// @route   POST /api/restaurants
const createRestaurant = async (req, res) => {
  const existing = await Restaurant.findOne({ owner: req.user._id });
  if (existing) {
    return errorResponse(res, 'You already have a registered restaurant', 409);
  }

  const restaurant = await Restaurant.create({ ...req.body, owner: req.user._id });
  return successResponse(res, { restaurant }, 'Restaurant created. Pending admin approval.', 201);
};

// @desc    Get all approved restaurants (with pagination + filters)
// @route   GET /api/restaurants
const getRestaurants = async (req, res) => {
  const { page = 1, limit = 10, cuisine, search, sort = '-rating', city } = req.query;

  const cacheKey = `restaurants:${JSON.stringify(req.query)}`;
  try {
    const redis = getRedis();
    const cached = await redis.get(cacheKey);
    if (cached) return res.status(200).json(JSON.parse(cached));
  } catch (_) {}

  const filter = { isApproved: true, isActive: true };
  if (cuisine) filter.cuisines = { $in: [cuisine] };
  if (city) filter['address.city'] = new RegExp(city, 'i');
  if (search) filter.$text = { $search: search };

  const skip = (page - 1) * limit;
  const [restaurants, total] = await Promise.all([
    Restaurant.find(filter)
      .sort(sort)
      .skip(skip)
      .limit(parseInt(limit))
      .select('-owner'),
    Restaurant.countDocuments(filter),
  ]);

  const result = { success: true, message: 'Success', data: restaurants, pagination: { total, page: parseInt(page), limit: parseInt(limit), pages: Math.ceil(total / limit) } };

  try {
    const redis = getRedis();
    await redis.setex(cacheKey, CACHE_TTL, JSON.stringify(result));
  } catch (_) {}

  return res.status(200).json(result);
};

// @desc    Get single restaurant by ID
// @route   GET /api/restaurants/:id
const getRestaurant = async (req, res) => {
  const cacheKey = `restaurant:${req.params.id}`;
  try {
    const redis = getRedis();
    const cached = await redis.get(cacheKey);
    if (cached) return res.status(200).json(JSON.parse(cached));
  } catch (_) {}

  const restaurant = await Restaurant.findOne({
    _id: req.params.id,
    isApproved: true,
    isActive: true,
  }).populate('owner', 'name email');

  if (!restaurant) return errorResponse(res, 'Restaurant not found', 404);

  const result = { success: true, message: 'Success', data: { restaurant } };

  try {
    const redis = getRedis();
    await redis.setex(cacheKey, CACHE_TTL, JSON.stringify(result));
  } catch (_) {}

  return res.status(200).json(result);
};

// @desc    Get my restaurant (owner)
// @route   GET /api/restaurants/my
const getMyRestaurant = async (req, res) => {
  const restaurant = await Restaurant.findOne({ owner: req.user._id });
  if (!restaurant) return errorResponse(res, 'You have no restaurant yet', 404);
  return successResponse(res, { restaurant });
};

// @desc    Update restaurant
// @route   PUT /api/restaurants/:id
const updateRestaurant = async (req, res) => {
  const restaurant = await Restaurant.findOne({ _id: req.params.id, owner: req.user._id });
  if (!restaurant) return errorResponse(res, 'Restaurant not found or unauthorized', 404);

  const updated = await Restaurant.findByIdAndUpdate(req.params.id, req.body, {
    new: true,
    runValidators: true,
  });

  // Invalidate cache
  try {
    const redis = getRedis();
    await redis.del(`restaurant:${req.params.id}`);
  } catch (_) {}

  return successResponse(res, { restaurant: updated }, 'Restaurant updated');
};

// @desc    Toggle restaurant open/close
// @route   PATCH /api/restaurants/:id/toggle
const toggleRestaurant = async (req, res) => {
  const restaurant = await Restaurant.findOne({ _id: req.params.id, owner: req.user._id });
  if (!restaurant) return errorResponse(res, 'Restaurant not found or unauthorized', 404);

  restaurant.isOpen = !restaurant.isOpen;
  await restaurant.save();

  return successResponse(res, { isOpen: restaurant.isOpen }, `Restaurant is now ${restaurant.isOpen ? 'open' : 'closed'}`);
};

// @desc    Admin: approve restaurant
// @route   PATCH /api/restaurants/:id/approve
const approveRestaurant = async (req, res) => {
  const restaurant = await Restaurant.findByIdAndUpdate(
    req.params.id,
    { isApproved: true },
    { new: true }
  );
  if (!restaurant) return errorResponse(res, 'Restaurant not found', 404);
  return successResponse(res, { restaurant }, 'Restaurant approved');
};

// @desc    Get nearby restaurants
// @route   GET /api/restaurants/nearby?lat=&lng=&radius=
const getNearbyRestaurants = async (req, res) => {
  const { lat, lng, radius = 5 } = req.query; // radius in km
  if (!lat || !lng) return errorResponse(res, 'Latitude and longitude required', 400);

  const restaurants = await Restaurant.find({
    isApproved: true,
    isActive: true,
    'address.coordinates': {
      $near: {
        $geometry: { type: 'Point', coordinates: [parseFloat(lng), parseFloat(lat)] },
        $maxDistance: radius * 1000,
      },
    },
  }).limit(20);

  return successResponse(res, { restaurants });
};

module.exports = {
  createRestaurant,
  getRestaurants,
  getRestaurant,
  getMyRestaurant,
  updateRestaurant,
  toggleRestaurant,
  approveRestaurant,
  getNearbyRestaurants,
};
