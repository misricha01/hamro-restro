**# restrox — Full API Integration Report

Generated 2026-08-06. This supersedes `API_DOCUMENTATION.md` (kept for reference) with stricter verification: every row below was checked **repository → provider → actual call site in a screen**, not just "the screen imports the provider." Several methods exist in a repository/provider but are **never called by any screen** — these are called out explicitly as "not wired to UI" rather than counted as integrated.

Swagger source: `http://192.168.1.27:8002/docs-json` (252 total operations). Flutter source: `lib/data/repositories/*`, `lib/providers/*`, `lib/services/restaurant_service.dart`, `lib/screens/*`.

---

# 1. CRUD Integration Status

✅ = called from a screen and confirmed working live (or by code inspection) · ⚠️ = repository/provider method exists but no screen calls it (UI stub or missing) · ❌ = no repository method / no endpoint at all

### Auth
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Auth | Login | ❌ | ✅ POST /api/auth/login | ❌ | ❌ | Integrated |
| Auth | (any screen, automatic) | ❌ | ✅ POST /api/auth/refresh (on 401, via Dio interceptor) | ❌ | ❌ | Integrated |
| Auth | Manage > Logout action | ❌ | ✅ POST /api/auth/logout | ❌ | ❌ | Integrated |

### Dashboard / Analytics
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Dashboard | Analytics Overview | ✅ GET /api/dashboard | ❌ | ❌ | ❌ | Integrated (read-only) |
| Dashboard | Order Analytics | ✅ GET /api/dashboard/order | ❌ | ❌ | ❌ | Integrated (read-only) |
| Dashboard | Finance Analytics | ✅ GET /api/dashboard/finance | ❌ | ❌ | ❌ | Integrated (read-only) |

### Restaurant Profile
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Restaurant | Restaurant Details (Edit Details) | ✅ GET /api/restaurant, GET /api/type-of-restro | ❌ | ✅ PATCH /api/restaurant/settings | ❌ | Integrated |

### Customers
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Customers | Customer List | ✅ GET /api/customers | ❌ | ❌ | ❌ | Integrated (read-only) |
| Customers | Add Customer | GET customer groups | ✅ POST /api/customers, POST /api/customer-group (inline create) | ❌ | ❌ | Integrated |
| Customers | Customer Detail | ✅ GET (from list) | ❌ | ⚠️ PATCH /api/customers/{id} — method exists (`CustomerProvider.updateCustomer`) but **no Edit button/flow calls it** | ✅ DELETE /api/customers/{id} | Partially Integrated |
| Customers | Customer Detail — Comments tab | ✅ GET /api/customer-comments/customer/{id} | ✅ POST /api/customer-comments | ✅ PATCH /api/customer-comments/{id} | ✅ DELETE /api/customer-comments/{id} | Fully Integrated |
| Customers | Customer Detail — Transactions/Invoice/Credit List tabs | ❌ static placeholders | ❌ | ❌ | ❌ | Dummy (see Section 6) |

