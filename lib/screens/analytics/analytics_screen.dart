import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_theme.dart';
import '../../models/subscription.dart';
import '../../services/storage_service.dart';
import '../../core/data/service_icons.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  List<Subscription> _subscriptions = [];
  late AnimationController _chartAnim;

  @override
  void initState() {
    super.initState();
    _chartAnim = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final subs = await StorageService().getSubscriptions();
    if (mounted) {
      setState(() => _subscriptions = subs);
      _chartAnim.forward();
    }
  }

  @override
  void dispose() {
    _chartAnim.dispose();
    super.dispose();
  }

  double get _monthlyTotal => _subscriptions.fold(0, (s, sub) => s + sub.monthlyCost);
  double get _yearlyTotal => _monthlyTotal * 12;

  Map<String, double> get _categorySpending {
    final map = <String, double>{};
    for (final sub in _subscriptions) {
      map[sub.category] = (map[sub.category] ?? 0) + sub.monthlyCost;
    }
    return Map.fromEntries(map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: _subscriptions.isEmpty
          ? _emptyState()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Analytics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary, letterSpacing: -0.8)),
                  const SizedBox(height: 4),
                  Text('Your spending overview', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                  const SizedBox(height: 28),
                  
                  // Summary cards
                  Row(
                    children: [
                      _summaryCard('Monthly', '€${_monthlyTotal.toStringAsFixed(2)}', AppTheme.accent),
                      const SizedBox(width: 12),
                      _summaryCard('Yearly', '€${_yearlyTotal.toStringAsFixed(0)}', AppTheme.accentMuted),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _summaryCard('Active', '${_subscriptions.length}', AppTheme.success),
                      const SizedBox(width: 12),
                      _summaryCard('Avg/sub', '€${(_monthlyTotal / _subscriptions.length).toStringAsFixed(2)}', AppTheme.textSecondary),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Chart
                  Text('BY CATEGORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  Center(
                    child: AnimatedBuilder(
                      animation: _chartAnim,
                      builder: (context, child) {
                        return SizedBox(
                          width: 200, height: 200,
                          child: CustomPaint(
                            painter: _DonutPainter(
                              categories: _categorySpending,
                              total: _monthlyTotal,
                              progress: CurvedAnimation(parent: _chartAnim, curve: Curves.easeOutCubic).value,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  // Category list
                  ..._categorySpending.entries.map((e) {
                    final pct = _monthlyTotal > 0 ? (e.value / _monthlyTotal * 100) : 0.0;
                    final color = AppTheme.getCategoryColor(e.key);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: AppTheme.softCard(radius: 22),
                      child: Row(
                        children: [
                          Container(
                            width: 10, height: 10,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(e.key[0].toUpperCase() + e.key.substring(1),
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                          ),
                          Text('€${e.value.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                          const SizedBox(width: 10),
                          Container(
                            width: 44,
                            alignment: Alignment.centerRight,
                            child: Text('${pct.toStringAsFixed(0)}%',
                                style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                          ),
                        ],
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 28),
                  
                  // Top spending
                  Text('TOP SPENDING', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  ...(_subscriptions..sort((a, b) => b.monthlyCost.compareTo(a.monthlyCost)))
                      .take(5).map((sub) {
                    final color = ServiceIcons.getService(sub.name)?.brandColor ?? AppTheme.getCategoryColor(sub.category);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: AppTheme.softCard(radius: 22),
                      child: Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(ServiceIcons.getService(sub.name)?.icon ?? Icons.receipt_long_rounded,
                                size: 16, color: color),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(sub.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                          ),
                          Text('€${sub.monthlyCost.toStringAsFixed(2)}/mo',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.softCard(radius: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                color: AppTheme.textMuted, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                color: color, letterSpacing: -0.5)),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insights_rounded, size: 48, color: AppTheme.textMuted),
          const SizedBox(height: 20),
          Text('No data yet', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text('Add subscriptions to see analytics', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final Map<String, double> categories;
  final double total;
  final double progress;

  _DonutPainter({required this.categories, required this.total, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 18.0;
    
    // Background ring
    final bgPaint = Paint()
      ..color = AppTheme.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);
    
    if (total <= 0 || categories.isEmpty) return;
    
    double startAngle = -math.pi / 2;
    final entries = categories.entries.toList();
    
    for (int i = 0; i < entries.length; i++) {
      final sweepAngle = (entries[i].value / total) * 2 * math.pi * progress;
      final paint = Paint()
        ..color = AppTheme.getCategoryColor(entries[i].key)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
    
    // Center text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '€${total.toStringAsFixed(0)}',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.5),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.progress != progress;
}
