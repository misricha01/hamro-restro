import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/orders/table_model.dart';
import '../../data/models/table_activity/table_activity_model.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/table_activity_provider.dart';
import '../../widgets/common/setting_empty_state.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _formatDateTime(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final ampm = d.hour < 12 ? 'AM' : 'PM';
  return '${_months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year} · ${h.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} $ampm';
}

IconData _iconFor(String activityType) {
  switch (activityType) {
    case 'order_placed':
      return Icons.receipt_long_outlined;
    case 'checkout_initated':
    case 'checkout_initiated':
      return Icons.point_of_sale_outlined;
    case 'checkout_completed':
      return Icons.check_circle_outline;
    case 'move_table':
      return Icons.swap_horiz;
    default:
      return Icons.circle_outlined;
  }
}

/// One activity session's worth of events for the table, most recent first.
class _Session {
  final String sessionId;
  final bool isActive;
  final List<TableActivityEntry> events;
  _Session({required this.sessionId, required this.isActive, required this.events});
}

/// "Activity" reached from a table's long-press menu on the Orders screen —
/// backed by `GET /api/table-activity` (`TableActivityProvider`). The
/// backend has no `tableId` filter, so this fetches a page of every table's
/// activity and filters/groups by session client-side.
class TableActivityScreen extends StatefulWidget {
  final RestaurantTable table;
  const TableActivityScreen({super.key, required this.table});

  @override
  State<TableActivityScreen> createState() => _TableActivityScreenState();
}

class _TableActivityScreenState extends State<TableActivityScreen> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<TableActivityProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchActivity());
  }

  List<_Session> _sessionsFor(List<TableActivityEntry> all) {
    final forTable = all.where((e) => e.table?.id == widget.table.id).toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final bySession = <String, List<TableActivityEntry>>{};
    for (final e in forTable) {
      (bySession[e.activitySessionId] ??= []).add(e);
    }
    final sessions = bySession.entries
        .map((entry) => _Session(sessionId: entry.key, isActive: entry.value.any((e) => e.isActive), events: entry.value))
        .toList();
    sessions.sort((a, b) => b.events.last.createdAt.compareTo(a.events.last.createdAt));
    return sessions;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TableActivityProvider>();

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
        title: Text('${widget.table.tableName} Activity', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 19, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
      ),
      body: SafeArea(child: _buildBody(provider)),
    );
  }

  Widget _buildBody(TableActivityProvider provider) {
    if (provider.status == LoadStatus.loading || provider.status == LoadStatus.idle) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (provider.status == LoadStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 40, color: AppTheme.textSecondary),
              const SizedBox(height: 10),
              Text(provider.errorMessage ?? 'Something went wrong.', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.read<TableActivityProvider>().fetchActivity(),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
              ),
            ],
          ),
        ),
      );
    }

    final sessions = _sessionsFor(provider.activity);
    if (sessions.isEmpty) {
      return const SettingEmptyState(title: 'Activity', subtitle: 'No activity recorded for this table yet.');
    }

    return RefreshIndicator(
      color: AppTheme.accent,
      onRefresh: () => context.read<TableActivityProvider>().fetchActivity(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sessions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) => _SessionCard(session: sessions[index]),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final _Session session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_formatDateTime(session.events.first.createdAt), style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5, decoration: TextDecoration.none)),
              const Spacer(),
              if (session.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.completed.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Active', style: TextStyle(color: AppTheme.completed, fontSize: 11.5, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < session.events.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == session.events.length - 1 ? 0 : 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_iconFor(session.events[i].activityType), color: AppTheme.accent, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(session.events[i].description, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13.5, decoration: TextDecoration.none)),
                        if (session.events[i].changedTable != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'From ${session.events[i].changedTable!.tableName}',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, decoration: TextDecoration.none),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
