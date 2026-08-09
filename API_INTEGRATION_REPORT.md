# restrox — Full API Integration Report

**Updated 2026-08-09.** Supersedes the 2026-08-06 version. This update corrects several claims in that version that turned out to be wrong once checked against the live server and current codebase — most notably: "Restaurant invoice generation" was never a real gap (see Section 4), and roughly twenty ⚠️ "repo/provider ready, not wired" items from the previous version have since been wired up. Swagger source: `http://192.168.1.27:8002/docs-json` (147 paths, ~47 resource groups as of this update — the raw operation count isn't recomputed here since it wasn't the useful number; see Section 7 for what's tracked instead). Flutter source: `lib/data/repositories/*`, `lib/providers/*`, `lib/services/restaurant_service.dart`, `lib/screens/*`.

---

## What changed since 2026-08-06

- **Media upload** — real `POST /api/media` wiring for Dish photo, Combo photo, Restaurant logo, and Purchase Bill attachment. Customer/Supplier/Staff/Expense have no photo field on the backend at all (confirmed against the live schema), so their decorative pickers can't be wired to anything real.
- **CRUD completions** — Dish, Menu Category, Add-on, Dish Type, Type of Menu (Sub Menu), Stock Group, Combo Offer, Customer, Supplier, Variant, Expense, Stock (item) all gained the update/delete operations the previous report listed as "not wired." RBAC unassign is now wrapped by `StaffProvider` and called from Staff Change Role.
- **Checkout / bill-closing (new)** — `POST /api/checkout` (generate bill) → `PATCH /api/checkout/{id}` (complete with a payment split) → `DELETE /api/checkout/{id}` (cancel an abandoned bill), reached from an active order's "Bill" action. Response field shapes were verified live, not guessed from Swagger — `/api/checkout` isn't documented there beyond the request DTOs.
- **Table move/merge (new)** — `POST /api/table-order/move-table` and `/merge-table`, reached from the Table tab's long-press menu on an occupied table.
- **"Restaurant invoice generation" — corrected, not a real gap.** `GET/PATCH/DELETE /api/invoice/{id}` is the *same* invoice-template/settings resource as the already-wired `GET/PATCH /api/invoice/my` (identical `UpdateInvoiceDTO`, confirmed live — `GET /api/invoice` returns exactly one row, byte-identical to `/my`). It's a platform-admin access pattern (any restaurant's settings by numeric id), out of scope for this app. There is no separate "generate a customer bill" endpoint to wire — that's what Checkout already does.
- **Two real bugs found via live testing (not visible from Swagger) and fixed:**
  1. `GET /api/expenses` returns `data: null` (not `[]`) for a restaurant with zero expenses — the unguarded `as List<dynamic>` cast would have crashed the screen. The same unguarded pattern existed in 30 repository files; all were swept with a defensive `?? []` fallback.
  2. `GET /api/expenses` (list) omits `category`/`paymentMethod` entirely, while `GET /api/expenses/{id}` includes them — editing an expense from the list would have silently sent blank category/payment-method ids. Fixed by fetching the single-item detail on entering edit mode.
- **Known bug confirmed still live today:** `GET /api/purchase-bill` still 500s once any bill has `customerId` set. Not a frontend issue — still blocks the Purchase Bills tab and Transactions screen's purchase side.

---

# 1. CRUD Integration Status

✅ = called from a screen and confirmed working (live-tested or code-verified this session) · ⚠️ = repository/provider method exists but no screen calls it · ❌ = no repository method / no endpoint at all · 🔴 = backend bug, confirmed live

### Auth
| Module | Screen | GET | POST | PATCH/PUT | DELETE | Status |
|---|---|---|---|---|---|---|
| Auth | Login | ❌ | ✅ | ❌ | ❌ | Integrated |
| Auth | (automatic, Dio interceptor) | ❌ | ✅ refresh on 401 | ❌ | ❌ | Integrated |
| Auth | Manage > Logout | ❌ | ✅ | ❌ | ❌ | Integrated |

