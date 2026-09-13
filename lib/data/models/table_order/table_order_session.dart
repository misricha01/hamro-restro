import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/table_order_provider.dart';
import '../../../screens/orders/table_order_sessions_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/table_order/table_order_session.dart';
import '../../providers/table_order_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;

/// Active table-order sessions list, backed by `GET /api/table-order`
/// (`TableOrderProvider`). Reached from Orders > Actions ("Table Sessions").
///
/// This is a read-only view of raw table-order sessions -- `move-table` and
/// `merge-table` actions live in their own existing flow and are untouched
/// by this screen.
class TableOrderSessionsScreen extends StatefulWidget {
  const TableOrderSessionsScreen({super.key});

  @override
  State<TableOrderSessionsScreen> createState() => _TableOrderSessionsScreenState();
}

class _TableOrderSessionsScreenState extends State<TableOrderSessionsScreen> {
  // null = "All" -- matches the Swagger-documented values (active | completed | cancelled).
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<TableOrderProvider>().fetchSessions(tableStatus: _statusFilter));
  }

  void _selectFilter(String? status) {
    setState(() => _statusFilter = status);
    context.read<TableOrderProvider>().fetchSessions(tableStatus: status);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TableOrderProvider>();

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
        title: const Text('Table Sessions', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  _FilterChip(label: 'All', selected: _statusFilter == null, onTap: () => _selectFilter(null)),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Active', selected: _statusFilter == 'active', onTap: () => _selectFilter('active')),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Completed', selected: _statusFilter == 'completed', onTap: () => _selectFilter('completed')),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Cancelled', selected: _statusFilter == 'cancelled', onTap: () => _selectFilter('cancelled')),
                ],
              ),
            ),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(TableOrderProvider provider) {
    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48, color: AppTheme.textSecondary),
                const SizedBox(height: 12),
                Text(provider.errorMessage ?? 'Something went wrong.', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => provider.fetchSessions(tableStatus: _statusFilter),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        if (provider.sessions.isEmpty) return const _EmptyState();
        return RefreshIndicator(
          color: AppTheme.accent,
          onRefresh: () => provider.fetchSessions(tableStatus: _statusFilter),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: provider.sessions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _SessionTile(session: provider.sessions[index]),
          ),
        );
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent : AppTheme.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(color: selected ? Colors.white : AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.none),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.table_restaurant_outlined, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text('No table sessions', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 17, decoration: TextDecoration.none)),
            const SizedBox(height: 8),
            const Text('Nothing matches this filter right now.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final TableOrderSession session;
  const _SessionTile({required this.session});

  Color get _statusColor {
    switch (session.tableStatus) {
      case 'active':
        return AppTheme.completed;
      case 'cancelled':
        return AppTheme.cancelled;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _formatTime(DateTime? d) {
    if (d == null) return '--';
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} · $h:${d.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.table_bar_outlined, color: AppTheme.textPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.table.tableName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, decoration: TextDecoration.none)),
                const SizedBox(height: 2),
                Text(
                  '${session.table.tableType} · ${session.table.capacity} seats · ${session.order.kotCount} KOT${session.order.kotCount == 1 ? '' : 's'}',
                  style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, decoration: TextDecoration.none),
                ),
                const SizedBox(height: 2),
                Text(_formatTime(session.createdAt), style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary, decoration: TextDecoration.none)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: _statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(session.tableStatus, style: TextStyle(color: _statusColor, fontWeight: FontWeight.w600, fontSize: 11.5, decoration: TextDecoration.none)),
          ),
        ],
      ),
    );
  }
}