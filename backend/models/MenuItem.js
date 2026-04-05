const mongoose = require('mongoose');

const customizationOptionSchema = new mongoose.Schema({
  name: String,
  additionalPrice: { type: Number, default: 0 },
});

const customizationGroupSchema = new mongoose.Schema({
  groupName: { type: String, required: true },
  isRequired: { type: Boolean, default: false },
  minSelect: { type: Number, default: 0 },
  maxSelect: { type: Number, default: 1 },
  options: [customizationOptionSchema],
});

const menuItemSchema = new mongoose.Schema(
  {
    restaurant: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Restaurant',
      required: true,
    },
    category: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'MenuCategory',
      required: true,
    },
    name: {
      type: String,
      required: [true, 'Item name is required'],
      trim: true,
    },
    description: { type: String, maxlength: 300 },
    price: {
      type: Number,
      required: [true, 'Price is required'],
      min: 0,
    },
    discountedPrice: { type: Number, default: null },
    image: { type: String },
    isVeg: { type: Boolean, default: true },
    isAvailable: { type: Boolean, default: true },
    isBestSeller: { type: Boolean, default: false },
    spiceLevel: {
      type: String,
      enum: ['mild', 'medium', 'hot', 'extra_hot'],
      default: 'mild',
    },
    nutritionInfo: {
      calories: Number,
      protein: Number,
      carbs: Number,
      fat: Number,
    },
    customizations: [customizationGroupSchema],
    tags: [String],
    prepTime: { type: Number, default: 15 }, // in minutes
    sortOrder: { type: Number, default: 0 },
  },
  { timestamps: true }
);

menuItemSchema.index({ restaurant: 1, category: 1 });
menuItemSchema.index({ name: 'text', description: 'text' });

module.exports = mongoose.model('MenuItem', menuItemSchema);
