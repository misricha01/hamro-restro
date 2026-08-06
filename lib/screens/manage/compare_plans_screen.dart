import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/subscription/plan_model.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/plan_provider.dart';

/// "Compare All Plans" table reached from the Change Plan screen, sourced
/// live from [PlanProvider] (backend: `/api/plans` x `/api/features` x
/// `/api/plan-features`) — every plan tier's real feature grants side by
/// side. Replaces the previous curated ~40-row comparison table, since most
/// of those rows (Reservation, Printer, Storage, Activity Log, ...) had no
/// corresponding backend feature.
class ComparePlansScreen extends StatefulWidget {
  const ComparePlansScreen({super.key});

  @override
  State<ComparePlansScreen> createState() => _ComparePlansScreenState();
}

class _ComparePlansScreenState extends State<ComparePlansScreen> {
  static const double _rowHeight = 48;
  static const double _labelWidth = 160;
  static const double _valueWidth = 120;

  @override
  void initState() {
    super.initState();
    final provider = context.read<PlanProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchCatalog());
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlanProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: 'Restro', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 22, decoration: TextDecoration.none)),
                        TextSpan(text: 'X', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 22, decoration: TextDecoration.none)),
                      ]),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: AppTheme.textPrimary, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('All Plans', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.none)),
                  SizedBox(height: 4),
                  Text('Grow Your Restaurant', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 22, decoration: TextDecoration.none)),
                ],
              ),
            ),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(PlanProvider provider) {
    switch (provider.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
      case LoadStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48, color: AppTheme.textSecondary),
                const SizedBox(height: 12),
                Text(provider.errorMessage ?? 'Something went wrong.', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => provider.fetchCatalog(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        final plans = provider.sortedPlans;
        if (plans.isEmpty || provider.features.isEmpty) {
          return const Center(child: Text('No plans configured yet.', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)));
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(14)),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: _labelWidth,
                    child: Column(children: _buildLabelColumn(provider)),
                  ),
                  Container(width: 1, color: AppTheme.divider),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: _valueWidth * plans.length,
                      child: Column(children: _buildValueColumns(provider)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  List<Widget> _buildLabelColumn(PlanProvider provider) {
    final widgets = <Widget>[
      Container(height: _rowHeight, color: AppTheme.card),
    ];
    for (final feature in provider.features) {
      widgets.add(_rowContainer(
        child: Text(feature.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13.5, decoration: TextDecoration.none)),
      ));
    }
    return widgets;
  }

  List<Widget> _buildValueColumns(PlanProvider provider) {
    final plans = provider.sortedPlans;
    final widgets = <Widget>[
      Container(
        height: _rowHeight,
        color: AppTheme.card,
        child: Row(
          children: plans.map((plan) {
            return SizedBox(
              width: _valueWidth,
              child: Center(child: Text(plan.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14, decoration: TextDecoration.none))),
            );
          }).toList(),
        ),
      ),
    ];
    for (final feature in provider.features) {
      widgets.add(
        Container(
          height: _rowHeight,
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.divider))),
          child: Row(
            children: plans.map((plan) {
              final grant = provider.grantFor(planId: plan.id, featureId: feature.id);
              return SizedBox(
                width: _valueWidth,
                child: Center(child: _valueWidget(grant, feature.valueType)),
              );
            }).toList(),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _valueWidget(PlanFeatureGrant? grant, String valueType) {
    if (grant == null || !grant.isEnabled) return const Icon(Icons.close, color: AppTheme.cancelled, size: 18);
    if (valueType == 'boolean') return const Icon(Icons.check, color: AppTheme.completed, size: 18);
    final label = grant.limitValue == null ? 'Unlimited' : '${grant.limitValue}';
    return Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, decoration: TextDecoration.none));
  }

  Widget _rowContainer({required Widget child}) {
    return Container(
      height: _rowHeight,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.divider))),
      child: child,
    );
  }
}
