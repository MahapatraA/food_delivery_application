// lib/core/constants/api_constants.dart

class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:5000/api'; // iOS simulator
  // static const String baseUrl = 'http://YOUR_IP:5000/api'; // Physical device

  static const String socketUrl = 'http://10.0.2.2:5000';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String updateProfile = '/auth/me';
  static const String changePassword = '/auth/change-password';
  static const String addAddress = '/auth/address';

  // Restaurants
  static const String restaurants = '/restaurants';
  static const String nearbyRestaurants = '/restaurants/nearby';
  static const String myRestaurant = '/restaurants/my';

  // Menu
  static const String menu = '/menu';
  static const String menuItems = '/menu/items';
  static const String menuCategories = '/menu/categories';

  // Cart
  static const String cart = '/cart';
  static const String cartAdd = '/cart/add';
  static const String cartCoupon = '/cart/coupon';

  // Orders
  static const String orders = '/orders';
  static const String myOrders = '/orders/my';

  // Payment
  static const String paymentCreateOrder = '/payment/create-order';
  static const String paymentVerify = '/payment/verify';
  static const String paymentWebhook = '/payment/webhook';

  // Razorpay
  static const String razorpayKeyId = 'YOUR_RAZORPAY_KEY_ID'; // replace
}