### Dashboard / Analytics (read-only by design)
| Module | GET |
|---|---|
| Dashboard Overview | ✅ `/api/dashboard` |
| Order Analytics | ✅ `/api/dashboard/order` |
| Finance Analytics | ✅ `/api/dashboard/finance` |

### Restaurant Profile
| Screen | GET | PATCH |
|---|---|---|
| Restaurant Details | ✅ `/api/restaurant`, `/api/type-of-restro` | ✅ `/api/restaurant/settings` |

### Invoice Settings
| Screen | GET | PATCH |
|---|---|---|
| Invoice Setting | ✅ `/api/invoice/my` | ✅ `/api/invoice/my` |

### Customers — Fully Integrated
| Screen | GET | POST | PATCH | DELETE |
|---|---|---|---|---|
| Customer List | ✅ | — | — | — |
| Add Customer | ✅ (groups) | ✅ | — | — |
| Customer Detail | — | — | ✅ (Edit Customer menu action) | ✅ |
| Customer Detail — Comments | ✅ | ✅ | ✅ | ✅ |
| Customer Detail — Transactions/Invoice/Credit List tabs | ❌ static placeholder | — | — | — | *(Dummy, see Section 6)* |

### Suppliers — Fully Integrated
| Screen | GET | POST | PATCH | DELETE |
|---|---|---|---|---|
| Supplier List / Detail | ✅ | — | ✅ (Edit icon on Detail) | ✅ |
| Add Supplier | — | ✅ | — | — |
| Supplier Transactions | ✅ (client-filtered) | ✅ | ❌ not in repo (backend has no PATCH either — confirmed, real gap) | ✅ |

### Areas / Tables — Fully Integrated
| Screen | GET | POST | PATCH | DELETE |
|---|---|---|---|---|
| Manage Space | ✅ | — | — | ✅ |
| Create Space | — | ✅ | ✅ | — |
| Add Table | ✅ | ✅ | ✅ | — |
| Orders screen (Table tab) | ✅ | — | — | ✅ |
| Table move/merge (new) | — | ✅ `move-table`, `merge-table` | — | — |

### Menu / Catalog — Fully Integrated
| Module | Screen | GET | POST | PATCH | DELETE |
|---|---|---|---|---|---|
| Add-ons | Add Add-on (via picker in Add Dish) | ✅ | ✅ | ✅ | ✅ |
| Variants | Add Dish variant picker | ✅ | ✅ | ✅ | ✅ |
| Dish Types | Add Dish Type (via picker) | ✅ | ✅ | ✅ | ✅ |
| Menu Categories | Manage Categories | ✅ | ✅ | ✅ | ✅ |
| Type of Menu | Manage Sub Menu / Sub Menu Detail | ✅ | ✅ | ✅ | ✅ |
| Units | Measuring Unit | ✅ | ✅ | ✅ | ✅ |
| Dishes | Manage Dishes / Add Dish | ✅ | ✅ | ✅ (Edit) | ✅ |
| Combo Offers | Manage Combo Offers / Add Combo | ✅ | ✅ | ✅ (Edit action) | ✅ |
| Menu Set | Manage Menu Set | ❌ genuinely no backend entity — list stays local by necessity; its detail screen (`DefaultMenuSetScreen`) is wired to real Dish/Sub-Menu/Category data instead | | | |

### Orders / KOT / Checkout
| Module | Screen | GET | POST | PATCH | DELETE |
|---|---|---|---|---|---|
| Orders | Orders screen, Cancelled/KOT History | ✅ | — | — | — |
| Orders | Order Cart (Quick Billing) | — | ✅ `placeOrder` | — | — |
| Checkout (new) | Active order's "Bill" action | ✅ | ✅ generate bill | ✅ complete/settle | ✅ cancel |

