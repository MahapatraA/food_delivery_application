# 🍔 Food Delivery Application

A full-stack food delivery application built with **Flutter** and **Node.js**, backed by **MongoDB** and **Redis**. The application provides authentication, restaurant discovery, menu browsing, cart management, order placement, online payments, and real-time order tracking.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-green?logo=dart)
![Node.js](https://img.shields.io/badge/Node.js-Express-green?logo=node.js)
![MongoDB](https://img.shields.io/badge/MongoDB-Mongoose-green?logo=mongodb)
![Redis](https://img.shields.io/badge/Redis-Ioredis-red?logo=redis)
![Socket.IO](https://img.shields.io/badge/Socket.IO-Real--Time-black?logo=socket.io)
![Razorpay](https://img.shields.io/badge/Payments-Razorpay-blue)

---

## 📋 Table of Contents

* [Overview](#-overview)
* [Features](#-features)
* [Tech Stack](#-tech-stack)
* [Application Architecture](#-application-architecture)
* [Prerequisites](#-prerequisites)
* [Installation](#-installation)
* [Project Structure](#-project-structure)
* [Configuration](#-configuration)
* [API Endpoints](#-api-endpoints)
* [Authentication](#-authentication)
* [Cart & Ordering Flow](#-cart--ordering-flow)
* [Payment Flow](#-payment-flow)
* [Real-Time Order Tracking](#-real-time-order-tracking)
* [Running the Application](#-running-the-application)
* [Troubleshooting](#-troubleshooting)
* [Security](#-security)
* [Contributing](#-contributing)
* [License](#-license)
* [Future Improvements](#-future-improvements)

---

## 📱 Overview

The Food Delivery Application is a full-stack food ordering platform designed to demonstrate a complete client-server architecture.

The application combines a **Flutter frontend** with a **Node.js/Express backend**, while MongoDB is used for persistent application data and Redis is used for supporting backend operations.

The backend is organized around dedicated modules for:

* User authentication
* Restaurant management
* Menu management
* Shopping cart management
* Order processing
* Payment processing
* Validation and error handling
* Logging
* Real-time order tracking

The backend exposes REST APIs under `/api`, while Socket.IO provides real-time communication for order-related updates.

### Key Highlights

* 🔐 JWT-based authentication
* 👤 User account management
* 🍽️ Restaurant browsing
* 📖 Menu and menu-item management
* 🛒 Shopping cart management
* 📦 Order creation and management
* 💳 Razorpay payment integration
* 🔄 Redis integration
* ⚡ Socket.IO real-time communication
* 🧾 Centralized API responses
* ✅ Request validation
* 🚦 Rate limiting
* 🪵 Application logging
* 🛡️ Centralized error handling
* 📱 Flutter mobile frontend

---

## ✨ Features

### 🔐 Authentication

* ✅ User registration
* ✅ User login
* ✅ Password hashing with bcrypt
* ✅ JWT-based authentication
* ✅ Protected API routes
* ✅ Token-based session handling

### 👤 User Management

* ✅ User profile handling
* ✅ Authenticated user operations
* ✅ Secure password storage
* ✅ JWT-protected resources

### 🍽️ Restaurant Discovery

* ✅ Browse restaurants
* ✅ Restaurant-related API operations
* ✅ Restaurant data management
* ✅ Restaurant-specific menu access

### 🍔 Menu Management

* ✅ Browse menu items
* ✅ Restaurant-specific menus
* ✅ Menu-item management APIs
* ✅ Menu item data persistence

### 🛒 Shopping Cart

* ✅ Add items to cart
* ✅ Update cart contents
* ✅ Remove items
* ✅ Cart persistence
* ✅ Cart-specific backend APIs

### 📦 Order Management

* ✅ Create orders
* ✅ Retrieve orders
* ✅ Manage order data
* ✅ Track order-related information
* ✅ Restaurant/order relationship handling

### 💳 Payments

* ✅ Razorpay integration
* ✅ Payment-related backend APIs
* ✅ Payment processing support
* ✅ Order/payment workflow integration

### ⚡ Real-Time Features

* ✅ Socket.IO integration
* ✅ Real-time order tracking support
* ✅ Order-specific Socket.IO rooms
* ✅ Restaurant-specific Socket.IO rooms
* ✅ Connection/disconnection logging

The backend explicitly creates Socket.IO rooms for orders and restaurants, enabling real-time communication around order tracking.

### 🛡️ Backend Infrastructure

* ✅ Express async error handling
* ✅ Request validation
* ✅ Global error handling
* ✅ API response utility
* ✅ Rate limiting
* ✅ HTTP request logging
* ✅ Application logging
* ✅ Redis integration
* ✅ Environment-based configuration

---

## 🛠️ Tech Stack

### Frontend

* **Framework:** Flutter
* **Language:** Dart
* **State Management:** Provider
* **HTTP:** `http`
* **API Client:** Dio
* **Storage:** SharedPreferences
* **Secure Storage:** Flutter Secure Storage
* **Payments:** Razorpay Flutter
* **Networking:** Socket.IO Client
* **UI:** Flutter Material/Cupertino
* **Typography:** Google Fonts
* **Images:** Cached Network Image
* **SVG:** flutter_svg
* **Animations:** Lottie
* **Loading UI:** Shimmer
* **Badges:** badges

The current `pubspec.yaml` includes Provider, HTTP/Dio, SharedPreferences, Flutter Secure Storage, Razorpay, Google Fonts, cached images, SVG, shimmer, Lottie, badges, intl, UUID, and Socket.IO client packages.

### Backend

* **Runtime:** Node.js
* **Framework:** Express.js
* **Database:** MongoDB
* **ODM:** Mongoose
* **Cache/Supporting Store:** Redis
* **Authentication:** JWT
* **Password Hashing:** bcryptjs
* **Payments:** Razorpay
* **Real-Time Communication:** Socket.IO
* **Validation:** express-validator
* **Rate Limiting:** express-rate-limit
* **Logging:** Winston
* **HTTP Logging:** Morgan
* **File Uploads:** Multer
* **IDs:** UUID

The backend dependency configuration confirms MongoDB/Mongoose, Redis, JWT, Razorpay, Socket.IO, validation, rate limiting, logging, and upload-related packages.

---

## 🏗️ Application Architecture

The application follows a client-server architecture:

```text
                         ┌─────────────────────────┐
                         │     Flutter Frontend    │
                         │                         │
                         │  Screens / UI           │
                         │       ↓                 │
                         │  Providers              │
                         │       ↓                 │
                         │  Services / API Client  │
                         └────────────┬────────────┘
                                      │
                              HTTP / REST API
                                      │
                                      ▼
                         ┌─────────────────────────┐
                         │    Node.js + Express    │
                         │                         │
                         │     Routes              │
                         │       ↓                 │
                         │    Controllers          │
                         │       ↓                 │
                         │    Validation           │
                         │       ↓                 │
                         │      Models             │
                         └───────┬───────┬─────────┘
                                 │       │
                      ┌──────────┘       └───────────┐
                      ▼                              ▼
              ┌──────────────┐              ┌──────────────┐
              │   MongoDB    │              │    Redis     │
              │              │              │              │
              │ Users        │              │ Cache /      │
              │ Restaurants  │              │ supporting   │
              │ Menu Items   │              │ operations   │
              │ Carts        │              │              │
              │ Orders       │              └──────────────┘
              └──────────────┘

                         ┌─────────────────────────┐
                         │       Socket.IO         │
                         │                         │
                         │ Real-time order updates │
                         └─────────────────────────┘
```

The Express server creates an HTTP server, attaches Socket.IO, connects MongoDB and Redis, mounts the API routes, and registers a global error handler.

---

## 📦 Prerequisites

Before running the project, install the following.

### Required Software

1. **Node.js**

   * Required for the backend.

2. **npm**

   * Included with Node.js.

3. **MongoDB**

   * Local MongoDB installation or MongoDB Atlas.

4. **Redis**

   * Required by the backend Redis integration.

5. **Flutter SDK**

   * Required for the mobile application.

6. **Dart**

   * Included with Flutter.

7. **Git**

   * Recommended for source control.

### Optional Development Tools

* Android Studio
* VS Code
* Android Emulator
* Physical Android device

### Verify Installation

```bash
node --version
npm --version
flutter --version
dart --version
git --version
```

For Flutter:

```bash
flutter doctor
```

---

## 🚀 Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/MahapatraA/food_delivery_application.git
cd food_delivery_application
```

---

### Step 2: Backend Setup

Navigate to the backend:

```bash
cd backend
```

Install dependencies:

```bash
npm install
```

The backend currently provides both production and development scripts:

```bash
npm start
npm run dev
```

The project uses `node server.js` for the production start command and `nodemon server.js` for development.

---

### Step 3: Configure Environment Variables

Create a backend environment configuration file based on the variables used by the application.

Example:

```env
NODE_ENV=development
PORT=5000

MONGO_URI=your_mongodb_connection_string

REDIS_URL=your_redis_connection_string

JWT_SECRET=your_jwt_secret

CLIENT_URL=http://localhost:3000

RAZORPAY_KEY_ID=your_razorpay_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret
```

> Use the exact environment variable names expected by the files in the repository. Do not commit credentials or production secrets.

---

### Step 4: Start the Backend

Development:

```bash
npm run dev
```

Production-style start:

```bash
npm start
```

The backend defaults to port:

```text
5000
```

The server also exposes:

```text
GET /health
```

for a basic health check.

---

### Step 5: Flutter Setup

Open another terminal:

```bash
cd frontend
```

Install dependencies:

```bash
flutter pub get
```

Check available devices:

```bash
flutter devices
```

Run the application:

```bash
flutter run
```

---

## 📁 Project Structure

```text
food_delivery_application/
│
├── backend/
│   │
│   ├── controller/
│   │   ├── authController.js
│   │   ├── cartController.js
│   │   ├── menuController.js
│   │   ├── orderController.js
│   │   ├── paymentController.js
│   │   └── restaurantController.js
│   │
│   ├── models/
│   │   ├── User.js
│   │   ├── Restaurant.js
│   │   ├── MenuItem.js
│   │   ├── Cart.js
│   │   └── Order.js
│   │
│   ├── routes/
│   │   ├── authRoutes.js
│   │   ├── restaurantRoutes.js
│   │   ├── menuRoutes.js
│   │   ├── cartRoutes.js
│   │   ├── orderRoutes.js
│   │   └── paymentRoutes.js
│   │
│   ├── apiResponse.js
│   ├── auth.js
│   ├── db.js
│   ├── errorHandler.js
│   ├── jwtHelper.js
│   ├── logger.js
│   ├── redis.js
│   ├── validate.js
│   ├── server.js
│   └── package.json
│
├── frontend/
│   │
│   ├── lib/
│   │   └── ...
│   │
│   ├── assets/
│   │   ├── images/
│   │   └── animations/
│   │
│   ├── android/
│   ├── ios/
│   ├── linux/
│   ├── macos/
│   ├── web/
│   ├── windows/
│   │
│   ├── pubspec.yaml
│   └── analysis_options.yaml
│
└── README.md
```

The backend repository currently separates controllers, models and route modules for authentication, restaurants, menus, carts, orders and payments.

### Backend Controllers

| Controller                | Responsibility                             |
| ------------------------- | ------------------------------------------ |
| `authController.js`       | Authentication and user-related operations |
| `restaurantController.js` | Restaurant operations                      |
| `menuController.js`       | Menu/menu-item operations                  |
| `cartController.js`       | Shopping cart operations                   |
| `orderController.js`      | Order processing and management            |
| `paymentController.js`    | Payment-related operations                 |

### Backend Models

| Model           | Purpose                                  |
| --------------- | ---------------------------------------- |
| `User.js`       | User information and authentication data |
| `Restaurant.js` | Restaurant information                   |
| `MenuItem.js`   | Food/menu item information               |
| `Cart.js`       | User cart data                           |
| `Order.js`      | Order and order-related data             |

### Backend Routes

| Route              | Purpose         |
| ------------------ | --------------- |
| `/api/auth`        | Authentication  |
| `/api/restaurants` | Restaurant APIs |
| `/api/menu`        | Menu APIs       |
| `/api/cart`        | Cart APIs       |
| `/api/orders`      | Order APIs      |
| `/api/payment`     | Payment APIs    |

These route groups are mounted directly by the Express server.

---

## ⚙️ Configuration

### Backend

The server uses environment variables through `dotenv`.

Core configuration areas include:

```text
MongoDB
Redis
JWT
Razorpay
Client URL
Server Port
Node Environment
```

The repository also includes dedicated modules for database connectivity, Redis, JWT support, logging, validation and error handling.

---

### Flutter Configuration

The Flutter application requires the backend URL to be configured in the appropriate frontend service/configuration layer.

Typical development URLs are:

```text
Android Emulator:
http://10.0.2.2:5000

Physical Android Device:
http://<YOUR-PC-IP>:5000
```

For a physical device, make sure the phone and development machine are connected to the same local network.

---

## 🔌 API Endpoints

Base API URL:

```text
http://localhost:5000/api
```

### 🔐 Authentication

```text
POST /api/auth/...
```

Authentication-related operations are handled through `authRoutes.js` and `authController.js`.

### 🍽️ Restaurants

```text
/api/restaurants
```

Used for restaurant-related operations.

### 🍔 Menu

```text
/api/menu
```

Used for menu and food-item operations.

### 🛒 Cart

```text
/api/cart
```

Used for shopping-cart operations.

### 📦 Orders

```text
/api/orders
```

Used for creating and managing orders.

### 💳 Payments

```text
/api/payment
```

Used for payment-related operations and Razorpay integration.

### ❤️ Health Check

```http
GET /health
```

Example response:

```json
{
  "status": "OK",
  "timestamp": "2026-09-02T00:00:00.000Z"
}
```

The backend defines the health endpoint directly in `server.js`.

> The exact request/response payloads should be documented from the individual route/controller implementations rather than guessed.

---

## 🔑 Authentication

Authentication is based on **JWT tokens**.

### Authentication Flow

```text
User
 │
 │ Register / Login
 ▼
Flutter Application
 │
 │ HTTP Request
 ▼
Express API
 │
 │ Validate credentials
 ▼
MongoDB
 │
 │ User verified
 ▼
JWT Token
 │
 ▼
Flutter Application
 │
 │ Store token securely
 ▼
Authenticated API Requests
 │
 │ Authorization Header
 ▼
JWT Middleware
 │
 ▼
Protected Controller
```

JWT-related functionality is separated into dedicated authentication/JWT helpers in the backend.

---

## 🛒 Cart & Ordering Flow

The core ordering workflow can be represented as:

```text
Browse Restaurants
        │
        ▼
Select Restaurant
        │
        ▼
Browse Menu
        │
        ▼
Select Food Items
        │
        ▼
Add Items to Cart
        │
        ▼
Review Cart
        │
        ▼
Create Order
        │
        ▼
Payment
        │
        ▼
Order Created
        │
        ▼
Track Order
```

The project separates cart and order responsibilities into independent controllers, models and route modules.

---

## 💳 Payment Flow

The backend integrates **Razorpay** for payment processing.

```text
User
 │
 │ Checkout
 ▼
Flutter App
 │
 │ Payment Request
 ▼
Backend
 │
 │ Razorpay Integration
 ▼
Razorpay
 │
 │ Payment Result
 ▼
Backend
 │
 ▼
Order / Payment Processing
```

The project includes both a dedicated payment controller and payment routes, and the backend declares the Razorpay package as a dependency.

---

## ⚡ Real-Time Order Tracking

The backend uses **Socket.IO** for real-time communication.

The Socket.IO server supports:

```text
join_order_room
join_restaurant_room
disconnect
```

Clients can join an order-specific room:

```text
order_<orderId>
```

or a restaurant-specific room:

```text
restaurant_<restaurantId>
```

This architecture allows order-related updates to be delivered to connected clients without requiring constant polling.

### Real-Time Flow

```text
Order Event
    │
    ▼
Backend Controller
    │
    ▼
Socket.IO
    │
    ├── order_<orderId>
    │
    └── restaurant_<restaurantId>
            │
            ▼
       Connected Clients
```

---

## 🧰 Backend Infrastructure

### Validation

The project includes `express-validator` and a dedicated validation module for request validation.

### Rate Limiting

API requests are protected with rate-limiting middleware to help control excessive requests.

### Logging

The backend uses:

* Morgan for HTTP request logging
* Winston for application logging

### Error Handling

The application uses:

* `express-async-errors`
* A centralized error handler
* API response utilities

This provides a consistent backend error-handling layer.

---

## ▶️ Running the Application

### Start MongoDB

Ensure your MongoDB instance is running.

### Start Redis

Ensure Redis is available using the connection details configured in your environment.

### Start Backend

```bash
cd backend
npm install
npm run dev
```

### Start Frontend

In a second terminal:

```bash
cd frontend
flutter pub get
flutter run
```

### Check Backend

Open:

```text
http://localhost:5000/health
```

Expected response format:

```json
{
  "status": "OK",
  "timestamp": "..."
}
```

---

## 🧪 Development Commands

### Backend

```bash
npm install
npm run dev
npm start
```

### Flutter

```bash
flutter pub get
flutter run
flutter clean
flutter analyze
```

---

## 🐛 Troubleshooting

### "MongoDB connection failed"

Check:

* MongoDB is running.
* The MongoDB URI is correct.
* Your environment variables are loaded.
* MongoDB Atlas network access is configured when applicable.

---

### "Redis connection failed"

Check:

* Redis is running.
* Redis connection details are correct.
* The backend environment configuration is loaded.

---

### "Flutter cannot connect to backend"

For Android Emulator:

```text
http://10.0.2.2:5000
```

For physical device:

```text
http://<YOUR-PC-IP>:5000
```

Also ensure:

* Both devices are on the same network.
* The backend is running.
* Firewall rules allow the connection.

---

### "JWT authentication failed"

Check:

* JWT secret configuration.
* Token validity.
* Authorization header format.

Example:

```http
Authorization: Bearer <JWT_TOKEN>
```

---

### "Razorpay payment is not working"

Check:

* Razorpay credentials.
* Backend environment variables.
* Network connection.
* Payment configuration in the Flutter application.
* Backend payment routes/controllers.

---

### "Socket.IO connection fails"

Check:

* Backend server is running.
* Socket endpoint is correct.
* Client and server Socket.IO versions are compatible.
* CORS configuration allows the client origin.

The backend currently configures Socket.IO CORS using `CLIENT_URL`, falling back to `*` when it is not configured.

---

## 🔐 Security

The application includes several security-related mechanisms:

* 🔒 bcrypt password hashing
* 🔑 JWT authentication
* 🚦 Rate limiting
* ✅ Request validation
* 🌐 CORS configuration
* 🛡️ Centralized error handling
* 🔐 Environment-based secret configuration

### Important

This project should be treated as a learning/full-stack application rather than a production food-delivery platform unless the necessary security, payment, infrastructure, privacy and operational controls have been independently validated.

Never commit:

```text
.env
API keys
JWT secrets
Razorpay secrets
Database credentials
Redis credentials
```

---

## 🤝 Contributing

Contributions and improvements are welcome.

### 1. Fork the Repository

```bash
git clone https://github.com/MahapatraA/food_delivery_application.git
cd food_delivery_application
```

### 2. Create a Feature Branch

```bash
git checkout -b feature/your-feature
```

### 3. Make Changes

Follow the existing project structure and coding style.

### 4. Test

Backend:

```bash
cd backend
npm run dev
```

Frontend:

```bash
cd frontend
flutter run
```

### 5. Commit

```bash
git add .
git commit -m "feat: add your feature"
```

### 6. Push

```bash
git push origin feature/your-feature
```

### 7. Open a Pull Request

Clearly describe:

* What changed
* Why it changed
* How it was tested

---

## 📄 License

This repository currently does not provide a dedicated license file.

Before distributing the project as open-source software, add an appropriate `LICENSE` file.

---

## 🚧 Future Improvements

Potential enhancements include:

* ⭐ Restaurant ratings and reviews
* 🔎 Advanced restaurant/menu search
* 🏷️ Coupons and discount management
* 📍 Delivery-address management
* 🗺️ Map-based delivery tracking
* 🔔 Push notifications
* 📦 More detailed order-status workflow
* 🧑‍🍳 Restaurant/admin dashboard
* 👨‍💼 Restaurant management portal
* 📊 Analytics dashboard
* 💳 Expanded payment verification
* 🧪 Automated backend tests
* 🧪 Flutter unit/widget/integration tests
* 🐳 Docker support
* ☁️ Cloud deployment
* 📚 Swagger/OpenAPI documentation
* 🔐 Stronger production security controls
* ⚡ Expanded Redis caching
* 📈 Performance monitoring

---

## 📊 Project Summary

### Frontend

```text
Framework       : Flutter
Language        : Dart
State Management: Provider
HTTP            : HTTP + Dio
Storage         : SharedPreferences
Secure Storage  : Flutter Secure Storage
Payments        : Razorpay Flutter
Realtime        : Socket.IO
```

### Backend

```text
Runtime         : Node.js
Framework       : Express.js
Database        : MongoDB
ODM             : Mongoose
Cache/Store     : Redis
Authentication  : JWT
Password Hashing: bcryptjs
Payments        : Razorpay
Realtime        : Socket.IO
Validation      : express-validator
Rate Limiting   : express-rate-limit
Logging         : Morgan + Winston
```

The dependency configuration supports this overall stack.

---

## 🎓 Learning Objectives

This project demonstrates practical implementation of:

* Full-stack application development
* Flutter frontend development
* REST API development
* MongoDB and Mongoose
* Redis integration
* JWT authentication
* Password hashing
* Request validation
* Rate limiting
* Shopping cart architecture
* Order management
* Payment gateway integration
* Real-time communication using Socket.IO
* Controller/model/route separation
* Error handling
* Application logging
* Client-server architecture

---

## ⭐ If You Like This Project

If you found this project useful or interesting, consider giving the repository a ⭐ on GitHub.

---

## 👨‍💻 Author

**MahapatraA**

GitHub:

https://github.com/MahapatraA

---

## 📝 Project Status

**Version:** 1.0.0
**Status:** 🚧 Development / Learning Project

---

**Made with ❤️ using Flutter, Node.js, MongoDB, Redis and Socket.IO**

**Happy Ordering! 🍔📦**
