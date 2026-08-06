/// A tax/VAT rate managed from Manage > Setting > Tax & Rates.
class TaxRate {
  final String name;
  final double rate;
  final String notes;

  const TaxRate({required this.name, required this.rate, this.notes = ''});
}
