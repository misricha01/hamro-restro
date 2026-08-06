import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/subscription/plan_model.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/plan_provider.dart';
import '../../providers/subscription_provider.dart';
import 'compare_plans_screen.dart';

/// "RestroX" branded plan carousel reached from Billing & Subscription's
/// "Change Plan" button, sourced live from [PlanProvider] (backend:
/// `/api/plans`, `/api/plan-prices`, `/api/features`, `/api/plan-features`)
/// — a swipeable deck of whatever plans are actually configured, not a
/// fixed Free/Basic/Premium/Platinum list.
///
/// Actually purchasing/changing a plan starts a real payment (eSewa) that
/// this app has no browser-launch capability for yet, so the action button
/// surfaces that rather than attempting a flow that can't complete.
class ChangePlanScreen extends StatefulWidget {
  const ChangePlanScreen({super.key});

  @override
  State<ChangePlanScreen> createState() => _ChangePlanScreenState();
}

class _ChangePlanScreenState extends State<ChangePlanScreen> {
  final _controller = PageController(viewportFraction: 0.84);

  @override
  void initState() {
    super.initState();
    final provider = context.read<PlanProvider>();
    if (provider.status == LoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.fetchCatalog());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openCompare() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ComparePlansScreen()));
  }

  void _notAvailable(Plan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Not available yet', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: Text(
          "Switching to ${plan.name} isn't supported in the app yet — this requires completing a payment. Please contact support to change your plan.",
          style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700, decoration: TextDecoration.none))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlanProvider>();
    final currentPlanId = context.watch<SubscriptionProvider>().subscription.planId;

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
            Expanded(child: _buildBody(provider, currentPlanId)),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + MediaQuery.of(context).padding.bottom),
              child: Center(
                child: TextButton(
                  onPressed: _openCompare,
                  child: const Text('Compare All Plans >>', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(PlanProvider provider, String? currentPlanId) {
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
        if (plans.isEmpty) {
          return const Center(child: Text('No plans configured yet.', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)));
        }
        return PageView.builder(
          controller: _controller,
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                double scale = 1;
                if (_controller.position.haveDimensions) {
                  scale = (1 - ((_controller.page ?? 0) - index).abs() * 0.08).clamp(0.9, 1.0);
                }
                return Center(child: Transform.scale(scale: scale, child: child));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: _PlanCard(
                  plan: plan,
                  prices: provider.pricesFor(plan.id),
                  features: provider.features,
                  grantFor: (featureId) => provider.grantFor(planId: plan.id, featureId: featureId),
                  isCurrent: plan.id == currentPlanId,
                  onAction: () => _notAvailable(plan),
                ),
              ),
            );
          },
        );
    }
  }
}

class _PlanCard extends StatefulWidget {
  final Plan plan;
  final List<PlanPrice> prices;
  final List<PlanFeatureDef> features;
  final PlanFeatureGrant? Function(String featureId) grantFor;
  final bool isCurrent;
  final VoidCallback onAction;

  const _PlanCard({
    required this.plan,
    required this.prices,
    required this.features,
    required this.grantFor,
    required this.isCurrent,
    required this.onAction,
  });

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  late PlanPrice? _selectedPrice = widget.prices.isEmpty
      ? null
      : (widget.prices.where((p) => p.billingCycle == 'yearly').isNotEmpty ? widget.prices.firstWhere((p) => p.billingCycle == 'yearly') : widget.prices.first);

  String _cycleLabel(String cycle) {
    switch (cycle) {
      case 'semi_annual':
        return '6 Months';
      case 'yearly':
        return 'Yearly';
      case 'lifetime':
        return 'Lifetime';
      default:
        return cycle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final grantedFeatures = widget.features.where((f) {
      final g = widget.grantFor(f.id);
      return g != null && g.isEnabled;
    }).toList();

    return Column(
      children: [
        if (plan.isPopular)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: AppTheme.cancelled, borderRadius: BorderRadius.circular(20)),
            child: const Text('Most Popular', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, decoration: TextDecoration.none)),
          ),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: widget.isCurrent ? AppTheme.primary : AppTheme.divider, width: widget.isCurrent ? 2 : 1),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.prices.length > 1)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Row(
                        children: widget.prices.map((price) {
                          final selected = price == _selectedPrice;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedPrice = price),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                color: selected ? AppTheme.primary : AppTheme.card,
                                child: Text(_cycleLabel(price.billingCycle), style: TextStyle(color: selected ? Colors.white : AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 12.5, decoration: TextDecoration.none)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(plan.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 26, decoration: TextDecoration.none)),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _selectedPrice == null ? 'Free' : 'Rs ${_selectedPrice!.price.toStringAsFixed(0)} / ${_cycleLabel(_selectedPrice!.billingCycle)}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16, decoration: TextDecoration.none),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: widget.isCurrent ? null : widget.onAction,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: widget.isCurrent ? AppTheme.card : AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: widget.isCurrent ? AppTheme.divider : AppTheme.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        widget.isCurrent ? 'Current Plan' : 'Select ${plan.name}',
                        style: TextStyle(color: widget.isCurrent ? AppTheme.textSecondary : Colors.white, fontWeight: FontWeight.w700, decoration: TextDecoration.none),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (plan.description != null) ...[
                    Text(plan.description!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none)),
                    const SizedBox(height: 10),
                  ],
                  const Text('Included Features', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                  const SizedBox(height: 6),
                  if (grantedFeatures.isEmpty)
                    const Text('No features configured for this plan yet.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none))
                  else
                    for (final feature in grantedFeatures) _FeatureLine(feature: feature, grant: widget.grantFor(feature.id)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureLine extends StatelessWidget {
  final PlanFeatureDef feature;
  final PlanFeatureGrant? grant;
  const _FeatureLine({required this.feature, required this.grant});

  @override
  Widget build(BuildContext context) {
    final limit = grant?.limitValue;
    final text = limit == null ? feature.name : '${feature.name} (up to $limit)';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: AppTheme.completed),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13.5, decoration: TextDecoration.none))),
        ],
      ),
    );
  }
}
