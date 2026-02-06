import 'package:uuid/uuid.dart';

class Subscription {
  final String id;
  final String name;
  final double price;
  final String currency;
  final String category;
  final DateTime startDate;
  final DateTime nextBillingDate;
  final String billingCycle; // 'monthly', 'yearly', 'weekly'
  final String? iconName;
  final String? notes;
  final bool isActive;
  final bool notificationsEnabled;
  final int reminderDaysBefore;

  Subscription({
    String? id,
    required this.name,
    required this.price,
    this.currency = '€',
    required this.category,
    required this.startDate,
    required this.nextBillingDate,
    this.billingCycle = 'monthly',
    this.iconName,
    this.notes,
    this.isActive = true,
    this.notificationsEnabled = true,
    this.reminderDaysBefore = 3,
  }) : id = id ?? const Uuid().v4();

  // Calculate next billing date based on cycle
  DateTime calculateNextBillingDate() {
    final now = DateTime.now();
    var next = nextBillingDate;
    
    while (next.isBefore(now)) {
      switch (billingCycle) {
        case 'weekly':
          next = next.add(const Duration(days: 7));
          break;
        case 'yearly':
          next = DateTime(next.year + 1, next.month, next.day);
          break;
        case 'monthly':
        default:
          next = DateTime(next.year, next.month + 1, next.day);
          break;
      }
    }
    return next;
  }

  // Days until next billing
  int get daysUntilBilling {
    return nextBillingDate.difference(DateTime.now()).inDays;
  }

  // Monthly cost (normalized)
  double get monthlyCost {
    switch (billingCycle) {
      case 'weekly':
        return price * 4.33;
      case 'yearly':
        return price / 12;
      case 'monthly':
      default:
        return price;
    }
  }

  // Yearly cost (normalized)
  double get yearlyCost {
    switch (billingCycle) {
      case 'weekly':
        return price * 52;
      case 'yearly':
        return price;
      case 'monthly':
      default:
        return price * 12;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'currency': currency,
      'category': category,
      'startDate': startDate.toIso8601String(),
      'nextBillingDate': nextBillingDate.toIso8601String(),
      'billingCycle': billingCycle,
      'iconName': iconName,
      'notes': notes,
      'isActive': isActive,
      'notificationsEnabled': notificationsEnabled,
      'reminderDaysBefore': reminderDaysBefore,
    };
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? '€',
      category: json['category'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      nextBillingDate: DateTime.parse(json['nextBillingDate'] as String),
      billingCycle: json['billingCycle'] as String? ?? 'monthly',
      iconName: json['iconName'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      reminderDaysBefore: json['reminderDaysBefore'] as int? ?? 3,
    );
  }

  Subscription copyWith({
    String? name,
    double? price,
    String? currency,
    String? category,
    DateTime? startDate,
    DateTime? nextBillingDate,
    String? billingCycle,
    String? iconName,
    String? notes,
    bool? isActive,
    bool? notificationsEnabled,
    int? reminderDaysBefore,
  }) {
    return Subscription(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      billingCycle: billingCycle ?? this.billingCycle,
      iconName: iconName ?? this.iconName,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
    );
  }
}
