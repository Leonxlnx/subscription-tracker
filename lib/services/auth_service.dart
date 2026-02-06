import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class AuthService {
  static const String _passwordHashKey = 'password_hash';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _autoLockMinutesKey = 'auto_lock_minutes';
  static const String _lastActiveKey = 'last_active_time';
  
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  // === PASSWORD ===
  
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }
  
  Future<bool> hasPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordHashKey) != null;
  }
  
  Future<void> setPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordHashKey, _hashPassword(password));
  }
  
  Future<bool> verifyPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_passwordHashKey);
    if (stored == null) return false;
    return stored == _hashPassword(password);
  }
  
  Future<void> removePassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_passwordHashKey);
  }
  
  // === BIOMETRIC ===
  
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } on PlatformException {
      return false;
    }
  }
  
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }
  
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }
  
  Future<bool> authenticateWithBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Unlock Subscriptions',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
  
  // === AUTO-LOCK ===
  
  Future<int> getAutoLockMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_autoLockMinutesKey) ?? 5;
  }
  
  Future<void> setAutoLockMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_autoLockMinutesKey, minutes);
  }
  
  Future<void> updateLastActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastActiveKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  Future<bool> shouldLock() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActive = prefs.getInt(_lastActiveKey);
    if (lastActive == null) return true;
    
    final minutes = await getAutoLockMinutes();
    final elapsed = DateTime.now().millisecondsSinceEpoch - lastActive;
    return elapsed > (minutes * 60 * 1000);
  }
}
