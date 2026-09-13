import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/staff/staff_member_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/staff_provider.dart';
import '../../services/restaurant_service.dart';

/// "Transfer Ownership" screen reached from Manage > Setting > Dangerous
/// Area: hands SuperAdmin permissions to another staff member, matching the
/// reference's warning copy + staff picker.
///
/// Backed by `POST /api/restaurant/transfer-ownership`
/// (`TransferOwnershipDTO { userId }`) -- the picker is populated from
/// [StaffProvider] (`GET /api/user/all`), the same real staff list used by
/// StaffListScreen, not placeholder data.
class TransferOwnershipScreen extends StatefulWidget {
  const TransferOwnershipScreen({super.key});

  @override
  State<TransferOwnershipScreen> createState() => _TransferOwnershipScreenState();
}

class _TransferOwnershipScreenState extends State<TransferOwnershipScreen> {
  String? _selectedUserId;
  bool _transferring = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StaffProvider>();
      if (provider.staff.isEmpty) provider.fetchStaff();
    });
  }

  Future<void> _transfer() async {
    if (_selectedUserId == null) {
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
    if (confirmed != true || !mounted) return;

    setState(() => _transferring = true);
    try {
      await RestaurantService.transferOwnership(_selectedUserId!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ownership transferred')));
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _transferring = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();
    final currentUserId = context.watch<AuthProvider>().currentUser?.id;
    // Only other staff can receive ownership -- exclude the current user.
    final candidates = staffProvider.staff.where((s) => s.id != currentUserId).toList();

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
            if (staffProvider.status == LoadStatus.loading && candidates.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
              )
            else if (candidates.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('No other staff available to receive ownership.', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
              )
            else
              for (final staff in candidates) _StaffTile(staff: staff, selected: _selectedUserId == staff.id, onTap: () => setState(() => _selectedUserId = staff.id)),
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
            onPressed: _transferring ? null : _transfer,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cancelled, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: _transferring
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                : const Text('Transfer Ownership', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
          ),
        ),
      ),
    );
  }
}

class _StaffTile extends StatelessWidget {
  final StaffMember staff;
  final bool selected;
  final VoidCallback onTap;
  const _StaffTile({required this.staff, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final initials = staff.fullname.trim().isEmpty ? '?' : staff.fullname.trim().split(RegExp(r'\s+')).map((p) => p[0]).take(2).join().toUpperCase();
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.card,
              child: Text(initials, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(staff.fullname, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.5, decoration: TextDecoration.none)),
                  Text(staff.email, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(8)),
              child: Text(staff.role, style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 11.5, decoration: TextDecoration.none)),
            ),
          ],
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