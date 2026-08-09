import 'package:dio/dio.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/dish/dish_model.dart';

abstract class DishRepository {
  Future<List<Dish>> getDishes();

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
}
