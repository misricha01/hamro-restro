import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../data/models/subscription/plan_model.dart';
import '../data/repositories/plan_repository.dart';
import 'order_provider.dart' show LoadStatus;

/// ViewModel for Compare Plans / Change Plan, backed by the real plan
/// catalog (`/api/plans`, `/api/plan-prices`, `/api/features`,
/// `/api/plan-features`) — all shared, tenant-visible vocabulary, so one
/// fetch loads everything needed to render the comparison table.
class PlanProvider extends ChangeNotifier {
  final PlanRepository _repository;

  PlanProvider({required PlanRepository repository}) : _repository = repository;

  LoadStatus status = LoadStatus.idle;
  List<Plan> plans = [];
  List<PlanPrice> prices = [];
  List<PlanFeatureDef> features = [];
  List<PlanFeatureGrant> grants = [];
  String? errorMessage;

  List<Plan> get sortedPlans => [...plans]..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

  List<PlanPrice> pricesFor(String planId) => prices.where((p) => p.planId == planId).toList();

  PlanFeatureGrant? grantFor({required String planId, required String featureId}) {
    for (final g in grants) {
      if (g.planId == planId && g.featureId == featureId) return g;
    }
    return null;
  }

  Future<void> fetchCatalog() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getPlans(),
        _repository.getPlanPrices(),
        _repository.getFeatures(),
        _repository.getPlanFeatures(),
      ]);
      plans = results[0] as List<Plan>;
      prices = results[1] as List<PlanPrice>;
      features = results[2] as List<PlanFeatureDef>;
      grants = results[3] as List<PlanFeatureGrant>;
      status = LoadStatus.loaded;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }
}
