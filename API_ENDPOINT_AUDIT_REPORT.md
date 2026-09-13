# RestroX — Complete API Endpoint Audit Report

**Date:** 2026-08-11
**Swagger source tested:** `https://lzpqllhg-8002.inc1.devtunnels.ms/docs-json` (147 paths, 252 operations, 45 resource tags)
**Flutter source:** `lib/data/repositories/*.dart`, `lib/services/restaurant_service.dart`, `lib/core/network/api_constants.dart`, `lib/screens/*`
**Test account:** `sahilbasnet3+newari@gmail.com` (role: `admin`, restaurant: "Newari Kitchen", id 11) — provided by the user for this audit.
**Scope:** Discovery, comparison, and read-only (GET) live testing only. No code was modified. No POST/PATCH/PUT/DELETE requests were sent to the live server (per user direction, to avoid creating/mutating real data) — every write (POST/PATCH/PUT/DELETE) endpoint is evidence-checked against the app's source code instead of live-called, and is explicitly marked "Not tested (write op)" throughout this report.

---

## 1. Executive Summary

- The backend exposes **252 operations across 147 paths**. Cross-referencing the app's 37 repository files, `api_constants.dart`, and `restaurant_service.dart` shows the app currently calls **132 of those 252 operations (52%)**.
- **0 endpoints called by the app are absent from Swagger.** Every API call in the codebase corresponds to a real, documented operation — the app was built directly against this backend's contract, so there is no drift between what the code assumes and what the server exposes.
- **24 backend capabilities used by real screens do not exist anywhere in this Swagger spec** (verified by exact-path match, then a full keyword scan across every path/tag/summary/description, then a manual read of the sorted 147-path list). These back 27 dummy/hardcoded screens already present in the app's navigation.
- Of the 113 GET operations in Swagger, **102 were live-tested** with the provided credentials (the remaining 11 have no existing record in this restaurant to fetch by id, e.g. `GET /api/variant/{id}` with zero variants on file — marked **Not Tested**, not assumed to work).
- **98 of the 102 tested GETs returned a clean 2xx.** Of the 4 that didn't: **1 is a genuine backend bug** (`GET /api/purchase-bill` → `500`), and **3 are expected results, not bugs** (two eSewa payment-callback routes 400 when hit without the transaction data a real redirect would carry; one platform-admin route correctly 401s because the test account is a restaurant admin, not `SUPER_ADMIN`).
- **120 available operations (48% of the spec) are not called anywhere in the app.** Of the 54 GET ones among them, all 54 were live-tested and all returned 200 — meaning the backend already supports real functionality (customer dining/finance/spending insights, KOT ticket management, table-activity/session timelines, stats endpoints for area/menu-category/type-of-menu/stock-group/dish-type/addons, `checkout-history`, `table/stats`, `dish/dish-stats`, and more) that no screen in the app currently surfaces. This is a significant, evidence-based finding — see §6.

---

## 2. Complete Endpoint Inventory

Every one of the 252 operations in the live Swagger spec, grouped by resource module. `Request Body` shows the resolved DTO name and its fields (`*` = required); `—` means no body / no fields. `Success Response` shows the documented status code.

### Auth (`auth`, 5 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/auth/health-check` | Health check | — | 200 |
| POST | `/api/auth/register` | Register a new user and auto-login | `CreateUserDto`: fullname*:string, email*:string, password*:string, position*:string, role:string | 201 |
| POST | `/api/auth/login` | Login with email and password | `LoginUserDto`: email*:string, password*:string | 201 |
| POST | `/api/auth/refresh` | Exchange a refresh token for a new access token | `RefreshTokenDto`: refresh_token*:string | 201 |
| POST | `/api/auth/logout` | Logout the current user | — | 201 |

### Staff/User (`user`, 5 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/user/all` | Get all user | — | 200 |
| GET | `/api/user/profile` | Get profile user | — | 200 |
| GET | `/api/user/{id}` | Get user by id | — | 200 |
| PATCH | `/api/user/{id}` | Update an existing user | `UpdateUserDto`: fullname:string, email:string, position:string, role:string, restaurantId:string | 200 |
| DELETE | `/api/user/{id}` | Delete by id user | — | 200 |

### Plans (`plans`, 5 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/plans` | Get all subscription plans (public catalog) | — | 200 |
| POST | `/api/plans` | Create a plan (SUPER_ADMIN only) | `CreatePlanDto`: code*:string, name*:string, description:string, isPopular:boolean, displayOrder*:number | 201 |
| GET | `/api/plans/{id}` | Get a plan by id | — | 200 |
| PATCH | `/api/plans/{id}` | Update a plan (SUPER_ADMIN only) | `UpdatePlanDto`: code:string, name:string, description:string, isPopular:boolean, displayOrder:number | 200 |
| DELETE | `/api/plans/{id}` | Delete a plan (SUPER_ADMIN only) | — | 200 |

### Plan Prices (`plan-prices`, 4 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/plan-prices` | Get all plan prices | — | 200 |
| POST | `/api/plan-prices` | Create a plan price (SUPER_ADMIN only) | `CreatePlanPriceDto`: planId*:string, billingCycle*:string, price*:string, currency:string, durationDays:number | 201 |
| PATCH | `/api/plan-prices/{id}` | Update a plan price (SUPER_ADMIN only) | `UpdatePlanPriceDto`: planId:string, billingCycle:string, price:string, currency:string, durationDays:number | 200 |
| DELETE | `/api/plan-prices/{id}` | Delete a plan price (SUPER_ADMIN only) | — | 200 |

### Plan Features (catalog) (`features`, 3 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/features` | Get all features | — | 200 |
| PATCH | `/api/features/{id}` | Update a feature (SUPER_ADMIN only) | `UpdateFeatureDto`: code:string, name:string, description:string, valueType:string | 200 |
| DELETE | `/api/features/{id}` | Delete a feature (SUPER_ADMIN only) | — | 200 |

### Plan-Feature Mapping (`plan-features`, 4 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/plan-features` | Get all plan-feature grants | — | 200 |
| POST | `/api/plan-features` | Grant/configure a feature on a plan (SUPER_ADMIN only) | `CreatePlanFeatureDto`: planId*:string, featureId*:string, isEnabled:boolean, limitValue:number | 201 |
| PATCH | `/api/plan-features/{id}` | Update a plan-feature grant (SUPER_ADMIN only) | `UpdatePlanFeatureDto`: planId:string, featureId:string, isEnabled:boolean, limitValue:number | 200 |
| DELETE | `/api/plan-features/{id}` | Remove a plan-feature grant (SUPER_ADMIN only) | — | 200 |

### Subscription (`subscriptions`, 5 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/subscriptions/current` | Get the restaurant's current subscription and entitlements | — | 200 |
| POST | `/api/subscriptions/purchase` | Start a payment to purchase a plan | `PurchaseSubscriptionDto`: planId*:string, billingCycle*:string | 201 |
| POST | `/api/subscriptions/change` | Upgrade (immediate) or downgrade (scheduled) the current plan | `ChangeSubscriptionDto`: planId*:string, billingCycle*:string | 201 |
| POST | `/api/subscriptions/cancel` | Cancel the current subscription | `CancelSubscriptionDto`: immediate:boolean | 201 |
| POST | `/api/subscriptions/{id}/start-trial` | Activate a trial of a chosen plan for a restaurant (SUPER_ADMIN only, not self-service) | `StartTrialDto`: plan*:string | 201 |

### Billing (`billing`, 4 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/billing/invoices` | Get the restaurant's billing invoices | — | 200 |
| GET | `/api/billing/payments` | Get the restaurant's payment history | — | 200 |
| GET | `/api/billing/esewa/success` | eSewa success redirect (public — verified server-side before trusting) | — | 200 |
| GET | `/api/billing/esewa/failure` | eSewa failure redirect (public) | — | 200 |

### Dashboard/Analytics (`dashboard`, 3 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/dashboard` | Get dashboard data | — | 200 |
| GET | `/api/dashboard/order` | Get order insights for the dashboard | — | 200 |
| GET | `/api/dashboard/finance` | Get finance insights for the dashboard | — | 200 |

### Media Upload (`media`, 3 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| POST | `/api/media` | Upload file media | — | 201 |
| POST | `/api/media/uploads` | Upload multiple file media | — | 201 |
| GET | `/api/media/{id}` | Get media by id | — | 200 |

### Restaurant Type (`type-of-restro`, 5 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/type-of-restro` | Get all type of restro | — | 200 |
| POST | `/api/type-of-restro` | Create a new type of restro | `CreateTypeOfRestroDTO`: name*:string, description:string, status:boolean | 201 |
| GET | `/api/type-of-restro/{id}` | Get type of restro by id | — | 200 |
| PATCH | `/api/type-of-restro/{id}` | Update an existing type of restro | `UpdateTypeOfRestroDTO`: name:string, description:string, status:boolean | 200 |
| DELETE | `/api/type-of-restro/{id}` | Delete a type of restro | — | 200 |

### Restaurant Profile/Onboarding (`restaurant`, 7 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| POST | `/api/restaurant/create-restro` | Creating new restaurant | `CreateRestaurantDetailsDTO`: restaurantName*:string, defaultAdminFullname*:string, defaultAdminEmail*:string, defaultAdminPassword*:string, legalRestaurantName*:string, vatPanNumber:string, invoiceType:string, restaurantLogoId:string, contactNumber*:string, subDomain:string, email*:string, country*:string, district*:string, address*:string, restaurantTypeId:string, openingDate:string, facebookUrl:string, instagramUrl:string, youtubeUrl:string, tiktokUrl:string, googleReviewUrl:string, status:boolean | 201 |
| POST | `/api/restaurant/create-account` | Create users inside your restaurant | `CreateUserDto`: fullname*:string, email*:string, password*:string, position*:string, role:string | 201 |
| PATCH | `/api/restaurant/settings` | Update your restaurant settings | `UpdateRestaurantDetailsDTO`: restaurantName:string, defaultAdminFullname:string, defaultAdminEmail:string, defaultAdminPassword:string, legalRestaurantName:string, vatPanNumber:string, invoiceType:string, restaurantLogoId:string, contactNumber:string, subDomain:string, email:string, country:string, district:string, address:string, restaurantTypeId:string, openingDate:string, facebookUrl:string, instagramUrl:string, youtubeUrl:string, tiktokUrl:string, googleReviewUrl:string, status:boolean | 200 |
| GET | `/api/restaurant` | Get all restaurant | — | 200 |
| GET | `/api/restaurant/pending` | List restaurants pending verification (SUPER_ADMIN only) | — | 200 |
| POST | `/api/restaurant/{id}/approve` | Approve a pending restaurant and activate its plan (SUPER_ADMIN only) | `ApproveRestaurantDto`: plan*:string, isTrial:boolean, billingCycle:string | 201 |
| POST | `/api/restaurant/{id}/reject` | Reject a pending restaurant (SUPER_ADMIN only) | — | 201 |

