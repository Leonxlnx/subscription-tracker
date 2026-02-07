import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../dashboard/dashboard_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with TickerProviderStateMixin {
  final _passwordController = TextEditingController();
  String _error = '';
  bool _loading = false;
  bool _obscure = true;
  late AnimationController _shakeController;
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500), vsync: this);
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 700), vsync: this);
    _entranceController.forward();
    _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    final auth = AuthService();
    if (await auth.isBiometricEnabled()) {
      setState(() => _loading = true);
      final ok = await auth.authenticateWithBiometric();
      if (ok && mounted) _unlock();
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitPassword() async {
    final pw = _passwordController.text;
    if (pw.isEmpty) return;
    
    setState(() => _loading = true);
    final ok = await AuthService().verifyPassword(pw);
    setState(() => _loading = false);
    
    if (ok) {
      HapticFeedback.mediumImpact();
      _unlock();
    } else {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0);
      setState(() {
        _error = 'Incorrect password';
        _passwordController.clear();
      });
    }
  }

  void _unlock() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _shakeController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05), end: Offset.zero,
              ).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // — Icon in neumorphic circle —
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.softShadows,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                      ),
                      child: Icon(Icons.lock_outline_rounded, size: 30, color: AppTheme.accent),
                    ),
                    const SizedBox(height: 32),
                    
                    // — Title —
                    Text('Welcome back',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary, letterSpacing: -0.5)),
                    const SizedBox(height: 6),
                    Text('Enter your password to continue',
                      style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                    const SizedBox(height: 36),
                    
                    // — Password field in neumorphic card —
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.softCard(radius: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PASSWORD', style: TextStyle(fontSize: 11,
                            fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 1.2)),
                          const SizedBox(height: 12),
                          
                          AnimatedBuilder(
                            animation: _shakeController,
                            builder: (context, child) {
                              final t = _shakeController.value;
                              final dx = t < 0.25 ? 12.0 * (t * 4)
                                  : t < 0.75 ? 12.0 * (1 - (t - 0.25) * 4)
                                  : 12.0 * ((t - 0.75) * 4 - 1);
                              return Transform.translate(offset: Offset(dx, 0), child: child);
                            },
                            child: Container(
                              decoration: AppTheme.softInset(radius: 16),
                              child: TextField(
                                controller: _passwordController,
                                obscureText: _obscure,
                                style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, letterSpacing: 2),
                                decoration: InputDecoration(
                                  hintText: 'Enter password',
                                  hintStyle: TextStyle(color: AppTheme.textSubtle, letterSpacing: 0),
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                      size: 20, color: AppTheme.textMuted,
                                    ),
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                onSubmitted: (_) => _submitPassword(),
                              ),
                            ),
                          ),
                          
                          // Error
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            child: _error.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline_rounded, size: 14, color: AppTheme.danger),
                                      const SizedBox(width: 6),
                                      Text(_error, style: TextStyle(fontSize: 12, color: AppTheme.danger)),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    
                    // — Unlock button (neumorphic) —
                    GestureDetector(
                      onTap: _loading ? null : _submitPassword,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: AppTheme.softButton(radius: 18),
                        alignment: Alignment.center,
                        child: _loading
                          ? SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppTheme.background))
                          : Text('Unlock', style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700,
                              color: AppTheme.background, letterSpacing: 0.3)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // — Biometric option —
                    GestureDetector(
                      onTap: _tryBiometric,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppTheme.softShadowsLight,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fingerprint_rounded, size: 20, color: AppTheme.accent),
                            const SizedBox(width: 10),
                            Text('Use biometrics', style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.accent)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
