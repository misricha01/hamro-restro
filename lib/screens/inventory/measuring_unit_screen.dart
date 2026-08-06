import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/unit/unit_model.dart';
import '../../providers/unit_provider.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import 'add_measuring_unit_screen.dart';

/// "Measuring Unit" screen reached from Inventory > Measuring Unit, sourced
/// live from [UnitProvider] (backend: `/api/unit`).
class MeasuringUnitScreen extends StatefulWidget {
  const MeasuringUnitScreen({super.key});

  @override
  State<MeasuringUnitScreen> createState() => _MeasuringUnitScreenState();
}

class _MeasuringUnitScreenState extends State<MeasuringUnitScreen> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<UnitProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchUnits());
    }
  }

  Future<void> _addUnit() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMeasuringUnitScreen()));
  }

  Future<void> _editUnit(Unit unit) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => AddMeasuringUnitScreen(initial: unit)));
  }

  Future<void> _deleteUnit(Unit unit) async {
    if (unit.id == null) return;
    final provider = context.read<UnitProvider>();
    final ok = await provider.deleteUnit(unit.id!);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.deleteErrorMessage ?? 'Something went wrong. Please try again.')));
    }
  }

  Future<void> _showRowMenu(Unit unit, Offset position) async {
    final action = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.divider)),
      items: const [
        PopupMenuItem(
          value: 'edit',
          child: Row(children: [Icon(Icons.edit_outlined, color: AppTheme.textPrimary, size: 18), SizedBox(width: 10), Text('Edit Unit', style: TextStyle(color: AppTheme.textPrimary, decoration: TextDecoration.none))]),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [Icon(Icons.delete_outline, color: AppTheme.cancelled, size: 18), SizedBox(width: 10), Text('Delete Unit', style: TextStyle(color: AppTheme.cancelled, decoration: TextDecoration.none))]),
        ),
      ],
    );
    if (action == 'edit') {
      _editUnit(unit);
    } else if (action == 'delete') {
      _deleteUnit(unit);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UnitProvider>();

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
          'Measuring Unit',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        ),
      ),
      body: SafeArea(child: _buildBody(provider)),
    );
  }

  Widget _buildBody(UnitProvider provider) {
    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return _ErrorState(message: provider.errorMessage ?? 'Something went wrong.', onRetry: () => provider.fetchUnits());
      case LoadStatus.loaded:
        return Column(
          children: [
            Expanded(
              child: provider.units.isEmpty
                  ? const _EmptyState()
                  : RefreshIndicator(
                      color: AppTheme.accent,
                      onRefresh: () => provider.fetchUnits(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.units.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final unit = provider.units[index];
                          return GestureDetector(
                            onLongPressStart: (details) => _showRowMenu(unit, details.globalPosition),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                              child: Row(
                                children: [
                                  Text(unit.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15.5, decoration: TextDecoration.none)),
                                  const Spacer(),
                                  if ((unit.description ?? '').isNotEmpty)
                                    Expanded(
                                      child: Text(
                                        unit.description!,
                                        textAlign: TextAlign.right,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Text(
                'Total Measuring Unit : ${provider.units.length}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _addUnit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cancelled, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Add New Measuring Unit', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                ),
              ),
            ),
          ],
        );
    }
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
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          'No measuring units created yet.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none),
        ),
      ),
    );
  }
}
