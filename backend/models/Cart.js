const mongoose = require('mongoose');

const cartItemSchema = new mongoose.Schema({
  menuItem: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'MenuItem',
    required: true,
  },
  name: String,
  price: Number,
  image: String,
  quantity: {
    type: Number,
    required: true,
    min: [1, 'Quantity must be at least 1'],
  },
  customizations: [
    {
      groupName: String,
      selectedOption: String,
      additionalPrice: Number,
    },
  ],
  itemTotal: Number,
});

const cartSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },
    restaurant: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Restaurant',
    },
    items: [cartItemSchema],
    subtotal: { type: Number, default: 0 },
    deliveryFee: { type: Number, default: 0 },
    taxes: { type: Number, default: 0 },
    total: { type: Number, default: 0 },
    couponCode: { type: String, default: null },
    discount: { type: Number, default: 0 },
  },
  { timestamps: true }
);

// Recalculate totals before saving
cartSchema.pre('save', function (next) {
  this.subtotal = this.items.reduce((sum, item) => sum + item.itemTotal, 0);
  this.taxes = Math.round(this.subtotal * 0.05); // 5% GST
  this.total = this.subtotal + this.deliveryFee + this.taxes - this.discount;
  next();
});

module.exports = mongoose.model('Cart', cartSchema);