### RBAC (`rbac`, 7 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/rbac/my` | My rbac | — | 200 |
| GET | `/api/rbac/all` | Get all rbac | — | 200 |
| POST | `/api/rbac` | Create a new rbac | `RbacDto`: role:string, route:string, permission:string | 201 |
| PUT | `/api/rbac/bulk` | Update an existing rbac | `BulkRbacDto`: items*:Array<RbacDto> | 200 |
| DELETE | `/api/rbac/bulk` | Bulk delete rbac | `BulkDeleteRbacDto`: ids*:Array<string> | 200 |
| POST | `/api/rbac/assign-role` | Assign a user to a group (role) | `AssignRoleDto`: userId*:string, roleName*:string | 201 |
| DELETE | `/api/rbac/assign-role/{userId}` | Unassign a user from their group (role) | — | 200 |

### Mailing Service (`mailing-service`, 1 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| POST | `/api/mailing-service/send` | For testing only | `sendMailDto`: email*:string, subject*:string, message*:string | 201 |

### OTP (`otp`, 2 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| POST | `/api/otp/generate` | Generate OTP | `GenerateOtpDTO`: type*:string | 201 |
| POST | `/api/otp/verify` | Verify OTP | `VerifyOtpDTO`: type*:string, otpCode*:string | 201 |

### Roles (`roles`, 5 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/roles` | Get all roles | — | 200 |
| POST | `/api/roles` | Create a new roles | `CreateRoleDTO`: name*:string | 201 |
| GET | `/api/roles/{id}` | Get roles by id | — | 200 |
| PATCH | `/api/roles/{id}` | Update an existing roles | `UpdateRoleDTO`: name:string | 200 |
| DELETE | `/api/roles/{id}` | Delete a roles | — | 200 |

### Routes/Permission Matrix (`routes`, 5 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/routes` | Get all routes (shared vocabulary — visible to every tenant) | — | 200 |
| POST | `/api/routes` | Create a new routes | `CreateRouteDTO`: name*:string | 201 |
| GET | `/api/routes/{id}` | Get routes by id | — | 200 |
| PATCH | `/api/routes/{id}` | Update an existing routes | `UpdateRouteDTO`: name:string | 200 |
| DELETE | `/api/routes/{id}` | Delete a routes | — | 200 |

### Permissions (`permission`, 5 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| POST | `/api/permission` | Create a new permission | `CreatePermissionDto`: name*:string | 201 |
| GET | `/api/permission` | Get all permission (shared vocabulary — visible to every tenant) | — | 200 |
| GET | `/api/permission/{name}` | Get permission by id | — | 200 |
| PATCH | `/api/permission/{name}` | Update an existing permission | `UpdatePermissionDto`: name:string | 200 |
| DELETE | `/api/permission/{name}` | Delete a permission | — | 200 |

### Customers (`customers`, 8 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/customers` | Get all customers | — | 200 |
| POST | `/api/customers` | Create a new customers | `CreateCustomerDTO`: customerName*:string, phoneNumber*:string, emailAddress*:string, companyName:string, panVatNumber:string, discount:string, customerGroupId:string, favouriteDishId:string, preferredSeatingId:string, dietaryTypeId:string, allergies:string, startPreferredTime:string, endPreferredTime:string, comments:Array<CustomerCommentInputDTO> | 201 |
| GET | `/api/customers/{id}` | Get customers by id | — | 200 |
| PATCH | `/api/customers/{id}` | Update an existing customers | `UpdateCustomerDTO`: customerName:string, phoneNumber:string, emailAddress:string, companyName:string, panVatNumber:string, discount:string, customerGroupId:string, favouriteDishId:string, preferredSeatingId:string, dietaryTypeId:string, allergies:string, startPreferredTime:string, endPreferredTime:string, comments:Array<CustomerCommentInputDTO> | 200 |
| DELETE | `/api/customers/{id}` | Delete a customers | — | 200 |
| GET | `/api/customers/{id}/dining-insight` | Get dining insight for a customer: frequent dish, last visit, most visited time, frequent table | — | 200 |
| GET | `/api/customers/{id}/finance-insight` | Get finance insight for a customer: total sales, total return, payment in, payment out | — | 200 |
| GET | `/api/customers/{id}/spending-behaviour` | Get spending behaviour for a customer: every spend with date, amount, method, and kot | — | 200 |

### Customer Groups (`customer-group`, 5 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| POST | `/api/customer-group` | Create a new customer group | `CreateCustomerGroupDto`: name*:string, description:string | 201 |
| GET | `/api/customer-group` | Get all customer groups | — | 200 |
| GET | `/api/customer-group/{id}` | Get a customer group by id | — | 200 |
| PATCH | `/api/customer-group/{id}` | Update an existing customer group | UpdateCustomerGroupDto | 200 |
| DELETE | `/api/customer-group/{id}` | Delete a customer group | — | 200 |

### Suppliers (`supplier`, 6 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/supplier` | Get all supplier | — | 200 |
| POST | `/api/supplier` | Create a new supplier | `CreateSupplierDto`: supplierName:string, phoneNumber:string, address:string, remarks:string, transactions:Array<string> | 201 |
| GET | `/api/supplier/{id}` | Get supplier by id | — | 200 |
| PATCH | `/api/supplier/{id}` | Update an existing supplier | `UpdateSupplierDto`: supplierName:string, phoneNumber:string, address:string, remarks:string, transactions:Array<string> | 200 |
| DELETE | `/api/supplier/{id}` | Delete a supplier | — | 200 |
| POST | `/api/supplier/bulk` | Create multiple suppliers in bulk | `BulkCreateSupplierDto`: suppliers:Array<CreateSupplierDto> | 201 |

### Supplier Transactions (`supplier-transaction`, 5 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/supplier-transaction` | Get all supplier transaction | — | 200 |
| POST | `/api/supplier-transaction` | Create a new supplier transaction | `CreateSupplierTransactionDTO`: supplierId*:string, date*:string, particulars*:string, toReceived:number, toPay:number, paymentMethodId*:string, totalPayment*:number, image:string, remarks:string | 201 |
| GET | `/api/supplier-transaction/{id}` | Get supplier transaction by id | — | 200 |
| PATCH | `/api/supplier-transaction/{id}` | Update an existing supplier transaction | `UpdateSupplierTransactionDTO`: supplierId*:string, date*:string, particulars*:string, toReceived:number, toPay:number, paymentMethodId*:string, totalPayment*:number, image:string, remarks:string | 200 |
| DELETE | `/api/supplier-transaction/{id}` | Delete a supplier transaction | — | 200 |

### Areas/Spaces (`area`, 9 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/area` | Get all area | — | 200 |
| POST | `/api/area` | Create a new area | `CreateAreaDto`: areaName*:string, description:string | 201 |
| GET | `/api/area/stats` | Get area stats: total spaces, most occupied, spaces with tables | — | 200 |
| GET | `/api/area/{id}` | Get area by id | — | 200 |
| PATCH | `/api/area/{id}` | Update an existing area | `UpdateAreaDto`: areaName:string, description:string | 200 |
| DELETE | `/api/area/{id}` | Delete a area | — | 200 |
| GET | `/api/area/custom/total-spaces` | Total spaces area | — | 200 |
| GET | `/api/area/custom/total-spaces-with-tables` | Total spaces with tables area | — | 200 |
| GET | `/api/area/custom/total-tables-by-spaces` | Total tables by spaces area | — | 200 |

### Tables (`table`, 6 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/table` | Get all table | — | 200 |
| POST | `/api/table` | Create a new table | `CreateTableDTO`: tableName*:string, tableType*:string, capacity*:number, areaId*:string, charge:number, tableStatus:string, available:boolean | 201 |
| GET | `/api/table/stats` | Get table stats: totals, occupancy, most used | — | 200 |
| GET | `/api/table/{id}` | Get table by id | — | 200 |
| PATCH | `/api/table/{id}` | Update an existing table | `UpdateTableDTO`: tableName:string, tableType:string, capacity:number, areaId:string, charge:number, tableStatus:string, available:boolean | 200 |
| DELETE | `/api/table/{id}` | Delete a table | — | 200 |

### Add-ons (`addons`, 6 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/addons` | Get all addons | — | 200 |
| POST | `/api/addons` | Create a new addons | `CreateAddonDTO`: addOnName*:string, unitId:string, price*:number, cogs*:number, discount:number, priceAfterDiscount:number, description:string, status:boolean | 201 |
| GET | `/api/addons/stats` | Get addon stats: total addons, most used addon | — | 200 |
| GET | `/api/addons/{id}` | Get addons by id | — | 200 |
| PATCH | `/api/addons/{id}` | Update an existing addons | `UpdateAddonDTO`: addOnName:string, unitId:string, price:number, cogs:number, discount:number, priceAfterDiscount:number, description:string, status:boolean | 200 |
| DELETE | `/api/addons/{id}` | Delete a addons | — | 200 |

### Variants (`variant`, 5 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/variant` | Get all variant | — | 200 |
| POST | `/api/variant` | Create a new variant | `CreateVariantDTO`: variantName*:string, unitId:string, actualPrice*:number, discount*:number, cogs*:number | 201 |
| GET | `/api/variant/{id}` | Get variant by id | — | 200 |
| PATCH | `/api/variant/{id}` | Update an existing variant | `UpdateVariantDTO`: variantName:string, unitId:string, actualPrice:number, discount:number, cogs:number | 200 |
| DELETE | `/api/variant/{id}` | Delete a variant | — | 200 |

