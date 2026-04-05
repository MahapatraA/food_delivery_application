const User = require('../models/User');
const { generateAccessToken, generateRefreshToken, verifyRefreshToken } = require('../utils/jwtHelper');
const { successResponse, errorResponse } = require('../utils/apiResponse');
const { getRedis } = require('../config/redis');

// @desc    Register user
// @route   POST /api/auth/register
const register = async (req, res) => {
  const { name, email, password, phone, role } = req.body;

  const existingUser = await User.findOne({ email });
  if (existingUser) {
    return errorResponse(res, 'Email already registered', 409);
  }

  const allowedRoles = ['user', 'restaurant_owner'];
  const userRole = allowedRoles.includes(role) ? role : 'user';

  const user = await User.create({ name, email, password, phone, role: userRole });

  const accessToken = generateAccessToken({ id: user._id, role: user.role });
  const refreshToken = generateRefreshToken({ id: user._id });

  user.refreshToken = refreshToken;
  await user.save({ validateBeforeSave: false });

  return successResponse(
    res,
    {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        phone: user.phone,
      },
      accessToken,
      refreshToken,
    },
    'Registered successfully',
    201
  );
};

// @desc    Login user
// @route   POST /api/auth/login
const login = async (req, res) => {
  const { email, password } = req.body;

  const user = await User.findOne({ email }).select('+password +refreshToken');
  if (!user || !(await user.comparePassword(password))) {
    return errorResponse(res, 'Invalid email or password', 401);
  }

  if (!user.isActive) {
    return errorResponse(res, 'Your account has been deactivated', 403);
  }

  const accessToken = generateAccessToken({ id: user._id, role: user.role });
  const refreshToken = generateRefreshToken({ id: user._id });

  user.refreshToken = refreshToken;
  await user.save({ validateBeforeSave: false });

  return successResponse(res, {
    user: {
      id: user._id,
      name: user.name,
      email: user.email,
      role: user.role,
      phone: user.phone,
      profileImage: user.profileImage,
    },
    accessToken,
    refreshToken,
  }, 'Login successful');
};

// @desc    Refresh access token
// @route   POST /api/auth/refresh-token
const refreshToken = async (req, res) => {
  const { refreshToken: token } = req.body;
  if (!token) return errorResponse(res, 'Refresh token required', 400);

  try {
    const decoded = verifyRefreshToken(token);
    const user = await User.findById(decoded.id).select('+refreshToken');

    if (!user || user.refreshToken !== token) {
      return errorResponse(res, 'Invalid refresh token', 401);
    }

    const newAccessToken = generateAccessToken({ id: user._id, role: user.role });
    const newRefreshToken = generateRefreshToken({ id: user._id });

    user.refreshToken = newRefreshToken;
    await user.save({ validateBeforeSave: false });

    return successResponse(res, {
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    }, 'Token refreshed');
  } catch {
    return errorResponse(res, 'Invalid or expired refresh token', 401);
  }
};

// @desc    Logout user
// @route   POST /api/auth/logout
const logout = async (req, res) => {
  const user = await User.findById(req.user._id);
  if (user) {
    user.refreshToken = null;
    await user.save({ validateBeforeSave: false });
  }

  // Blacklist the access token in Redis (TTL = 7 days)
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (token) {
      const redis = getRedis();
      await redis.setex(`blacklist_${token}`, 7 * 24 * 60 * 60, 'true');
    }
  } catch (_) {}

  return successResponse(res, {}, 'Logged out successfully');
};

// @desc    Get current user profile
// @route   GET /api/auth/me
const getMe = async (req, res) => {
  const user = await User.findById(req.user._id);
  return successResponse(res, { user });
};

// @desc    Update profile
// @route   PUT /api/auth/me
const updateProfile = async (req, res) => {
  const { name, phone, profileImage } = req.body;
  const user = await User.findByIdAndUpdate(
    req.user._id,
    { name, phone, profileImage },
    { new: true, runValidators: true }
  );
  return successResponse(res, { user }, 'Profile updated');
};

// @desc    Change password
// @route   PUT /api/auth/change-password
const changePassword = async (req, res) => {
  const { currentPassword, newPassword } = req.body;
  const user = await User.findById(req.user._id).select('+password');

  if (!(await user.comparePassword(currentPassword))) {
    return errorResponse(res, 'Current password is incorrect', 400);
  }

  user.password = newPassword;
  await user.save();

  return successResponse(res, {}, 'Password changed successfully');
};

// @desc    Add or update delivery address
// @route   POST /api/auth/address
const addAddress = async (req, res) => {
  const user = await User.findById(req.user._id);
  user.addresses.push(req.body);
  await user.save();
  return successResponse(res, { addresses: user.addresses }, 'Address added', 201);
};

// @desc    Delete address
// @route   DELETE /api/auth/address/:addressId
const deleteAddress = async (req, res) => {
  const user = await User.findById(req.user._id);
  user.addresses = user.addresses.filter(
    (a) => a._id.toString() !== req.params.addressId
  );
  await user.save();
  return successResponse(res, { addresses: user.addresses }, 'Address removed');
};

module.exports = {
  register,
  login,
  refreshToken,
  logout,
  getMe,
  updateProfile,
  changePassword,
  addAddress,
  deleteAddress,
};
