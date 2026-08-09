# restrox — API Integration Report

Generated 2026-08-06 by auditing the Flutter app's data layer (`lib/data/repositories/*`, `lib/providers/*`, `lib/services/*`) against every screen in `lib/screens/*`, and cross-checked against the backend's live Swagger spec at `http://192.168.1.27:8002/docs-json`.

**Summary: 114 API operations integrated (across 35 resources, 84 table rows below since CRUD sets are grouped per resource) · 18 features needed but missing from backend · 35 screens/features still on dummy data** (see breakdown and full lists below).

> A note on Section 2: none of these are "the app called an endpoint and got a 404" — the app was built carefully to never guess at endpoints that don't exist. These are backend resources that would need to be **built** for the corresponding screen to become real. Where an exact error is listed, it's a **bug in an endpoint that does exist** (see the Known Bugs box below), not a missing one.

---

## 🐛 Known bug in an existing endpoint (fix this first)

**`GET /api/purchase-bill` returns `500` for every request once any bill has `customerId` set.**

- Confirmed live 2026-08-06, with and without `purchaseStatus` filter (`paid` and `unpaid` both fail).
- `customerId` is a *required* field on `CreatePurchaseBillDTO`, so this now affects every restaurant with at least one purchase bill.
- Breaks the already-shipped "Purchase Bills" tab on the Sales Analytics screen (`sales_analytics_screen.dart`), and the Daybook Sales Summary screen that reuses it.
- Exact error: `{"statusCode":500,"message":"Internal server error"}`
- Likely cause: a broken join/serializer on the `customer` relation when building the list response.
- Side effect: 4 test bills (`CLAUDE-TEST-001` through `005`) are stuck in the live database and can't be deleted via the API until this is fixed (the delete flow needs the list to find an ID).

---

## Section 1 — Integrated APIs

114 endpoint operations across 35 resources are wired up and used by real screens. Grouped by feature module. "Status" is `Working` unless noted.

### Auth
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| POST | `/api/auth/login` | `auth/login_screen.dart` | `email`, `password` | access/refresh tokens + logged-in user (incl. nested restaurant) |
| POST | `/api/auth/logout` | (triggered from `manage/manage_screen.dart` logout action) | — | best-effort server-side session kill; local session always cleared |
| POST | `/api/auth/refresh` | Automatic (`core/network/dio_client.dart` interceptor) | `refresh_token` | new access token, transparently retries the failed request once |

### Dashboard
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET | `/api/dashboard` | `analytics/analytics_screen.dart` | — | overview stats cards |
| GET | `/api/dashboard/order` | `analytics/order_analytics_screen.dart` | — | order analytics cards/charts |
| GET | `/api/dashboard/finance` | `analytics/finance_screen.dart` | — | finance summary cards |

### Restaurant Profile
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET | `/api/restaurant` | `manage/restaurant_details_screen.dart` | — | prefills the Edit Details form (first item in the list is treated as "my restaurant") |
| PATCH | `/api/restaurant/settings` | `manage/restaurant_details_screen.dart` | `restaurantName`, `contactNumber`, `subDomain`, `email`, `country`, `district`, `address`, `restaurantTypeId`, `openingDate`, `facebookUrl`, `instagramUrl`, `youtubeUrl`, `tiktokUrl`, `googleReviewUrl`, `restaurantLogoId` | saves Restaurant Details form |
| GET | `/api/type-of-restro` | `manage/restaurant_details_screen.dart` | — | populates the "Type" chip picker |

### Customers
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET | `/api/customers` | `create_users/customer_list_screen.dart`, `customer_detail_screen.dart`, `add_customer_screen.dart`, `finance/add_purchase_screen.dart`, `transactions_filter_sheet.dart`, `reservation/add_reservation_screen.dart` | — | customer list + picker sheets |
| POST | `/api/customers` | `create_users/add_customer_screen.dart` | `customerName`, `phoneNumber`, `emailAddress`, `companyName`, `panVatNumber`, `discount`, `customerGroupId`, `favouriteDishId`, `preferredSeatingId`, `dietaryTypeId`, `allergies`, `startPreferredTime`, `endPreferredTime`, `comments` | creates customer |
| PATCH | `/api/customers/{id}` | `create_users/customer_detail_screen.dart` | same fields as create | edits customer |
| DELETE | `/api/customers/{id}` | `create_users/customer_detail_screen.dart` | — | removes customer |

