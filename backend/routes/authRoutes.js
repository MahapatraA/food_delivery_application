const express = require('express');
const router = express.Router();
const {
  register, login, refreshToken, logout, getMe,
  updateProfile, changePassword, addAddress, deleteAddress,
} = require('../controllers/authController');
const { protect } = require('../middleware/auth');
const { validate, registerRules, loginRules } = require('../middleware/validate');
const { authLimiter } = require('../middleware/rateLimiter');

// Public routes
router.post('/register', authLimiter, registerRules, validate, register);
router.post('/login', authLimiter, loginRules, validate, login);
router.post('/refresh-token', refreshToken);

// Protected routes
router.use(protect);
router.post('/logout', logout);
router.get('/me', getMe);
router.put('/me', updateProfile);
router.put('/change-password', changePassword);
router.post('/address', addAddress);
router.delete('/address/:addressId', deleteAddress);

module.exports = router;
