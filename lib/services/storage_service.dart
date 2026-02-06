import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription.dart';

class StorageService {
  static const String _subscriptionsKey = 'subscriptions';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _currencyKey = 'currency';

  // === SUBSCRIPTIONS ===
  
  Future<List<Subscription>> getSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_subscriptionsKey);
    
    if (data == null) return [];
    
    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((item) => Subscription.fromJson(item)).toList();
  }

  Future<void> saveSubscriptions(List<Subscription> subscriptions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = subscriptions.map((s) => s.toJson()).toList();
    await prefs.setString(_subscriptionsKey, json.encode(jsonList));
  }

  Future<void> addSubscription(Subscription subscription) async {
    final subscriptions = await getSubscriptions();
    subscriptions.add(subscription);
    await saveSubscriptions(subscriptions);
  }

  Future<void> updateSubscription(Subscription subscription) async {
    final subscriptions = await getSubscriptions();
    final index = subscriptions.indexWhere((s) => s.id == subscription.id);
    if (index != -1) {
      subscriptions[index] = subscription;
      await saveSubscriptions(subscriptions);
    }
  }

  Future<void> deleteSubscription(String id) async {
    final subscriptions = await getSubscriptions();
    subscriptions.removeWhere((s) => s.id == id);
    await saveSubscriptions(subscriptions);
  }

  // === SETTINGS ===
  
  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  Future<void> setOnboardingComplete(bool complete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, complete);
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey) ?? '€';
  }

  Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
  }

  // === DATA MANAGEMENT ===
  
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<String> exportData() async {
    final subscriptions = await getSubscriptions();
    final currency = await getCurrency();
    
    return json.encode({
      'subscriptions': subscriptions.map((s) => s.toJson()).toList(),
      'currency': currency,
      'exportDate': DateTime.now().toIso8601String(),
    });
  }

  Future<void> importData(String jsonData) async {
    final data = json.decode(jsonData);
    
    if (data['subscriptions'] != null) {
      final List<dynamic> subs = data['subscriptions'];
      final subscriptions = subs.map((s) => Subscription.fromJson(s)).toList();
      await saveSubscriptions(subscriptions);
    }
    
    if (data['currency'] != null) {
      await setCurrency(data['currency']);
    }
  }
}
