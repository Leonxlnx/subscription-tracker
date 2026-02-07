import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/service_icons.dart';
import '../../models/subscription.dart';
import '../../services/storage_service.dart';
import '../../services/notification_service.dart';
import '../add_subscription/add_subscription_screen.dart';
import '../analytics/analytics_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  List<Subscription> _subscriptions = [];
  int _currentTab = 0;
  late PageController _pageController;
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 500), vsync: this);
    _entranceController.forward();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    final subs = await StorageService().getSubscriptions();
    if (mounted) setState(() => _subscriptions = subs);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    HapticFeedback.selectionClick();
    setState(() => _currentTab = index);
    _pageController.animateToPage(index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic);
  }

  Future<void> _openAddSubscription([Subscription? existing]) async {
    final result = await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddSubscriptionScreen(subscription: existing),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (result == true) {
      _loadSubscriptions();
      // Reschedule notifications after save
      try {
        final subs = await StorageService().getSubscriptions();
        await NotificationService().rescheduleAllReminders(subs);
      } catch (_) {}
    }
  }

  double get _monthlyTotal => _subscriptions.fold(0, (sum, s) => sum + s.monthlyCost);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Page content
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildHomeTab(),
              AnalyticsScreen(onRefresh: _loadSubscriptions),
              const SettingsScreen(),
            ],
          ),
          // Floating bottom nav
          Positioned(
            left: 20, right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 12,
            child: _buildFloatingNav(),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  FLOATING ROUNDED NAV BAR
  // ═══════════════════════════════════════════
  Widget _buildFloatingNav() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, -1)),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(0, Icons.home_rounded, 'Home'),
          _navAdd(),
          _navItem(1, Icons.pie_chart_rounded, 'Analytics'),
          _navItem(2, Icons.settings_rounded, 'Settings'),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final active = _currentTab == index;
    return GestureDetector(
      onTap: () => _switchTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: active ? AppTheme.accent : AppTheme.textMuted),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(
              fontSize: 9, fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? AppTheme.accent : AppTheme.textMuted,
            )),
          ],
        ),
      ),
    );
  }

  Widget _navAdd() {
    return GestureDetector(
      onTap: () => _openAddSubscription(),
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppTheme.accent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: AppTheme.accent.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 3)),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: AppTheme.background, size: 22),
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  HOME TAB
  // ═══════════════════════════════════════════
  Widget _buildHomeTab() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadSubscriptions,
        color: AppTheme.accent,
        backgroundColor: AppTheme.surface,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('SubTracker',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary, letterSpacing: -0.6)),
                              const SizedBox(height: 2),
                              Text('${_subscriptions.length} active subscription${_subscriptions.length == 1 ? '' : 's'}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                            ],
                          ),
                        ),
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: AppTheme.softShadowsLight,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.04), width: 0.5),
                          ),
                          child: const Icon(Icons.notifications_none_rounded, size: 18, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Spending card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.softCard(radius: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34, height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.trending_up_rounded, size: 16, color: AppTheme.textSecondary),
                              ),
                              const SizedBox(width: 10),
                              Text('MONTHLY SPEND', style: TextStyle(fontSize: 10,
                                fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 1.2)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text('€${_monthlyTotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary, letterSpacing: -1.5, height: 1.0)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('€${(_monthlyTotal * 12).toStringAsFixed(0)} / year',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    
                    if (_subscriptions.isNotEmpty)
                      Text('SUBSCRIPTIONS', style: TextStyle(fontSize: 10,
                        fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 1.2)),
                  ],
                ),
              ),
            ),
            
            if (_subscriptions.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildSubscriptionCard(_subscriptions[index]),
                    childCount: _subscriptions.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: AppTheme.softCircle(),
            child: const Icon(Icons.receipt_long_rounded, size: 28, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 24),
          const Text('No subscriptions yet',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 6),
          const Text('Tap + to add your first one',
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(Subscription sub) {
    final service = ServiceIcons.getService(sub.name);
    final color = service?.brandColor ?? AppTheme.getCategoryColor(sub.category);
    final daysUntil = sub.nextBillingDate.difference(DateTime.now()).inDays;
    
    String dueText;
    if (daysUntil <= 0) {
      dueText = 'Due today';
    } else if (daysUntil == 1) {
      dueText = 'Tomorrow';
    } else {
      dueText = 'In $daysUntil days';
    }
    
    return GestureDetector(
      onTap: () => _openAddSubscription(sub),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: AppTheme.softCard(radius: 22),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                service?.icon ?? Icons.receipt_long_rounded,
                size: 20, color: color,
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sub.name, style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const SizedBox(height: 3),
                  Text(dueText, style: TextStyle(
                    fontSize: 12, color: daysUntil <= 3 ? AppTheme.warning : AppTheme.textMuted)),
                ],
              ),
            ),
            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('€${sub.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary, letterSpacing: -0.3)),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(sub.billingCycle, style: const TextStyle(
                    fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
