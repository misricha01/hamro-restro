import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/staff/staff_member_model.dart';
import '../../models/role_style.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/staff_provider.dart';
import 'create_staff_screen.dart';
import 'invite_staff_screen.dart';
import 'staff_detail_screen.dart';

/// "Staff" list reached from Manage > Users > Staff, sourced live from
/// [StaffProvider] (backend: `GET /api/user/all`). Tapping a row opens
/// [StaffDetailScreen]; "Invite Staff" reuses the existing [InviteStaffScreen]
/// instead of duplicating that flow, and the "+" action reuses
/// [CreateStaffScreen] for directly adding a staff member.
class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  final _searchController = TextEditingController();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<StaffProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchStaff());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StaffMember> _filtered(List<StaffMember> staff) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return staff;
    return staff.where((s) => s.fullname.toLowerCase().contains(query) || s.email.toLowerCase().contains(query)).toList();
  }

  Future<void> _openInviteStaff() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const InviteStaffScreen()));
  }

  Future<void> _openCreateStaff() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateStaffScreen()));
  }

  Future<void> _openStaffDetail(StaffMember staff) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => StaffDetailScreen(staff: staff)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffProvider>();

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
        title: const Text(
          'Staff',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: () => setState(() => _searching = !_searching),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(_searching ? Icons.close : Icons.search, color: AppTheme.textPrimary, size: 22),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _openCreateStaff,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.add, color: AppTheme.accent),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_searching)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none),
                    decoration: const InputDecoration(
                      hintText: 'Search staff',
                      hintStyle: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
                      prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _openInviteStaff,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
                  child: Row(
                    children: [
                      const Icon(Icons.person_add_alt_outlined, color: AppTheme.textPrimary, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text('Invite Staff', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.none)),
                      ),
                      const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: _buildBody(provider)),
            if (provider.status == LoadStatus.loaded && provider.staff.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text('Total Staff : ${provider.staff.length}', style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, decoration: TextDecoration.none)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(StaffProvider provider) {
    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return _ErrorState(message: provider.errorMessage ?? 'Something went wrong.', onRetry: () => provider.fetchStaff());
      case LoadStatus.loaded:
        final filtered = _filtered(provider.staff);
        if (filtered.isEmpty) {
          return _EmptyState(onCreate: _openCreateStaff);
        }
        return RefreshIndicator(
          color: AppTheme.accent,
          onRefresh: () => provider.fetchStaff(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final staff = filtered[index];
              return _StaffListTile(staff: staff, onTap: () => _openStaffDetail(staff));
            },
          ),
        );
    }
  }
}

class _StaffListTile extends StatelessWidget {
  final StaffMember staff;
  final VoidCallback onTap;

  const _StaffListTile({required this.staff, required this.onTap});

  String get _initials {
    final parts = staff.fullname.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    return parts.map((p) => p[0]).take(2).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final color = roleColorFor(staff.role);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
              child: Text(_initials, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(staff.fullname, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                  const SizedBox(height: 2),
                  Text(staff.position ?? 'Staff', style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, decoration: TextDecoration.none)),
                ],
              ),
            ),
            if (staff.role.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(staff.role, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12, decoration: TextDecoration.none)),
              ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 56, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
              child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 32, 24, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(color: AppTheme.surface, shape: BoxShape.circle),
            child: const Icon(Icons.people_outline, color: AppTheme.accent, size: 56),
          ),
          const SizedBox(height: 24),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
              children: [
                TextSpan(text: 'No ', style: TextStyle(color: AppTheme.textPrimary)),
                TextSpan(text: 'Staff', style: TextStyle(color: AppTheme.cancelled)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'There is no staff added till date.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onCreate,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Add New Staff', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
            ),
          ),
        ],
      ),
    );
  }
}
