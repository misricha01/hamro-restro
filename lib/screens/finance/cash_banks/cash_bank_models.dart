// Shared demo data + models for the Cash & Banks module (Account / Modes /
// Balance Transfer tabs, the reusable account-detail screen, and the Add
// Account / Add Payment Mode forms). Mutable top-level lists mirror the
// pattern already used by Add Income's account-head lists elsewhere in the
// Finance feature set — no backend exists yet for any Finance quick action.

class CashBankMode {
  final String code;
  final String label;
  CashBankMode(this.code, this.label);
}

class CashBankAccount {
  final String initials;
  final String name;
  final String accountType;
  final double balance;
  final bool active;
  final List<String> modeLabels;

  CashBankAccount({
    required this.initials,
    required this.name,
    required this.accountType,
    required this.balance,
    required this.modeLabels,
    this.active = true,
  });
}

/// Two-letter code shown in a mode's avatar chip, derived the same way the
/// reference design does: first letter of each word for multi-word labels
/// ("Bank Transfer" -> BT, "Nepal Pay" -> NP), first two letters otherwise
/// ("Cash" / "Card" -> CA, "Fonepay" -> FO).
String cashBankModeCode(String label) {
  final words = label.split(' ');
  if (words.length > 1) return words.map((w) => w[0]).take(2).join().toUpperCase();
  return label.length >= 2 ? label.substring(0, 2).toUpperCase() : label.toUpperCase();
}

final List<CashBankMode> cashBankModes = [
  CashBankMode('BT', 'Bank Transfer'),
  CashBankMode('CA', 'Card'),
  CashBankMode('CA', 'Cash'),
  CashBankMode('FO', 'Fonepay'),
  CashBankMode('NP', 'Nepal Pay'),
];

final List<CashBankAccount> cashBankAccounts = [
  CashBankAccount(initials: 'CO', name: 'Counter', accountType: 'Cash', balance: 0, modeLabels: ['Cash']),
  CashBankAccount(initials: 'BA', name: 'Bank Account', accountType: 'Bank', balance: 0, modeLabels: ['Card', 'Fonepay', 'Nepal Pay']),
  CashBankAccount(initials: 'OA', name: "Owner's Account", accountType: 'Cash', balance: 0, modeLabels: ['Bank Transfer']),
];

/// Account names each [CashBankMode.label] is currently settled into,
/// shown as "Accounts: ..." on the Modes tab.
List<String> cashBankAccountsForMode(String modeLabel) {
  return cashBankAccounts.where((a) => a.modeLabels.contains(modeLabel)).map((a) => a.name).toList();
}