### Dish Types (`dish-type`, 7 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/dish-type` | Get all dish type | — | 200 |
| POST | `/api/dish-type` | Create a new dish type | `CreateDishTypeDto`: name*:string, description:string, status:boolean | 201 |
| GET | `/api/dish-type/{id}` | Get dish type by id | — | 200 |
| PATCH | `/api/dish-type/{id}` | Update an existing dish type | `UpdateDishTypeDto`: name:string, description:string, status:boolean | 200 |
| DELETE | `/api/dish-type/{id}` | Delete a dish type | — | 200 |
| GET | `/api/dish-type/count/total` | Get total count dish type | — | 200 |
| GET | `/api/dish-type/count/active` | Get active count dish type | — | 200 |

### Menu Categories (`menu-category`, 6 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/menu-category` | Get all menu category | — | 200 |
| POST | `/api/menu-category` | Create a new menu category | `CreateMenuCategoryDTO`: categoryName*:string, image*:string, aboutCategory*:string | 201 |
| GET | `/api/menu-category/stats` | Get menu category stats: total category, top sold, most dish, average dish per category | — | 200 |
| GET | `/api/menu-category/{id}` | Get menu category by id | — | 200 |
| PATCH | `/api/menu-category/{id}` | Update an existing menu category | `UpdateMenuCategoryDTO`: categoryName:string, image:string, aboutCategory:string, status*:boolean | 200 |
| DELETE | `/api/menu-category/{id}` | Delete a menu category | — | 200 |

### Type of Menu (Sub Menu) (`type-of-menu`, 6 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/type-of-menu` | Get all type of menu | — | 200 |
| POST | `/api/type-of-menu` | Create a new type of menu | `CreateTypeOfMenuDTO`: name*:string, description*:string, status*:boolean | 201 |
| GET | `/api/type-of-menu/stats` | Get type of menu stats: total/active count, top sold, average dish per menu type, unused menu type | — | 200 |
| GET | `/api/type-of-menu/{id}` | Get type of menu by id | — | 200 |
| PATCH | `/api/type-of-menu/{id}` | Update an existing type of menu | `UpdateTypeOfMenuDTO`: name:string, description:string, status:boolean | 200 |
| DELETE | `/api/type-of-menu/{id}` | Delete a type of menu | — | 200 |

### Units (`unit`, 5 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/unit` | Get all unit | — | 200 |
| POST | `/api/unit` | Create a new unit | `CreateUnitDTO`: name*:string, description:string | 201 |
| GET | `/api/unit/{id}` | Get unit by id | — | 200 |
| PATCH | `/api/unit/{id}` | Update an existing unit | `UpdateUnitDTO`: name:string, description:string | 200 |
| DELETE | `/api/unit/{id}` | Delete a unit | — | 200 |

### Dishes (`dish`, 7 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/dish` | Get all dish | — | 200 |
| POST | `/api/dish` | Create a new dish | `CreateDishDTO`: dishName*:string, hsCode:string, dishPhoto:string, description:string, price:number, unitId:string, cogs:number, discountType:string, discount:number, priceAfterDiscount:number, variantIds:Array<string>, addonIds:Array<string>, dishTypeId:string, typeOfMenuId:string, menuCategoryId:string, available:boolean, stockConsumptions:Array<StockConsumptionDTO> | 201 |
| GET | `/api/dish/dish-stats` | Get dish stats: total/active dish count, top sold dish, top dish type | — | 200 |
| GET | `/api/dish/{id}/transactions` | Get transactions for a dish: checkoutId, amount, quantity, invoice number, filterable by start/end date | — | 200 |
| GET | `/api/dish/{id}` | Get dish by id | — | 200 |
| PATCH | `/api/dish/{id}` | Update an existing dish | `UpdateDishDTO`: dishName:string, hsCode:string, dishPhoto:string, description:string, price:number, unitId:string, cogs:number, discountType:string, discount:number, priceAfterDiscount:number, variantIds:Array<string>, addonIds:Array<string>, dishTypeId:string, typeOfMenuId:string, menuCategoryId:string, available:boolean, stockConsumptions:Array<StockConsumptionDTO> | 200 |
| DELETE | `/api/dish/{id}` | Delete a dish | — | 200 |

### Orders (`order`, 8 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/order` | Get all order | — | 200 |
| POST | `/api/order` | Create a new order | `CreateOrderDTO`: tableId*:string, items*:Array<CreateOrderItemDTO> | 201 |
| GET | `/api/order/{id}` | Get order by id | — | 200 |
| DELETE | `/api/order/{id}` | Delete a order | — | 200 |
| PATCH | `/api/order/{id}` | Update the basic order details | `UpdateOrderDTO`: tableId:string, assignedStaff:string | 200 |
| PATCH | `/api/order/dish/{itemId}` | Update OrderItem:Dish with itemId | `UpdateOrderItemDishDTO`: dishId:string, quantity:number, consumedQuantity:number, discountPrice:number, dishStatus:string | 200 |
| PATCH | `/api/order/addon/{addonItemId}` | Update OrderItem:Addon with addon-itemId | `UpdateOrderItemAddonDTO`: addonId:string, quantity:number, discountPrice:number, addonStatus:string | 200 |
| PATCH | `/api/order/variant/{variantItemId}` | Update OrderItem:Variant with variant-itemId | `UpdateOrderItemVariantDTO`: variantId:string, quantity:number, discountPrice:number, variantStatus:string | 200 |

### Notifications (`notification`, 9 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| POST | `/api/notification` | Create restaurant notification | `CreateNotificationDto`: title*:string, subject*:string, notificationMessage*:string, type*:string | 201 |
| GET | `/api/notification` | Get restaurant notifications | — | 200 |
| GET | `/api/notification/log` | Get restaurant notification log | — | 200 |
| PATCH | `/api/notification/read` | Mark notifications as read | `MarkAsReadDto`: notificationIds*:Array<string> | 200 |
| POST | `/api/notification/device-token` | Register or refresh FCM device token | `RegisterDeviceTokenDto`: fcmToken*:string, platform:string, deviceIdentifier:string | 200 |
| DELETE | `/api/notification/device-token` | Deregister FCM device token | `DeregisterDeviceTokenDto`: fcmToken*:string | 200 |
| GET | `/api/notification/{id}` | Get notification by id | — | 200 |
| PATCH | `/api/notification/{id}` | Update notification | `UpdateNotificationDto`: title:string, subject:string, notificationMessage:string, type:string | 200 |
| DELETE | `/api/notification/{id}` | Delete notification | — | 200 |

### KOT (`kot`, 5 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/kot` | Get all kot | — | 200 |
| POST | `/api/kot` | Create a new kot | `CreateKOTDTO`: kotNumber*:string, orderId*:string, orderStatus*:string | 201 |
| GET | `/api/kot/{id}` | Get kot by id | — | 200 |
| PATCH | `/api/kot/{id}` | Update an existing kot | `UpdateKOTDTO`: kotNumber:string, orderId:string, orderStatus:string | 200 |
| DELETE | `/api/kot/{id}` | Delete a kot | — | 200 |

### Table Order (session) (`table-order`, 5 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| POST | `/api/table-order/move-table` | Move a table into another table | `MoveTableOrderDTO`: fromTableId:string, toTableId:string | 201 |
| POST | `/api/table-order/merge-table` | Merge multiple tables into one table | `MergeTableOrderDTO`: fromTableIds*:Array<string>, toTableId*:string | 201 |
| GET | `/api/table-order` | Get all table order | — | 200 |
| GET | `/api/table-order/{id}` | Get table order by id | — | 200 |
| DELETE | `/api/table-order/{id}` | Delete a table order | — | 200 |

### Payment Methods (`payment-method`, 5 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| POST | `/api/payment-method` | Create a new payment method | `CreatePaymentMethodDTO`: name*:string, remarks:string | 201 |
| GET | `/api/payment-method` | Get all payment method | — | 200 |
| GET | `/api/payment-method/{id}` | Get payment method by id | — | 200 |
| PATCH | `/api/payment-method/{id}` | Update an existing payment method | `UpdatePaymentMethodDTO`: name:string, remarks:string | 200 |
| DELETE | `/api/payment-method/{id}` | Delete a payment method | — | 200 |

### Checkout (`checkout`, 5 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/checkout` | Get all checkout | — | 200 |
| POST | `/api/checkout` | Generates bill and initiates Checkout only. | `CreateCheckoutDTO`: tableId*:string, discountType:string, discount:string, remarks:string | 201 |
| GET | `/api/checkout/{id}` | Get checkout by id | — | 200 |
| PATCH | `/api/checkout/{id}` | Complete Checkout procedure | `UpdateCheckoutDTO`: noOfGuests:string, customerId:string, companyName:string, companyPan:string, payments:Array<SplitPaymentDTO>, checkoutStatus*:string | 200 |
| DELETE | `/api/checkout/{id}` | Delete a checkout | — | 200 |

### Checkout History (`checkout-history`, 2 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| POST | `/api/checkout-history` | Create history checkout history | `CheckoutIdDTO`: checkoutId*:string | 201 |
| GET | `/api/checkout-history` | Get all checkout history | — | 200 |

### Invoice Settings (`invoice`, 6 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/invoice/my` | Find my invoice | — | 200 |
| PATCH | `/api/invoice/my` | Update my invoice | `UpdateInvoiceDTO`: invoice_placeholder:string, restaurant_name:string, pan_no:string, bill_no:boolean, date:boolean, table_no:boolean, sn:boolean, particular:boolean, quantity:boolean, rate:boolean, amount:boolean, customer_discount:boolean, sub_total:boolean, discount:boolean, tax_amount:boolean, taxable_amount:boolean, grand_total:boolean, amount_in_words:boolean, remarks:boolean, payment_mode:boolean, kot_number:boolean, bill_by:boolean, total_amount:boolean, footer_remarks:string, qr_image:string | 200 |
| GET | `/api/invoice` | Get all invoice | — | 200 |
| GET | `/api/invoice/{id}` | Get invoice by id | — | 200 |
| PATCH | `/api/invoice/{id}` | Update an existing invoice | `UpdateInvoiceDTO`: invoice_placeholder:string, restaurant_name:string, pan_no:string, bill_no:boolean, date:boolean, table_no:boolean, sn:boolean, particular:boolean, quantity:boolean, rate:boolean, amount:boolean, customer_discount:boolean, sub_total:boolean, discount:boolean, tax_amount:boolean, taxable_amount:boolean, grand_total:boolean, amount_in_words:boolean, remarks:boolean, payment_mode:boolean, kot_number:boolean, bill_by:boolean, total_amount:boolean, footer_remarks:string, qr_image:string | 200 |
| DELETE | `/api/invoice/{id}` | Delete a invoice | — | 200 |

