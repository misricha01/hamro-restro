import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/notification_channel_card.dart' show kNotifyStaffOptions;

/// "Transfer Ownership" screen reached from Manage > Setting > Dangerous
/// Area: hands SuperAdmin permissions to another staff member, matching the
/// reference's warning copy + staff picker.
class TransferOwnershipScreen extends StatefulWidget {
  const TransferOwnershipScreen({super.key});

  @override
  State<TransferOwnershipScreen> createState() => _TransferOwnershipScreenState();
}

class _TransferOwnershipScreenState extends State<TransferOwnershipScreen> {
  String? _selectedUsername;

  Future<void> _transfer() async {
    if (_selectedUsername == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose a new Super Admin to continue')));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Transfer ownership?', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: const Text('This cannot be reversed. Your role will change to Admin immediately.', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Transfer', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w700, decoration: TextDecoration.none))),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ownership transferred')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.chevron_left, color: AppTheme.accent),
            ),
          ),
        ),
        title: const Text('Transfer Ownership', style: TextStyle(color: AppTheme.textPrimary, fontSize: 19, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _IconBadge(icon: Icons.groups_outlined, color: AppTheme.accent),
                Container(
                  width: 64,
                  height: 64,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppTheme.cancelled.withValues(alpha: 0.12), shape: BoxShape.circle),
                  child: const Icon(Icons.sync_alt, color: AppTheme.cancelled, size: 26),
                ),
                _IconBadge(icon: Icons.person_search_outlined, color: AppTheme.completed),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'This will transfer all your permission to new Super Admin.',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 17, decoration: TextDecoration.none),
            ),
            const SizedBox(height: 16),
            const _BulletLine('Every business can have only one Super Admin'),
            const _BulletLine('Once you transfer ownership to new owner, your role will be changed to Admin'),
            const _BulletLine('New Super Admin can remove you from restaurant or delete the restaurant'),
            const _BulletLine('You will not be able to reverse this.'),
            const SizedBox(height: 24),
            const Text('Choose New Super Admin', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
            const SizedBox(height: 12),
            for (final staff in kNotifyStaffOptions)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _selectedUsername = staff.username),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _selectedUsername == staff.username ? AppTheme.primary : AppTheme.divider),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.card,
                        child: Text(
                          staff.name.trim().isEmpty ? '?' : staff.name.trim().split(RegExp(r'\s+')).map((p) => p[0]).take(2).join().toUpperCase(),
                          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(staff.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.5, decoration: TextDecoration.none)),
                            Text('@${staff.username}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(8)),
                        child: const Text('SuperAdmin', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 11.5, decoration: TextDecoration.none)),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 14, 16, 14 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _transfer,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cancelled, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Transfer Ownership', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String text;
  const _BulletLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 5, color: AppTheme.textSecondary),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, height: 1.4, decoration: TextDecoration.none))),
        ],
      ),
    );
  }
}
