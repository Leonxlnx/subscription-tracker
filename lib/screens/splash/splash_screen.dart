import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../services/storage_service.dart';
import '../dashboard/dashboard_screen.dart';
import '../auth/lock_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400), vsync: this);
    _fadeController.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    
    // Reschedule all notifications on app start
    try {
      final subs = await StorageService().getSubscriptions();
      await NotificationService().rescheduleAllReminders(subs);
    } catch (_) {}
    
    if (!mounted) return;
    final auth = AuthService();
    final needsAuth = await auth.hasPassword() || await auth.isBiometricEnabled();
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            needsAuth ? const LockScreen() : const DashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: FadeTransition(
          opacity: CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.softShadows,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 0.5),
                ),
                child: const Icon(Icons.receipt_long_rounded, size: 28, color: AppTheme.accent),
              ),
              const SizedBox(height: 18),
              const Text('SubTracker', style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