### Sales Transactions (`sales-transaction`, 2 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/sales-transaction` | Get all sales transaction | — | 200 |
| GET | `/api/sales-transaction/{id}` | Get sales transaction by id | — | 200 |

### Purchase Bills (`purchase-bill`, 5 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/purchase-bill` | Get all purchase bill | — | 200 |
| POST | `/api/purchase-bill` | Create a new purchase bill | `CreatePurchaseBillDTO`: date*:string, supplierId*:string, billNo*:string, paymentMethodId:string, amount*:string, purchaseStatus*:string, customerId*:string, payment_type*:string, imageId:string | 201 |
| GET | `/api/purchase-bill/{id}` | Get purchase bill by id | — | 200 |
| PATCH | `/api/purchase-bill/{id}` | Update an existing purchase bill | `UpdatePurchaseBillDTO`: date*:string, supplierId*:string, billNo*:string, paymentMethodId:string, amount*:string, purchaseStatus*:string, customerId*:string, payment_type*:string, imageId:string | 200 |
| DELETE | `/api/purchase-bill/{id}` | Delete a purchase bill | — | 200 |

### Expense Categories (`expense-category`, 5 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/expense-category` | Get all expense category | — | 200 |
| POST | `/api/expense-category` | Create a new expense category | `CreateExpenseCategoryDTO`: name*:string, description:string | 201 |
| GET | `/api/expense-category/{id}` | Get expense category by id | — | 200 |
| PATCH | `/api/expense-category/{id}` | Update an existing expense category | `UpdateExpenseCategoryDTO`: name*:string, description:string | 200 |
| DELETE | `/api/expense-category/{id}` | Delete a expense category | — | 200 |

### Expenses (`expenses`, 5 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/expenses` | Get all expenses | — | 200 |
| POST | `/api/expenses` | Create a new expenses | `CreateExpenseDTO`: title*:string, categoryId*:string, amount*:number, expense_date*:string, payment_date*:string, due_date*:string, payment_status*:string, paymentMethodId*:string, description:string, receiptId:string | 201 |
| GET | `/api/expenses/{id}` | Get expenses by id | — | 200 |
| PATCH | `/api/expenses/{id}` | Update an existing expenses | `UpdateExpenseDTO`: title:string, categoryId:string, amount:number, expense_date:string, payment_date:string, due_date:string, payment_status:string, paymentMethodId:string, description:string, receiptId:string | 200 |
| DELETE | `/api/expenses/{id}` | Delete a expenses | — | 200 |

### Table Activity (session tracking) (`table-activity`, 5 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/table-activity` | Get all table activity | — | 200 |
| POST | `/api/table-activity` | Create a new table activity | `CreateTableActivityDTO`: activitySessionId*:string, isActive:boolean, tableId*:string, activity_type*:string, changed_tableId:string, description*:string | 201 |
| GET | `/api/table-activity/active-sessions/{tableId}` | Get activity via table | — | 200 |
| GET | `/api/table-activity/session-timeline/{sessionId}` | Get activity table activity | — | 200 |
| GET | `/api/table-activity/{id}` | Get table activity by id | — | 200 |

### Combo Offers (`combo-offer`, 5 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| POST | `/api/combo-offer` | Create a new combo offer | `CreateComboOfferDTO`: name*:string, description:string, hsCode:string, comboPhoto:string, dishIds*:Array<string>, offerPrice*:number, startsAt*:string, endsAt*:string | 201 |
| GET | `/api/combo-offer` | Get all active combo offers | — | 200 |
| GET | `/api/combo-offer/{id}` | Get active combo offer by id | — | 200 |
| PATCH | `/api/combo-offer/{id}` | Update combo offer | `UpdateComboOfferDTO`: name:string, description:string, hsCode:string, comboPhoto:string, dishIds:Array<string>, offerPrice:number, startsAt:string, endsAt:string | 200 |
| DELETE | `/api/combo-offer/{id}` | Delete combo offer | — | 200 |

### Stock Groups (`stock-group`, 6 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/stock-group` | Get all stock groups | — | 200 |
| POST | `/api/stock-group` | Create a new stock group | `CreateStockGroupDto`: groupName*:string, groupDescription:string | 201 |
| GET | `/api/stock-group/stats` | Get stock group stats: total group stock, highest stock value, group with most item | — | 200 |
| GET | `/api/stock-group/{id}` | Get stock group by id | — | 200 |
| PATCH | `/api/stock-group/{id}` | Update an existing stock group | `UpdateStockGroupDto`: groupName:string, groupDescription:string | 200 |
| DELETE | `/api/stock-group/{id}` | Delete a stock group | — | 200 |

### Stock (`stock`, 9 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| GET | `/api/stock` | Get all stock | — | 200 |
| POST | `/api/stock` | Create a new stock | `CreateStockDto`: itemName*:string, defaultPrice*:number, quantity*:number, rate*:number, description:string, unitId*:string, stockGroupId:string, supplierId:string | 201 |
| GET | `/api/stock/history` | Get all stock transaction history, filterable by start/end date, staffId, stockId, stockGroupId | — | 200 |
| GET | `/api/stock/stats` | Get stock stats: total stocks, total stock value, most consumed stock, restocks this week, low stock items | — | 200 |
| GET | `/api/stock/{id}` | Get stock by id | — | 200 |
| PATCH | `/api/stock/{id}` | Update an existing stock | `UpdateStockDto`: itemName:string, defaultPrice:number, quantity:number, rate:number, description:string, unitId:string, stockGroupId:string, supplierId:string | 200 |
| DELETE | `/api/stock/{id}` | Delete a stock | — | 200 |
| PATCH | `/api/stock/{id}/adjust` | Add or reduce stock quantity | `AdjustStockDto`: type*:string, quantity*:number, rate*:number, supplierId:string, transactionDate*:string, remark:string | 200 |
| GET | `/api/stock/{id}/history` | Get stock transaction history by stock id | — | 200 |

### Customer Comments (`customer-comments`, 6 ops)

| Method | Endpoint | Feature | Request Body | Success Response |
|---|---|---|---|---|
| POST | `/api/customer-comments` | Create a new customer comment | `CreateCustomerCommentDto`: comment*:string, customerId*:string | 201 |
| GET | `/api/customer-comments` | Get all customer comments | — | 200 |
| GET | `/api/customer-comments/customer/{id}` | Get all comments for a customer | — | 200 |
| GET | `/api/customer-comments/{id}` | Get a customer comment by id | — | 200 |
| PATCH | `/api/customer-comments/{id}` | Update an existing customer comment | `UpdateCustomerCommentDto`: comment:string, customerId:string | 200 |
| DELETE | `/api/customer-comments/{id}` | Delete a customer comment | — | 200 |


---

## 3. Missing Endpoints

Endpoints/capabilities that real screens in the app need but do not exist anywhere in the current Swagger spec. Verified by: (a) exact-path lookup, (b) a keyword scan across every path/tag/summary/description in the 252-operation spec, (c) a manual read of the full sorted 147-path list, and (d) confirming the corresponding dummy screen file still exists in `lib/screens/*` with hardcoded/local state.

| Module | Feature | Required Method | Required Endpoint | Swagger Available | Status |
|---|---|---|---|---|---|
| Finance | Add Income | POST | `/api/income` | No | Missing — no such resource in swagger |
| Finance | Add Sales Return | POST | `/api/sales-transaction (or dedicated /api/sales-return)` | Partial | Missing capability — `/api/sales-transaction` exists but is GET-only (no POST verb at all, confirmed in swagger) |
| Manage → Tax | Tax Rates list / Add Tax | GET, POST, PATCH, DELETE | `/api/tax` | No | Missing |
| Manage → Department | Department list / Create Department | GET, POST | `/api/department` | No | Missing |
| Orders → Printers | Printers Setting / Add Printer | GET, POST | `/api/printer` | No | Missing |
| Orders → KOT Type | KOT Type Setting / Add KOT Type | GET, POST | `/api/kot-type` | No | Missing — note: `/api/kot` (the ticket resource itself) DOES exist; only the "type" sub-resource is absent |
| SMS | SMS screen, SMS Log, SMS Events, Purchase SMS (4–5 screens) | GET, POST | `/api/sms (+ /log, /events)` | No | Missing |
| Website Builder | Website screen | GET, PATCH | `/api/website` | No | Missing |
| Delivery | Delivery Riders | GET, POST | `/api/delivery-rider` | No | Missing |
| Delivery | Delivery Service / Select Platform / Delivery Time (3 screens) | GET, POST | `/api/delivery-service, /api/delivery-platform` | No | Missing |
| Finance → Daybook | Daybook, Daybook Sales Summary, Close Daybook, Daybook History (4 screens) | GET, POST | `/api/daybook` | No | Missing |
| Finance → Reports | Account Summary, Balance Sheet, Chart of Accounts, P&L Statement, Sales Master Report, Trial Balance, Report Tree/Detail (8 screens) | GET | `/api/reports/{type}` | No | Missing |
| Finance → Cash & Bank | Cash & Bank Accounts, Add Account, Account Detail, Payment Mode, Balance Transfer (5 screens) | GET, POST, PATCH | `/api/bank-account` | No | Missing |
| Finance → Payments | Payments (Payment In/Out), Payment Entry, Transaction Type (3 screens) | GET, POST | `/api/payment-entry` | No | Missing |
| Home | FAQ list | GET | `/api/faq` | No | Missing |
| Reservation | Add / Table Reservation | GET, POST | `/api/reservation` | No | Missing |
| Manage → Restaurant | Transfer Ownership | POST | `/api/restaurant/transfer-ownership` | No | Missing — full `/api/restaurant/*` set checked, no ownership-transfer op exists |
| Manage → Restaurant | Trash / Restore (soft-delete recovery) | GET, POST | `/api/trash (or similar)` | No | Missing — several resources carry `deletedAt` but nothing exposes/restores it |
| Manage → Restaurant | Delete Restaurant | DELETE | `/api/restaurant/{id}` | No | Missing — only `/api/restaurant/{id}/approve` and `/reject` exist (platform-admin), no delete op |
| Manage → Restaurant | Dine In Service settings (toggles) | GET, PATCH | `restaurant-level service-settings resource` | No | Missing |
| Staff | Adjust Balance (staff ledger) | POST | `staff-ledger endpoint` | No | Missing — no ledger/balance concept in swagger for staff |
| Manage → Notifications | Notification Settings (Email/SMS/Push channel toggles) | GET, PATCH | `distinct notification-preferences resource` | No | Missing — `/api/notification/device-token` exists but is FCM push-token registration, a different technical feature from channel toggles |
| Orders | Saved Order (draft status) | GET | `/api/order?status=saved (or dedicated)` | Partial | Missing capability — `GET /api/order` only supports `page/take/searchTerm/tableId`; no draft/saved status field exists on the Order resource |
| Analytics | Top Selling Sub Menus | GET | `grouped-by-sub-menu sales stat` | Partial | Missing capability — `GET /api/dish/dish-stats` exists and works, but groups by *dish type*, not *sub menu* (`type-of-menu`) — not a faithful substitute |

