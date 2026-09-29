import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/order_provider.dart' show LoadStatus;
import '../../providers/plan_provider.dart';
import '../../providers/subscription_provider.dart';
import 'billing_history_screen.dart';
import 'change_plan_screen.dart';

/// "Billing & Subscription" hub reached from Manage > Setting > General
/// Setting, sourced live from [SubscriptionProvider] (backend:
/// `/api/subscriptions/current`) — current plan status + Change Plan +
/// real Cancel Subscription. "Renew" isn't wired since renewal is a
/// purchase (real payment) this app can't complete yet. The usage grid is
/// replaced with the current plan's real feature limits (from
/// [PlanProvider]) — there's no "used so far" figure in the API response,
/// so this shows limits only rather than fabricating usage numbers.
class BillingSubscriptionScreen extends StatefulWidget {
  const BillingSubscriptionScreen({super.key});

  @override
  State<BillingSubscriptionScreen> createState() => _BillingSubscriptionScreenState();
}

class _BillingSubscriptionScreenState extends State<BillingSubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    final subProvider = context.read<SubscriptionProvider>();
    final planProvider = context.read<PlanProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (subProvider.status == LoadStatus.idle) subProvider.fetchCurrentSubscription();
      if (planProvider.status == LoadStatus.idle) planProvider.fetchCatalog();
    });
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  void _changePlan() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePlanScreen()));
  }

  void _openBillingHistory() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const BillingHistoryScreen()));
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Cancel Subscription', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        content: const Text('Your subscription will stop auto-renewing at the end of the current period.', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep Subscription', style: TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.none))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cancel Subscription', style: TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w700, decoration: TextDecoration.none))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<SubscriptionProvider>();
    final ok = await provider.cancelSubscription();
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subscription will not renew at period end')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.cancelErrorMessage ?? 'Something went wrong. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final subProvider = context.watch<SubscriptionProvider>();
    final planProvider = context.watch<PlanProvider>();

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
        title: const Text('Billing & Subscription', style: TextStyle(color: AppTheme.textPrimary, fontSize: 19, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _openBillingHistory,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(border: Border.all(color: AppTheme.divider), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.more_horiz, color: AppTheme.textPrimary, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody(subProvider, planProvider)),
    );
  }

  Widget _buildBody(SubscriptionProvider subProvider, PlanProvider planProvider) {
    switch (subProvider.status) {
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
                const Icon(Icons.cloud_off_outlined, size: 56, color: AppTheme.textSecondary),
                const SizedBox(height: 16),
                Text(subProvider.errorMessage ?? 'Something went wrong.', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, decoration: TextDecoration.none)),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => subProvider.fetchCurrentSubscription(),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accent)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.accent, decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        final sub = subProvider.subscription;
        return ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + MediaQuery.of(context).padding.bottom),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF6A3FA0), AppTheme.primary]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.workspace_premium, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text('RestroX ${sub.planName ?? 'Plan'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.none)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (sub.cancelAtPeriodEnd)
                        const Text('Cancels at period end', style: TextStyle(color: AppTheme.pending, fontWeight: FontWeight.bold, fontSize: 12, decoration: TextDecoration.none))
                      else if (sub.isActive)
                        const Text('Active', style: TextStyle(color: AppTheme.completed, fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.none))
                      else
                        Text(sub.status ?? 'Unknown', style: const TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.none)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Current Plan', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                            const SizedBox(height: 4),
                            Text('${sub.planName ?? '—'} Plan', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Renews / Ends', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, decoration: TextDecoration.none)),
                            const SizedBox(height: 4),
                            Text(_formatDate(sub.currentPeriodEnd), style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.none)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: subProvider.isCancelling || sub.cancelAtPeriodEnd ? null : _confirmCancel,
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 13), side: const BorderSide(color: AppTheme.divider), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          child: subProvider.isCancelling
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.cancelled))
                              : Text(sub.cancelAtPeriodEnd ? 'Cancelling' : 'Cancel', style: const TextStyle(color: AppTheme.cancelled, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _changePlan,
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          child: const Text('Change Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Plan Limits', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
                  const SizedBox(height: 16),
                  _planLimits(sub.planId, planProvider),
                ],
              ),
            ),
          ],
        );
    }
  }

  Widget _planLimits(String? planId, PlanProvider planProvider) {
    if (planProvider.status != LoadStatus.loaded) {
      return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: CircularProgressIndicator(color: AppTheme.accent)));
    }
    if (planId == null) {
      return const Text('Plan details unavailable.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none));
    }
    final granted = planProvider.features.where((f) {
      final g = planProvider.grantFor(planId: planId, featureId: f.id);
      return g != null && g.isEnabled;
    }).toList();
    if (granted.isEmpty) {
      return const Text('No feature limits configured for this plan.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, decoration: TextDecoration.none));
    }
    return Wrap(
      spacing: 16,
      runSpacing: 14,
      children: granted.map((feature) {
        final grant = planProvider.grantFor(planId: planId, featureId: feature.id);
        final limit = grant?.limitValue;
        return SizedBox(
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(feature.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5, decoration: TextDecoration.none)),
              const SizedBox(height: 4),
              Text(limit == null ? 'Unlimited' : '$limit', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.none)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
