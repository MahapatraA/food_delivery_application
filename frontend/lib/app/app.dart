// lib/app/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_theme.dart';
import '../features/auth/presentation/provider/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/restaurant/presentation/provider/restaurant_provider.dart';
import '../features/menu/presentation/provider/menu_provider.dart';
import '../features/cart/presentation/provider/cart_provider.dart';
import '../features/order/presentation/provider/order_provider.dart';
import '../features/payment/presentation/provider/payment_provider.dart';
import 'app_shell.dart';
import 'splash_screen.dart';

class FoodDeliveryApp extends StatelessWidget {
  const FoodDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: MaterialApp(
        title: 'FoodDash',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await context.read<AuthProvider>().initialize();
    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const SplashScreen();

    final status = context.watch<AuthProvider>().status;

    if (status == AuthStatus.authenticated) return const AppShell();
    return const LoginScreen();
  }
}