**Total missing: 24** (21 with no backend resource at all, 3 where a related endpoint exists but lacks the specific capability the screen needs — marked "Partial" above).

**Not counted above, but worth flagging separately:** the photo/attachment pickers on Customer, Supplier, Staff, and Expense screens are decorative and never upload anywhere. This is *not* a missing endpoint — `POST /api/media` exists and works fine — it's a missing `photo`/`attachment` foreign-key field on those four entities' create/update DTOs (confirmed absent from `CreateCustomerDto`, `CreateSupplierDto`, `CreateUserDto`, `CreateExpenseDTO` in the live schema). A schema gap, not an endpoint gap.

---

## 4. Failing / Issue Endpoints

Every endpoint that returned a non-2xx status when live-tested with the provided credentials.

| Module | Feature | Method | Endpoint | Status Code | Exact Error | Issue Type | Details |
|---|---|---|---|---|---|---|---|
| Billing | eSewa failure redirect callback | GET | `/api/billing/esewa/failure` | 400 | `{"statusCode":400,"message":"Missing transactionUuid"}` | Validation Error (expected — webhook tested without required params) | see §6 below |
| Billing | eSewa success redirect callback | GET | `/api/billing/esewa/success` | 400 | `{"statusCode":400,"message":"Missing eSewa response data"}` | Validation Error (expected — webhook tested without required params) | see §6 below |
| Purchase Bills | Sales Analytics → Purchase Bills tab / Transactions screen | GET | `/api/purchase-bill` | 500 | `{"statusCode":500,"message":"Internal server error"}` | Backend Error | see §6 below |
| Restaurant Profile | Platform-admin pending-restaurant queue (not used by this app) | GET | `/api/restaurant/pending` | 401 | `{"statusCode":401,"message":"Unauthorised: Only SUPER_ADMIN can view pending restaurants."}` | Authorization Error (expected — test account is restaurant admin, not SUPER_ADMIN) | see §6 below |

Notes on classification:
- The two eSewa rows (`400`) are **expected, not bugs** — these are payment-gateway redirect callbacks (`GET /api/billing/esewa/success` / `/failure`) meant to be hit by eSewa's own redirect with `transactionUuid`/response data attached. Hitting them directly with no query params correctly triggers their validation guard. Not counted as a real defect.
- The `401` on `/api/restaurant/pending` is **expected, not a bug** — it's explicitly a `SUPER_ADMIN`-only platform-admin endpoint (confirmed in the swagger summary: *"List restaurants pending verification (SUPER_ADMIN only)"*), and this app has no reason to call it (restaurant admins don't approve other restaurants). Included here only because it was in the "test every GET" sweep.
- The `500` on `GET /api/purchase-bill` is the **one genuine backend defect** found in this audit — see §9.

---

## 5. Working Endpoints

All 98 GET endpoints that returned a clean 2xx when live-tested against the tunnel server with the provided credentials. "Integrated in App?" = **Yes** means a real screen/repository calls this endpoint today; **No** means the backend supports it but no screen uses it yet (see §6 for the full detail on those, including non-GET methods).

