class ApiConstants {
  /// Base URL can be configured at compile/run time via:
  /// `flutter run --dart-define=API_BASE_URL=https://your-domain.com`
  /// Defaults to the active server URL.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://inexpugnable-unrepressive-brice.ngrok-free.dev',
  );

  /// Host for resolving relative media upload paths (e.g. `/uploads/xyz.jpg`)
  static String get mediaBaseUrl => baseUrl;

  // --- Auth Endpoints ---
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String healthCheck = '/api/auth/health-check';

  // --- Restaurant Management ---
  static const String restaurant = '/api/restaurant';
  static const String restaurantSettings = '/api/restaurant/settings';
  static const String typeOfRestro = '/api/type-of-restro';
  static const String transferOwnership = '/api/restaurant/transfer-ownership';
  static const String createStaffAccount = '/api/restaurant/create-account';

  // --- Dining & Table Operations ---
  static const String tables = '/api/table';
  static const String areas = '/api/area';
  static const String orders = '/api/order';
  static const String kot = '/api/kot';
  static const String tableOrder = '/api/table-order';
  static const String tableActivity = '/api/table-activity';
  static const String moveTable = '/api/table-order/move-table';
  static const String mergeTable = '/api/table-order/merge-table';

  // --- Menu & Catalog ---
  static const String dishes = '/api/dish';
  static const String menuCategories = '/api/menu-category';
  static const String typeOfMenus = '/api/type-of-menu';
  static const String dishTypes = '/api/dish-type';
  static const String variants = '/api/variant';
  static const String addons = '/api/addons';
  static const String comboOffers = '/api/combo-offer';
  static const String units = '/api/unit';

  // --- Inventory & Stock ---
  static const String stocks = '/api/stock';
  static const String stockGroups = '/api/stock-group';
  static const String suppliers = '/api/supplier';
  static const String supplierTransactions = '/api/supplier-transaction';
  static const String purchaseBills = '/api/purchase-bill';

  // --- Billing, Invoices & Checkout ---
  static const String checkout = '/api/checkout';
  static const String checkoutHistory = '/api/checkout-history';
  static const String myInvoiceSettings = '/api/invoice/my';
  static const String salesTransactions = '/api/sales-transaction';
  static const String paymentMethods = '/api/payment-method';
  static const String expenses = '/api/expenses';
  static const String expenseCategories = '/api/expense-category';

  // --- Customers & Feedback ---
  static const String customers = '/api/customers';
  static const String customerGroups = '/api/customer-group';
  static const String customerComments = '/api/customer-comments';

  // --- Staff & RBAC ---
  static const String staff = '/api/user';
  static const String myProfile = '/api/user/profile';
  static const String roles = '/api/roles';
  static const String routes = '/api/routes';
  static const String rbacAssignRole = '/api/rbac/assign-role';
  static const String rbacAll = '/api/rbac/all';
  static const String rbacBulk = '/api/rbac/bulk';

  // --- SaaS Plans & Subscriptions ---
  static const String plans = '/api/plans';
  static const String planPrices = '/api/plan-prices';
  static const String features = '/api/features';
  static const String planFeatures = '/api/plan-features';
  static const String subscriptionCurrent = '/api/subscriptions/current';
  static const String subscriptionCancel = '/api/subscriptions/cancel';
  static const String billingInvoices = '/api/billing/invoices';
  static const String billingPayments = '/api/billing/payments';

  // --- Analytics & Utilities ---
  static const String dashboardOverview = '/api/dashboard';
  static const String orderDashboard = '/api/dashboard/order';
  static const String financeDashboard = '/api/dashboard/finance';
  static const String notifications = '/api/notification';
  static const String media = '/api/media';

  // --- Networking Timeouts ---
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}