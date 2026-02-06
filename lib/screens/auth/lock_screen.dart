import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../dashboard/dashboard_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with SingleTickerProviderStateMixin {
  final _pinController = TextEditingController();
  String _error = '';
  bool _loading = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
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
    final pw = _pinController.text;
    if (pw.isEmpty) return;
    
    final ok = await AuthService().verifyPassword(pw);
    if (ok) {
      _unlock();
    } else {
      _shakeController.forward(from: 0);
      setState(() {
        _error = 'Wrong password';
        _pinController.clear();
      });
    }
  }

  void _unlock() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Icon(Icons.lock_rounded, size: 26, color: AppTheme.accent),
                ),
                const SizedBox(height: 28),
                Text('Welcome Back', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary, letterSpacing: -0.4)),
                const SizedBox(height: 8),
                Text('Enter your password', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                const SizedBox(height: 36),
                
                AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    final shake = _shakeController.value;
                    final offset = shake < 0.5
                        ? Offset(8 * (shake * 4 - 1), 0)
                        : Offset(8 * (1 - shake * 2), 0);
                    return Transform.translate(offset: offset, child: child);
                  },
                  child: TextField(
                    controller: _pinController,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, letterSpacing: 4),
                    decoration: InputDecoration(
                      hintText: '• • • •',
                      hintStyle: TextStyle(color: AppTheme.textSubtle, letterSpacing: 8),
                    ),
                    onSubmitted: (_) => _submitPassword(),
                  ),
                ),
                
                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_error, style: TextStyle(fontSize: 12, color: AppTheme.danger)),
                  ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submitPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: const Color(0xFF0A0A0A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: _loading
                        ? SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0A0A0A)))
                        : Text('Unlock', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextButton.icon(
                  onPressed: _tryBiometric,
                  icon: Icon(Icons.fingerprint_rounded, size: 20, color: AppTheme.accent),
                  label: Text('Use Biometrics', style: TextStyle(fontSize: 13, color: AppTheme.accent)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