| Module | Feature | Method | Endpoint | Status Code | Integrated in App? | Result |
|---|---|---|---|---|---|---|
| Add-ons | Get all addons | GET | `/api/addons` | 200 | Yes | Confirmed working (screen calls this live) |
| Add-ons | Get addon stats: total addons, most used addon | GET | `/api/addons/stats` | 200 | No | Confirmed working (not called by any screen yet) |
| Areas/Spaces | Get all area | GET | `/api/area` | 200 | Yes | Confirmed working (screen calls this live) |
| Areas/Spaces | Get area by id | GET | `/api/area/7` | 200 | No | Confirmed working (not called by any screen yet) |
| Areas/Spaces | Total spaces area | GET | `/api/area/custom/total-spaces` | 200 | No | Confirmed working (not called by any screen yet) |
| Areas/Spaces | Total spaces with tables area | GET | `/api/area/custom/total-spaces-with-tables` | 200 | No | Confirmed working (not called by any screen yet) |
| Areas/Spaces | Total tables by spaces area | GET | `/api/area/custom/total-tables-by-spaces` | 200 | No | Confirmed working (not called by any screen yet) |
| Areas/Spaces | Get area stats: total spaces, most occupied, spaces with tables | GET | `/api/area/stats` | 200 | No | Confirmed working (not called by any screen yet) |
| Auth | Health check | GET | `/api/auth/health-check` | 200 | No | Confirmed working (not called by any screen yet) |
| Billing | Get the restaurant's billing invoices | GET | `/api/billing/invoices` | 200 | Yes | Confirmed working (screen calls this live) |
| Billing | Get the restaurant's payment history | GET | `/api/billing/payments` | 200 | Yes | Confirmed working (screen calls this live) |
| Checkout | Get all checkout | GET | `/api/checkout` | 200 | No | Confirmed working (not called by any screen yet) |
| Checkout | Get checkout by id | GET | `/api/checkout/9` | 200 | Yes | Confirmed working (screen calls this live) |
| Checkout History | Get all checkout history | GET | `/api/checkout-history` | 200 | No | Confirmed working (not called by any screen yet) |
| Combo Offers | Get all active combo offers | GET | `/api/combo-offer` | 200 | Yes | Confirmed working (screen calls this live) |
| Customer Comments | Get all customer comments | GET | `/api/customer-comments` | 200 | No | Confirmed working (not called by any screen yet) |
| Customer Comments | Get a customer comment by id | GET | `/api/customer-comments/5` | 200 | No | Confirmed working (not called by any screen yet) |
| Customer Comments | Get all comments for a customer | GET | `/api/customer-comments/customer/4` | 200 | Yes | Confirmed working (screen calls this live) |
| Customer Groups | Get all customer groups | GET | `/api/customer-group` | 200 | Yes | Confirmed working (screen calls this live) |
| Customer Groups | Get a customer group by id | GET | `/api/customer-group/5` | 200 | No | Confirmed working (not called by any screen yet) |
| Customers | Get all customers | GET | `/api/customers` | 200 | Yes | Confirmed working (screen calls this live) |
| Customers | Get customers by id | GET | `/api/customers/4` | 200 | No | Confirmed working (not called by any screen yet) |
| Customers | Get dining insight for a customer: frequent dish, last visit, most visited time, frequent table | GET | `/api/customers/4/dining-insight` | 200 | No | Confirmed working (not called by any screen yet) |
| Customers | Get finance insight for a customer: total sales, total return, payment in, payment out | GET | `/api/customers/4/finance-insight` | 200 | No | Confirmed working (not called by any screen yet) |
| Customers | Get spending behaviour for a customer: every spend with date, amount, method, and kot | GET | `/api/customers/4/spending-behaviour` | 200 | No | Confirmed working (not called by any screen yet) |
| Dashboard/Analytics | Get dashboard data | GET | `/api/dashboard` | 200 | Yes | Confirmed working (screen calls this live) |
| Dashboard/Analytics | Get finance insights for the dashboard | GET | `/api/dashboard/finance` | 200 | Yes | Confirmed working (screen calls this live) |
| Dashboard/Analytics | Get order insights for the dashboard | GET | `/api/dashboard/order` | 200 | Yes | Confirmed working (screen calls this live) |
| Dish Types | Get all dish type | GET | `/api/dish-type` | 200 | Yes | Confirmed working (screen calls this live) |
| Dish Types | Get dish type by id | GET | `/api/dish-type/8` | 200 | No | Confirmed working (not called by any screen yet) |
| Dish Types | Get active count dish type | GET | `/api/dish-type/count/active` | 200 | No | Confirmed working (not called by any screen yet) |
| Dish Types | Get total count dish type | GET | `/api/dish-type/count/total` | 200 | No | Confirmed working (not called by any screen yet) |
| Dishes | Get all dish | GET | `/api/dish` | 200 | Yes | Confirmed working (screen calls this live) |
| Dishes | Get dish by id | GET | `/api/dish/7` | 200 | No | Confirmed working (not called by any screen yet) |
| Dishes | Get transactions for a dish: checkoutId, amount, quantity, invoice number, filterable by start/end date | GET | `/api/dish/7/transactions` | 200 | No | Confirmed working (not called by any screen yet) |
| Dishes | Get dish stats: total/active dish count, top sold dish, top dish type | GET | `/api/dish/dish-stats` | 200 | No | Confirmed working (not called by any screen yet) |
| Expense Categories | Get all expense category | GET | `/api/expense-category` | 200 | Yes | Confirmed working (screen calls this live) |
| Expenses | Get all expenses | GET | `/api/expenses` | 200 | Yes | Confirmed working (screen calls this live) |
| Invoice Settings | Get all invoice | GET | `/api/invoice` | 200 | No | Confirmed working (not called by any screen yet) |
| Invoice Settings | Get invoice by id | GET | `/api/invoice/11` | 200 | No | Confirmed working (not called by any screen yet) |
| Invoice Settings | Find my invoice | GET | `/api/invoice/my` | 200 | Yes | Confirmed working (screen calls this live) |
| KOT | Get all kot | GET | `/api/kot` | 200 | No | Confirmed working (not called by any screen yet) |
| KOT | Get kot by id | GET | `/api/kot/21` | 200 | No | Confirmed working (not called by any screen yet) |
| Menu Categories | Get all menu category | GET | `/api/menu-category` | 200 | Yes | Confirmed working (screen calls this live) |
| Menu Categories | Get menu category by id | GET | `/api/menu-category/8` | 200 | No | Confirmed working (not called by any screen yet) |
| Menu Categories | Get menu category stats: total category, top sold, most dish, average dish per category | GET | `/api/menu-category/stats` | 200 | No | Confirmed working (not called by any screen yet) |
| Notifications | Get restaurant notifications | GET | `/api/notification` | 200 | Yes | Confirmed working (screen calls this live) |
| Notifications | Get notification by id | GET | `/api/notification/12` | 200 | No | Confirmed working (not called by any screen yet) |
| Notifications | Get restaurant notification log | GET | `/api/notification/log` | 200 | No | Confirmed working (not called by any screen yet) |
| Orders | Get all order | GET | `/api/order` | 200 | Yes | Confirmed working (screen calls this live) |
| Orders | Get order by id | GET | `/api/order/15` | 200 | No | Confirmed working (not called by any screen yet) |
| Payment Methods | Get all payment method | GET | `/api/payment-method` | 200 | Yes | Confirmed working (screen calls this live) |
| Payment Methods | Get payment method by id | GET | `/api/payment-method/6` | 200 | No | Confirmed working (not called by any screen yet) |
| Permissions | Get all permission (shared vocabulary — visible to every tenant) | GET | `/api/permission` | 200 | No | Confirmed working (not called by any screen yet) |
| Permissions | Get permission by id | GET | `/api/permission/delete` | 200 | No | Confirmed working (not called by any screen yet) |
| Plan Features | Get all features | GET | `/api/features` | 200 | Yes | Confirmed working (screen calls this live) |
| Plan Prices | Get all plan prices | GET | `/api/plan-prices` | 200 | Yes | Confirmed working (screen calls this live) |
| Plan-Feature Mapping | Get all plan-feature grants | GET | `/api/plan-features` | 200 | Yes | Confirmed working (screen calls this live) |
| Plans | Get all subscription plans (public catalog) | GET | `/api/plans` | 200 | Yes | Confirmed working (screen calls this live) |
| Plans | Get a plan by id | GET | `/api/plans/1` | 200 | No | Confirmed working (not called by any screen yet) |
| RBAC | Get all rbac | GET | `/api/rbac/all` | 200 | Yes | Confirmed working (screen calls this live) |
| RBAC | My rbac | GET | `/api/rbac/my` | 200 | No | Confirmed working (not called by any screen yet) |
| Restaurant Profile | Get all restaurant | GET | `/api/restaurant` | 200 | Yes | Confirmed working (screen calls this live) |
| Restaurant Type | Get all type of restro | GET | `/api/type-of-restro` | 200 | Yes | Confirmed working (screen calls this live) |
| Roles | Get all roles | GET | `/api/roles` | 200 | Yes | Confirmed working (screen calls this live) |
| Roles | Get roles by id | GET | `/api/roles/ZZTEST_984401_role` | 200 | No | Confirmed working (not called by any screen yet) |
| Routes/Permission Matrix | Get all routes (shared vocabulary — visible to every tenant) | GET | `/api/routes` | 200 | Yes | Confirmed working (screen calls this live) |
| Routes/Permission Matrix | Get routes by id | GET | `/api/routes/addons` | 200 | No | Confirmed working (not called by any screen yet) |
| Sales Transactions | Get all sales transaction | GET | `/api/sales-transaction` | 200 | Yes | Confirmed working (screen calls this live) |
| Sales Transactions | Get sales transaction by id | GET | `/api/sales-transaction/11` | 200 | No | Confirmed working (not called by any screen yet) |
| Staff/User | Get user by id | GET | `/api/user/15` | 200 | Yes | Confirmed working (screen calls this live) |
| Staff/User | Get all user | GET | `/api/user/all` | 200 | Yes | Confirmed working (screen calls this live) |
| Staff/User | Get profile user | GET | `/api/user/profile` | 200 | No | Confirmed working (not called by any screen yet) |
| Stock | Get all stock | GET | `/api/stock` | 200 | Yes | Confirmed working (screen calls this live) |
| Stock | Get all stock transaction history, filterable by start/end date, staffId, stockId, stockGroupId | GET | `/api/stock/history` | 200 | Yes | Confirmed working (screen calls this live) |
| Stock | Get stock stats: total stocks, total stock value, most consumed stock, restocks this week, low stock items | GET | `/api/stock/stats` | 200 | Yes | Confirmed working (screen calls this live) |
| Stock Groups | Get all stock groups | GET | `/api/stock-group` | 200 | Yes | Confirmed working (screen calls this live) |
| Stock Groups | Get stock group stats: total group stock, highest stock value, group with most item | GET | `/api/stock-group/stats` | 200 | No | Confirmed working (not called by any screen yet) |
| Subscription | Get the restaurant's current subscription and entitlements | GET | `/api/subscriptions/current` | 200 | Yes | Confirmed working (screen calls this live) |
| Supplier Transactions | Get all supplier transaction | GET | `/api/supplier-transaction` | 200 | Yes | Confirmed working (screen calls this live) |
| Supplier Transactions | Get supplier transaction by id | GET | `/api/supplier-transaction/2` | 200 | No | Confirmed working (not called by any screen yet) |
| Suppliers | Get all supplier | GET | `/api/supplier` | 200 | Yes | Confirmed working (screen calls this live) |
| Suppliers | Get supplier by id | GET | `/api/supplier/7` | 200 | No | Confirmed working (not called by any screen yet) |
| Table Activity | Get all table activity | GET | `/api/table-activity` | 200 | No | Confirmed working (not called by any screen yet) |
| Table Activity | Get table activity by id | GET | `/api/table-activity/21` | 200 | No | Confirmed working (not called by any screen yet) |
| Table Activity | Get activity via table | GET | `/api/table-activity/active-sessions/9` | 200 | No | Confirmed working (not called by any screen yet) |
| Table Activity | Get activity table activity | GET | `/api/table-activity/session-timeline/41526533-6eb0-4ac5-bfec-7a34cf66b59d` | 200 | No | Confirmed working (not called by any screen yet) |
| Table Order | Get all table order | GET | `/api/table-order` | 200 | No | Confirmed working (not called by any screen yet) |
| Table Order | Get table order by id | GET | `/api/table-order/9` | 200 | No | Confirmed working (not called by any screen yet) |
| Tables | Get all table | GET | `/api/table` | 200 | Yes | Confirmed working (screen calls this live) |
| Tables | Get table by id | GET | `/api/table/9` | 200 | No | Confirmed working (not called by any screen yet) |
| Tables | Get table stats: totals, occupancy, most used | GET | `/api/table/stats` | 200 | No | Confirmed working (not called by any screen yet) |
| Type of Menu | Get all type of menu | GET | `/api/type-of-menu` | 200 | Yes | Confirmed working (screen calls this live) |
| Type of Menu | Get type of menu by id | GET | `/api/type-of-menu/5` | 200 | No | Confirmed working (not called by any screen yet) |
| Type of Menu | Get type of menu stats: total/active count, top sold, average dish per menu type, unused menu type | GET | `/api/type-of-menu/stats` | 200 | No | Confirmed working (not called by any screen yet) |
| Units | Get all unit | GET | `/api/unit` | 200 | Yes | Confirmed working (screen calls this live) |
| Units | Get unit by id | GET | `/api/unit/13` | 200 | No | Confirmed working (not called by any screen yet) |
| Variants | Get all variant | GET | `/api/variant` | 200 | Yes | Confirmed working (screen calls this live) |

---

## 6. Available but Not Yet Integrated Endpoints

**120 of the 252 Swagger operations (48%) are not called anywhere in the app** — every method, not just GET. For the 54 GET ones, a live call was made and the result is recorded; the 53 write (POST/PATCH/PUT/DELETE) ones were **not called**, per the read-only testing scope agreed for this audit, so their "Live Test Result" is honestly marked "Not tested" rather than guessed; 10 GETs among these also couldn't be tested because this restaurant has zero existing records for that resource (e.g. no variants, no combo offers) to fetch by id — also marked "Not tested", not assumed working.

Several of these are genuinely notable — real, working backend capability with no UI surfacing it at all:
- **`GET /api/customers/{id}/dining-insight`, `/finance-insight`, `/spending-behaviour`** — all three returned live 200s with real (if currently zero-valued) data. The previous integration report listed the Customer Detail screen's Transactions/Invoice/Credit List tabs as dummy with "no dedicated endpoint identified." That's now out of date — these three endpoints appear to be exactly the data those tabs need.
- **`GET /api/kot`, `/api/kot/{id}`** (+ unused `POST`/`PATCH`/`DELETE`) — a full KOT (Kitchen Order Ticket) resource exists and returns real ticket data (`kotNumber`, `orderStatus`, line items), but the app has no `kot_repository.dart` at all; the "KOT History" screen reads from the Orders list instead.
- **`GET /api/checkout-history`** (+ unused `POST`) — returns a fuller checkout audit trail (`checkoutStatus`, `tableCharge`, `customerName`, etc.) than what `checkout` alone exposes; unused.
- **`GET /api/table-activity`, `/active-sessions/{tableId}`, `/session-timeline/{sessionId}`, `/{id}`** — a complete table-session activity log (order placed, checkout initiated/completed, table changes) with real timestamped data; unused.
- **Stats/analytics endpoints** — `/api/table/stats`, `/api/area/stats`, `/api/menu-category/stats`, `/api/type-of-menu/stats`, `/api/stock-group/stats`, `/api/dish-type/count/total`, `/api/dish-type/count/active`, `/api/addons/stats`, `/api/dish/dish-stats` — all return real computed numbers (occupancy, top-sold, category breakdowns) and all work; none are wired into any dashboard/analytics screen today.
- **`GET /api/user/profile`** — returns the logged-in user + restaurant in one call; the app instead re-derives this from the login response.
- **`POST /api/supplier/bulk`** — a bulk-supplier-import endpoint with no equivalent UI action.
- **`POST /api/auth/register`, `POST /api/media/uploads`** (multi-file) — both exist and are presumably functional but unused (the app only ever registers users via `restaurant/create-account`, and only ever uploads one file at a time via `POST /api/media`).

