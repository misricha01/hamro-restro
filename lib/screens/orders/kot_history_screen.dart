import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/kot_repository.dart';
import '../../providers/kot_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../widgets/common/setting_empty_state.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';

/// "KOT History" reached from Orders' 3-dot Actions menu, backed by
/// [KotProvider] (`GET /api/kot`). Shows every KOT that's no longer pending
/// (completed or cancelled).
class KotHistoryScreen extends StatefulWidget {
  const KotHistoryScreen({super.key});

  @override
  State<KotHistoryScreen> createState() => _KotHistoryScreenState();
}

class _KotHistoryScreenState extends State<KotHistoryScreen> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<KotProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchKots());
    }
  }

  @override
  Widget build(BuildContext context) {
    final kotProvider = context.watch<KotProvider>();

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
        title: const Text('KOT History', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: AppTheme.textPrimary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_alt_outlined, color: AppTheme.textPrimary), onPressed: () {}),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(child: _buildBody(kotProvider)),
    );
  }

  Widget _buildBody(KotProvider provider) {
    if (provider.status == LoadStatus.loading || provider.status == LoadStatus.idle) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (provider.status == LoadStatus.error) {
      return _ErrorState(message: provider.errorMessage ?? 'Something went wrong.', onRetry: () => context.read<KotProvider>().fetchKots());
    }

    final resolved = provider.kots.where((record) => record.kot.orderStatus.toLowerCase() != 'pending').toList();

    if (resolved.isEmpty) {
      return const SettingEmptyState(title: 'KOT History', subtitle: 'No KOT History found. Completed and cancelled KOTs will show up here.');
    }

    return RefreshIndicator(
      color: AppTheme.accent,
      onRefresh: () => context.read<KotProvider>().fetchKots(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: resolved.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _KotHistoryCard(record: resolved[index]),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40, color: AppTheme.textSecondary),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none)),
            const SizedBox(height: 12),
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

class _KotHistoryCard extends StatelessWidget {
  final KotRecord record;
  const _KotHistoryCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final kot = record.kot;
    final cancelled = kot.orderStatus.toLowerCase() == 'cancelled';
    final statusColor = cancelled ? AppTheme.cancelled : AppTheme.completed;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.soup_kitchen_outlined, color: AppTheme.accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KOT #${kot.kotNumber}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15, decoration: TextDecoration.none)),
                    const SizedBox(height: 3),
                    Text(
                      [
                        record.tableName ?? (record.orderId != null ? 'Order #${record.orderId}' : null),
                        if (record.createdAt != null) _formatDate(record.createdAt!),
                      ].whereType<String>().join(' · '),
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  kot.orderStatus.isEmpty ? '—' : kot.orderStatus[0].toUpperCase() + kot.orderStatus.substring(1),
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                ),
              ),
            ],
          ),
          if (kot.items.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppTheme.divider),
            const SizedBox(height: 10),
            for (final item in kot.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(item.displayName, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, decoration: TextDecoration.none))),
                    Text('x${item.quantity}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
