import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../models/subscription.dart';
import '../../services/storage_service.dart';
import '../../services/notification_service.dart';

class AddSubscriptionScreen extends StatefulWidget {
  final Subscription? subscription;
  const AddSubscriptionScreen({super.key, this.subscription});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _category = 'other';
  String _billingCycle = 'monthly';
  DateTime _nextBilling = DateTime.now().add(const Duration(days: 30));
  bool _notificationsEnabled = true;
  int _reminderDaysBefore = 3;
  bool _isEditing = false;
  
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    
    if (widget.subscription != null) {
      _isEditing = true;
      final s = widget.subscription!;
      _nameController.text = s.name;
      _priceController.text = s.price.toStringAsFixed(2);
      _category = s.category;
      _billingCycle = s.billingCycle;
      _nextBilling = s.nextBillingDate;
      _notificationsEnabled = s.notificationsEnabled;
      _reminderDaysBefore = s.reminderDaysBefore;
      _notesController.text = s.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.replaceAll(',', '.'));
    if (name.isEmpty || price == null || price <= 0) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a name and valid price'),
          backgroundColor: AppTheme.surfaceHigh,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
      return;
    }

    final subscription = Subscription(
      id: widget.subscription?.id ?? const Uuid().v4(),
      name: name,
      price: price,
      billingCycle: _billingCycle,
      startDate: widget.subscription?.startDate ?? DateTime.now(),
      nextBillingDate: _nextBilling,
      category: _category,
      notificationsEnabled: _notificationsEnabled,
      reminderDaysBefore: _reminderDaysBefore,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );
    
    final storage = StorageService();
    if (_isEditing) {
      await storage.updateSubscription(subscription);
    } else {
      await storage.addSubscription(subscription);
    }
    
    if (_notificationsEnabled) {
      try { await NotificationService().scheduleSubscriptionReminder(subscription); } catch (_) {}
    }

    HapticFeedback.mediumImpact();
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    if (widget.subscription == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Delete ${widget.subscription!.name}?',
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
        content: Text('This cannot be undone.',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await StorageService().deleteSubscription(widget.subscription!.id);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppTheme.softShadowsLight,
                        ),
                        child: Icon(Icons.arrow_back_rounded, color: AppTheme.textSecondary, size: 20),
                      ),
                    ),
                    const Spacer(),
                    Text(_isEditing ? 'Edit' : 'New Subscription',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    const Spacer(),
                    if (_isEditing)
                      GestureDetector(
                        onTap: _delete,
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.danger.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: AppTheme.softShadowsLight,
                          ),
                          child: Icon(Icons.delete_outline_rounded, color: AppTheme.danger, size: 20),
                        ),
                      )
                    else
                      const SizedBox(width: 44),
                  ],
                ),
              ),
              
              // Form
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      _fieldLabel('NAME'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: AppTheme.softInset(radius: 18),
                        child: TextField(
                          controller: _nameController,
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'Netflix, Spotify, iCloud...',
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Price + Cycle row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel('PRICE'),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: AppTheme.softInset(radius: 18),
                                  child: TextField(
                                    controller: _priceController,
                                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      hintText: '0.00',
                                      prefixText: '€ ',
                                      prefixStyle: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600, fontSize: 15),
                                      filled: false,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel('BILLING'),
                                const SizedBox(height: 8),
                                Container(
                                  height: 54,
                                  decoration: AppTheme.softInset(radius: 18),
                                  child: Row(
                                    children: [
                                      _cycleChip('monthly', 'Mo'),
                                      _cycleChip('yearly', 'Yr'),
                                      _cycleChip('weekly', 'Wk'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Category
                      _fieldLabel('CATEGORY'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AppTheme.categoryColors.keys.map((cat) => _categoryChip(cat)).toList(),
                      ),
                      const SizedBox(height: 24),
                      
                      // Next billing date
                      _fieldLabel('NEXT BILLING'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _nextBilling,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 730)),
                            builder: (context, child) => Theme(
                              data: AppTheme.darkTheme.copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppTheme.accent,
                                  surface: AppTheme.surfaceHigh,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (date != null) setState(() => _nextBilling = date);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          decoration: AppTheme.softInset(radius: 18),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.accent),
                              const SizedBox(width: 14),
                              Text(DateFormat('dd MMM yyyy').format(_nextBilling),
                                  style: TextStyle(fontSize: 15, color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
                              const Spacer(),
                              Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.textMuted),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Notification toggle
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: AppTheme.softCard(radius: 20),
                        child: Row(
                          children: [
                            Icon(Icons.notifications_none_rounded, size: 20, color: AppTheme.accent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('Reminder', style: TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
                            ),
                            if (_notificationsEnabled)
                              Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _reminderDaysBefore,
                                    isDense: true,
                                    dropdownColor: AppTheme.surfaceHigh,
                                    style: TextStyle(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w500),
                                    icon: Icon(Icons.unfold_more_rounded, size: 14, color: AppTheme.accent),
                                    items: [1, 2, 3, 5, 7].map((d) =>
                                      DropdownMenuItem(value: d, child: Text('${d}d'))).toList(),
                                    onChanged: (v) => setState(() => _reminderDaysBefore = v ?? 3),
                                  ),
                                ),
                              ),
                            Switch(
                              value: _notificationsEnabled,
                              onChanged: (v) => setState(() => _notificationsEnabled = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Notes
                      _fieldLabel('NOTES'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: AppTheme.softInset(radius: 18),
                        child: TextField(
                          controller: _notesController,
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Optional notes...',
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Save button (neumorphic)
                      GestureDetector(
                        onTap: _save,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: AppTheme.softButton(radius: 18),
                          alignment: Alignment.center,
                          child: Text(_isEditing ? 'Update' : 'Add Subscription',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                              color: AppTheme.background, letterSpacing: 0.3)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
        color: AppTheme.textMuted, letterSpacing: 1.2));
  }

  Widget _cycleChip(String value, String label) {
    final active = _billingCycle == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _billingCycle = value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: active ? AppTheme.accent.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: active ? Border.all(color: AppTheme.accent.withValues(alpha: 0.25)) : null,
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(
            fontSize: 12, fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? AppTheme.accent : AppTheme.textMuted,
          )),
        ),
      ),
    );
  }

  Widget _categoryChip(String cat) {
    final active = _category == cat;
    final color = AppTheme.getCategoryColor(cat);
    final label = cat[0].toUpperCase() + cat.substring(1);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _category = cat);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.12) : AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? color.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.04),
            width: active ? 1 : 0.5,
          ),
          boxShadow: active ? null : AppTheme.softShadowsLight,
        ),
        child: Text(label, style: TextStyle(
          fontSize: 12, fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          color: active ? color : AppTheme.textMuted,
        )),
      ),
    );
  }
}