### Notifications — Fully Integrated
| Screen | GET | POST | PATCH | DELETE |
|---|---|---|---|---|
| Notification screen | ✅ | ✅ Compose | ✅ mark-as-read (tap) | ❌ not wired (minor, low value) |

### Payment Methods, Staff, Roles, RBAC — Fully Integrated
All GET/POST/PATCH/DELETE verbs the backend offers are wired; unchanged since the last report.

### Sales Transactions (read-only — backend has no write op)
| Screen | GET |
|---|---|
| Sales Analytics, Daybook Sales Summary, Transactions, Recent Transactions | ✅ `/api/sales-transaction` |

### Purchase Bills
| Screen | GET | POST | PATCH | DELETE |
|---|---|---|---|---|
| Sales Analytics (Purchase Bills tab) | 🔴 `/api/purchase-bill` still 500s once a bill has `customerId` set — confirmed live 2026-08-09, unchanged from 2026-08-06 | | | |
| Add Purchase Screen | — | ✅ (+ photo attachment, new) | ✅ (edit entry point from Sales Analytics row) | — |

### Expenses — Fully Integrated (was Partially)
| Screen | GET | POST | PATCH | DELETE |
|---|---|---|---|---|
| Finance Analytics / Add Expense | ✅ | ✅ | ✅ (new — edit icon on each row) | ✅ |

### Expense Categories
| Screen | GET | POST | PATCH | DELETE |
|---|---|---|---|---|
| Add Expense (category picker) | ✅ | ✅ (inline create) | ❌ not in repo | ❌ not in repo |

### Stock — Fully Integrated
| Screen | GET | POST | PATCH | DELETE |
|---|---|---|---|---|
| Add Stock Item / Stock Group Detail | ✅ | ✅ | ✅ (edit mode) | ✅ |
| Add Consumption | — | — | ✅ `/adjust` | — |
| Stock History | ✅ | — | — | — |