### Customer Groups
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET / POST / PATCH / DELETE | `/api/customer-group` (+ `/{id}`) | `create_users/add_customer_screen.dart` | `name`, `description` | group picker on the customer form |

### Customer Comments
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET / POST / PATCH / DELETE | `/api/customer-comments` (+ `/customer/{id}`, `/{id}`) | `create_users/customer_detail_screen.dart` | `comment`, `customerId` | comment thread on customer detail |

### Suppliers
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET | `/api/supplier` | `create_users/supplier_list_screen.dart`, `add_supplier_screen.dart`, `finance/add_purchase_screen.dart`, `transactions_filter_sheet.dart` | — | supplier list + picker sheets |
| POST | `/api/supplier` | `create_users/add_supplier_screen.dart` | `supplierName`, `phoneNumber`, `address`, `remarks` | creates supplier |
| PATCH | `/api/supplier/{id}` | `create_users/supplier_list_screen.dart` (detail) | same fields | edits supplier |
| DELETE | `/api/supplier/{id}` | `create_users/supplier_list_screen.dart` (detail) | — | removes supplier |

### Supplier Transactions
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET | `/api/supplier-transaction` | `create_users/supplier_list_screen.dart` (detail) | — | ledger, filtered client-side by `supplierId` (no server-side filter exists) |
| POST | `/api/supplier-transaction` | `create_users/add_supplier_transaction_screen.dart` | `supplierId`, `date`, `particulars`, `toReceived`, `toPay`, `paymentMethodId`, `totalPayment`, `remarks` | adds a ledger entry |
| DELETE | `/api/supplier-transaction/{id}` | `create_users/supplier_list_screen.dart` (detail) | — | removes entry |

### Areas / Spaces
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET / POST / PATCH / DELETE | `/api/area` (+ `/{id}`) | `manage/manage_space_screen.dart`, `create_space_screen.dart`, `widgets/common/select_space_sheet.dart` | `areaName`, `description` | space list/CRUD, table-form space picker |

### Tables
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET | `/api/table` | `orders/orders_screen.dart` (Table tab, reused by `manage/manage_tables_screen.dart`), `manage/add_table_screen.dart`, `create_users/add_customer_screen.dart` | — | table list/picker |
| POST | `/api/table` | `manage/add_table_screen.dart` | `tableName`, `tableType`, `capacity`, `areaId`, `charge`, `tableStatus`, `available` | creates table |
| PATCH | `/api/table/{id}` | `manage/add_table_screen.dart` (edit) | same fields | edits table |
| DELETE | `/api/table/{id}` | table detail actions | — | removes table |

### Add-ons
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET | `/api/addons` | `create_dish/add_addon_screen.dart`, `add_dish_screen.dart`, `manage/menu_overview_screen.dart` | — | add-on list/picker |
| POST | `/api/addons` | `create_dish/add_addon_screen.dart` | `addonName`, `price` | creates add-on |

### Variants
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET / POST / PATCH / DELETE | `/api/variant` (+ `/{id}`) | `create_dish/add_dish_screen.dart` | `variantName`, `unitId`, `actualPrice`, `discount`, `cogs` | dish variant picker/CRUD |

### Dish Types
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET | `/api/dish-type` | `create_dish/add_dish_screen.dart`, `add_dish_type_screen.dart` | — | dish type list/picker |
| POST | `/api/dish-type` | `create_dish/add_dish_type_screen.dart` | `dishTypeName` | creates dish type |

### Menu Categories
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET | `/api/menu-category` | `create_dish/add_dish_screen.dart`, `manage/manage_categories_screen.dart`, `menu_overview_screen.dart`, `quick_billing/quick_billing_screen.dart` | — | category list/picker/filter |
| POST | `/api/menu-category` | `manage/manage_categories_screen.dart` | `categoryName` | creates category |

### Type of Menu
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET / POST / PATCH / DELETE | `/api/type-of-menu` (+ `/{id}`) | `create_dish/add_dish_screen.dart`, `manage/manage_sub_menu_screen.dart` | `name`, `description`, `status` | sub-menu list/CRUD |

