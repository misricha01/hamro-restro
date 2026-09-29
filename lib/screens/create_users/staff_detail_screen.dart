import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/staff/staff_member_model.dart';
import '../../models/role_style.dart';
import '../../models/staff.dart';
import '../../providers/staff_provider.dart';
import '../../widgets/common/analytics_cards.dart';
import '../analytics/sales_analytics_screen.dart' show InvoiceEmptyState;
import '../finance/payments/payment_entry_screen.dart';
import 'adjust_balance_screen.dart';
import 'create_staff_screen.dart';
import 'staff_change_role_screen.dart';
import 'staff_permission_details_screen.dart';

enum _StaffMenuAction { edit, adjustBalance, leave, help }

/// Staff profile screen reached by tapping a row in [StaffListScreen].
/// Mirrors the reference's Profile / Transactions / Invoice / Credit List
/// tabs, reusing [PaymentEntryScreen] from Finance > Payments for the
/// Payment In / Payment Out actions instead of duplicating that flow.
///
/// `contactNumber`/balance are not part of this backend's user entity —
/// the "Contact" row is dropped, and balance/discount stay local-only state
/// (see [AdjustBalanceScreen]). "Leave Restaurant" calls
/// [StaffProvider.deleteStaff] (`DELETE /api/user/{id}`).
class StaffDetailScreen extends StatefulWidget {
  final StaffMember staff;

  const StaffDetailScreen({super.key, required this.staff});

  @override
  State<StaffDetailScreen> createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends State<StaffDetailScreen> {
  late StaffMember _staff = widget.staff;
  double _balance = 0;
  StaffBalanceType _balanceType = StaffBalanceType.toCollect;
  int _tabIndex = 0;

  Future<void> _editStaff() async {
    final updated = await Navigator.push<StaffMember>(context, MaterialPageRoute(builder: (context) => CreateStaffScreen(existingStaff: _staff)));
    if (updated != null) setState(() => _staff = updated);
  }

  Future<void> _adjustBalance() async {
    final result = await Navigator.push<({double balance, StaffBalanceType balanceType})>(
      context,
      MaterialPageRoute(builder: (context) => AdjustBalanceScreen(staff: _staff, currentBalance: _balance, currentBalanceType: _balanceType)),
    );
    if (result != null) {
      setState(() {
        _balance = result.balance;
        _balanceType = result.balanceType;
      });
    }
  }

  void _applyRoleChange(String roleName) {
    setState(() {
      _staff = StaffMember(
        id: _staff.id,
        restaurantId: _staff.restaurantId,
        fullname: _staff.fullname,
        email: _staff.email,
        role: roleName,
        position: _staff.position,
        isDefaultAdmin: _staff.isDefaultAdmin,
        status: _staff.status,
        createdAt: _staff.createdAt,
      );
    });
  }

  Future<void> _changeRole() async {
    final newRole = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => StaffChangeRoleScreen(staffId: _staff.id, staffName: _staff.fullname, currentRoleName: _staff.role)),
    );
    if (newRole != null) _applyRoleChange(newRole);
  }

  void _viewPermissionDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StaffPermissionDetailsScreen(
          staffId: _staff.id,
          staffName: _staff.fullname,
          roleName: _staff.role,
          onRoleChanged: _applyRoleChange,
        ),
      ),
    );
  }

  Future<void> _confirmLeaveRestaurant() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Leave Restaurant', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: Text(
          "Remove ${_staff.fullname} from this restaurant? They'll lose access immediately.",
          style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w700, decoration: TextDecoration.none)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<StaffProvider>();
    final ok = await provider.deleteStaff(_staff.id);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.deleteErrorMessage ?? 'Something went wrong. Please try again.')));
    }
  }

  void _handleMenuAction(_StaffMenuAction action) {
    switch (action) {
      case _StaffMenuAction.edit:
        _editStaff();
      case _StaffMenuAction.adjustBalance:
        _adjustBalance();
      case _StaffMenuAction.leave:
        _confirmLeaveRestaurant();
      case _StaffMenuAction.help:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Help & support coming soon')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDeleting = context.watch<StaffProvider>().isDeleting;

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
        title: Text(
          _staff.fullname,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: isDeleting
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent)),
                  )
                : PopupMenuButton<_StaffMenuAction>(
                    onSelected: _handleMenuAction,
                    color: AppTheme.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.divider)),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: _StaffMenuAction.edit, child: _MenuRow(icon: Icons.edit_outlined, label: 'Edit Staff')),
                      PopupMenuItem(value: _StaffMenuAction.adjustBalance, child: _MenuRow(icon: Icons.percent, label: 'Adjust Balance')),
                      PopupMenuItem(value: _StaffMenuAction.leave, child: _MenuRow(icon: Icons.delete_outline, label: 'Leave Restaurant', color: AppTheme.cancelled)),
                      PopupMenuDivider(),
                      PopupMenuItem(value: _StaffMenuAction.help, child: _MenuRow(icon: Icons.help_outline, label: 'Help')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.more_horiz, color: AppTheme.textPrimary, size: 20),
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _DetailTabRow(
                index: _tabIndex,
                onChanged: (i) => setState(() => _tabIndex = i),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: [
                  _ProfileTab(
                    staff: _staff,
                    balance: _balance,
                    balanceType: _balanceType,
                    onPaymentIn: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentEntryScreen(isPaymentIn: true))),
                    onPaymentOut: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentEntryScreen(isPaymentIn: false))),
                    onChangeRole: _changeRole,
                    onViewPermissionDetails: _viewPermissionDetails,
                  ),
                  const InvoiceEmptyState(entityName: 'Transactions'),
                  const InvoiceEmptyState(entityName: 'Invoice'),
                  const _CreditListTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MenuRow({required this.icon, required this.label, this.color = AppTheme.textPrimary});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
      ],
    );
  }
}

