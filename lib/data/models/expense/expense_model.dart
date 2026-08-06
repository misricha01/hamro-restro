/// An expense category (backend: `/api/expense-category`).
class ExpenseCategory {
  final String id;
  final String name;
  final String? description;

  const ExpenseCategory({required this.id, required this.name, this.description});

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }
}

/// A single expense entry (backend: `/api/expenses`). The response shape
/// isn't documented in Swagger beyond the create/update DTOs, so category
/// and payment-method names are parsed defensively from a possible embedded
/// object and fall back to null (the screen then looks the name up locally
/// from the already-fetched category/payment-method lists).
class Expense {
  final String id;
  final String title;
  final String categoryId;
  final String? categoryName;
  final double amount;
  final DateTime? expenseDate;
  final DateTime? paymentDate;
  final DateTime? dueDate;
  final String paymentStatus;
  final String paymentMethodId;
  final String? paymentMethodName;
  final String? description;

  const Expense({
    required this.id,
    required this.title,
    required this.categoryId,
    this.categoryName,
    required this.amount,
    this.expenseDate,
    this.paymentDate,
    this.dueDate,
    required this.paymentStatus,
    required this.paymentMethodId,
    this.paymentMethodName,
    this.description,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    final paymentMethod = json['paymentMethod'];
    return Expense(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      categoryId: (json['categoryId'] ?? (category is Map ? category['id'] : null))?.toString() ?? '',
      categoryName: category is Map ? category['name'] as String? : null,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      expenseDate: DateTime.tryParse((json['expense_date'] ?? '').toString()),
      paymentDate: DateTime.tryParse((json['payment_date'] ?? '').toString()),
      dueDate: DateTime.tryParse((json['due_date'] ?? '').toString()),
      paymentStatus: json['payment_status'] as String? ?? '',
      paymentMethodId: (json['paymentMethodId'] ?? (paymentMethod is Map ? paymentMethod['id'] : null))?.toString() ?? '',
      paymentMethodName: paymentMethod is Map ? paymentMethod['name'] as String? : null,
      description: json['description'] as String?,
    );
  }
}
