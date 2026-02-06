import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/storage_service.dart';
import '../../services/notification_service.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _currency = 'EUR';
  bool _biometricEnabled = false;
  bool _autoLockEnabled = false;
  bool _passwordEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storage = StorageService();
    final auth = AuthService();
    final notif = await storage.areNotificationsEnabled();
    final curr = await storage.getCurrency();
    final bio = await auth.isBiometricEnabled();
    final autoLockMinutes = await auth.getAutoLockMinutes();
    final pass = await auth.hasPassword();
    if (mounted) {
      setState(() {
        _notificationsEnabled = notif;
        _currency = curr;
        _biometricEnabled = bio;
        _autoLockEnabled = autoLockMinutes > 0;
        _passwordEnabled = pass;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary, letterSpacing: -0.8)),
              const SizedBox(height: 4),
              Text('Personalize your experience', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
              const SizedBox(height: 32),
              
              _sectionLabel('GENERAL'),
              const SizedBox(height: 12),
              _settingsCard([
                _toggleRow(Icons.notifications_none_rounded, 'Notifications', _notificationsEnabled, (v) async {
                  await StorageService().setNotificationsEnabled(v);
                  setState(() => _notificationsEnabled = v);
                }),
                _divider(),
                _tapRow(Icons.language_rounded, 'Currency', _currency, () => _showCurrencyPicker()),
                _divider(),
                _tapRow(Icons.send_rounded, 'Test Notification', '', () async {
                  await NotificationService().showTestNotification();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Test notification sent'),
                      backgroundColor: AppTheme.surfaceElevated,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ));
                  }
                }),
              ]),
              const SizedBox(height: 28),
              
              _sectionLabel('SECURITY'),
              const SizedBox(height: 12),
              _settingsCard([
                _toggleRow(Icons.fingerprint_rounded, 'Biometric Lock', _biometricEnabled, (v) async {
                  await AuthService().setBiometricEnabled(v);
                  setState(() => _biometricEnabled = v);
                }),
                _divider(),
                _toggleRow(Icons.lock_clock_rounded, 'Auto Lock', _autoLockEnabled, (v) async {
                  await AuthService().setAutoLockMinutes(v ? 5 : 0);
                  setState(() => _autoLockEnabled = v);
                }),
                _divider(),
                _tapRow(
                  Icons.lock_outline_rounded,
                  'Password',
                  _passwordEnabled ? 'Set' : 'Not set',
                  () => _showPasswordDialog(),
                ),
              ]),
              const SizedBox(height: 28),
              
              _sectionLabel('DATA'),
              const SizedBox(height: 12),
              _settingsCard([
                _tapRow(Icons.download_rounded, 'Export Data', '', () => _exportData()),
                _divider(),
                _tapRow(Icons.delete_outline_rounded, 'Clear All', '', () => _clearAllData(), danger: true),
              ]),
              const SizedBox(height: 32),
              
              Center(
                child: Text('SubTracker v2.1', style: TextStyle(fontSize: 11, color: AppTheme.textSubtle)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
        color: AppTheme.textMuted, letterSpacing: 1.5));
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: AppTheme.softCard(radius: 24),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Divider(height: 0.5, thickness: 0.5, color: AppTheme.border, indent: 56);
  }

  Widget _toggleRow(IconData icon, String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.accentMuted),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary))),
          Switch(value: value, onChanged: onChanged, activeColor: AppTheme.accent),
        ],
      ),
    );
  }

  Widget _tapRow(IconData icon, String label, String subtitle, VoidCallback onTap, {bool danger = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: danger ? AppTheme.danger : AppTheme.accentMuted),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                color: danger ? AppTheme.danger : AppTheme.textPrimary))),
            if (subtitle.isNotEmpty)
              Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.textSubtle),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker() {
    final currencies = ['EUR', 'USD', 'GBP', 'CHF', 'JPY'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: AppTheme.surfaceBright, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            ...currencies.map((c) => ListTile(
              title: Text(c, style: TextStyle(color: AppTheme.textPrimary)),
              trailing: _currency == c ? Icon(Icons.check_rounded, color: AppTheme.accent, size: 20) : null,
              onTap: () async {
                await StorageService().setCurrency(c);
                setState(() => _currency = c);
                if (mounted) Navigator.pop(ctx);
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showPasswordDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(_passwordEnabled ? 'Change Password' : 'Set Password',
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          obscureText: true,
          style: TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(hintText: 'Enter password'),
        ),
        actions: [
          if (_passwordEnabled)
            TextButton(
              onPressed: () async {
                await AuthService().removePassword();
                if (mounted) { setState(() => _passwordEnabled = false); Navigator.pop(ctx); }
              },
              child: Text('Remove', style: TextStyle(color: AppTheme.danger)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text('Save', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await AuthService().setPassword(result);
      setState(() => _passwordEnabled = true);
    }
  }

  Future<void> _exportData() async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Export not yet implemented'),
      backgroundColor: AppTheme.surfaceElevated,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Clear All Data?', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
        content: Text('This will delete all subscriptions. Cannot be undone.',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete All', style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await StorageService().clearAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('All data cleared'),
          backgroundColor: AppTheme.surfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ));
      }
    }
  }
}
