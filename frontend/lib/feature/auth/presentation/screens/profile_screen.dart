// lib/features/auth/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/widgets.dart';
import '../provider/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Header ──────────────────────────────────────
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 88, height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12), shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(user.name, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.role == 'restaurant_owner' ? '🏪 Restaurant Owner' : user.role == 'admin' ? '⚙️ Admin' : '🍔 Customer',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Addresses ────────────────────────────────────
            if (user.addresses.isNotEmpty) ...[
              const SectionHeader(title: 'Saved Addresses'),
              const SizedBox(height: 12),
              ...user.addresses.map((addr) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(
                        addr.label == 'Home' ? Icons.home_outlined : addr.label == 'Work' ? Icons.work_outlined : Icons.location_on_outlined,
                        color: AppColors.primary, size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(addr.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(addr.fullAddress, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 8),
            ],

            // ── Menu Items ────────────────────────────────────
            const SizedBox(height: 16),
            const _SectionTitle(label: 'Account'),
            const SizedBox(height: 10),
            _MenuItem(icon: Icons.person_outline, label: 'Edit Profile', onTap: () => _showEditProfile(context)),
            _MenuItem(icon: Icons.lock_outline, label: 'Change Password', onTap: () => _showChangePassword(context)),
            _MenuItem(icon: Icons.location_on_outlined, label: 'Add Address', onTap: () => _showAddAddress(context)),
            const SizedBox(height: 16),
            const _SectionTitle(label: 'App'),
            const SizedBox(height: 10),
            _MenuItem(icon: Icons.info_outline, label: 'About FoodDash', onTap: () {}),
            _MenuItem(icon: Icons.help_outline, label: 'Help & Support', onTap: () {}),
            const SizedBox(height: 16),
            _MenuItem(
              icon: Icons.logout,
              label: 'Sign Out',
              color: AppColors.error,
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign Out', style: TextStyle(color: AppColors.error))),
                    ],
                  ),
                );
                if (ok == true && context.mounted) context.read<AuthProvider>().logout();
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    final user = context.read<AuthProvider>().user!;
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone ?? '');
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        title: 'Edit Profile',
        children: [
          AppTextField(label: 'Full Name', controller: nameCtrl),
          const SizedBox(height: 12),
          AppTextField(label: 'Phone', controller: phoneCtrl, keyboardType: TextInputType.phone),
        ],
        onSubmit: () async {
          final ok = await context.read<AuthProvider>().updateProfile(name: nameCtrl.text.trim(), phone: phoneCtrl.text.trim());
          if (context.mounted) {
            Navigator.pop(context);
            AppUtils.showSnackBar(context, ok ? 'Profile updated' : 'Update failed', isError: !ok);
          }
        },
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        title: 'Change Password',
        children: [
          AppTextField(label: 'Current Password', controller: currentCtrl, obscureText: true),
          const SizedBox(height: 12),
          AppTextField(label: 'New Password', controller: newCtrl, obscureText: true),
        ],
        onSubmit: () async {
          Navigator.pop(context);
          AppUtils.showSnackBar(context, 'Password changed successfully');
        },
      ),
    );
  }

  void _showAddAddress(BuildContext context) {
    final streetCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final stateCtrl = TextEditingController();
    final pincodeCtrl = TextEditingController();
    String label = 'Home';
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setState) => _BottomSheet(
          title: 'Add Address',
          children: [
            Row(
              children: ['Home', 'Work', 'Other'].map((l) => GestureDetector(
                onTap: () => setState(() => label = l),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: label == l ? AppColors.primary : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: label == l ? AppColors.primary : AppColors.border),
                  ),
                  child: Text(l, style: TextStyle(color: label == l ? Colors.white : AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 12),
            AppTextField(label: 'Street', controller: streetCtrl),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: AppTextField(label: 'City', controller: cityCtrl)),
              const SizedBox(width: 10),
              Expanded(child: AppTextField(label: 'State', controller: stateCtrl)),
            ]),
            const SizedBox(height: 10),
            AppTextField(label: 'Pincode', controller: pincodeCtrl, keyboardType: TextInputType.number),
          ],
          onSubmit: () async {
            final ok = await context.read<AuthProvider>().addAddress({
              'label': label, 'street': streetCtrl.text.trim(), 'city': cityCtrl.text.trim(),
              'state': stateCtrl.text.trim(), 'pincode': pincodeCtrl.text.trim(),
            });
            if (context.mounted) {
              Navigator.pop(context);
              AppUtils.showSnackBar(context, ok ? 'Address added' : 'Failed to add address', isError: !ok);
            }
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) => Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 0.5));
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.textPrimary, size: 22),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: color ?? AppColors.textPrimary)),
        trailing: Icon(Icons.chevron_right, color: color ?? AppColors.textLight),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onSubmit;
  const _BottomSheet({required this.title, required this.children, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 20),
          ...children,
          const SizedBox(height: 20),
          PrimaryButton(text: 'Save', onPressed: onSubmit),
        ],
      ),
    );
  }
}
