import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../dashboard/dashboard_screen.dart';
import '../auth/lock_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _scaleController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    
    _fadeController.forward();
    _scaleController.forward();
    
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1400));
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
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: FadeTransition(
          opacity: CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(
              CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Neumorphic logo
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      ...AppTheme.softShadows,
                      BoxShadow(color: AppTheme.accent.withValues(alpha: 0.12), blurRadius: 24, spreadRadius: -6),
                    ],
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 0.5),
                  ),
                  child: Icon(Icons.receipt_long_rounded, size: 30, color: AppTheme.accent),
                ),
                const SizedBox(height: 20),
                Text('SubTracker', style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.6)),
                const SizedBox(height: 6),
                Text('Track every penny', style: TextStyle(
                  fontSize: 13, color: AppTheme.textMuted, letterSpacing: 0.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