class _DetailTabRow extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _DetailTabRow({required this.index, required this.onChanged});

  static const _labels = ['Profile', 'Transactions', 'Invoice', 'Credit List'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < _labels.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _labels[i],
                    style: TextStyle(
                      color: index == i ? AppTheme.cancelled : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(height: 2, width: 44, color: index == i ? AppTheme.cancelled : Colors.transparent),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _CreditListTab extends StatefulWidget {
  const _CreditListTab();

  @override
  State<_CreditListTab> createState() => _CreditListTabState();
}

class _CreditListTabState extends State<_CreditListTab> {
  String _dateFilter = 'Life Time';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              AnalyticsFilterDropdown(
                label: _dateFilter,
                options: kAnalyticsDateFilterOptions,
                onSelected: (v) => setState(() => _dateFilter = v),
              ),
            ],
          ),
        ),
        const Expanded(child: InvoiceEmptyState(entityName: 'Credit List')),
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final StaffMember staff;
  final double balance;
  final StaffBalanceType balanceType;
  final VoidCallback onPaymentIn;
  final VoidCallback onPaymentOut;
  final VoidCallback onChangeRole;
  final VoidCallback onViewPermissionDetails;

  const _ProfileTab({
    required this.staff,
    required this.balance,
    required this.balanceType,
    required this.onPaymentIn,
    required this.onPaymentOut,
    required this.onChangeRole,
    required this.onViewPermissionDetails,
  });

  String _formatDate(DateTime d) => '${d.year}, ${_month(d.month)} ${d.day.toString().padLeft(2, '0')}';

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  String _month(int m) => _months[m - 1];

  @override
  Widget build(BuildContext context) {
    final roleColor = roleColorFor(staff.role);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _SummaryCard(staff: staff, balance: balance, balanceType: balanceType),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _TintedButton(label: 'Payment Out (Payment)', icon: Icons.south_west, color: AppTheme.cancelled, onTap: onPaymentOut),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TintedButton(label: 'Payment In (Receipt)', icon: Icons.trending_up, color: AppTheme.completed, onTap: onPaymentIn),
            ),
          ],
        ),
        const SizedBox(height: 20),

        const Text('Details', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 17, decoration: TextDecoration.none)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
          child: Column(
            children: [
              _DetailRow(
                label: 'Role',
                value: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(staff.role.isEmpty ? '—' : staff.role, style: TextStyle(color: roleColor, fontWeight: FontWeight.w700, fontSize: 12.5, decoration: TextDecoration.none)),
                ),
              ),
              _DetailRow(
                label: 'Position',
                value: Text(staff.position ?? 'Staff', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
              ),
              _DetailRow(
                label: 'Email',
                value: Text(staff.email, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                isLast: staff.createdAt == null,
              ),
              if (staff.createdAt != null)
                _DetailRow(
                  label: 'Joined',
                  value: Text(_formatDate(staff.createdAt!), style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                  isLast: true,
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text('Role & Permission', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 17, decoration: TextDecoration.none)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: roleColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(staff.role.isEmpty ? 'No role assigned' : staff.role, style: TextStyle(color: roleColor, fontWeight: FontWeight.w700, fontSize: 15, decoration: TextDecoration.none))),
                    ElevatedButton.icon(
                      onPressed: onChangeRole,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.completed,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.sync, color: Colors.white, size: 16),
                      label: const Text('Change Role', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onViewPermissionDetails,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10)),
                  child: const Text(
                    'View Permission Details',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final Widget value;
  final bool isLast;

  const _DetailRow({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppTheme.divider))),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          const Text(':  ', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
          Expanded(child: value),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final StaffMember staff;
  final double balance;
  final StaffBalanceType balanceType;
  const _SummaryCard({required this.staff, required this.balance, required this.balanceType});

  String get _initials {
    final parts = staff.fullname.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    return parts.map((p) => p[0]).take(2).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = roleColorFor(staff.role);
    final balanceLabel = balanceType == StaffBalanceType.toCollect ? 'To Collect | Debit Balance' : 'To Pay | Advance Balance';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12)),
            child: Text(_initials, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(staff.fullname, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
                    ),
                    if (staff.role.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                        child: Text(staff.role, style: TextStyle(color: roleColor, fontWeight: FontWeight.w700, fontSize: 12, decoration: TextDecoration.none)),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(balanceLabel, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text('Rs ${balance.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18, decoration: TextDecoration.none)),
                    ),
                    Text('Position: ${staff.position ?? 'Staff'}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TintedButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TintedButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Flexible(child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12.5, decoration: TextDecoration.none))),
          ],
        ),
      ),
    );
  }
}