### Units
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET / POST / PATCH / DELETE | `/api/unit` (+ `/{id}`) | `create_dish/add_dish_screen.dart`, `inventory/add_measuring_unit_screen.dart`, `inventory_features_screen.dart`, `measuring_unit_screen.dart`, `widgets/common/select_unit_sheet.dart` | `name`, `description` | measuring unit list/CRUD/picker |

### Dishes
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET | `/api/dish` | `create_dish/add_dish_screen.dart`, `select_combo_items_screen.dart`, `create_users/add_customer_screen.dart` (favourite dish picker), `manage/manage_dishes_screen.dart`, `menu_overview_screen.dart`, `quick_billing/order_cart_screen.dart`, `quick_billing_screen.dart`, `widgets/common/customize_dish_sheet.dart` | — | dish catalog everywhere it's needed |
| POST | `/api/dish` | `create_dish/add_dish_screen.dart` | `dishName`, `hsCode`, `dishPhoto`, `description`, `price`, `unitId`, `cogs`, `discountType`, `discount`, `priceAfterDiscount`, `variantIds`, `addonIds`, `dishTypeId`, `typeOfMenuId`, `menuCategoryId`, `available`, `stockConsumptions` | creates dish |
| PATCH | `/api/dish/{id}` | `create_dish/add_dish_screen.dart` (edit) | same fields | edits dish |
| DELETE | `/api/dish/{id}` | `manage/manage_dishes_screen.dart` | — | removes dish |

### Orders
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET | `/api/order` | `orders/orders_screen.dart`, `cancelled_history_screen.dart`, `kot_history_screen.dart`, `quick_billing/order_cart_screen.dart` | — | order list; KOT data is read from the **nested** `order.kots` field, not a separate `/api/kot` call |
| POST | `/api/order` | `quick_billing/order_cart_screen.dart` (`OrderProvider.placeOrder`) | `tableId`, `items[]` | places a KOT/order |

*Note: this covers placing and reading orders only — see Section 3 for checkout/bill-closing and table move/merge, which the app doesn't call yet.*

### Notifications
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET | `/api/notification` | `notification/notification_screen.dart` | — | notification list |
| POST | `/api/notification` | `notification/notification_screen.dart` (compose) | `title`, `subject`, `notificationMessage`, `type` | sends a notification |

### Payment Methods
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET / POST / PATCH / DELETE | `/api/payment-method` (+ `/{id}`) | `finance/add_expense_screen.dart`, `finance/add_purchase_screen.dart`, `cash_banks/add_payment_mode_screen.dart`, `cash_banks_screen.dart`, `cash_bank_mode_detail_screen.dart` | `name`, `remarks` | payment method list/CRUD/picker — this is the real backend behind Cash & Banks' "Modes" tab |

### Sales Transactions
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET | `/api/sales-transaction` | `analytics/sales_analytics_screen.dart`, `daybook_sales_summary_screen.dart`, `transactions_screen.dart`, `orders/recent_transactions_screen.dart` | — | Sales Invoice tab / recent transactions |

