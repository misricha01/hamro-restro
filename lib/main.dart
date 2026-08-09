import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/dio_client.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/addon_repository.dart';
import 'data/repositories/area_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/checkout_repository.dart';
import 'data/repositories/customer_comment_repository.dart';
import 'data/repositories/customer_group_repository.dart';
import 'data/repositories/combo_offer_repository.dart';
import 'data/repositories/customer_repository.dart';
import 'data/repositories/dashboard_repository.dart';
import 'data/repositories/dish_repository.dart';
import 'data/repositories/dish_type_repository.dart';
import 'data/repositories/expense_category_repository.dart';
import 'data/repositories/expense_repository.dart';
import 'data/repositories/finance_repository.dart';
import 'data/repositories/invoice_settings_repository.dart';
import 'data/repositories/media_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/order_analytics_repository.dart';
import 'data/repositories/order_repository.dart';
import 'data/repositories/payment_method_repository.dart';
import 'data/repositories/plan_repository.dart';
import 'data/repositories/purchase_bill_repository.dart';
import 'data/repositories/rbac_repository.dart';
import 'data/repositories/role_repository.dart';
import 'data/repositories/route_repository.dart';
import 'data/repositories/sales_transaction_repository.dart';
import 'data/repositories/staff_repository.dart';
import 'data/repositories/subscription_repository.dart';
import 'data/repositories/stock_group_repository.dart';
import 'data/repositories/stock_repository.dart';
import 'data/repositories/supplier_repository.dart';
import 'data/repositories/supplier_transaction_repository.dart';
import 'data/repositories/table_repository.dart';
import 'data/repositories/type_of_menu_repository.dart';
import 'data/repositories/unit_repository.dart';
import 'data/repositories/variant_repository.dart';
import 'navigation/app_gate.dart';
import 'providers/addon_provider.dart';
import 'providers/area_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/category_provider.dart';
import 'providers/checkout_provider.dart';
import 'providers/combo_offer_provider.dart';
import 'providers/customer_comment_provider.dart';
import 'providers/customer_group_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/dish_provider.dart';
import 'providers/dish_type_provider.dart';
import 'providers/expense_category_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/finance_provider.dart';
import 'providers/invoice_settings_provider.dart';
import 'providers/media_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/order_analytics_provider.dart';
import 'providers/order_provider.dart';
import 'providers/payment_method_provider.dart';
import 'providers/plan_provider.dart';
import 'providers/purchase_bill_provider.dart';
import 'providers/role_provider.dart';
import 'providers/route_provider.dart';
import 'providers/sales_transaction_provider.dart';
import 'providers/staff_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/stock_group_provider.dart';
import 'providers/stock_provider.dart';
import 'providers/supplier_provider.dart';
import 'providers/supplier_transaction_provider.dart';
import 'providers/table_provider.dart';
import 'providers/type_of_menu_provider.dart';
import 'providers/unit_provider.dart';
import 'providers/variant_provider.dart';

void main() {
  final dioClient = DioClient();
  runApp(RestroXApp(dioClient: dioClient));
}

class RestroXApp extends StatelessWidget {
  final DioClient dioClient;

  const RestroXApp({super.key, required this.dioClient});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Shared Dio instance — every future module's repository should be
        // built with this, not a fresh DioClient(), so the token-refresh
        // interceptor and auth header stay consistent app-wide.
        Provider<DioClient>.value(value: dioClient),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) {
          final authProvider = AuthProvider(repository: AuthRepositoryImpl(dioClient: dioClient));
          dioClient.onUnauthenticated = authProvider.forceLogout;
          return authProvider;
        }),
        ChangeNotifierProvider(create: (_) => OrderProvider(repository: OrderRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => CheckoutProvider(repository: CheckoutRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => TableProvider(repository: TableRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => AreaProvider(repository: AreaRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => CategoryProvider(repository: CategoryRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => CustomerProvider(repository: CustomerRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => AddOnProvider(repository: AddOnRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => DishTypeProvider(repository: DishTypeRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => DishProvider(repository: DishRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => DashboardProvider(repository: DashboardRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => FinanceProvider(repository: FinanceRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => OrderAnalyticsProvider(repository: OrderAnalyticsRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => SalesTransactionProvider(repository: SalesTransactionRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => PurchaseBillProvider(repository: PurchaseBillRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => SupplierProvider(repository: SupplierRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => UnitProvider(repository: UnitRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => NotificationProvider(repository: NotificationRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => MediaProvider(repository: MediaRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => StockGroupProvider(repository: StockGroupRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => StockProvider(repository: StockRepositoryImpl(dioClient: dioClient))),
        Provider<RbacRepository>.value(value: RbacRepositoryImpl(dioClient: dioClient)),
        ChangeNotifierProvider(
          create: (_) => StaffProvider(
            repository: StaffRepositoryImpl(dioClient: dioClient),
            rbacRepository: RbacRepositoryImpl(dioClient: dioClient),
          ),
        ),
        ChangeNotifierProvider(create: (_) => RoleProvider(repository: RoleRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => PaymentMethodProvider(repository: PaymentMethodRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => CustomerGroupProvider(repository: CustomerGroupRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => CustomerCommentProvider(repository: CustomerCommentRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => ComboOfferProvider(repository: ComboOfferRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => VariantProvider(repository: VariantRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => TypeOfMenuProvider(repository: TypeOfMenuRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => RouteProvider(repository: RouteRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => InvoiceSettingsProvider(repository: InvoiceSettingsRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => PlanProvider(repository: PlanRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider(repository: SubscriptionRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => ExpenseCategoryProvider(repository: ExpenseCategoryRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => ExpenseProvider(repository: ExpenseRepositoryImpl(dioClient: dioClient))),
        ChangeNotifierProvider(create: (_) => SupplierTransactionProvider(repository: SupplierTransactionRepositoryImpl(dioClient: dioClient))),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Hamro Restro',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AppGate(),
          );
        },
      ),
    );
  }
}