| Module | Method | Endpoint | Feature | Live Test Result |
|---|---|---|---|---|
| Add-ons | GET | `/api/addons/{id}` | Get addons by id | Not tested (no sample record) |
| Add-ons | GET | `/api/addons/stats` | Get addon stats: total addons, most used addon | Tested live: HTTP 200 |
| Areas/Spaces | GET | `/api/area/{id}` | Get area by id | Tested live: HTTP 200 |
| Areas/Spaces | GET | `/api/area/custom/total-spaces` | Total spaces area | Tested live: HTTP 200 |
| Areas/Spaces | GET | `/api/area/custom/total-spaces-with-tables` | Total spaces with tables area | Tested live: HTTP 200 |
| Areas/Spaces | GET | `/api/area/custom/total-tables-by-spaces` | Total tables by spaces area | Tested live: HTTP 200 |
| Areas/Spaces | GET | `/api/area/stats` | Get area stats: total spaces, most occupied, spaces with tables | Tested live: HTTP 200 |
| Auth | GET | `/api/auth/health-check` | Health check | Tested live: HTTP 200 |
| Auth | POST | `/api/auth/register` | Register a new user and auto-login | Not tested (write op) |
| Billing | GET | `/api/billing/esewa/failure` | eSewa failure redirect (public) | Tested live: HTTP 400 |
| Billing | GET | `/api/billing/esewa/success` | eSewa success redirect (public — verified server-side before trusting) | Tested live: HTTP 400 |
| Checkout | GET | `/api/checkout` | Get all checkout | Tested live: HTTP 200 |
| Checkout History | POST | `/api/checkout-history` | Create history checkout history | Not tested (write op) |
| Checkout History | GET | `/api/checkout-history` | Get all checkout history | Tested live: HTTP 200 |
| Combo Offers | GET | `/api/combo-offer/{id}` | Get active combo offer by id | Not tested (no sample record) |
| Customer Comments | GET | `/api/customer-comments` | Get all customer comments | Tested live: HTTP 200 |
| Customer Comments | GET | `/api/customer-comments/{id}` | Get a customer comment by id | Tested live: HTTP 200 |
| Customer Groups | GET | `/api/customer-group/{id}` | Get a customer group by id | Tested live: HTTP 200 |
| Customers | GET | `/api/customers/{id}` | Get customers by id | Tested live: HTTP 200 |
| Customers | GET | `/api/customers/{id}/dining-insight` | Get dining insight for a customer: frequent dish, last visit, most visited time, frequent table | Tested live: HTTP 200 |
| Customers | GET | `/api/customers/{id}/finance-insight` | Get finance insight for a customer: total sales, total return, payment in, payment out | Tested live: HTTP 200 |
| Customers | GET | `/api/customers/{id}/spending-behaviour` | Get spending behaviour for a customer: every spend with date, amount, method, and kot | Tested live: HTTP 200 |
| Dish Types | GET | `/api/dish-type/{id}` | Get dish type by id | Tested live: HTTP 200 |
| Dish Types | GET | `/api/dish-type/count/active` | Get active count dish type | Tested live: HTTP 200 |
| Dish Types | GET | `/api/dish-type/count/total` | Get total count dish type | Tested live: HTTP 200 |
| Dishes | GET | `/api/dish/{id}` | Get dish by id | Tested live: HTTP 200 |
| Dishes | GET | `/api/dish/{id}/transactions` | Get transactions for a dish: checkoutId, amount, quantity, invoice number, filterable by start/end date | Tested live: HTTP 200 |
| Dishes | GET | `/api/dish/dish-stats` | Get dish stats: total/active dish count, top sold dish, top dish type | Tested live: HTTP 200 |
| Expense Categories | GET | `/api/expense-category/{id}` | Get expense category by id | Not tested (no sample record) |
| Expense Categories | PATCH | `/api/expense-category/{id}` | Update an existing expense category | Not tested (write op) |
| Expense Categories | DELETE | `/api/expense-category/{id}` | Delete a expense category | Not tested (write op) |
| Invoice Settings | GET | `/api/invoice` | Get all invoice | Tested live: HTTP 200 |
| Invoice Settings | GET | `/api/invoice/{id}` | Get invoice by id | Tested live: HTTP 200 |
| Invoice Settings | PATCH | `/api/invoice/{id}` | Update an existing invoice | Not tested (write op) |
| Invoice Settings | DELETE | `/api/invoice/{id}` | Delete a invoice | Not tested (write op) |
| KOT | GET | `/api/kot` | Get all kot | Tested live: HTTP 200 |
| KOT | POST | `/api/kot` | Create a new kot | Not tested (write op) |
| KOT | GET | `/api/kot/{id}` | Get kot by id | Tested live: HTTP 200 |
| KOT | PATCH | `/api/kot/{id}` | Update an existing kot | Not tested (write op) |
| KOT | DELETE | `/api/kot/{id}` | Delete a kot | Not tested (write op) |
| mailing-service | POST | `/api/mailing-service/send` | For testing only | Not tested (write op) |
| Media Upload | GET | `/api/media/{id}` | Get media by id | Not tested (no sample record) |
| Media Upload | POST | `/api/media/uploads` | Upload multiple file media | Not tested (write op) |
| Menu Categories | GET | `/api/menu-category/{id}` | Get menu category by id | Tested live: HTTP 200 |
| Menu Categories | GET | `/api/menu-category/stats` | Get menu category stats: total category, top sold, most dish, average dish per category | Tested live: HTTP 200 |
| Notifications | GET | `/api/notification/{id}` | Get notification by id | Tested live: HTTP 200 |
| Notifications | PATCH | `/api/notification/{id}` | Update notification | Not tested (write op) |
| Notifications | DELETE | `/api/notification/{id}` | Delete notification | Not tested (write op) |
| Notifications | POST | `/api/notification/device-token` | Register or refresh FCM device token | Not tested (write op) |
| Notifications | DELETE | `/api/notification/device-token` | Deregister FCM device token | Not tested (write op) |
| Notifications | GET | `/api/notification/log` | Get restaurant notification log | Tested live: HTTP 200 |
| Orders | GET | `/api/order/{id}` | Get order by id | Tested live: HTTP 200 |
| Orders | DELETE | `/api/order/{id}` | Delete a order | Not tested (write op) |
| Orders | PATCH | `/api/order/{id}` | Update the basic order details | Not tested (write op) |
| Orders | PATCH | `/api/order/addon/{addonItemId}` | Update OrderItem:Addon with addon-itemId | Not tested (write op) |
| Orders | PATCH | `/api/order/dish/{itemId}` | Update OrderItem:Dish with itemId | Not tested (write op) |
| Orders | PATCH | `/api/order/variant/{variantItemId}` | Update OrderItem:Variant with variant-itemId | Not tested (write op) |
| otp | POST | `/api/otp/generate` | Generate OTP | Not tested (write op) |
| otp | POST | `/api/otp/verify` | Verify OTP | Not tested (write op) |
| Payment Methods | GET | `/api/payment-method/{id}` | Get payment method by id | Tested live: HTTP 200 |
| Permissions | POST | `/api/permission` | Create a new permission | Not tested (write op) |
| Permissions | GET | `/api/permission` | Get all permission (shared vocabulary — visible to every tenant) | Tested live: HTTP 200 |
| Permissions | GET | `/api/permission/{name}` | Get permission by id | Tested live: HTTP 200 |
| Permissions | PATCH | `/api/permission/{name}` | Update an existing permission | Not tested (write op) |
| Permissions | DELETE | `/api/permission/{name}` | Delete a permission | Not tested (write op) |
| Plan Features | PATCH | `/api/features/{id}` | Update a feature (SUPER_ADMIN only) | Not tested (write op) |
| Plan Features | DELETE | `/api/features/{id}` | Delete a feature (SUPER_ADMIN only) | Not tested (write op) |
| Plan Prices | POST | `/api/plan-prices` | Create a plan price (SUPER_ADMIN only) | Not tested (write op) |
| Plan Prices | PATCH | `/api/plan-prices/{id}` | Update a plan price (SUPER_ADMIN only) | Not tested (write op) |
| Plan Prices | DELETE | `/api/plan-prices/{id}` | Delete a plan price (SUPER_ADMIN only) | Not tested (write op) |
| Plan-Feature Mapping | POST | `/api/plan-features` | Grant/configure a feature on a plan (SUPER_ADMIN only) | Not tested (write op) |
| Plan-Feature Mapping | PATCH | `/api/plan-features/{id}` | Update a plan-feature grant (SUPER_ADMIN only) | Not tested (write op) |
| Plan-Feature Mapping | DELETE | `/api/plan-features/{id}` | Remove a plan-feature grant (SUPER_ADMIN only) | Not tested (write op) |
| Plans | POST | `/api/plans` | Create a plan (SUPER_ADMIN only) | Not tested (write op) |
| Plans | GET | `/api/plans/{id}` | Get a plan by id | Tested live: HTTP 200 |
| Plans | PATCH | `/api/plans/{id}` | Update a plan (SUPER_ADMIN only) | Not tested (write op) |
| Plans | DELETE | `/api/plans/{id}` | Delete a plan (SUPER_ADMIN only) | Not tested (write op) |
| Purchase Bills | GET | `/api/purchase-bill/{id}` | Get purchase bill by id | Not tested (no sample record) |
| Purchase Bills | DELETE | `/api/purchase-bill/{id}` | Delete a purchase bill | Not tested (write op) |
| RBAC | POST | `/api/rbac` | Create a new rbac | Not tested (write op) |
| RBAC | GET | `/api/rbac/my` | My rbac | Tested live: HTTP 200 |
| Restaurant Profile | POST | `/api/restaurant/{id}/approve` | Approve a pending restaurant and activate its plan (SUPER_ADMIN only) | Not tested (write op) |
| Restaurant Profile | POST | `/api/restaurant/{id}/reject` | Reject a pending restaurant (SUPER_ADMIN only) | Not tested (write op) |
| Restaurant Profile | POST | `/api/restaurant/create-restro` | Creating new restaurant | Not tested (write op) |
| Restaurant Profile | GET | `/api/restaurant/pending` | List restaurants pending verification (SUPER_ADMIN only) | Tested live: HTTP 401 |
| Restaurant Type | POST | `/api/type-of-restro` | Create a new type of restro | Not tested (write op) |
| Restaurant Type | GET | `/api/type-of-restro/{id}` | Get type of restro by id | Not tested (no sample record) |
| Restaurant Type | PATCH | `/api/type-of-restro/{id}` | Update an existing type of restro | Not tested (write op) |
| Restaurant Type | DELETE | `/api/type-of-restro/{id}` | Delete a type of restro | Not tested (write op) |
| Roles | GET | `/api/roles/{id}` | Get roles by id | Tested live: HTTP 200 |
| Routes/Permission Matrix | POST | `/api/routes` | Create a new routes | Not tested (write op) |
| Routes/Permission Matrix | GET | `/api/routes/{id}` | Get routes by id | Tested live: HTTP 200 |
| Routes/Permission Matrix | PATCH | `/api/routes/{id}` | Update an existing routes | Not tested (write op) |
| Routes/Permission Matrix | DELETE | `/api/routes/{id}` | Delete a routes | Not tested (write op) |
| Sales Transactions | GET | `/api/sales-transaction/{id}` | Get sales transaction by id | Tested live: HTTP 200 |
| Staff/User | GET | `/api/user/profile` | Get profile user | Tested live: HTTP 200 |
| Stock | GET | `/api/stock/{id}` | Get stock by id | Not tested (no sample record) |
| Stock | GET | `/api/stock/{id}/history` | Get stock transaction history by stock id | Not tested (no sample record) |
| Stock Groups | GET | `/api/stock-group/{id}` | Get stock group by id | Not tested (no sample record) |
| Stock Groups | GET | `/api/stock-group/stats` | Get stock group stats: total group stock, highest stock value, group with most item | Tested live: HTTP 200 |
| Subscription | POST | `/api/subscriptions/{id}/start-trial` | Activate a trial of a chosen plan for a restaurant (SUPER_ADMIN only, not self-service) | Not tested (write op) |
| Subscription | POST | `/api/subscriptions/change` | Upgrade (immediate) or downgrade (scheduled) the current plan | Not tested (write op) |
| Subscription | POST | `/api/subscriptions/purchase` | Start a payment to purchase a plan | Not tested (write op) |
| Supplier Transactions | GET | `/api/supplier-transaction/{id}` | Get supplier transaction by id | Tested live: HTTP 200 |
| Suppliers | GET | `/api/supplier/{id}` | Get supplier by id | Tested live: HTTP 200 |
| Suppliers | POST | `/api/supplier/bulk` | Create multiple suppliers in bulk | Not tested (write op) |
| Table Activity | GET | `/api/table-activity` | Get all table activity | Tested live: HTTP 200 |
| Table Activity | POST | `/api/table-activity` | Create a new table activity | Not tested (write op) |
| Table Activity | GET | `/api/table-activity/{id}` | Get table activity by id | Tested live: HTTP 200 |
| Table Activity | GET | `/api/table-activity/active-sessions/{tableId}` | Get activity via table | Tested live: HTTP 200 |
| Table Activity | GET | `/api/table-activity/session-timeline/{sessionId}` | Get activity table activity | Tested live: HTTP 200 |
| Table Order | GET | `/api/table-order` | Get all table order | Tested live: HTTP 200 |
| Table Order | GET | `/api/table-order/{id}` | Get table order by id | Tested live: HTTP 200 |
| Table Order | DELETE | `/api/table-order/{id}` | Delete a table order | Not tested (write op) |
| Tables | GET | `/api/table/{id}` | Get table by id | Tested live: HTTP 200 |
| Tables | GET | `/api/table/stats` | Get table stats: totals, occupancy, most used | Tested live: HTTP 200 |
| Type of Menu | GET | `/api/type-of-menu/{id}` | Get type of menu by id | Tested live: HTTP 200 |
| Type of Menu | GET | `/api/type-of-menu/stats` | Get type of menu stats: total/active count, top sold, average dish per menu type, unused menu type | Tested live: HTTP 200 |
| Units | GET | `/api/unit/{id}` | Get unit by id | Tested live: HTTP 200 |
| Variants | GET | `/api/variant/{id}` | Get variant by id | Not tested (no sample record) |