### Suppliers
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Suppliers | Supplier List | ✅ GET /api/supplier | ❌ | ❌ | ❌ | Integrated (read-only) |
| Suppliers | Add Supplier | ❌ | ✅ POST /api/supplier | ❌ | ❌ | Integrated |
| Suppliers | Supplier Detail | ✅ GET (from list) | ❌ | ⚠️ PATCH /api/supplier/{id} — method exists (`SupplierProvider.updateSupplier`) but **not called from any screen** | ✅ DELETE /api/supplier/{id} | Partially Integrated |
| Suppliers | Supplier Detail — Transactions | ✅ GET /api/supplier-transaction (client-filtered by supplierId — no server filter exists) | ✅ POST /api/supplier-transaction | ❌ no update UI (endpoint exists in Swagger, repo doesn't expose it) | ✅ DELETE /api/supplier-transaction/{id} | Partially Integrated |

### Areas / Spaces
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Areas | Manage Space | ✅ GET /api/area | ❌ | ❌ | ✅ DELETE /api/area/{id} | Integrated |
| Areas | Create Space | ❌ | ✅ POST /api/area | ✅ PATCH /api/area/{id} | ❌ | Integrated |

### Tables
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Tables | Add Table | ✅ GET /api/table | ✅ POST /api/table | ✅ PATCH /api/table/{id} | ❌ | Integrated |
| Tables | Orders screen (Table tab) | ✅ GET /api/table | ❌ | ❌ | ✅ DELETE /api/table/{id} | Integrated |

### Add-ons
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Add-ons | Add Addon | ✅ GET /api/addons | ✅ POST /api/addons | ❌ no update/delete UI (endpoints exist in Swagger, repo doesn't expose them) | ❌ | Partially Integrated |

### Variants
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Variants | Add Dish (variant picker/creator) | ✅ GET /api/variant | ✅ POST /api/variant | ✅ PATCH /api/variant/{id} | ⚠️ DELETE /api/variant/{id} — method exists (`VariantProvider.deleteVariant`) but **not called from any screen** | Partially Integrated |

### Dish Types
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Dish Types | Add Dish (type picker), Add Dish Type | ✅ GET /api/dish-type | ✅ POST /api/dish-type | ❌ no update/delete UI (endpoints exist in Swagger, repo doesn't expose them) | ❌ | Partially Integrated |

### Menu Categories
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Menu Categories | Manage Categories, Add Dish, Menu Overview, Quick Billing | ✅ GET /api/menu-category | ✅ POST /api/menu-category | ❌ no update/delete UI (endpoints exist in Swagger, repo doesn't expose them) | ❌ | Partially Integrated |

### Type of Menu (Sub Menu)
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Type of Menu | Manage Sub Menu, Add Dish | ✅ GET /api/type-of-menu | ✅ POST /api/type-of-menu | ❌ no update/delete UI (**repo has both, provider exposes neither**) | ❌ | Partially Integrated |

### Units
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Units | Measuring Unit, Add Measuring Unit, Add Dish | ✅ GET /api/unit | ✅ POST /api/unit | ✅ PATCH /api/unit/{id} | ✅ DELETE /api/unit/{id} | Fully Integrated |

### Dishes
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Dishes | Add Dish (create), Manage Dishes, Menu Overview, Quick Billing | ✅ GET /api/dish | ✅ POST /api/dish | ⚠️ PATCH /api/dish/{id} — method exists but **no screen calls it** | ⚠️ DELETE /api/dish/{id} — Manage Dishes has a visible "Edit" **button with a literal `// TODO: Open dish edit flow once available.` stub**; no delete button found either | Partially Integrated |

### Orders / KOT
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Orders | Orders screen, Cancelled History, KOT History | ✅ GET /api/order (KOT read via nested `order.kots`, not `/api/kot`) | ❌ | ❌ | ❌ | Integrated (read-only) |
| Orders | Order Cart (Quick Billing) | ❌ | ✅ POST /api/order (`OrderProvider.placeOrder`) | ❌ | ❌ | Integrated |
| Orders | — (no screen) | ❌ | ❌ | ❌ | ❌ | Checkout/bill-closing not integrated at all — see Section 4 |

### Notifications
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Notifications | Notification screen | ✅ GET /api/notification | ❌ `createNotification` method exists in provider/repo but **no compose UI calls it** | ❌ no read/mark-as-read UI (`PATCH /api/notification/read` exists in Swagger, unused) | ❌ | Partially Integrated |

### Payment Methods
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Payment Methods | Cash & Banks (Modes tab), Add Payment Mode, Mode Detail, Add Expense/Purchase pickers | ✅ GET /api/payment-method | ✅ POST /api/payment-method | ✅ PATCH /api/payment-method/{id} | ✅ DELETE /api/payment-method/{id} | Fully Integrated |

### Sales Transactions
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Sales Transactions | Sales Analytics (Sales Invoice tab), Daybook Sales Summary, Transactions, Recent Transactions | ✅ GET /api/sales-transaction | ❌ no `POST` exists on this endpoint at all | ❌ | ❌ | Integrated (read-only, backend has no write op) |

### Purchase Bills
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Purchase Bills | Sales Analytics (Purchase Bills tab), Daybook Sales Summary, Transactions | 🔴 GET /api/purchase-bill — **500 error, confirmed live** (see Known Bug below) | ❌ | ❌ | ❌ | **Broken** |
| Purchase Bills | Add Purchase | ❌ | ✅ POST /api/purchase-bill — confirmed working live | ❌ no update UI (endpoint exists, repo doesn't expose it) | ❌ | Partially Integrated |

### Expenses
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Expense Categories | Add Expense (category picker) | ✅ GET /api/expense-category | ✅ POST /api/expense-category (inline create) | ❌ no update/delete UI (endpoints exist, repo doesn't expose them) | ❌ | Partially Integrated |
| Expenses | Finance Analytics, Add Expense | ✅ GET /api/expenses | ✅ POST /api/expenses | ❌ no update UI (`PATCH /api/expenses/{id}` exists in Swagger, unused) | ⚠️ DELETE /api/expenses/{id} — method exists in provider but **no delete UI in the expense list** | Partially Integrated |

### Stock Groups
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Stock Groups | Add Stock Group, Inventory Features, Stock Group screen | ✅ GET /api/stock-group, GET /api/stock-group/stats (Inventory Features) | ✅ POST /api/stock-group | ⚠️ PATCH /api/stock-group/{id} — method exists but **not called from any screen** | ⚠️ DELETE /api/stock-group/{id} — method exists but **not called from any screen** | Partially Integrated |

### Stock
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Stock | Add Stock Item, Inventory Features, Stock Group screen | ✅ GET /api/stock | ✅ POST /api/stock | ❌ no update UI (`PATCH /api/stock/{id}` exists in Swagger, provider doesn't expose it) | ⚠️ DELETE /api/stock/{id} — method exists but **not called from any screen** | Partially Integrated |
| Stock | Add Consumption | ❌ | ❌ | ✅ PATCH /api/stock/{id}/adjust | ❌ | Integrated |
| Stock | Stock History | ✅ GET /api/stock/history | ❌ | ❌ | ❌ | Integrated (read-only) |

### Staff / Users
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Staff | Staff List, User Role screen | ✅ GET /api/user/all | ❌ | ❌ | ✅ DELETE /api/user/{id} (Staff List) | Integrated |
| Staff | Staff Detail | ✅ GET /api/user/{id} | ❌ | ❌ | ✅ DELETE /api/user/{id} | Integrated |
| Staff | Create Staff, Invite Staff | ❌ | ✅ POST /api/restaurant/create-account | ✅ PATCH /api/user/{id} (Create Staff, edit mode) | ❌ | Integrated |

### Roles & Permissions
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Roles | User Role screen, Create User Role, Role Detail, Staff Change Role | ✅ GET /api/roles | ✅ POST /api/roles | ✅ PATCH /api/roles/{id} | ✅ DELETE /api/roles/{id} | Fully Integrated |
| RBAC | Staff Change Role | ❌ | ✅ POST /api/rbac/assign-role | ❌ | ⚠️ DELETE /api/rbac/assign-role/{userId} — `unassignRole` method exists in `RbacRepository` but **called from nowhere, not even wrapped by a provider** | Partially Integrated |
| RBAC | Role Detail (permission matrix), Staff Permission Details (direct repo call, no provider) | ✅ GET /api/rbac/all | ❌ | ✅ PUT /api/rbac/bulk | ✅ DELETE /api/rbac/bulk | Integrated |
| Routes | Role Detail (permission matrix axis) | ✅ GET /api/routes | ❌ | ❌ | ❌ | Integrated (read-only) |

### Invoice Settings
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Invoice Settings | Invoice Setting screen | ✅ GET /api/invoice/my | ❌ | ✅ PATCH /api/invoice/my (`saveSettings`) | ❌ | Fully Integrated |

### Plans & Subscription
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Plans | Change Plan, Compare Plans | ✅ GET /api/plans, /api/plan-prices, /api/features, /api/plan-features | ❌ | ❌ | ❌ | Integrated (read-only) |
| Subscription | Billing Subscription | ✅ GET /api/subscriptions/current | ✅ POST /api/subscriptions/cancel | ❌ **intentional** — purchase/change need a webview/payment redirect the app doesn't have yet | ❌ | Partially Integrated (by design) |
| Billing | Billing History | ✅ GET /api/billing/invoices, GET /api/billing/payments | ❌ | ❌ | ❌ | Integrated (read-only) |

### Combo Offers
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Combo Offers | Manage Combo Offers, Add Combo | ✅ GET /api/combo-offer | ✅ POST /api/combo-offer | ❌ **repo has `updateComboOffer`, provider does not expose it — 0% reachable** | ⚠️ **repo + provider both have `deleteComboOffer`, but no screen calls it** | Partially Integrated |

---

# 2. Pending CRUD

Grouped the way you asked — per module, which verbs are missing and why.

**Customers**
- GET ✅
- POST ✅
- PATCH ⚠️ Repo + provider ready (`updateCustomer`), no Edit UI wired
- DELETE ✅

**Suppliers**
- GET ✅
- POST ✅
- PATCH ⚠️ Repo + provider ready (`updateSupplier`), no Edit UI wired
- DELETE ✅

**Supplier Transactions**
- GET ✅
- POST ✅
- PATCH ❌ Not in repo (endpoint exists in Swagger, never implemented client-side)
- DELETE ✅

**Areas**
- GET ✅ POST ✅ PATCH ✅ DELETE ✅ — fully done

**Tables**
- GET ✅ POST ✅ PATCH ✅
- DELETE ✅ (done, but only reachable from Orders screen's Table tab, not from Add Table)

**Add-ons**
- GET ✅ POST ✅
- PATCH ❌ Not in repo
- DELETE ❌ Not in repo

**Variants**
- GET ✅ POST ✅ PATCH ✅
- DELETE ⚠️ Repo + provider ready (`deleteVariant`), no UI wired

**Dish Types**
- GET ✅ POST ✅
- PATCH ❌ Not in repo
- DELETE ❌ Not in repo

**Menu Categories**
- GET ✅ POST ✅
- PATCH ❌ Not in repo
- DELETE ❌ Not in repo

**Type of Menu**
- GET ✅ POST ✅
- PATCH ⚠️ Repo has it, provider doesn't expose it
- DELETE ⚠️ Repo has it, provider doesn't expose it

**Units**
- GET ✅ POST ✅ PATCH ✅ DELETE ✅ — fully done

**Dishes**
- GET ✅ POST ✅
- PATCH ⚠️ Repo + provider ready, no UI wired
- DELETE ⚠️ Repo + provider ready; Manage Dishes has a visible Edit button that's a `TODO` stub, no Delete button seen at all

**Orders**
- GET ✅ POST ✅
- PATCH ❌ Not called (order status update, dish/addon/variant line-item update endpoints all unused)
- DELETE ❌ Not called
- Checkout/bill-closing: ❌ Not integrated (see Section 4)

**Notifications**
- GET ✅
- POST ⚠️ Repo + provider ready (`createNotification`), no compose UI
- PATCH ❌ Not called (`/read` marking)
- DELETE ❌ Not called

**Payment Methods**
- GET ✅ POST ✅ PATCH ✅ DELETE ✅ — fully done

**Purchase Bills**
- GET 🔴 Broken (500 on backend, not a frontend gap)
- POST ✅
- PATCH ❌ Not in repo
- DELETE ❌ Not in repo

**Expense Categories**
- GET ✅ POST ✅
- PATCH ❌ Not in repo
- DELETE ❌ Not in repo

**Expenses**
- GET ✅ POST ✅
- PATCH ❌ Not in repo
- DELETE ⚠️ Repo + provider ready (`deleteExpense`), no delete UI in the list

**Stock Groups**
- GET ✅ POST ✅
- PATCH ⚠️ Repo + provider ready, no UI wired
- DELETE ⚠️ Repo + provider ready, no UI wired

**Stock**
- GET ✅ POST ✅
- PATCH ❌ Not in provider (repo-only)
- DELETE ⚠️ Repo + provider ready, no UI wired
- (Adjust/History/Stats are separate real endpoints, all integrated)

**Staff**
- GET ✅ POST ✅ PATCH ✅ DELETE ✅ — fully done

**Roles**
- GET ✅ POST ✅ PATCH ✅ DELETE ✅ — fully done

**RBAC**
- Assign ✅
- Unassign ⚠️ Repo-only, called from nowhere
- Bulk set/delete ✅

**Combo Offers**
- GET ✅ POST ✅
- PATCH ❌ Repo-only, provider doesn't expose it
- DELETE ⚠️ Repo + provider ready, no UI wired

---

# 3. Screen-wise API Mapping

Only screens that touch (or should touch) an API are listed (53 blocks — one per row in Section 1's CRUD tables, so every module/screen pairing shown there has a matching block here with Repository/Provider added and a single-word Status). Pure navigation/menu screens with zero data of their own are omitted (see Section 6 for the dummy-data screen list).

Status legend: **Fully Integrated** = every verb this screen needs is ✅ · **Partially Integrated** = at least one ⚠️ (repo/provider ready, not wired to UI) or a documented missing piece · **Read-Only (by design)** = screen only ever needs GET, nothing missing.

---

**Module:** Auth
**Screen:** `auth/login_screen.dart`
**GET:** ❌ not needed
**POST:** ✅ POST /api/auth/login
**PATCH:** ❌ not needed
**DELETE:** ❌ not needed
**Repository:** `AuthRepository`
**Provider:** `AuthProvider`
**Status:** Fully Integrated

---

**Module:** Auth
**Screen:** (automatic, no screen — Dio interceptor)
**GET:** ❌
**POST:** ✅ POST /api/auth/refresh (on any 401)
**PATCH:** ❌
**DELETE:** ❌
**Repository:** `AuthRepository` (via `DioClient`)
**Provider:** — (interceptor-level, not provider-level)
**Status:** Fully Integrated

---

**Module:** Auth
**Screen:** `manage/manage_screen.dart` (Logout action)
**GET:** ❌ not needed
**POST:** ✅ POST /api/auth/logout
**PATCH:** ❌ not needed
**DELETE:** ❌ not needed
**Repository:** `AuthRepository`
**Provider:** `AuthProvider`
**Status:** Fully Integrated

---

**Module:** Dashboard
**Screen:** `analytics/analytics_screen.dart`
**GET:** ✅ GET /api/dashboard
**POST:** ❌ not needed
**PATCH:** ❌ not needed
**DELETE:** ❌ not needed
**Repository:** `DashboardRepository`
**Provider:** `DashboardProvider`
**Status:** Read-Only (by design)

---

**Module:** Dashboard
**Screen:** `analytics/order_analytics_screen.dart`
**GET:** ✅ GET /api/dashboard/order
**POST:** ❌ not needed
**PATCH:** ❌ not needed
**DELETE:** ❌ not needed
**Repository:** `OrderAnalyticsRepository`
**Provider:** `OrderAnalyticsProvider`
**Status:** Read-Only (by design)

---

**Module:** Dashboard
**Screen:** `analytics/finance_screen.dart`
**GET:** ✅ GET /api/dashboard/finance
**POST:** ❌ not needed
**PATCH:** ❌ not needed
**DELETE:** ❌ not needed
**Repository:** `FinanceRepository`
**Provider:** `FinanceProvider`
**Status:** Read-Only (by design)

---

**Module:** Restaurant Profile
**Screen:** `manage/restaurant_details_screen.dart`
**GET:** ✅ GET /api/restaurant, GET /api/type-of-restro
**POST:** ❌ not needed
**PATCH:** ✅ PATCH /api/restaurant/settings
**DELETE:** ❌ not needed
**Repository:** — (uses `RestaurantService`, a standalone service class, not the repository pattern used everywhere else)
**Provider:** — (no provider; screen calls `RestaurantService` static methods directly)
**Status:** Fully Integrated

---

**Module:** Customers
**Screen:** `create_users/customer_list_screen.dart`
**GET:** ✅ GET /api/customers
**POST:** ❌ not on this screen
**PATCH:** ❌ not on this screen
**DELETE:** ❌ not on this screen
**Repository:** `CustomerRepository`
**Provider:** `CustomerProvider`
**Status:** Read-Only (by design)

---

**Module:** Customers
**Screen:** `create_users/add_customer_screen.dart`
**GET:** ✅ GET /api/customer-group (picker)
**POST:** ✅ POST /api/customers, POST /api/customer-group (inline create)
**PATCH:** ❌ not on this screen
**DELETE:** ❌ not on this screen
**Repository:** `CustomerRepository`, `CustomerGroupRepository`
**Provider:** `CustomerProvider`, `CustomerGroupProvider`
**Status:** Fully Integrated

---

**Module:** Customers
**Screen:** `create_users/customer_detail_screen.dart` (Profile tab + Delete action)
**GET:** ✅ (customer passed in from list, not re-fetched)
**POST:** ❌ not on this screen
**PATCH:** ⚠️ PATCH /api/customers/{id} — `CustomerProvider.updateCustomer` exists, **no Edit button calls it**
**DELETE:** ✅ DELETE /api/customers/{id}
**Repository:** `CustomerRepository`
**Provider:** `CustomerProvider`
**Status:** Partially Integrated

---

**Module:** Customers
**Screen:** `create_users/customer_detail_screen.dart` (Comments tab)
**GET:** ✅ GET /api/customer-comments/customer/{id}
**POST:** ✅ POST /api/customer-comments
**PATCH:** ✅ PATCH /api/customer-comments/{id}
**DELETE:** ✅ DELETE /api/customer-comments/{id}
**Repository:** `CustomerCommentRepository`
**Provider:** `CustomerCommentProvider`
**Status:** Fully Integrated

---

**Module:** Customers
**Screen:** `create_users/customer_detail_screen.dart` (Transactions/Invoice/Credit List tabs)
**GET:** ❌ static placeholders
**POST:** ❌
**PATCH:** ❌
**DELETE:** ❌
**Repository:** — none
**Provider:** — none
**Status:** Dummy Data (see Section 6)

---

**Module:** Suppliers
**Screen:** `create_users/supplier_list_screen.dart` (list)
**GET:** ✅ GET /api/supplier
**POST:** ❌ not on this screen
**PATCH:** ❌ not on this screen
**DELETE:** ❌ not on this screen
**Repository:** `SupplierRepository`
**Provider:** `SupplierProvider`
**Status:** Read-Only (by design)

---

**Module:** Suppliers
**Screen:** `create_users/add_supplier_screen.dart`
**GET:** ❌ not needed
**POST:** ✅ POST /api/supplier
**PATCH:** ❌ not on this screen
**DELETE:** ❌ not needed
**Repository:** `SupplierRepository`
**Provider:** `SupplierProvider`
**Status:** Fully Integrated

---

**Module:** Suppliers
**Screen:** `create_users/supplier_list_screen.dart` (`SupplierDetailScreen`)
**GET:** ✅ (supplier passed in from list)
**POST:** ❌ not on this screen
**PATCH:** ⚠️ PATCH /api/supplier/{id} — `SupplierProvider.updateSupplier` exists, **not called anywhere**
**DELETE:** ✅ DELETE /api/supplier/{id}
**Repository:** `SupplierRepository`
**Provider:** `SupplierProvider`
**Status:** Partially Integrated

---

**Module:** Suppliers
**Screen:** `create_users/supplier_list_screen.dart` (`SupplierDetailScreen` — Transactions section) + `create_users/add_supplier_transaction_screen.dart`
**GET:** ✅ GET /api/supplier-transaction (client-filtered by supplierId; no server-side filter exists)
**POST:** ✅ POST /api/supplier-transaction
**PATCH:** ❌ `PATCH /api/supplier-transaction/{id}` exists in Swagger, repo never implemented it
**DELETE:** ✅ DELETE /api/supplier-transaction/{id}
**Repository:** `SupplierTransactionRepository`
**Provider:** `SupplierTransactionProvider`
**Status:** Partially Integrated

---

**Module:** Areas / Spaces
**Screen:** `manage/manage_space_screen.dart`
**GET:** ✅ GET /api/area
**POST:** ❌ not on this screen
**PATCH:** ❌ not on this screen
**DELETE:** ✅ DELETE /api/area/{id}
**Repository:** `AreaRepository`
**Provider:** `AreaProvider`
**Status:** Fully Integrated

---

**Module:** Areas / Spaces
**Screen:** `manage/create_space_screen.dart`
**GET:** ❌ not on this screen
**POST:** ✅ POST /api/area
**PATCH:** ✅ PATCH /api/area/{id}
**DELETE:** ❌ not on this screen
**Repository:** `AreaRepository`
**Provider:** `AreaProvider`
**Status:** Fully Integrated

---

**Module:** Tables
**Screen:** `manage/add_table_screen.dart`
**GET:** ✅ GET /api/table
**POST:** ✅ POST /api/table
**PATCH:** ✅ PATCH /api/table/{id}
**DELETE:** ❌ not on this screen (delete only reachable from Orders screen)
**Repository:** `TableRepository`
**Provider:** `TableProvider`
**Status:** Partially Integrated

---

**Module:** Tables
**Screen:** `orders/orders_screen.dart` (Table tab)
**GET:** ✅ GET /api/table
**POST:** ❌ not on this screen
**PATCH:** ❌ not on this screen
**DELETE:** ✅ DELETE /api/table/{id}
**Repository:** `TableRepository`, `OrderRepository`
**Provider:** `TableProvider`, `OrderProvider`
**Status:** Partially Integrated (table move/merge endpoints exist in Swagger, never called — see Section 4)

---

**Module:** Add-ons
**Screen:** `create_dish/add_addon_screen.dart`
**GET:** ✅ GET /api/addons
**POST:** ✅ POST /api/addons
**PATCH:** ❌ not in repo
**DELETE:** ❌ not in repo
**Repository:** `AddOnRepository`
**Provider:** `AddOnProvider`
**Status:** Partially Integrated

---

**Module:** Variants
**Screen:** `create_dish/add_dish_screen.dart` (variant picker/creator)
**GET:** ✅ GET /api/variant
**POST:** ✅ POST /api/variant
**PATCH:** ✅ PATCH /api/variant/{id}
**DELETE:** ⚠️ DELETE /api/variant/{id} — `VariantProvider.deleteVariant` exists, **not called anywhere**
**Repository:** `VariantRepository`
**Provider:** `VariantProvider`
**Status:** Partially Integrated

---

**Module:** Dish Types
**Screen:** `create_dish/add_dish_type_screen.dart` (+ picker in `add_dish_screen.dart`)
**GET:** ✅ GET /api/dish-type
**POST:** ✅ POST /api/dish-type
**PATCH:** ❌ not in repo
**DELETE:** ❌ not in repo
**Repository:** `DishTypeRepository`
**Provider:** `DishTypeProvider`
**Status:** Partially Integrated

---

**Module:** Menu Categories
**Screen:** `manage/manage_categories_screen.dart` (+ pickers in `add_dish_screen.dart`, `menu_overview_screen.dart`, `quick_billing_screen.dart`)
**GET:** ✅ GET /api/menu-category
**POST:** ✅ POST /api/menu-category
**PATCH:** ❌ not in repo
**DELETE:** ❌ not in repo
**Repository:** `CategoryRepository`
**Provider:** `CategoryProvider`
**Status:** Partially Integrated

---

**Module:** Type of Menu
**Screen:** `manage/manage_sub_menu_screen.dart` (+ picker in `add_dish_screen.dart`)
**GET:** ✅ GET /api/type-of-menu
**POST:** ✅ POST /api/type-of-menu
**PATCH:** ⚠️ repo has `updateTypeOfMenu`, **provider doesn't expose it**
**DELETE:** ⚠️ repo has `deleteTypeOfMenu`, **provider doesn't expose it**
**Repository:** `TypeOfMenuRepository`
**Provider:** `TypeOfMenuProvider`
**Status:** Partially Integrated

---

**Module:** Units
**Screen:** `inventory/measuring_unit_screen.dart`, `add_measuring_unit_screen.dart` (+ picker in `add_dish_screen.dart`)
**GET:** ✅ GET /api/unit
**POST:** ✅ POST /api/unit
**PATCH:** ✅ PATCH /api/unit/{id}
**DELETE:** ✅ DELETE /api/unit/{id}
**Repository:** `UnitRepository`
**Provider:** `UnitProvider`
**Status:** Fully Integrated

---

**Module:** Dishes
**Screen:** `create_dish/add_dish_screen.dart` (create) + `manage/manage_dishes_screen.dart` (list)
**GET:** ✅ GET /api/dish
**POST:** ✅ POST /api/dish
**PATCH:** ⚠️ PATCH /api/dish/{id} — `DishProvider.updateDish` exists; Manage Dishes has a visible **"Edit" button whose handler is a literal `// TODO: Open dish edit flow once available.` stub**
**DELETE:** ⚠️ DELETE /api/dish/{id} — `DishProvider.deleteDish` exists, **no Delete button found anywhere**
**Repository:** `DishRepository`
**Provider:** `DishProvider`
**Status:** Partially Integrated

---

**Module:** Orders / KOT
**Screen:** `orders/orders_screen.dart`, `cancelled_history_screen.dart`, `kot_history_screen.dart`
**GET:** ✅ GET /api/order (KOT read via nested `order.kots`, not a separate `/api/kot` call)
**POST:** ❌ not on these screens
**PATCH:** ❌ not on these screens
**DELETE:** ❌ not on these screens
**Repository:** `OrderRepository`
**Provider:** `OrderProvider`
**Status:** Read-Only (by design)

---

**Module:** Orders / KOT
**Screen:** `quick_billing/order_cart_screen.dart`
**GET:** ❌ not on this screen
**POST:** ✅ POST /api/order (`OrderProvider.placeOrder`)
**PATCH:** ❌ not on this screen
**DELETE:** ❌ not on this screen
**Repository:** `OrderRepository`
**Provider:** `OrderProvider`
**Status:** Fully Integrated

---

**Module:** Orders / KOT
**Screen:** — (no screen exists for this yet)
**GET:** ❌
**POST:** ❌
**PATCH:** ❌
**DELETE:** ❌
**Repository:** — none
**Provider:** — none
**Status:** Not Integrated — checkout/bill-closing has zero UI or wiring anywhere in the app (see Section 4)

---

**Module:** Notifications
**Screen:** `notification/notification_screen.dart`
**GET:** ✅ GET /api/notification
**POST:** ⚠️ `NotificationProvider.createNotification` exists, **no compose UI calls it**
**PATCH:** ❌ `/read` marking exists in Swagger, unused
**DELETE:** ❌ not called
**Repository:** `NotificationRepository`
**Provider:** `NotificationProvider`
**Status:** Partially Integrated

---

**Module:** Payment Methods
**Screen:** `finance/cash_banks/cash_banks_screen.dart` (Modes tab), `add_payment_mode_screen.dart`, `cash_bank_mode_detail_screen.dart` (+ pickers in `add_expense_screen.dart`, `add_purchase_screen.dart`)
**GET:** ✅ GET /api/payment-method
**POST:** ✅ POST /api/payment-method
**PATCH:** ✅ PATCH /api/payment-method/{id}
**DELETE:** ✅ DELETE /api/payment-method/{id}
**Repository:** `PaymentMethodRepository`
**Provider:** `PaymentMethodProvider`
**Status:** Fully Integrated

---

**Module:** Sales Transactions
**Screen:** `analytics/sales_analytics_screen.dart` (Sales Invoice tab), `daybook_sales_summary_screen.dart`, `transactions_screen.dart`, `orders/recent_transactions_screen.dart`
**GET:** ✅ GET /api/sales-transaction
**POST:** ❌ endpoint has no `POST` at all
**PATCH:** ❌ not in Swagger
**DELETE:** ❌ not in Swagger
**Repository:** `SalesTransactionRepository`
**Provider:** `SalesTransactionProvider`
**Status:** Read-Only (backend has no write op)

---

**Module:** Purchase Bills
**Screen:** `analytics/sales_analytics_screen.dart` (Purchase Bills tab), `daybook_sales_summary_screen.dart`, `transactions_screen.dart`
**GET:** 🔴 GET /api/purchase-bill — **500 error, confirmed live** (see Known Bug)
**POST:** ❌ not on these screens
**PATCH:** ❌ not on these screens
**DELETE:** ❌ not on these screens
**Repository:** `PurchaseBillRepository`
**Provider:** `PurchaseBillProvider`
**Status:** Broken (backend bug, not a frontend gap)

---

**Module:** Purchase Bills
**Screen:** `finance/add_purchase_screen.dart`
**GET:** ❌ not on this screen
**POST:** ✅ POST /api/purchase-bill — confirmed working live
**PATCH:** ❌ endpoint exists, repo doesn't expose it
**DELETE:** ❌ not on this screen
**Repository:** `PurchaseBillRepository`, `SupplierRepository`, `CustomerRepository`, `PaymentMethodRepository`
**Provider:** `PurchaseBillProvider`, `SupplierProvider`, `CustomerProvider`, `PaymentMethodProvider`
**Status:** Fully Integrated (for what this screen needs — Create only)

---

**Module:** Expenses
**Screen:** `finance/add_expense_screen.dart` (category picker)
**GET:** ✅ GET /api/expense-category
**POST:** ✅ POST /api/expense-category (inline create)
**PATCH:** ❌ not in repo
**DELETE:** ❌ not in repo
**Repository:** `ExpenseCategoryRepository`
**Provider:** `ExpenseCategoryProvider`
**Status:** Partially Integrated

---

**Module:** Expenses
**Screen:** `analytics/finance_analytics_screen.dart` (list) + `finance/add_expense_screen.dart` (create)
**GET:** ✅ GET /api/expenses
**POST:** ✅ POST /api/expenses
**PATCH:** ❌ `PATCH /api/expenses/{id}` exists in Swagger, unused
**DELETE:** ⚠️ `ExpenseProvider.deleteExpense` exists, **no delete UI in the list**
**Repository:** `ExpenseRepository`
**Provider:** `ExpenseProvider`
**Status:** Partially Integrated

---

**Module:** Stock Groups
**Screen:** `inventory/add_stock_group_screen.dart`, `stock_group_screen.dart`, `inventory_features_screen.dart`
**GET:** ✅ GET /api/stock-group, GET /api/stock-group/stats
**POST:** ✅ POST /api/stock-group
**PATCH:** ⚠️ `StockGroupProvider.updateStockGroup` exists, **not called anywhere**
**DELETE:** ⚠️ `StockGroupProvider.deleteStockGroup` exists, **not called anywhere**
**Repository:** `StockGroupRepository`
**Provider:** `StockGroupProvider`
**Status:** Partially Integrated

---

**Module:** Stock
**Screen:** `inventory/add_stock_item_screen.dart`, `inventory_features_screen.dart`, `stock_group_screen.dart`
**GET:** ✅ GET /api/stock
**POST:** ✅ POST /api/stock
**PATCH:** ❌ `PATCH /api/stock/{id}` exists in Swagger, provider doesn't expose it
**DELETE:** ⚠️ `StockProvider.deleteStock` exists, **not called anywhere**
**Repository:** `StockRepository`
**Provider:** `StockProvider`
**Status:** Partially Integrated

---

**Module:** Stock
**Screen:** `inventory/add_consumption_screen.dart`
**GET:** ❌ not on this screen
**POST:** ❌ not on this screen
**PATCH:** ✅ PATCH /api/stock/{id}/adjust
**DELETE:** ❌ not on this screen
**Repository:** `StockRepository`
**Provider:** `StockProvider`
**Status:** Fully Integrated

---

**Module:** Stock
**Screen:** `inventory/stock_history_screen.dart`
**GET:** ✅ GET /api/stock/history
**POST:** ❌ not needed
**PATCH:** ❌ not needed
**DELETE:** ❌ not needed
**Repository:** `StockRepository`
**Provider:** `StockProvider`
**Status:** Read-Only (by design)

---

**Module:** Staff
**Screen:** `create_users/staff_list_screen.dart`, `manage/user_role_screen.dart`
**GET:** ✅ GET /api/user/all
**POST:** ❌ not on these screens
**PATCH:** ❌ not on these screens
**DELETE:** ✅ DELETE /api/user/{id} (Staff List)
**Repository:** `StaffRepository`
**Provider:** `StaffProvider`
**Status:** Fully Integrated

---

**Module:** Staff
**Screen:** `create_users/staff_detail_screen.dart`
**GET:** ✅ GET /api/user/{id}
**POST:** ❌ not on this screen
**PATCH:** ❌ not on this screen
**DELETE:** ✅ DELETE /api/user/{id}
**Repository:** `StaffRepository`
**Provider:** `StaffProvider`
**Status:** Fully Integrated

---

**Module:** Staff
**Screen:** `create_users/create_staff_screen.dart`, `invite_staff_screen.dart`
**GET:** ❌ not on these screens
**POST:** ✅ POST /api/restaurant/create-account
**PATCH:** ✅ PATCH /api/user/{id} (Create Staff, edit mode)
**DELETE:** ❌ not on these screens
**Repository:** `StaffRepository`
**Provider:** `StaffProvider`
**Status:** Fully Integrated

---

**Module:** Roles & Permissions
**Screen:** `manage/user_role_screen.dart`, `create_user_role_screen.dart`, `role_detail_screen.dart`, `staff_change_role_screen.dart`
**GET:** ✅ GET /api/roles
**POST:** ✅ POST /api/roles
**PATCH:** ✅ PATCH /api/roles/{id}
**DELETE:** ✅ DELETE /api/roles/{id}
**Repository:** `RoleRepository`
**Provider:** `RoleProvider`
**Status:** Fully Integrated

---

**Module:** Roles & Permissions
**Screen:** `create_users/staff_change_role_screen.dart` (RBAC assign)
**GET:** ❌ not on this screen
**POST:** ✅ POST /api/rbac/assign-role
**PATCH:** ❌ not needed
**DELETE:** ⚠️ DELETE /api/rbac/assign-role/{userId} — `RbacRepository.unassignRole` exists, **called from nowhere, not even wrapped by a provider**
**Repository:** `RbacRepository`
**Provider:** — (called directly, no provider wrapper)
**Status:** Partially Integrated

---

**Module:** Roles & Permissions
**Screen:** `manage/role_detail_screen.dart` (permission matrix), `create_users/staff_permission_details_screen.dart` (read-only view)
**GET:** ✅ GET /api/rbac/all
**POST:** ❌ not on these screens
**PATCH:** ✅ PUT /api/rbac/bulk
**DELETE:** ✅ DELETE /api/rbac/bulk
**Repository:** `RbacRepository`
**Provider:** — (both screens call `RbacRepository` directly, no provider wrapper)
**Status:** Fully Integrated

---

**Module:** Roles & Permissions
**Screen:** `manage/role_detail_screen.dart` (permission matrix — route axis)
**GET:** ✅ GET /api/routes
**POST:** ❌ not needed
**PATCH:** ❌ not needed
**DELETE:** ❌ not needed
**Repository:** `RouteRepository`
**Provider:** `RouteProvider`
**Status:** Read-Only (by design)

---

**Module:** Invoice Settings
**Screen:** `orders/invoice_setting_screen.dart`
**GET:** ✅ GET /api/invoice/my
**POST:** ❌ not needed
**PATCH:** ✅ PATCH /api/invoice/my (`saveSettings`)
**DELETE:** ❌ not needed
**Repository:** `InvoiceSettingsRepository`
**Provider:** `InvoiceSettingsProvider`
**Status:** Fully Integrated

---

**Module:** Plans & Subscription
**Screen:** `manage/change_plan_screen.dart`, `compare_plans_screen.dart`
**GET:** ✅ GET /api/plans, /api/plan-prices, /api/features, /api/plan-features
**POST:** ❌ not on these screens
**PATCH:** ❌ not on these screens
**DELETE:** ❌ not on these screens
**Repository:** `PlanRepository`
**Provider:** `PlanProvider`
**Status:** Read-Only (by design)

---

**Module:** Plans & Subscription
**Screen:** `manage/billing_subscription_screen.dart`
**GET:** ✅ GET /api/subscriptions/current
**POST:** ✅ POST /api/subscriptions/cancel
**PATCH:** ❌ intentional — purchase/change need a webview/payment redirect the app doesn't have yet
**DELETE:** ❌ not applicable
**Repository:** `SubscriptionRepository`
**Provider:** `SubscriptionProvider`
**Status:** Partially Integrated (by design)

---

**Module:** Plans & Subscription
**Screen:** `manage/billing_history_screen.dart`
**GET:** ✅ GET /api/billing/invoices, GET /api/billing/payments
**POST:** ❌ not needed
**PATCH:** ❌ not needed
**DELETE:** ❌ not needed
**Repository:** `SubscriptionRepository`
**Provider:** `SubscriptionProvider`
**Status:** Read-Only (by design)

---

**Module:** Combo Offers
**Screen:** `manage/manage_combo_offers_screen.dart` (list) + `create_dish/add_combo_screen.dart` (create)
**GET:** ✅ GET /api/combo-offer
**POST:** ✅ POST /api/combo-offer
**PATCH:** ❌ repo has `updateComboOffer`, **provider does not expose it — 0% reachable**
**DELETE:** ⚠️ repo + provider both have `deleteComboOffer`, **no screen calls it**
**Repository:** `ComboOfferRepository`
**Provider:** `ComboOfferProvider`
**Status:** Partially Integrated

---

## Appendix — original prose-style mapping (kept for reference)

**Screen:** `auth/login_screen.dart`
**Repository:** `AuthRepository`
**Provider:** `AuthProvider`
**Endpoints:** `POST /api/auth/login`
**CRUD Operations:** Create session (login)
**Missing:** —

**Screen:** `create_users/customer_list_screen.dart`
**Repository:** `CustomerRepository`
**Provider:** `CustomerProvider`
**Endpoints:** `GET /api/customers`
**CRUD Operations:** Read
**Missing:** —

**Screen:** `create_users/add_customer_screen.dart`
**Repository:** `CustomerRepository`, `CustomerGroupRepository`
**Provider:** `CustomerProvider`, `CustomerGroupProvider`
**Endpoints:** `GET /api/customer-group`, `POST /api/customers`, `POST /api/customer-group`
**CRUD Operations:** Create
**Missing:** —

**Screen:** `create_users/customer_detail_screen.dart`
**Repository:** `CustomerRepository`, `CustomerCommentRepository`
**Provider:** `CustomerProvider`, `CustomerCommentProvider`
**Endpoints:** `DELETE /api/customers/{id}`, `GET/POST/PATCH/DELETE /api/customer-comments`
**CRUD Operations:** Delete (customer), full CRUD (comments)
**Missing:** Update customer (Profile tab is view-only — no Edit button at all)

**Screen:** `create_users/supplier_list_screen.dart` (includes `SupplierDetailScreen`)
**Repository:** `SupplierRepository`, `SupplierTransactionRepository`
**Provider:** `SupplierProvider`, `SupplierTransactionProvider`
**Endpoints:** `GET /api/supplier`, `DELETE /api/supplier/{id}`, `GET/POST/DELETE /api/supplier-transaction`
**CRUD Operations:** Read, Delete (supplier), Create/Read/Delete (transactions)
**Missing:** Update supplier (repo + provider ready, not wired to UI)

**Screen:** `create_users/add_supplier_screen.dart`
**Repository:** `SupplierRepository`
**Provider:** `SupplierProvider`
**Endpoints:** `POST /api/supplier`
**CRUD Operations:** Create
**Missing:** —

**Screen:** `create_users/add_supplier_transaction_screen.dart`
**Repository:** `SupplierTransactionRepository`, `PaymentMethodRepository`
**Provider:** `SupplierTransactionProvider`, `PaymentMethodProvider`
**Endpoints:** `POST /api/supplier-transaction`, `GET /api/payment-method`
**CRUD Operations:** Create
**Missing:** —

**Screen:** `manage/manage_space_screen.dart`
**Repository:** `AreaRepository`
**Provider:** `AreaProvider`
**Endpoints:** `GET /api/area`, `DELETE /api/area/{id}`
**CRUD Operations:** Read, Delete
**Missing:** —

**Screen:** `manage/create_space_screen.dart`
**Repository:** `AreaRepository`
**Provider:** `AreaProvider`
**Endpoints:** `POST /api/area`, `PATCH /api/area/{id}`
**CRUD Operations:** Create, Update
**Missing:** —

**Screen:** `manage/add_table_screen.dart`
**Repository:** `TableRepository`
**Provider:** `TableProvider`
**Endpoints:** `GET /api/table`, `POST /api/table`, `PATCH /api/table/{id}`
**CRUD Operations:** Create, Read, Update
**Missing:** Delete integration (exists, but only reachable from `orders/orders_screen.dart`, not from this screen)

**Screen:** `orders/orders_screen.dart`
**Repository:** `TableRepository`, `OrderRepository`
**Provider:** `TableProvider`, `OrderProvider`
**Endpoints:** `GET /api/table`, `DELETE /api/table/{id}`, `GET /api/order`
**CRUD Operations:** Read, Delete (table), Read (orders, incl. nested KOT)
**Missing:** Table move/merge (`POST /api/table-order/move-table`, `/merge-table` — not called at all)

**Screen:** `create_dish/add_dish_screen.dart` (also hosts the real `AddCategoryScreen`/`AddSubMenuScreen` used elsewhere)
**Repository:** `DishRepository`, `CategoryRepository`, `DishTypeRepository`, `TypeOfMenuRepository`, `UnitRepository`, `VariantRepository`, `AddOnRepository`
**Provider:** `DishProvider`, `CategoryProvider`, `DishTypeProvider`, `TypeOfMenuProvider`, `UnitProvider`, `VariantProvider`, `AddOnProvider`
**Endpoints:** `GET/POST /api/dish`, `GET/POST /api/menu-category`, `GET/POST /api/dish-type`, `GET/POST /api/type-of-menu`, `GET/POST/PATCH/DELETE /api/unit`, `GET/POST/PATCH /api/variant`, `GET/POST /api/addons`
**CRUD Operations:** Create (dish), Read (all pickers), full CRUD (units), Create/Update (variants)
**Missing:** Update Dish (repo + provider ready, no edit entry point)
**Screen:** `create_dish/add_addon_screen.dart`
**Repository:** `AddOnRepository`
**Provider:** `AddOnProvider`
**Endpoints:** `GET/POST /api/addons`
**CRUD Operations:** Create, Read
**Missing:** Update/Delete (not in repo at all)

**Screen:** `create_dish/add_dish_type_screen.dart`
**Repository:** `DishTypeRepository`
**Provider:** `DishTypeProvider`
**Endpoints:** `GET/POST /api/dish-type`
**CRUD Operations:** Create, Read
**Missing:** Update/Delete (not in repo at all)

**Screen:** `manage/manage_categories_screen.dart`
**Repository:** `CategoryRepository`
**Provider:** `CategoryProvider`
**Endpoints:** `GET/POST /api/menu-category`
**CRUD Operations:** Create, Read
**Missing:** Update/Delete (not in repo at all)

**Screen:** `manage/manage_sub_menu_screen.dart`
**Repository:** `TypeOfMenuRepository`
**Provider:** `TypeOfMenuProvider`
**Endpoints:** `GET/POST /api/type-of-menu`
**CRUD Operations:** Create, Read
**Missing:** Update/Delete (repo has both, provider exposes neither)

**Screen:** `inventory/add_measuring_unit_screen.dart` / `measuring_unit_screen.dart`
**Repository:** `UnitRepository`
**Provider:** `UnitProvider`
**Endpoints:** `GET/POST/PATCH/DELETE /api/unit`
**CRUD Operations:** Full CRUD
**Missing:** —

**Screen:** `inventory/add_stock_group_screen.dart` / `stock_group_screen.dart`
**Repository:** `StockGroupRepository`
**Provider:** `StockGroupProvider`
**Endpoints:** `GET/POST /api/stock-group`, `GET /api/stock-group/stats`
**CRUD Operations:** Create, Read
**Missing:** Update/Delete (repo + provider ready, no UI wired)

**Screen:** `inventory/add_stock_item_screen.dart`
**Repository:** `StockRepository`
**Provider:** `StockProvider`
**Endpoints:** `POST /api/stock`
**CRUD Operations:** Create
**Missing:** —

**Screen:** `inventory/add_consumption_screen.dart`
**Repository:** `StockRepository`
**Provider:** `StockProvider`
**Endpoints:** `PATCH /api/stock/{id}/adjust`
**CRUD Operations:** Update (adjust)
**Missing:** —

**Screen:** `inventory/stock_history_screen.dart`
**Repository:** `StockRepository`
**Provider:** `StockProvider`
**Endpoints:** `GET /api/stock/history`
**CRUD Operations:** Read
**Missing:** —

**Screen:** `inventory/inventory_features_screen.dart`
**Repository:** `StockRepository`, `StockGroupRepository`, `UnitRepository`
**Provider:** `StockProvider`, `StockGroupProvider`, `UnitProvider`
**Endpoints:** `GET /api/stock/stats`, `GET /api/stock-group`, `GET /api/unit`
**CRUD Operations:** Read
**Missing:** —

**Screen:** `manage/manage_dishes_screen.dart`
**Repository:** `DishRepository`
**Provider:** `DishProvider`
**Endpoints:** `GET /api/dish`
**CRUD Operations:** Read
**Missing:** Update (visible "Edit" button, handler is a literal `// TODO` stub), Delete (no button found)

**Screen:** `manage/menu_overview_screen.dart`
**Repository:** `DishRepository`, `CategoryRepository`, `AddOnRepository`
**Provider:** `DishProvider`, `CategoryProvider`, `AddOnProvider`
**Endpoints:** `GET /api/dish`, `GET /api/menu-category`, `GET /api/addons`
**CRUD Operations:** Read
**Missing:** —

**Screen:** `create_dish/add_combo_screen.dart`
**Repository:** `ComboOfferRepository`, `DishRepository`
**Provider:** `ComboOfferProvider`, `DishProvider`
**Endpoints:** `POST /api/combo-offer`, `GET /api/dish`
**CRUD Operations:** Create
**Missing:** —

**Screen:** `manage/manage_combo_offers_screen.dart`
**Repository:** `ComboOfferRepository`
**Provider:** `ComboOfferProvider`
**Endpoints:** `GET /api/combo-offer`
**CRUD Operations:** Read
**Missing:** Update (repo-only, provider doesn't expose it), Delete (repo + provider ready, no UI wired)

**Screen:** `quick_billing/quick_billing_screen.dart`
**Repository:** `DishRepository`, `CategoryRepository`
**Provider:** `DishProvider`, `CategoryProvider`
**Endpoints:** `GET /api/dish`, `GET /api/menu-category`
**CRUD Operations:** Read
**Missing:** Checkout/bill-closing (see Section 4)

**Screen:** `quick_billing/order_cart_screen.dart`
**Repository:** `OrderRepository`
**Provider:** `OrderProvider`
**Endpoints:** `POST /api/order`
**CRUD Operations:** Create (`placeOrder`)
**Missing:** —

**Screen:** `orders/cancelled_history_screen.dart`, `orders/kot_history_screen.dart`
**Repository:** `OrderRepository`
**Provider:** `OrderProvider`
**Endpoints:** `GET /api/order`
**CRUD Operations:** Read
**Missing:** —

**Screen:** `orders/recent_transactions_screen.dart`
**Repository:** `SalesTransactionRepository`
**Provider:** `SalesTransactionProvider`
**Endpoints:** `GET /api/sales-transaction`
**CRUD Operations:** Read
**Missing:** —

**Screen:** `orders/invoice_setting_screen.dart`
**Repository:** `InvoiceSettingsRepository`
**Provider:** `InvoiceSettingsProvider`
**Endpoints:** `GET/PATCH /api/invoice/my`
**CRUD Operations:** Read, Update
**Missing:** —

**Screen:** `notification/notification_screen.dart`
**Repository:** `NotificationRepository`
**Provider:** `NotificationProvider`
**Endpoints:** `GET /api/notification`
**CRUD Operations:** Read
**Missing:** Create (compose UI doesn't call `createNotification`, though the method exists)

**Screen:** `finance/cash_banks/cash_banks_screen.dart` (Modes tab), `add_payment_mode_screen.dart`, `cash_bank_mode_detail_screen.dart`
**Repository:** `PaymentMethodRepository`
**Provider:** `PaymentMethodProvider`
**Endpoints:** `GET/POST/PATCH/DELETE /api/payment-method`
**CRUD Operations:** Full CRUD
**Missing:** — (Account tab and Balance Transfer tab on the same screen are dummy — see Section 6)

**Screen:** `analytics/sales_analytics_screen.dart`
**Repository:** `SalesTransactionRepository`, `PurchaseBillRepository`
**Provider:** `SalesTransactionProvider`, `PurchaseBillProvider`
**Endpoints:** `GET /api/sales-transaction`, `GET /api/purchase-bill`
**CRUD Operations:** Read
**Missing:** Purchase Bills tab is broken — see Known Bug

**Screen:** `finance/add_purchase_screen.dart`
**Repository:** `PurchaseBillRepository`, `SupplierRepository`, `CustomerRepository`, `PaymentMethodRepository`
**Provider:** `PurchaseBillProvider`, `SupplierProvider`, `CustomerProvider`, `PaymentMethodProvider`
**Endpoints:** `POST /api/purchase-bill`, `GET /api/supplier`, `GET /api/customers`, `GET /api/payment-method`
**CRUD Operations:** Create
**Missing:** —

**Screen:** `finance/transactions/transactions_screen.dart`, `transactions_filter_sheet.dart`
**Repository:** `SalesTransactionRepository`, `PurchaseBillRepository`, `SupplierRepository`, `CustomerRepository`
**Provider:** `SalesTransactionProvider`, `PurchaseBillProvider`, `SupplierProvider`, `CustomerProvider`
**Endpoints:** `GET /api/sales-transaction`, `GET /api/purchase-bill`, `GET /api/supplier`, `GET /api/customers`
**CRUD Operations:** Read
**Missing:** Purchase Bills side is broken — see Known Bug

**Screen:** `finance/daybook/daybook_sales_summary_screen.dart`
**Repository:** (reuses `SalesTransactionProvider`/`PurchaseBillProvider` via composed widgets)
**Provider:** `SalesTransactionProvider`, `PurchaseBillProvider`
**Endpoints:** `GET /api/sales-transaction`, `GET /api/purchase-bill`
**CRUD Operations:** Read
**Missing:** —

**Screen:** `finance/add_expense_screen.dart`
**Repository:** `ExpenseRepository`, `ExpenseCategoryRepository`, `PaymentMethodRepository`
**Provider:** `ExpenseProvider`, `ExpenseCategoryProvider`, `PaymentMethodProvider`
**Endpoints:** `POST /api/expenses`, `GET/POST /api/expense-category`, `GET /api/payment-method`
**CRUD Operations:** Create
**Missing:** —

**Screen:** `analytics/finance_analytics_screen.dart`
**Repository:** `ExpenseRepository`
**Provider:** `ExpenseProvider`
**Endpoints:** `GET /api/expenses`
**CRUD Operations:** Read
**Missing:** Delete (method exists, no delete UI in this list)

**Screen:** `analytics/finance_screen.dart`
**Repository:** `FinanceRepository`
**Provider:** `FinanceProvider`
**Endpoints:** `GET /api/dashboard/finance`
**CRUD Operations:** Read
**Missing:** —

**Screen:** `analytics/order_analytics_screen.dart`
**Repository:** `OrderAnalyticsRepository`
**Provider:** `OrderAnalyticsProvider`
**Endpoints:** `GET /api/dashboard/order`
**CRUD Operations:** Read
**Missing:** —

**Screen:** `analytics/analytics_screen.dart`
**Repository:** `DashboardRepository`
**Provider:** `DashboardProvider`
**Endpoints:** `GET /api/dashboard`
**CRUD Operations:** Read
**Missing:** —

**Screen:** `create_users/staff_list_screen.dart`
**Repository:** `StaffRepository`
**Provider:** `StaffProvider`
**Endpoints:** `GET /api/user/all`, `DELETE /api/user/{id}`
**CRUD Operations:** Read, Delete
**Missing:** —

**Screen:** `create_users/staff_detail_screen.dart`
**Repository:** `StaffRepository`
**Provider:** `StaffProvider`
**Endpoints:** `GET /api/user/{id}`, `DELETE /api/user/{id}`
**CRUD Operations:** Read, Delete
**Missing:** —

**Screen:** `create_users/create_staff_screen.dart`
**Repository:** `StaffRepository`
**Provider:** `StaffProvider`
**Endpoints:** `POST /api/restaurant/create-account`, `PATCH /api/user/{id}`
**CRUD Operations:** Create, Update (edit mode)
**Missing:** —

**Screen:** `create_users/invite_staff_screen.dart`
**Repository:** `StaffRepository`
**Provider:** `StaffProvider`
**Endpoints:** `POST /api/restaurant/create-account`
**CRUD Operations:** Create
**Missing:** —

**Screen:** `create_users/staff_change_role_screen.dart`
**Repository:** `RoleRepository`, `RbacRepository`
**Provider:** `RoleProvider`
**Endpoints:** `GET /api/roles`, `POST /api/rbac/assign-role`
**CRUD Operations:** Read, Create (assign)
**Missing:** Unassign role (`unassignRole` defined in `RbacRepository`, called from nowhere)

**Screen:** `create_users/staff_permission_details_screen.dart`
**Repository:** `RbacRepository` (called directly, not through a Provider)
**Provider:** — (none)
**Endpoints:** `GET /api/rbac/all`
**CRUD Operations:** Read
**Missing:** —

**Screen:** `manage/user_role_screen.dart`
**Repository:** `RoleRepository`, `StaffRepository`
**Provider:** `RoleProvider`, `StaffProvider`
**Endpoints:** `GET /api/roles`, `GET /api/user/all`
**CRUD Operations:** Read
**Missing:** —

**Screen:** `manage/create_user_role_screen.dart`
**Repository:** `RoleRepository`
**Provider:** `RoleProvider`
**Endpoints:** `POST /api/roles`
**CRUD Operations:** Create
**Missing:** —

**Screen:** `manage/role_detail_screen.dart`
**Repository:** `RoleRepository`, `RbacRepository`, `RouteRepository`
**Provider:** `RoleProvider`, `RouteProvider`
**Endpoints:** `PATCH /api/roles/{id}`, `DELETE /api/roles/{id}`, `GET /api/rbac/all`, `PUT /api/rbac/bulk`, `DELETE /api/rbac/bulk`, `GET /api/routes`
**CRUD Operations:** Update/Delete (role), Read (permissions/routes), Bulk update (permission matrix)
**Missing:** —

**Screen:** `manage/billing_subscription_screen.dart`
**Repository:** `SubscriptionRepository`
**Provider:** `SubscriptionProvider`
**Endpoints:** `GET /api/subscriptions/current`, `POST /api/subscriptions/cancel`
**CRUD Operations:** Read, Update (cancel)
**Missing:** Purchase/change (intentionally unwired — see Section 1 note)

**Screen:** `manage/change_plan_screen.dart`, `manage/compare_plans_screen.dart`
**Repository:** `PlanRepository`
**Provider:** `PlanProvider`
**Endpoints:** `GET /api/plans`, `GET /api/plan-prices`, `GET /api/features`, `GET /api/plan-features`
**CRUD Operations:** Read
**Missing:** Actual plan change (see above)

**Screen:** `manage/billing_history_screen.dart`
**Repository:** `SubscriptionRepository`
**Provider:** `SubscriptionProvider`
**Endpoints:** `GET /api/billing/invoices`, `GET /api/billing/payments`
**CRUD Operations:** Read
**Missing:** —

---

# 4. Backend APIs Missing

Every screen that cannot be integrated because the backend endpoint does not exist at all (verified against the full 252-operation Swagger spec).

| Screen | Expected Endpoint | Backend Status |
|---|---|---|
| Add Income | `POST /api/income` | Missing in backend |
| Add Sales Return | `POST /api/sales-transaction` | Endpoint exists but has no `POST` — read-only |
| Tax Rates / Add Tax | `GET/POST/PATCH/DELETE /api/tax` | Missing in backend |
| Department screen / Create Department | `GET/POST/PATCH/DELETE /api/department` | Missing in backend |
| Printers Setting / Add Printer | `GET/POST/PATCH/DELETE /api/printer` | Missing in backend |
| KOT Type Setting / Add KOT Type | `GET/POST/PATCH/DELETE /api/kot-type` | Missing in backend |
| SMS screens (5) | `GET/POST /api/sms` | Missing in backend |
| Website Builder (4 screens) | `GET/PATCH /api/website` | Missing in backend |
| Delivery (5 screens) | `GET/POST /api/delivery`, `/delivery-rider`, `/delivery-platform` | Missing in backend |
| Daybook (3 screens) | `GET/POST /api/daybook` | Missing in backend |
| Financial Reports (8 screens) | `GET /api/reports/{type}` | Missing in backend |
| Cash & Bank Accounts tab / Balance Transfer | `GET/POST/PATCH/DELETE /api/bank-account` | Missing in backend |
| Payments (Payment In/Out) | `GET/POST /api/payment-entry` | Missing in backend |
| Menu Set | `GET/POST/PATCH/DELETE /api/menu-set` | Missing in backend |
| Checkout / bill-closing | `POST /api/checkout`, `GET /api/checkout-history` | **Exists in Swagger, just never called by the app** — not a backend gap |
| Table move/merge | `POST /api/table-order/move-table`, `/merge-table` | **Exists in Swagger, just never called** — not a backend gap |
| Restaurant invoice generation | `GET/POST /api/invoice` | **Exists in Swagger (distinct from `/api/invoice/my` settings, which is wired), just never called** |
| Photo/attachment upload (cross-cutting, ~10 screens) | `POST /api/media/uploads` | **Exists in Swagger, just never called** — every photo picker in the app is decorative-only |

---

# 5. Swagger APIs Not Used

Full diff: every one of the 252 Swagger operations that has zero call site anywhere in the Flutter codebase. Grouped by resource; reason given per group where it's a pattern (e.g. "list-only stat/detail endpoints the app doesn't need yet") rather than repeated per line.

**Auth / platform-admin**
- `GET /api/auth/health-check` — no health-check UI needed
- `POST /api/auth/register` — no in-app registration flow (accounts created via web/admin)

**Media**
- `POST /api/media`, `POST /api/media/uploads`, `GET /api/media/{id}` — see Section 4, no upload flow wired anywhere

**Misc utility**
- `POST /api/mailing-service/send`, `POST /api/otp/generate`, `POST /api/otp/verify` — not used by any screen
- `GET/POST/PATCH/DELETE /api/permission` (+ `/{name}`) — separate from `/api/rbac/*`, which is what the app actually uses

**Restaurant (platform/admin side)**
- `POST /api/restaurant/create-restro`, `GET /api/restaurant/pending`, `POST /api/restaurant/{id}/approve`, `POST /api/restaurant/{id}/reject` — these are super-admin approval-workflow endpoints, out of scope for the restaurant-facing app
- `DELETE /api/type-of-restro/{id}`, `PATCH /api/type-of-restro/{id}`, `POST /api/type-of-restro` — app only reads the type list

**Customers**
- `GET /api/customers/{id}` — app fetches the full list and doesn't hit single-customer GET
- `GET /api/customers/{id}/dining-insight`, `/finance-insight`, `/spending-behaviour` — no analytics UI built for these yet

**Suppliers**
- `POST /api/supplier/bulk` — no bulk-import UI
- `GET /api/supplier-transaction/{id}`, `PATCH /api/supplier-transaction/{id}` — single-fetch and update not used (list fetched in full, no edit UI)

**Area / Table**
- `GET /api/area/{id}`, `GET /api/area/stats`, `GET /api/area/custom/total-spaces`, `/total-spaces-with-tables`, `/total-tables-by-spaces` — no area-level stats UI
- `GET /api/table/{id}`, `GET /api/table/stats` — table stats not surfaced anywhere

**Menu / Catalog**
- `GET /api/addons/{id}`, `GET /api/addons/stats`, `PATCH /api/addons/{id}`, `DELETE /api/addons/{id}`
- `GET /api/dish-type/{id}`, `GET /api/dish-type/count/total`, `/count/active`, `PATCH /api/dish-type/{id}`, `DELETE /api/dish-type/{id}`
- `GET /api/menu-category/{id}`, `GET /api/menu-category/stats`, `PATCH /api/menu-category/{id}`, `DELETE /api/menu-category/{id}`
- `GET /api/type-of-menu/{id}`, `GET /api/type-of-menu/stats`, `PATCH /api/type-of-menu/{id}`, `DELETE /api/type-of-menu/{id}`
- `GET /api/unit/{id}` — single-fetch not used (full list only)
- `GET /api/dish/{id}`, `GET /api/dish/dish-stats`, `GET /api/dish/{id}/transactions`, `PATCH /api/dish/{id}`, `DELETE /api/dish/{id}`
- `GET /api/variant/{id}` — single-fetch not used
- All of the above single-item/`{id}` GETs are unused because every list screen fetches the full collection and filters/finds locally rather than fetching one record at a time.

**Orders / KOT / Checkout / Tables**
- `GET /api/order/{id}`, `PATCH /api/order/{id}`, `DELETE /api/order/{id}`, `PATCH /api/order/dish/{itemId}`, `PATCH /api/order/addon/{addonItemId}`, `PATCH /api/order/variant/{variantItemId}` — no per-order edit/line-item-update UI
- `GET /api/kot`, `GET /api/kot/{id}`, `POST /api/kot`, `PATCH /api/kot/{id}`, `DELETE /api/kot/{id}` — KOT is only ever read as nested data inside `/api/order`, this dedicated resource is never called
- `GET/POST/PATCH/DELETE /api/checkout` (+ `-history`) — see Section 4, bill-closing not built
- `GET/POST/DELETE /api/table-order` (+ move/merge) — see Section 4, table move/merge not built
- `GET/POST /api/table-activity` (+ sessions/timeline) — no table-activity/session tracking UI built

**Notification**
- `GET /api/notification/log`, `PATCH /api/notification/read`, `GET /api/notification/{id}`, `PATCH /api/notification/{id}`, `DELETE /api/notification/{id}`, `POST/DELETE /api/notification/device-token` — no notification detail/read-tracking/push-token UI

**Payment method**
- `GET /api/payment-method/{id}` — single-fetch not used

**Sales / Purchase**
- `GET /api/sales-transaction/{id}` — single-fetch not used
- `GET /api/purchase-bill/{id}`, `PATCH /api/purchase-bill/{id}`, `DELETE /api/purchase-bill/{id}` — no detail/edit/delete UI built for purchase bills yet

**Expenses**
- `GET /api/expense-category/{id}`, `PATCH /api/expense-category/{id}`, `DELETE /api/expense-category/{id}`
- `GET /api/expenses/{id}`, `PATCH /api/expenses/{id}`

**Stock**
- `GET /api/stock-group/{id}`, `GET /api/stock-group/stats` *(note: stats IS used, via Inventory Features)*
- `GET /api/stock/{id}`, `PATCH /api/stock/{id}`, `GET /api/stock/{id}/history` (app uses the flat `/api/stock/history` instead)

**Staff / User**
- `GET /api/user/profile` — app reads staff via `/api/user/all` + `/{id}` instead

**Invoice**
- `GET /api/invoice`, `GET /api/invoice/{id}`, `PATCH /api/invoice/{id}`, `DELETE /api/invoice/{id}` — the full invoice CRUD resource, distinct from `/api/invoice/my` (settings, which IS wired) — see Section 4

**Plans / Subscriptions / Billing (admin-side CRUD)**
- `GET /api/plans/{id}`, and all `POST/PATCH/DELETE` on `/api/plans`, `/api/plan-prices`, `/api/features`, `/api/plan-features` — this app only ever reads these (they're managed on the admin/platform side)
- `POST /api/subscriptions/purchase`, `/change`, `/{id}/start-trial` — intentional, see Section 1
- `GET /api/billing/esewa/success`, `/failure` — payment-redirect callback URLs, not something the app calls directly

**RBAC**
- `GET /api/rbac/my` — app uses `/api/rbac/all?role=X` instead
- `POST /api/rbac` (single, non-bulk create) — app only uses the bulk variant

**Routes**
- `GET /api/routes/{id}`, `POST /api/routes`, `PATCH /api/routes/{id}`, `DELETE /api/routes/{id}` — app only reads the full route list for the permission matrix

**Combo Offers**
- `GET /api/combo-offer/{id}` — single-fetch not used

---

# 6. Dummy Screens

Screens confirmed **reachable** from app navigation that still use hardcoded/local state instead of a real API call. (Two files were checked and excluded as **dead code** with zero references anywhere: `menu/add_dish_screen.dart`, `create_dish/add_category_screen.dart`, `create_dish/add_sub_menu_screen.dart` — their real, integrated equivalents live inside `create_dish/add_dish_screen.dart`.)

| Screen | Reason | API required | Backend exists? | Frontend-only pending? |
|---|---|---|---|---|
| `create_users/customer_detail_screen.dart` — Transactions/Invoice/Credit List tabs | Static placeholder tabs | TBD | Unclear — no dedicated endpoint seen | No, needs backend design first |
| `finance/cash_banks/cash_banks_screen.dart` — Account tab | Hardcoded account list | `/api/bank-account` | ❌ No | No |
| `finance/cash_banks/add_cash_bank_account_screen.dart`, `cash_bank_account_detail_screen.dart` | Local-only form/detail | `/api/bank-account` | ❌ No | No |
| `finance/cash_banks/cash_banks_screen.dart` — Balance Transfer tab, `transfer_balance_screen.dart` | Local-only | `/api/bank-account` (transfer sub-resource) | ❌ No | No |
| `finance/add_income_screen.dart` | Entire form is local, `_save()` just pops the screen | `/api/income` | ❌ No | No |
| `finance/add_sales_return_screen.dart` | Entire form is local | `/api/sales-transaction` needs a `POST` | ❌ No (read-only) | No |
| `finance/daybook/daybook_screen.dart`, `close_daybook_screen.dart`, `daybook_history_screen.dart` | Hardcoded day totals/history | `/api/daybook` | ❌ No | No |
| `finance/payments/payments_screen.dart`, `payment_entry_screen.dart` | Hardcoded ledger | `/api/payment-entry` | ❌ No | No |
| `finance/reports/*` (8 screens) | Hardcoded report rows | `/api/reports/{type}` | ❌ No | No |
| `finance/transactions/transaction_type_screen.dart` | Generic empty-state placeholder for Payment In/Out/Balance Transfer | Same as Payments/Cash&Bank above | ❌ No | No |
| `home/faq_list_screen.dart` | Hardcoded FAQ list | TBD (`/api/faq`-style) | ❌ Not seen in Swagger | No |
| `inventory/stock_group_detail_sheet.dart` | Hardcoded display copy in the sheet (the underlying Stock Group CRUD it's attached to is real) | none — cosmetic fix only | N/A | **Yes** — this one just needs frontend wiring to real Stock Group data already available |
| `manage/tax_rates_screen.dart`, `add_tax_screen.dart` | Hardcoded tax list | `/api/tax` | ❌ No | No |
| `manage/department_screen.dart`, `create_department_screen.dart` | Hardcoded department list | `/api/department` | ❌ No | No |
| `manage/delete_restaurant_screen.dart` | No-op confirmation UI | `DELETE /api/restaurant/{id}` | Unclear — endpoint pattern exists for admin approval flows only | Unclear |
| `manage/dine_in_service_screen.dart` | Hardcoded toggles | TBD | ❌ Not seen | No |
| `manage/manage_menu_set_screen.dart`, `create_dish/add_menu_set_screen.dart` | Local-only, `_save()` just pops with a name string | `/api/menu-set` | ❌ No | No |
| `manage/notification_settings_screen.dart` | Hardcoded channel toggles | TBD | ❌ Not seen (distinct from `/api/notification` feed, which is real) | No |
| `manage/reset_delete_screen.dart`, `reset_restaurant_screen.dart` | No-op confirmation UI | TBD | ❌ Not seen | No |
| `manage/transfer_ownership_screen.dart` | Local-only form | TBD | ❌ Not seen | No |
| `manage/trash_screen.dart` | Hardcoded/empty | TBD (soft-delete recovery) | ❌ No "restore"/"list deleted" endpoint exists, even though several resources have `deletedAt` fields | No |
| `orders/kot_type_setting_screen.dart`, `add_kot_type_screen.dart` | Hardcoded KOT type list | `/api/kot-type` | ❌ No | No |
| `orders/printers_setting_screen.dart`, `add_printer_screen.dart` | Hardcoded printer list | `/api/printer` | ❌ No | No |
| `orders/saved_order_screen.dart` | Hardcoded list | TBD — possibly a status filter on `/api/order` | Unclear | Unclear |
| `sms/sms_screen.dart`, `sms_log_screen.dart`, `sms_events_screen.dart`, `purchase_sms_screen.dart`, `purchase_history_screen.dart` | Hardcoded throughout | `/api/sms` | ❌ No | No |
| `website/website_screen.dart`, `edit_details_screen.dart`, `custom_link_sheet.dart`, `social_links_sheet.dart` | Hardcoded throughout | `/api/website` | ❌ No | No |
| `delivery/delivery_riders_screen.dart`, `add_rider_screen.dart`, `delivery_service_screen.dart`, `delivery_time_screen.dart`, `select_delivery_platform_screen.dart` | Hardcoded throughout | `/api/delivery*` | ❌ No | No |
| `create_users/adjust_balance_screen.dart` | Local-only, values passed via constructor/pop, not persisted | TBD | ❌ No staff-ledger concept on backend at all | No |
| `analytics/top_selling_sub_menus_screen.dart` | Hardcoded ranking list | TBD — likely a grouped variant of `/api/dish/dish-stats` | Base endpoint exists but not grouped by sub-menu | Unclear |
| Every "Attachment"/"Photo" picker app-wide (Dish photo, Restaurant logo, Expense/Purchase attachment, Customer profile pic, etc.) | Picks a local file, never uploads it | `POST /api/media/uploads` | ✅ Yes — endpoint exists | **Yes** — pure frontend gap, backend already supports it |

*(Pure navigation/menu screens with no data of their own — `finance/finance_features_screen.dart`, `manage/other_services_screen.dart`, `services/services_screen.dart`, `manage/restaurant_setting_screen.dart`, `inventory/inventory_add_menu_sheet.dart` — are intentionally excluded from this table; they route to other screens and have nothing to integrate.)*

---

# 7. Final Summary

```
Total Screens (lib/screens/*.dart):        137 files (132 actual screens; 5 are shared
                                            widget/model helpers, not screens themselves:
                                            sms_empty_state.dart, cash_bank_models.dart,
                                            cash_bank_widgets.dart, report_tree_widgets.dart,
                                            daybook_table.dart)
Total APIs in Swagger:                      252 operations (35 resource groups)

GET integrated:                             45
POST integrated:                            29
PATCH integrated:                           11
PUT integrated:                             1   (PUT /api/rbac/bulk)
DELETE integrated:                          11
  ─────────────────────────────────────────────
  Total UI-verified operations:             97
  (cross-checked programmatically against the raw 252-operation Swagger
  list — this excludes every ⚠️ "repo/provider ready, not wired to UI"
  method from Sections 1-2, e.g. updateCustomer, updateSupplier,
  deleteDish, deleteStock, updateStockGroup, deleteStockGroup,
  deleteVariant, deleteExpense, unassignRole, createNotification)

Fully CRUD modules (all applicable verbs wired to UI):
  Units, Payment Methods, Staff, Roles                              (4 modules)

Partially CRUD modules (some verbs wired, some repo/provider-ready-
but-not-wired, or backend doesn't offer them):
  Customers, Suppliers, Supplier Transactions, Add-ons, Variants,
  Dish Types, Menu Categories, Type of Menu, Dishes, Orders,
  Notifications, Purchase Bills, Expense Categories, Expenses,
  Stock Groups, Stock, RBAC, Subscription, Combo Offers            (19 modules)

Read-only modules (backend has no write op the app needs, or app
only ever reads):
  Dashboard (x3), Sales Transactions, Plans, Billing, Routes        (7 modules)

Dummy screens (Section 6):                  28 (+ 4 attachment-picker
                                             instances counted as one
                                             cross-cutting row)

Missing backend endpoints (Section 4):      18 features/screens blocked
                                             on backend work not existing
                                             (15 truly missing + 3 that
                                             exist in Swagger but the
                                             app never calls)

Unused Swagger endpoints (Section 5):       155 operations with zero
                                             call site in the app (252
                                             total − 97 used) — mostly
                                             single-item `{id}` GETs
                                             (list-and-filter is used
                                             instead), admin/platform-
                                             side endpoints out of scope
                                             for this app, and the
                                             intentionally-deferred
                                             payment/checkout/media flows
```

**Known bug (see also `API_DOCUMENTATION.md`):** `GET /api/purchase-bill` returns `500` once any bill has `customerId` set — confirmed live 2026-08-06, breaks the shipped Purchase Bills tab. Fix this before anything else in this report.

**Biggest "quick win" for the backend team:** none of the CRUD-verb gaps above need new endpoints — every ⚠️ item already has a working backend operation, it's either not exposed by the Flutter provider layer or has no button wired to it in the UI. Those are frontend tickets, not backend ones.**