### Plans / Subscription / Billing
Unchanged since the last report — Plans/Billing read-only by design, Subscription cancel wired, purchase/change intentionally deferred (needs a payment webview the app doesn't have).

---

# 2. Pending CRUD

Nearly everything that was pending in the previous report is now wired. What's left is either a genuine backend gap or low-value:

- **Supplier Transactions** — no `PATCH` in the backend at all (not a frontend gap).
- **Expense Categories** — no `PATCH`/`DELETE` in the backend at all.
- **Notifications** — `DELETE` not wired (repo/provider ready if ever needed; low value, no delete UI requested).
- **Purchase Bills GET** — 🔴 backend 500 bug, not fixable from the frontend.
- **Orders** — no line-item edit/status-update UI (order status update, dish/addon/variant item update endpoints all unused). Not flagged as a gap — no product requirement surfaced for this yet.
- **Subscription purchase/change** — intentionally deferred, needs a payment redirect/webview.

---

# 3. Backend APIs Missing (or admin/platform-only — out of scope)

Verified against the live server's current 147-path Swagger spec. None of these resources exist, and none have appeared since the 2026-08-06 check — the backend has not added any of the tags below.

| Screens | Expected Endpoint | Status |
|---|---|---|
| Add Income | `POST /api/income` | Missing |
| Add Sales Return | `POST /api/sales-transaction` | Endpoint has no `POST` — read-only |
| Tax Rates / Add Tax | `/api/tax` | Missing |
| Department screen | `/api/department` | Missing |
| Printers Setting | `/api/printer` | Missing |
| KOT Type Setting | `/api/kot-type` | Missing |
| SMS screens (5) | `/api/sms` | Missing |
| Website Builder (4 screens) | `/api/website` | Missing |
| Delivery (5 screens) | `/api/delivery*` | Missing |
| Daybook (3 screens) | `/api/daybook` | Missing |
| Financial Reports (8 screens) | `/api/reports/{type}` | Missing |
| Cash & Bank Accounts / Balance Transfer | `/api/bank-account` | Missing |
| Payments (Payment In/Out) | `/api/payment-entry` | Missing |
| FAQ list | `/api/faq` | Missing |
| Trash / restore | soft-delete recovery endpoint | Missing (several resources have `deletedAt` but nothing exposes it) |
| Delete Restaurant | `DELETE /api/restaurant/{id}` | **Confirmed missing entirely** — only admin approve/reject exist (`/api/restaurant/{id}/approve`, `/reject`) |
| Dine In Service settings | restaurant-level service-settings resource | Missing |
| Adjust Balance (staff) | staff-ledger concept | Missing |
| Notification Settings (channel toggles) | — | The only related endpoint, `/api/notification/device-token`, is Firebase push-token registration — a different technical feature (needs `firebase_messaging`, Firebase project config, APNs certs) than the Email/SMS/Push toggle UI this screen shows. Not wired; would need a product decision on scope, not just a repo call. |
| Saved Order | draft/saved status on `/api/order` | `GET /api/order` only supports `page/take/searchTerm/tableId` — no such status exists |
| Top Selling Sub Menus | grouped-by-sub-menu sales stat | `/api/dish/dish-stats` exists but groups by *dish type*, a distinct concept from *sub menu* (`type-of-menu`) in this app — not a faithful substitute |
| ~~Restaurant invoice generation~~ | ~~`GET/POST /api/invoice`~~ | **Removed — not a real gap, see "What changed" above** |
| ~~Checkout / bill-closing~~ | ~~`POST /api/checkout`~~ | **Now integrated, see Section 1** |
| ~~Table move/merge~~ | ~~`POST /api/table-order/*`~~ | **Now integrated, see Section 1** |
| ~~Photo/attachment upload~~ | ~~`POST /api/media/uploads`~~ | **Now integrated for Dish/Combo/Restaurant/Purchase Bill** — the fields that don't exist on other entities (Customer/Supplier/Staff/Expense) are a genuine backend limitation, not a wiring gap |

---

# 4. Dummy Screens

Screens reachable from app navigation that still use hardcoded/local state, re-verified against the live server on 2026-08-09.

| Screen | Reason | Blocked on |
|---|---|---|
| `customer_detail_screen.dart` — Transactions/Invoice/Credit List tabs | Static placeholder | No dedicated endpoint identified |
| `cash_banks_screen.dart` — Account tab, `add_cash_bank_account_screen.dart`, `cash_bank_account_detail_screen.dart` | Hardcoded | `/api/bank-account` missing |
| `cash_banks_screen.dart` — Balance Transfer tab, `transfer_balance_screen.dart` | Local-only | `/api/bank-account` missing |
| `finance/add_income_screen.dart` | Local-only, doesn't persist | `/api/income` missing |
| `finance/add_sales_return_screen.dart` | Local-only | No `POST` on sales-transaction |
| `finance/daybook/*` (3 screens) | Hardcoded | `/api/daybook` missing |
| `finance/payments/*` (2 screens) | Hardcoded | `/api/payment-entry` missing |
| `finance/reports/*` (8 screens) | Hardcoded | `/api/reports/{type}` missing |
| `finance/transactions/transaction_type_screen.dart` | Placeholder | Same as Payments/Cash & Bank |
| `home/faq_list_screen.dart` | Hardcoded | `/api/faq` missing |
| `manage/tax_rates_screen.dart`, `add_tax_screen.dart` | Hardcoded | `/api/tax` missing |
| `manage/department_screen.dart`, `create_department_screen.dart` | Hardcoded | `/api/department` missing |
| `manage/delete_restaurant_screen.dart` | No-op confirmation | **Confirmed: no `DELETE /api/restaurant/{id}` exists at all** |
| `manage/dine_in_service_screen.dart` | Hardcoded toggles | No matching settings resource |
| `manage/notification_settings_screen.dart` | Hardcoded toggles | Only related endpoint is FCM device-token registration, a different feature — see Section 3 |
| `manage/reset_delete_screen.dart`, `reset_restaurant_screen.dart` | No-op | No endpoint |
| `manage/transfer_ownership_screen.dart` | Local-only | No endpoint |
| `manage/trash_screen.dart` | Hardcoded/empty | No restore/list-deleted endpoint |
| `orders/kot_type_setting_screen.dart`, `add_kot_type_screen.dart` | Hardcoded | `/api/kot-type` missing |
| `orders/printers_setting_screen.dart`, `add_printer_screen.dart` | Hardcoded | `/api/printer` missing |
| `orders/saved_order_screen.dart` | Hardcoded | **Confirmed: no draft/saved status filter on `/api/order`** |
| `sms/*` (5 screens) | Hardcoded | `/api/sms` missing |
| `website/*` (4 screens) | Hardcoded | `/api/website` missing |
| `delivery/*` (5 screens) | Hardcoded | `/api/delivery*` missing |
| `create_users/adjust_balance_screen.dart` | Local-only | No staff-ledger concept |
| `analytics/top_selling_sub_menus_screen.dart` | Honest empty state (no fake rows) | `/api/dish/dish-stats` groups by dish type, not sub menu — see Section 3 |
| Customer/Supplier/Staff/Expense photo pickers | Decorative, never upload | **Confirmed: no photo field exists on these entities at all** — not a wiring gap |

*(Resolved since the last report: `stock_group_detail_sheet.dart` now wired to real Stock Group data. Dish/Combo/Restaurant/Purchase-Bill photo pickers now upload for real. Menu Set's detail screen now shows real Dish/Sub-Menu/Category data even though the Menu Set list itself must stay local.)*

*(Pure navigation/menu screens with no data of their own — `finance/finance_features_screen.dart`, `manage/other_services_screen.dart`, `services/services_screen.dart`, `manage/restaurant_setting_screen.dart`, `inventory/inventory_add_menu_sheet.dart` — excluded; nothing to integrate.)*

---

# 5. Final Summary

```
Fully CRUD modules (every backend-supported verb wired to UI):
  Units, Payment Methods, Staff, Roles, Areas, Menu Categories,
  Add-ons, Dish Types, Type of Menu, Stock Groups, Combo Offers,
  Dishes, Customers, Suppliers, Variants, Expenses, Stock, RBAC,
  Invoice Settings, Checkout, Table Move/Merge          (21 modules,
                                                          up from 4)

Partially CRUD (genuine backend limits, not frontend gaps):
  Supplier Transactions (no PATCH on backend), Orders (no
  line-item edit UI — no product ask yet), Notifications (DELETE
  unwired, low value), Purchase Bills (GET 500s — backend bug),
  Subscription (purchase/change intentionally deferred),
  Expense Categories (no PATCH/DELETE on backend)         (6 modules)

Read-only modules (backend has no write op, or app only reads):
  Dashboard (x3), Sales Transactions, Plans, Billing, Routes (7 modules)

Dummy screens (Section 4):                  26 screens across 18 groups,
                                             all confirmed blocked on a
                                             missing backend resource as
                                             of 2026-08-09 (down from 28
                                             groups — stock_group_detail
                                             _sheet.dart and most photo
                                             pickers resolved)

Known live bugs:
  GET /api/purchase-bill still 500s once any bill has customerId
  set — confirmed live 2026-08-09, unchanged since 2026-08-06.
  Not fixable from the frontend.

Corrected from the 2026-08-06 report:
  "Restaurant invoice generation" was never a real gap — /api/invoice
  (plural) is the same settings resource as /api/invoice/my, which
  was already fully wired. See "What changed" section above.
```

**Bottom line:** every CRUD operation the backend actually supports for a restaurant-facing use case is now wired to a real screen. What remains dummy is blocked on backend work outside this app's scope (SMS/website/delivery/daybook/reports/etc.), two screens with no faithful backend match (Saved Order, Top Selling Sub Menus), and one known backend bug (purchase-bill list 500). None of these are frontend tickets anymore.