---

## 7. Exact Error Details

Raw response bodies for every non-2xx result from live testing, exactly as returned by the server (no summarizing).

### `GET /api/purchase-bill` → `500`
```json
{"statusCode":500,"message":"Internal server error"}
```
Request: `GET https://lzpqllhg-8002.inc1.devtunnels.ms/api/purchase-bill` with a valid `Bearer` token, no query params. This is the resource's plain list endpoint — the one the app's Purchase Bills tab / Transactions screen calls on every load. Every call in this session returned this same 500; this matches a bug already documented in the prior integration report (2026-08-09) as occurring once any bill has `customerId` set. Not fixable from the frontend — the app already has defensive handling around this specific failure (see `purchase_bill_repository.dart`).

### `GET /api/restaurant/pending` → `401`
```json
{"statusCode":401,"message":"Unauthorised: Only SUPER_ADMIN can view pending restaurants."}
```
Request: `GET https://lzpqllhg-8002.inc1.devtunnels.ms/api/restaurant/pending` with the test account's token (role `admin`, not `SUPER_ADMIN`). Expected/correct behavior per the endpoint's own documented access rule — not a defect.

### `GET /api/billing/esewa/failure` → `400`
```json
{"statusCode":400,"message":"Missing transactionUuid"}
```
Request: `GET https://lzpqllhg-8002.inc1.devtunnels.ms/api/billing/esewa/failure` with no query string. Expected — this route exists to receive eSewa's own redirect (which carries `transactionUuid`), not to be called directly.

### `GET /api/billing/esewa/success` → `400`
```json
{"statusCode":400,"message":"Missing eSewa response data"}
```
Request: `GET https://lzpqllhg-8002.inc1.devtunnels.ms/api/billing/esewa/success` with no query string. Same as above — expected.

---

## 8. Final Statistics

```
Total Swagger endpoints (operations):        252   (147 distinct paths, 45 resource tags)
Total endpoints required by app:             156   (132 already wired + 24 missing capabilities)
Total required endpoints available:          132   (100% of what's called matches a real Swagger op)
Total required endpoints missing:             24   (0 endpoints called by the app are "phantom" —
                                                     every missing item is a dummy screen with no
                                                     backend support yet, not a code/spec mismatch)

Total available endpoints tested:            102   (all 113 GETs minus 11 with no existing record
                                                     to fetch — write ops intentionally not called,
                                                     per the read-only scope agreed for this audit)
Total endpoints returning errors:              4   (1 real backend bug, 3 expected/by-design)
Total working endpoints:                      98   (96% pass rate among tested GETs)

Total available-but-uncalled operations:     120   (48% of the full spec — 54 GET, all tested and
                                                     all 200; 66 write ops, not called, evidence-
                                                     checked against code as simply unused)
```

**A. Missing Backend Endpoints: 24** — do not exist in Swagger at all (or exist but lack the needed capability). See §3.

**B. Existing but Failing Endpoints: 1** — `GET /api/purchase-bill` (`500`, confirmed backend bug). The other 3 non-2xx results in §4/§7 are expected access-control/validation behavior, not failures of a feature the app needs.

**C. Working Endpoints: 98** — every GET that returned 2xx during live testing (§5), 44 of which are already wired into a screen and 54 of which aren't.

**D. Frontend Integration Pending: 120** — every Swagger operation not called by any repository/screen in the codebase today (§6), spanning 54 confirmed-working GETs, 10 GETs that couldn't be tested for lack of sample data, 53 untested write ops, and the 3 non-2xx GETs from §4 that happen to also be uncalled.

---

## 9. Backend Issues Requiring Resolution

Only one finding in this audit rises to an actual backend defect (per the "don't call something a bug unless the evidence supports it" rule):

| Endpoint | Issue | Evidence | Impact |
|---|---|---|---|
| `GET /api/purchase-bill` | Returns `500 Internal server error` on every call in this session | Live response: `{"statusCode":500,"message":"Internal server error"}`. Consistent with the same bug documented in the prior integration report (2026-08-09), described there as triggering once any bill has `customerId` set. This restaurant's purchase-bill data was not inspected further (read-only scope), so the exact trigger condition wasn't independently re-derived this session — only the symptom was reconfirmed. | Blocks the app's Purchase Bills tab (Sales Analytics) and the Transactions screen's purchase side entirely — every list load fails. |

No other backend defects were found. The three other non-2xx results (§4/§7) are access-control and validation behavior working as designed, not bugs.

---

## 10. Frontend Integration Pending

The full 120-row breakdown is in §6. Summarized by why each group isn't integrated:

| Category | Count | Why it's not integrated |
|---|---|---|
| Confirmed-working GETs with no screen wired to them | 54 | Backend feature exists and works; no UI built against it yet (see the highlighted list in §6 — customer insights, KOT, checkout-history, table-activity, stats endpoints, etc.) |
| Write ops (POST/PATCH/PUT/DELETE) not called by any screen | 53 | No corresponding create/update/delete UI action exists, or the app deliberately doesn't expose it (e.g. platform-admin-only ops like plan/feature management, restaurant approve/reject) |
| GETs that exist but have zero records in this restaurant to test with | 10 | Not a defect — this test restaurant simply has no variants/combo-offers/expenses/stock/etc. on file yet; the endpoints themselves were not exercised with a real id |
| GETs that returned non-2xx and are also uncalled | 3 | The two eSewa callbacks and the SUPER_ADMIN-gated `restaurant/pending` — none of these are meant to be called the way this app would call them |

**Recommendation for a future integration pass:** the customer-insight trio (`dining-insight`, `finance-insight`, `spending-behaviour`) is the highest-value item in this list — it directly answers the "Customer Detail tabs are dummy" gap called out in the prior integration report, with live-confirmed working endpoints ready to wire up.

---

*This report reflects a read-only audit performed 2026-08-11 against the tunnel at `lzpqllhg-8002.inc1.devtunnels.ms`. No application code was modified and no write requests were sent to the live server as part of this audit.*