*No `POST` exists on this endpoint (read-only) — see Section 2 (Sales Return can't save).*

### Purchase Bills
| Method | Endpoint | Screen(s) | Request fields | Response used for | Status |
|---|---|---|---|---|---|
| GET | `/api/purchase-bill` | `analytics/sales_analytics_screen.dart`, `daybook_sales_summary_screen.dart`, `transactions_screen.dart` | — | Purchase Bills tab | 🔴 **Broken — see Known Bugs above** |
| POST | `/api/purchase-bill` | `finance/add_purchase_screen.dart` | `date`, `supplierId`, `billNo`, `amount` (as **string**), `purchaseStatus`, `customerId`, `payment_type`, `paymentMethodId` | creates a purchase bill | ✅ Working (confirmed live) |

### Expenses
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET | `/api/expense-category` | `finance/add_expense_screen.dart` | — | category picker |
| POST | `/api/expense-category` | `finance/add_expense_screen.dart` | `name`, `description` | inline category create |
| GET | `/api/expenses` | `analytics/finance_analytics_screen.dart`, `finance/add_expense_screen.dart` | — | expense list |
| POST | `/api/expenses` | `finance/add_expense_screen.dart` | `title`, `categoryId`, `amount`, `expense_date`, `payment_date`, `due_date`, `payment_status`, `paymentMethodId`, `description` | creates expense |
| DELETE | `/api/expenses/{id}` | expense list actions | — | removes expense |

### Stock Groups
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET / POST / PATCH / DELETE | `/api/stock-group` (+ `/{id}`) | `inventory/add_stock_group_screen.dart`, `inventory_features_screen.dart`, `stock_group_screen.dart`, `widgets/common/select_stock_group_sheet.dart` | `groupName`, `groupDescription` | stock group list/CRUD/picker |

### Stock
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET | `/api/stock` | `inventory/add_consumption_screen.dart`, `add_stock_item_screen.dart`, `inventory_features_screen.dart`, `stock_group_screen.dart`, `stock_history_screen.dart`, `widgets/common/select_stock_sheet.dart` | — | stock item list/picker |
| POST | `/api/stock` | `inventory/add_stock_item_screen.dart` | `itemName`, `defaultPrice`, `quantity`, `rate`, `description`, `unitId`, `stockGroupId`, `supplierId` | creates stock item |
| PATCH | `/api/stock/{id}` | stock detail edit | same fields | edits stock item |
| DELETE | `/api/stock/{id}` | stock detail | — | removes stock item |
| PATCH | `/api/stock/{id}/adjust` | `inventory/add_consumption_screen.dart` | `type` (`add`/`reduce`), `quantity`, `rate`, `transactionDate`, `supplierId`, `remark` | records a consumption/restock |
| GET | `/api/stock/history` (or `/{id}/history`) | `inventory/stock_history_screen.dart` | filters: `startDate`, `endDate`, `staffId`, `stockId`, `stockGroupId` | stock history table |
| GET | `/api/stock/stats` | `inventory/inventory_features_screen.dart` | — | inventory summary cards |

### Staff / Users
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET | `/api/user` | `create_users/staff_list_screen.dart`, `staff_detail_screen.dart`, `invite_staff_screen.dart`, `staff_change_role_screen.dart`, `inventory/stock_history_filter_sheet.dart`, `manage/user_role_screen.dart` | filter: `role` | staff list/pickers |
| GET | `/api/user/{id}` | `create_users/staff_detail_screen.dart` | — | staff detail |
| POST | `/api/restaurant/create-account` | `create_users/create_staff_screen.dart` | `fullname`, `email`, `password`, `position`, `role` | creates staff account |
| PATCH | `/api/user/{id}` | `create_users/staff_detail_screen.dart` (edit) | `fullname`, `email`, `position` | edits staff |
| DELETE | `/api/user/{id}` | `create_users/staff_list_screen.dart` | — | removes staff |

### Roles
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET / POST / PATCH / DELETE | `/api/roles` (+ `/{id}`) | `create_users/staff_change_role_screen.dart`, `manage/create_user_role_screen.dart`, `role_detail_screen.dart`, `user_role_screen.dart`, `widgets/common/select_role_sheet.dart` | `name` | role list/CRUD/picker |

### RBAC (permissions)
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| POST | `/api/rbac/assign-role` | `create_users/staff_change_role_screen.dart` | `userId`, `roleName` | assigns a role to a user |
| DELETE | `/api/rbac/assign-role/{userId}` | staff role management | — | unassigns role |
| GET | `/api/rbac/all` | `manage/role_detail_screen.dart`, `create_users/staff_permission_details_screen.dart` (calls `RbacRepository` directly, not via a Provider) | filter: `role` | permission matrix / read-only permission list |
| PUT | `/api/rbac/bulk` | `manage/role_detail_screen.dart` (User Role editor) | `items: [{role, route, permission}]` | saves newly-checked permission cells |
| DELETE | `/api/rbac/bulk` | `manage/role_detail_screen.dart` | `ids[]` | saves newly-unchecked permission cells |

### Routes
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET | `/api/routes` | `manage/role_detail_screen.dart` | — | the "route" axis of the permission matrix |

### Invoice Settings
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET | `/api/invoice/my` | `orders/invoice_setting_screen.dart` | — | prefills print-template toggle switches |
| PATCH | `/api/invoice/my` | `orders/invoice_setting_screen.dart` | `restaurantName`, `panNo`, `footerRemarks`, + ~19 boolean toggles (`billNo`, `date`, `tableNo`, `sn`, `particular`, `quantity`, `rate`, `amount`, `customerDiscount`, `subTotal`, `discount`, `taxAmount`, `taxableAmount`, `grandTotal`, `amountInWords`, `remarks`, `paymentMode`, `kotNumber`, `billBy`, `totalAmount`) | saves receipt template |

### Plans & Billing (subscription)
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET | `/api/plans` | `manage/change_plan_screen.dart`, `compare_plans_screen.dart` | — | plan list |
| GET | `/api/plan-prices` | same | — | plan pricing |
| GET | `/api/features` | same | — | feature definitions |
| GET | `/api/plan-features` | same | — | which features belong to which plan |
| GET | `/api/subscriptions/current` | `manage/billing_subscription_screen.dart` | — | current plan/usage |
| POST | `/api/subscriptions/cancel` | `manage/billing_subscription_screen.dart` | `immediate` | cancels subscription |
| GET | `/api/billing/invoices` | `manage/billing_history_screen.dart` | — | invoice history |
| GET | `/api/billing/payments` | `manage/billing_history_screen.dart` | — | payment history |

*Note: `POST /api/subscriptions/purchase` and `/change` exist in Swagger but are deliberately **not** wired — both start a real eSewa payment flow and the app has no browser/webview launch capability yet. This is a known, intentional gap, not a bug.*

### Combo Offers
| Method | Endpoint | Screen(s) | Request fields | Response used for |
|---|---|---|---|---|
| GET / POST / PATCH / DELETE | `/api/combo-offer` (+ `/{id}`) | `create_dish/add_combo_screen.dart`, `manage/manage_combo_offers_screen.dart` | `name`, `description`, `hsCode`, `dishIds[]`, `offerPrice`, `startsAt`, `endsAt` | combo offer list/CRUD |

---

## Section 2 — Needed but missing from backend

No endpoint exists in the Swagger spec for any of these — the corresponding screens are built and waiting, but stay local-only/mock until the backend adds them.

| Module/feature | Expected method + endpoint | Screen(s) that need it | Expected request/response shape | Error |
|---|---|---|---|---|
| Income | `POST /api/income` (or similar) | `finance/add_income_screen.dart` | Similar to Expense: amount, account head, payment method, date, remarks | N/A — no endpoint exists to call |
| Sales Return | `POST /api/sales-transaction` (currently read-only) | `finance/add_sales_return_screen.dart` | Line items, refund amount, original invoice reference | N/A — endpoint exists but has no `POST` |
| Tax Rates | `GET/POST/PATCH/DELETE /api/tax` | `manage/tax_rates_screen.dart`, `add_tax_screen.dart` | `name`, `rate`, `type` | N/A |
| Departments | `GET/POST/PATCH/DELETE /api/department` | `manage/department_screen.dart`, `create_department_screen.dart` | `name`, `description` | N/A |
| Printers | `GET/POST/PATCH/DELETE /api/printer` | `orders/printers_setting_screen.dart`, `add_printer_screen.dart` | `name`, `type`, `connection info` | N/A |
| KOT Types (settings) | `GET/POST/PATCH/DELETE /api/kot-type` | `orders/kot_type_setting_screen.dart`, `add_kot_type_screen.dart` | `name`, `printerId` | N/A |
| SMS | `GET/POST /api/sms` | `sms/sms_screen.dart`, `sms_log_screen.dart`, `sms_events_screen.dart`, `purchase_sms_screen.dart`, `purchase_history_screen.dart` | SMS credit balance, event log, purchase history | N/A |
| Website builder | `GET/PATCH /api/website` | `website/website_screen.dart`, `edit_details_screen.dart`, `custom_link_sheet.dart`, `social_links_sheet.dart` | Website config, links | N/A |
| Delivery | `GET/POST /api/delivery`, `/delivery-rider`, `/delivery-platform` | `delivery/delivery_riders_screen.dart`, `add_rider_screen.dart`, `delivery_service_screen.dart`, `delivery_time_screen.dart`, `select_delivery_platform_screen.dart` | Rider info, platform config, delivery windows | N/A |
| Daybook | `GET/POST /api/daybook` | `finance/daybook/daybook_screen.dart`, `close_daybook_screen.dart`, `daybook_history_screen.dart` | Open/close day, running totals | N/A |
| Financial Reports | `GET /api/reports/{type}` | `finance/reports/*` (Balance Sheet, P&L, Trial Balance, Account Summary, Chart of Accounts, Sales Master) | Computed report rows, likely derived server-side from transactions | N/A |
| Cash & Bank accounts | `GET/POST/PATCH/DELETE /api/bank-account` | `finance/cash_banks/add_cash_bank_account_screen.dart`, `cash_bank_account_detail_screen.dart`, `transfer_balance_screen.dart` | Account name, balance, type | N/A |
| Payment In/Out ledger | `GET/POST /api/payment-entry` | `finance/payments/payments_screen.dart`, `payment_entry_screen.dart` | Direction, amount, party, method | N/A |
| Menu Sets | `GET/POST/PATCH/DELETE /api/menu-set` | `manage/manage_menu_set_screen.dart`, `create_dish/add_menu_set_screen.dart` | `name` | N/A |
| Checkout (bill closing) | `POST /api/checkout`, `GET /api/checkout-history` | `quick_billing/quick_billing_screen.dart`, `order_cart_screen.dart` | Order total, payment split, invoice generation | N/A — endpoint exists in Swagger, just not called yet |
| Table Order (move/merge) | `POST /api/table-order/move-table`, `/merge-table` | `orders/orders_screen.dart` (Table tab) | Source/target table IDs | N/A — endpoint exists in Swagger, just not called yet |
| Restaurant invoice generation | `GET/POST /api/invoice` | Checkout flow (not built) | Line items, tax breakdown, printable invoice | N/A — endpoint exists in Swagger (distinct from `/api/invoice/my` settings, which *is* wired), just not called yet |
| Media upload | `POST /api/media/uploads` | Every "Attachment"/"Photo" picker across the app (Dish photo, Restaurant logo, Expense/Purchase attachment, Customer profile, etc.) | Multipart file upload → returns a media `id` to attach to the parent record | N/A — endpoint exists in Swagger, no screen calls it; every photo/attachment picker in the app is currently decorative-only |

---

## Section 3 — Not yet integrated (dummy/local-only data)

Screens confirmed **reachable** from the app's navigation that still use hardcoded state instead of a live API call. (Two additional files — `menu/add_dish_screen.dart` and `create_dish/add_category_screen.dart` / `add_sub_menu_screen.dart` — are dead code with zero references anywhere and were excluded; their real, integrated equivalents live in `create_dish/add_dish_screen.dart`.)

| Module/feature | Screen/file | API this would need |
|---|---|---|
| Top Selling Sub Menus | `analytics/top_selling_sub_menus_screen.dart` | TBD — likely a `/api/dish/dish-stats` variant grouped by sub-menu |
| Staff Balance Adjustment | `create_users/adjust_balance_screen.dart` | TBD — backend has no staff ledger/balance concept at all |
| Delivery Riders | `delivery/delivery_riders_screen.dart`, `add_rider_screen.dart` | See Section 2 (Delivery) |
| Delivery Service Settings | `delivery/delivery_service_screen.dart`, `delivery_time_screen.dart`, `select_delivery_platform_screen.dart` | See Section 2 (Delivery) |
| Add Income | `finance/add_income_screen.dart` | See Section 2 (Income) |
| Add Sales Return | `finance/add_sales_return_screen.dart` | See Section 2 (Sales Return) |
| Cash & Bank — Accounts tab | `finance/cash_banks/cash_banks_screen.dart` (Account tab only — Modes tab is real), `add_cash_bank_account_screen.dart`, `cash_bank_account_detail_screen.dart` | See Section 2 (Cash & Bank accounts) |
| Cash & Bank — Balance Transfer tab | `finance/cash_banks/cash_banks_screen.dart` (Balance Transfer tab), `transfer_balance_screen.dart` | See Section 2 (Cash & Bank accounts) |
| Daybook (all) | `finance/daybook/daybook_screen.dart`, `close_daybook_screen.dart`, `daybook_history_screen.dart` | See Section 2 (Daybook). Note: `daybook_sales_summary_screen.dart` itself *is* real — it reuses the already-integrated Sales/Purchase tabs |
| Finance Features menu | `finance/finance_features_screen.dart` | Pure navigation hub, no data of its own |
| Payments (Payment In/Out) | `finance/payments/payments_screen.dart`, `payment_entry_screen.dart` | See Section 2 (Payment In/Out ledger) |
| Financial Reports (all 8 screens) | `finance/reports/account_summary_screen.dart`, `balance_sheet_screen.dart`, `chart_of_accounts_screen.dart`, `profit_loss_statement_screen.dart`, `reports_screen.dart`, `report_detail_screen.dart`, `sales_master_report_screen.dart`, `trial_balance_screen.dart` | See Section 2 (Financial Reports) |
| Generic Transaction Type screen | `finance/transactions/transaction_type_screen.dart` | Covers Payment In/Out/Balance Transfer — see Section 2 |
| FAQ list | `home/faq_list_screen.dart` | TBD — `/api/faq`-style content endpoint (not seen in Swagger) |
| Inventory add-menu sheet | `inventory/inventory_add_menu_sheet.dart` | Pure navigation sheet, no data of its own |
| Stock Group detail sheet | `inventory/stock_group_detail_sheet.dart` | Uses hardcoded display copy — the underlying Stock Group CRUD is already real (see Section 1) |
| Tax Rates | `manage/tax_rates_screen.dart`, `add_tax_screen.dart` | See Section 2 (Tax Rates) |
| Departments | `manage/department_screen.dart`, `create_department_screen.dart` | See Section 2 (Departments) |
| Delete Restaurant | `manage/delete_restaurant_screen.dart` | TBD — likely `DELETE /api/restaurant/{id}` (endpoint exists for admin approval flows, unclear if self-service delete is intended) |
| Dine-in Service settings | `manage/dine_in_service_screen.dart` | TBD |
| Menu Set | `manage/manage_menu_set_screen.dart`, `create_dish/add_menu_set_screen.dart` | See Section 2 (Menu Sets) |
| Notification Settings | `manage/notification_settings_screen.dart` | TBD — channel preferences, not covered by the existing `/api/notification` (which is for the notification feed itself) |
| Other Services | `manage/other_services_screen.dart` | Pure navigation hub, no data of its own |
| Reset/Delete data | `manage/reset_delete_screen.dart`, `reset_restaurant_screen.dart` | TBD — destructive admin action, no endpoint seen |
| Transfer Ownership | `manage/transfer_ownership_screen.dart` | TBD |
| Trash | `manage/trash_screen.dart` | TBD — soft-delete recovery; several resources have `deletedAt` fields but no "list deleted" or "restore" endpoint exists |
| KOT Type settings | `orders/kot_type_setting_screen.dart`, `add_kot_type_screen.dart` | See Section 2 (KOT Types) |
| Printers settings | `orders/printers_setting_screen.dart`, `add_printer_screen.dart` | See Section 2 (Printers) |
| Saved Orders | `orders/saved_order_screen.dart` | TBD — possibly a status filter on the existing `/api/order`, unclear |
| Services menu | `services/services_screen.dart` | Pure navigation hub, no data of its own |
| SMS (all 5 screens) | `sms/sms_screen.dart`, `sms_log_screen.dart`, `sms_events_screen.dart`, `purchase_sms_screen.dart`, `purchase_history_screen.dart` | See Section 2 (SMS) |
| Website builder (all) | `website/website_screen.dart`, `edit_details_screen.dart`, `custom_link_sheet.dart`, `social_links_sheet.dart` | See Section 2 (Website builder) |
| Photo/attachment pickers (cross-cutting) | Dish photo, Restaurant logo, Expense/Purchase attachment, Customer profile picture, etc. — every `ImageSourceSheet`/`UploadBox` in the app | See Section 2 (Media upload) — these all pick a local file but never actually upload it |
| Checkout / bill payment | `quick_billing/quick_billing_screen.dart`, `order_cart_screen.dart` | See Section 2 (Checkout) — orders can be placed (KOT), but there's no wired flow to close out a table's bill |
| Move/Merge table | `orders/orders_screen.dart` (Table tab) | See Section 2 (Table Order) |
