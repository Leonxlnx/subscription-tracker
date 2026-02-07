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
  String _pin = '';
  String _error = '';
  late AnimationController _shakeController;
  late AnimationController _entranceController;

  static const int _pinLength = 6;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500), vsync: this);
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 600), vsync: this);
    _entranceController.forward();
    _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    final auth = AuthService();
    if (await auth.isBiometricEnabled()) {

      final ok = await auth.authenticateWithBiometric();
      if (ok && mounted) _unlock();

    }
  }

  void _addDigit(String digit) {
    if (_pin.length >= _pinLength) return;
    HapticFeedback.lightImpact();
    setState(() {
      _pin += digit;
      _error = '';
    });
    if (_pin.length == _pinLength) {
      _submitPin();
    }
  }

  void _removeDigit() {
    if (_pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = '';
    });
  }

  Future<void> _submitPin() async {

    final ok = await AuthService().verifyPassword(_pin);

    
    if (ok) {
      HapticFeedback.mediumImpact();
      _unlock();
    } else {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0);
      setState(() {
        _error = 'Wrong PIN';
        _pin = '';
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
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03), end: Offset.zero,
            ).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic)),
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // — Lock icon —
                Container(
                  width: 72, height: 72,
                  decoration: AppTheme.softCircle(),
                  child: const Icon(Icons.lock_outline_rounded, size: 28, color: AppTheme.accent),
                ),
                const SizedBox(height: 28),
                
                // — Title —
                const Text('Enter PIN',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary, letterSpacing: -0.3)),
                const SizedBox(height: 8),
                Text(_error.isNotEmpty ? _error : 'Enter your 6-digit PIN',
                  style: TextStyle(fontSize: 13, 
                    color: _error.isNotEmpty ? AppTheme.danger : AppTheme.textMuted)),
                const SizedBox(height: 32),
                
                // — PIN dots —
                AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    final t = _shakeController.value;
                    final dx = t < 0.25 ? 12.0 * (t * 4)
                        : t < 0.75 ? 12.0 * (1 - (t - 0.25) * 4)
                        : 12.0 * ((t - 0.75) * 4 - 1);
                    return Transform.translate(offset: Offset(dx, 0), child: child);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pinLength, (i) {
                      final filled = i < _pin.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        width: filled ? 14 : 12,
                        height: filled ? 14 : 12,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _error.isNotEmpty 
                              ? AppTheme.danger.withValues(alpha: 0.7) 
                              : filled 
                                  ? AppTheme.accent 
                                  : Colors.transparent,
                          border: Border.all(
                            color: _error.isNotEmpty
                                ? AppTheme.danger.withValues(alpha: 0.5)
                                : filled 
                                    ? AppTheme.accent 
                                    : AppTheme.textMuted.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                
                const Spacer(flex: 1),
                
                // — Number pad —
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    children: [
                      _buildPadRow(['1', '2', '3']),
                      const SizedBox(height: 16),
                      _buildPadRow(['4', '5', '6']),
                      const SizedBox(height: 16),
                      _buildPadRow(['7', '8', '9']),
                      const SizedBox(height: 16),
                      _buildPadRow(['bio', '0', 'del']),
                    ],
                  ),
                ),
                
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => _buildPadKey(key)).toList(),
    );
  }

  Widget _buildPadKey(String key) {
    final isDigit = key.length == 1 && int.tryParse(key) != null;
    final isBio = key == 'bio';
    final isDel = key == 'del';

    return GestureDetector(
      onTap: () {
        if (isDigit) {
          _addDigit(key);
        } else if (isDel) {
          _removeDigit();
        } else if (isBio) {
          _tryBiometric();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: isDigit ? AppTheme.surface : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isDigit ? AppTheme.softShadowsLight : [],
          border: Border.all(
            color: isDigit 
                ? Colors.white.withValues(alpha: 0.04) 
                : Colors.transparent,
            width: 0.5,
          ),
        ),
        alignment: Alignment.center,
        child: isBio
            ? Icon(Icons.fingerprint_rounded, size: 26, color: AppTheme.textMuted)
            : isDel
                ? Icon(Icons.backspace_outlined, size: 22, color: AppTheme.textMuted)
                : Text(key, style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w500, 
                    color: AppTheme.textPrimary)),
      ),
    );
  }
}
