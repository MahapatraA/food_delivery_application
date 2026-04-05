const mongoose = require('mongoose');

const timingSchema = new mongoose.Schema({
  day: {
    type: String,
    enum: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  },
  open: String,   // e.g. "09:00"
  close: String,  // e.g. "22:00"
  isClosed: { type: Boolean, default: false },
});

const restaurantSchema = new mongoose.Schema(
  {
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    name: {
      type: String,
      required: [true, 'Restaurant name is required'],
      trim: true,
    },
    description: { type: String, maxlength: 500 },
    cuisines: [{ type: String }],
    address: {
      street: { type: String, required: true },
      city: { type: String, required: true },
      state: { type: String, required: true },
      pincode: { type: String, required: true },
      coordinates: {
        lat: { type: Number, required: true },
        lng: { type: Number, required: true },
      },
    },
    phone: { type: String, required: true },
    email: { type: String },
    images: [{ type: String }],
    logo: { type: String },
    rating: { type: Number, default: 0, min: 0, max: 5 },
    totalReviews: { type: Number, default: 0 },
    priceForTwo: { type: Number },
    deliveryTime: { type: Number, default: 30 }, // in minutes
    minOrderAmount: { type: Number, default: 0 },
    deliveryFee: { type: Number, default: 0 },
    isVeg: { type: Boolean, default: false },
    isPureVeg: { type: Boolean, default: false },
    timings: [timingSchema],
    isOpen: { type: Boolean, default: true },
    isActive: { type: Boolean, default: true },
    isApproved: { type: Boolean, default: false },
    tags: [{ type: String }],
    offerText: { type: String },
  },
  { timestamps: true }
);

// Index for geo queries and text search
restaurantSchema.index({ 'address.coordinates': '2dsphere' });
restaurantSchema.index({ name: 'text', cuisines: 'text' });

module.exports = mongoose.model('Restaurant', restaurantSchema);
