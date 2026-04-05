const { body, validationResult } = require('express-validator');
const { errorResponse } = require('../utils/apiResponse');

// Middleware to handle validation errors
const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return errorResponse(res, 'Validation failed', 400, errors.array());
  }
  next();
};

// Auth validation rules
const registerRules = [
  body('name').trim().notEmpty().withMessage('Name is required'),
  body('email').isEmail().normalizeEmail().withMessage('Valid email is required'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters'),
];

const loginRules = [
  body('email').isEmail().normalizeEmail().withMessage('Valid email is required'),
  body('password').notEmpty().withMessage('Password is required'),
];

// Restaurant validation rules
const restaurantRules = [
  body('name').trim().notEmpty().withMessage('Restaurant name is required'),
  body('phone').notEmpty().withMessage('Phone is required'),
  body('address.street').notEmpty().withMessage('Street is required'),
  body('address.city').notEmpty().withMessage('City is required'),
  body('address.state').notEmpty().withMessage('State is required'),
  body('address.pincode').notEmpty().withMessage('Pincode is required'),
  body('address.coordinates.lat').isFloat().withMessage('Valid latitude is required'),
  body('address.coordinates.lng').isFloat().withMessage('Valid longitude is required'),
];

// Menu item validation rules
const menuItemRules = [
  body('name').trim().notEmpty().withMessage('Item name is required'),
  body('price').isFloat({ min: 0 }).withMessage('Valid price is required'),
  body('category').isMongoId().withMessage('Valid category ID is required'),
];

module.exports = {
  validate,
  registerRules,
  loginRules,
  restaurantRules,
  menuItemRules,
};
