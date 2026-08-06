/// What a [Printer] is used for — mirrors the "Select what you print in this
/// Printer?" choice on the Add/Edit Printer screen.
enum PrintFor { kotAndBot, billsAndReceipts }

/// A configured printer, managed from Manage > Setting > Printer.
class Printer {
  final String name;
  final String paperWidth;
  final String ipAddress;
  final PrintFor printFor;
  final bool fullKot;
  final bool kot;
  final bool bot;

  const Printer({
    required this.name,
    required this.paperWidth,
    required this.ipAddress,
    required this.printFor,
    this.fullKot = true,
    this.kot = false,
    this.bot = false,
  });
}
