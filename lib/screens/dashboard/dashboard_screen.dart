import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/service_icons.dart';
import '../../models/subscription.dart';
import '../../services/storage_service.dart';
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
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fabController.forward();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    final subs = await StorageService().getSubscriptions();
    if (mounted) setState(() => _subscriptions = subs);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    setState(() => _currentTab = index);
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 350),
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
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
    if (result == true) _loadSubscriptions();
  }

  double get _monthlyTotal => _subscriptions.fold(0, (sum, s) => sum + s.monthlyCost);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildHomeTab(),
          const AnalyticsScreen(),
          const SettingsScreen(),
        ],
      ),
      floatingActionButton: _currentTab == 0
          ? ScaleTransition(
              scale: CurvedAnimation(parent: _fabController, curve: Curves.easeOutBack),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withValues(alpha: 0.25),
                      blurRadius: 20,
                      spreadRadius: -4,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: () => _openAddSubscription(),
                  backgroundColor: AppTheme.accent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  child: const Icon(Icons.add_rounded, color: Color(0xFF0A0A0A), size: 26),
                ),
              ),
            )
          : null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.grid_view_rounded, 'Home'),
              _navItem(1, Icons.insights_rounded, 'Analytics'),
              _navItem(2, Icons.tune_rounded, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final active = _currentTab == index;
    return GestureDetector(
      onTap: () => _switchTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppTheme.accent.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: active ? AppTheme.accent : AppTheme.textMuted),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
              fontSize: 10, fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? AppTheme.accent : AppTheme.textMuted,
              letterSpacing: 0.3,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadSubscriptions,
        color: AppTheme.accent,
        backgroundColor: AppTheme.surfaceElevated,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SubTracker',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary, letterSpacing: -0.8)),
                              const SizedBox(height: 2),
                              Text('${_subscriptions.length} active',
                                style: TextStyle(fontSize: 13, color: AppTheme.textMuted, letterSpacing: 0.2)),
                            ],
                          ),
                        ),
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.border, width: 0.5),
                          ),
                          child: Icon(Icons.notifications_none_rounded, size: 20, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    
                    // Spending card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: AppTheme.accentGlow(radius: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MONTHLY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                              color: AppTheme.accent.withValues(alpha: 0.7), letterSpacing: 1.5)),
                          const SizedBox(height: 10),
                          Text('€${_monthlyTotal.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary, letterSpacing: -2, height: 1.0)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 4, height: 4,
                                decoration: BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Text('€${(_monthlyTotal * 12).toStringAsFixed(0)} per year',
                                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    if (_subscriptions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('ACTIVE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted, letterSpacing: 1.5)),
                      ),
                  ],
                ),
              ),
            ),
            
            if (_subscriptions.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
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
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppTheme.border),
            ),
            child: Icon(Icons.receipt_long_rounded, size: 28, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 24),
          Text('No subscriptions yet', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text('Tap + to add one', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: AppTheme.softCard(radius: 24),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.08)),
              ),
              child: Icon(
                service?.icon ?? Icons.receipt_long_rounded,
                size: 20, color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sub.name, style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const SizedBox(height: 3),
                  Text(dueText, style: TextStyle(
                    fontSize: 12, color: daysUntil <= 3 ? AppTheme.warning : AppTheme.textMuted)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('€${sub.price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.3)),
                const SizedBox(height: 2),
                Text(sub.billingCycle, style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
