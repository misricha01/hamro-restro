import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/dish/dish_model.dart';

class DishStats {
  final int totalDish;
  final int activeDish;
  final String? topSoldName;
  final int? topSoldOrders;
  final String? topDishTypeName;
  final int? topDishTypeCount;

  const DishStats({
    required this.totalDish,
    required this.activeDish,
    this.topSoldName,
    this.topSoldOrders,
    this.topDishTypeName,
    this.topDishTypeCount,
  });

  factory DishStats.fromJson(Map<String, dynamic> json) {
    final dish = json['dish'] as Map<String, dynamic>?;
    final topSold = json['topSold'] as Map<String, dynamic>?;
    final topDishType = json['topDishType'] as Map<String, dynamic>?;
    return DishStats(
      totalDish: (dish?['total'] as num?)?.toInt() ?? 0,
      activeDish: (dish?['activeDish'] as num?)?.toInt() ?? 0,
      topSoldName: topSold?['name'] as String?,
      topSoldOrders: (topSold?['noOfOrder'] as num?)?.toInt(),
      topDishTypeName: topDishType?['name'] as String?,
      topDishTypeCount: (topDishType?['noOfDish'] as num?)?.toInt(),
    );
  }
}

/// A single row from `GET /api/dish/{id}/transactions` — "checkoutId,
/// amount, quantity, invoice number" per the Swagger summary; `date` isn't
/// explicitly documented there but is parsed defensively in case it's
/// present, matching every other transaction-shaped model in this app.
class DishTransaction {
  final String? checkoutId;
  final double amount;
  final int quantity;
  final String? invoiceNumber;
  final DateTime? date;

  const DishTransaction({this.checkoutId, this.amount = 0, this.quantity = 0, this.invoiceNumber, this.date});

  factory DishTransaction.fromJson(Map<String, dynamic> json) {
    return DishTransaction(
      checkoutId: json['checkoutId']?.toString(),
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      invoiceNumber: json['invoiceNumber'] as String?,
      date: DateTime.tryParse((json['date'] ?? json['createdAt'] ?? '').toString()),
    );
  }
}

abstract class DishRepository {
  Future<List<Dish>> getDishes();

  Future<DishStats> getDishStats();

  Future<List<DishTransaction>> getDishTransactions(String dishId);

  Future<Dish> createDish({
    required String dishName,
    String? hsCode,
    String? dishPhoto,
    String? description,
    double? price,
    String? unitId,
    double? cogs,
    String? discountType,
    double? discount,
    double? priceAfterDiscount,
    List<String> variantIds,
    List<String> addonIds,
    required String dishTypeId,
    String? typeOfMenuId,
    required String menuCategoryId,
    bool available,
    List<DishStockConsumption> stockConsumptions,
  });

  Future<Dish> updateDish({
    required String id,
    required String dishName,
    String? hsCode,
    String? dishPhoto,
    String? description,
    double? price,
    String? unitId,
    double? cogs,
    String? discountType,
    double? discount,
    double? priceAfterDiscount,
    List<String> variantIds,
    List<String> addonIds,
    required String dishTypeId,
    String? typeOfMenuId,
    required String menuCategoryId,
    required bool available,
    List<DishStockConsumption> stockConsumptions,
  });

  Future<void> deleteDish(String id);
}

class DishRepositoryImpl implements DishRepository {
  final Dio _dio;

  DishRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<Dish>> getDishes() async {
    try {
      final response = await _dio.get(ApiConstants.dishes, queryParameters: {'page': 1, 'take': 200});
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => Dish.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<DishStats> getDishStats() async {
    try {
      final response = await _dio.get('${ApiConstants.dishes}/dish-stats');
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return DishStats.fromJson(data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Map<String, dynamic> _body({
    required String dishName,
    String? hsCode,
    String? dishPhoto,
    String? description,
    double? price,
    String? unitId,
    double? cogs,
    String? discountType,
    double? discount,
    double? priceAfterDiscount,
    required List<String> variantIds,
    required List<String> addonIds,
    required String dishTypeId,
    String? typeOfMenuId,
    required String menuCategoryId,
    required bool available,
    required List<DishStockConsumption> stockConsumptions,
  }) {
    return {
      'dishName': dishName,
      'hsCode': hsCode,
      'dishPhoto': dishPhoto,
      'description': description,
      'price': price,
      'unitId': unitId,
      'cogs': cogs,
      'discountType': discountType,
      'discount': discount,
      'priceAfterDiscount': priceAfterDiscount,
      'variantIds': variantIds,
      'addonIds': addonIds,
      'dishTypeId': dishTypeId,
      'typeOfMenuId': typeOfMenuId,
      'menuCategoryId': menuCategoryId,
      'available': available,
      'stockConsumptions': stockConsumptions.map((e) => e.toJson()).toList(),
    };
  }

  @override
  Future<Dish> createDish({
    required String dishName,
    String? hsCode,
    String? dishPhoto,
    String? description,
    double? price,
    String? unitId,
    double? cogs,
    String? discountType,
    double? discount,
    double? priceAfterDiscount,
    List<String> variantIds = const [],
    List<String> addonIds = const [],
    required String dishTypeId,
    String? typeOfMenuId,
    required String menuCategoryId,
    bool available = true,
    List<DishStockConsumption> stockConsumptions = const [],
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.dishes,
        data: _body(
          dishName: dishName,
          hsCode: hsCode,
          dishPhoto: dishPhoto,
          description: description,
          price: price,
          unitId: unitId,
          cogs: cogs,
          discountType: discountType,
          discount: discount,
          priceAfterDiscount: priceAfterDiscount,
          variantIds: variantIds,
          addonIds: addonIds,
          dishTypeId: dishTypeId,
          typeOfMenuId: typeOfMenuId,
          menuCategoryId: menuCategoryId,
          available: available,
          stockConsumptions: stockConsumptions,
        ),
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic>) return Dish.fromJson(raw);

      // Same "create response omits the entity" fallback as
      // TableRepositoryImpl.createTable — refetch and match by name.
      final dishes = await getDishes();
      final matches = dishes.where((d) => d.dishName == dishName).toList();
      if (matches.length == 1) return matches.first;
      if (matches.isNotEmpty) {
        matches.sort((a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0));
        return matches.first;
      }
      throw const ApiException('Dish was created, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Dish> updateDish({
    required String id,
    required String dishName,
    String? hsCode,
    String? dishPhoto,
    String? description,
    double? price,
    String? unitId,
    double? cogs,
    String? discountType,
    double? discount,
    double? priceAfterDiscount,
    List<String> variantIds = const [],
    List<String> addonIds = const [],
    required String dishTypeId,
    String? typeOfMenuId,
    required String menuCategoryId,
    required bool available,
    List<DishStockConsumption> stockConsumptions = const [],
  }) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.dishes}/$id',
        data: _body(
          dishName: dishName,
          hsCode: hsCode,
          dishPhoto: dishPhoto,
          description: description,
          price: price,
          unitId: unitId,
          cogs: cogs,
          discountType: discountType,
          discount: discount,
          priceAfterDiscount: priceAfterDiscount,
          variantIds: variantIds,
          addonIds: addonIds,
          dishTypeId: dishTypeId,
          typeOfMenuId: typeOfMenuId,
          menuCategoryId: menuCategoryId,
          available: available,
          stockConsumptions: stockConsumptions,
        ),
      );
      final raw = response.data['data'];
      if (raw is Map<String, dynamic>) return Dish.fromJson(raw);

      // Same fallback as createDish — the update still succeeded even
      // though the response omitted the entity.
      final dishes = await getDishes();
      final match = dishes.where((d) => d.id == id).toList();
      if (match.isNotEmpty) return match.first;
      throw const ApiException('Dish was updated, but the list could not be refreshed.');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteDish(String id) async {
    try {
      await _dio.delete('${ApiConstants.dishes}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<DishTransaction>> getDishTransactions(String dishId) async {
    try {
      final response = await _dio.get('${ApiConstants.dishes}/$dishId/transactions');
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => DishTransaction.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
