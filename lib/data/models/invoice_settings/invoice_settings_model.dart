/// Invoice print-template settings for this restaurant (backend:
/// `GET`/`PATCH /api/invoice/my`) — which fields appear on a printed
/// receipt, not a record of past invoices. Booleans default to `true` so a
/// freshly-fetched/unconfigured settings doc renders with everything on,
/// matching the reference design's default look.
class InvoiceSettings {
  final String? restaurantName;
  final String? panNo;
  final String? footerRemarks;
  final bool billNo;
  final bool date;
  final bool tableNo;
  final bool sn;
  final bool particular;
  final bool quantity;
  final bool rate;
  final bool amount;
  final bool customerDiscount;
  final bool subTotal;
  final bool discount;
  final bool taxAmount;
  final bool taxableAmount;
  final bool grandTotal;
  final bool amountInWords;
  final bool remarks;
  final bool paymentMode;
  final bool kotNumber;
  final bool billBy;
  final bool totalAmount;

  const InvoiceSettings({
    this.restaurantName,
    this.panNo,
    this.footerRemarks,
    this.billNo = true,
    this.date = true,
    this.tableNo = true,
    this.sn = true,
    this.particular = true,
    this.quantity = true,
    this.rate = true,
    this.amount = true,
    this.customerDiscount = true,
    this.subTotal = true,
    this.discount = true,
    this.taxAmount = true,
    this.taxableAmount = true,
    this.grandTotal = true,
    this.amountInWords = true,
    this.remarks = true,
    this.paymentMode = true,
    this.kotNumber = true,
    this.billBy = true,
    this.totalAmount = true,
  });

  factory InvoiceSettings.fromJson(Map<String, dynamic> json) {
    bool flag(String key) => json[key] as bool? ?? true;
    return InvoiceSettings(
      restaurantName: json['restaurant_name'] as String?,
      panNo: json['pan_no'] as String?,
      footerRemarks: json['footer_remarks'] as String?,
      billNo: flag('bill_no'),
      date: flag('date'),
      tableNo: flag('table_no'),
      sn: flag('sn'),
      particular: flag('particular'),
      quantity: flag('quantity'),
      rate: flag('rate'),
      amount: flag('amount'),
      customerDiscount: flag('customer_discount'),
      subTotal: flag('sub_total'),
      discount: flag('discount'),
      taxAmount: flag('tax_amount'),
      taxableAmount: flag('taxable_amount'),
      grandTotal: flag('grand_total'),
      amountInWords: flag('amount_in_words'),
      remarks: flag('remarks'),
      paymentMode: flag('payment_mode'),
      kotNumber: flag('kot_number'),
      billBy: flag('bill_by'),
      totalAmount: flag('total_amount'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (restaurantName != null) 'restaurant_name': restaurantName,
      if (panNo != null) 'pan_no': panNo,
      if (footerRemarks != null) 'footer_remarks': footerRemarks,
      'bill_no': billNo,
      'date': date,
      'table_no': tableNo,
      'sn': sn,
      'particular': particular,
      'quantity': quantity,
      'rate': rate,
      'amount': amount,
      'customer_discount': customerDiscount,
      'sub_total': subTotal,
      'discount': discount,
      'tax_amount': taxAmount,
      'taxable_amount': taxableAmount,
      'grand_total': grandTotal,
      'amount_in_words': amountInWords,
      'remarks': remarks,
      'payment_mode': paymentMode,
      'kot_number': kotNumber,
      'bill_by': billBy,
      'total_amount': totalAmount,
    };
  }

  InvoiceSettings copyWith({
    String? restaurantName,
    String? panNo,
    String? footerRemarks,
    bool? billNo,
    bool? date,
    bool? tableNo,
    bool? sn,
    bool? particular,
    bool? quantity,
    bool? rate,
    bool? amount,
    bool? customerDiscount,
    bool? subTotal,
    bool? discount,
    bool? taxAmount,
    bool? taxableAmount,
    bool? grandTotal,
    bool? amountInWords,
    bool? remarks,
    bool? paymentMode,
    bool? kotNumber,
    bool? billBy,
    bool? totalAmount,
  }) {
    return InvoiceSettings(
      restaurantName: restaurantName ?? this.restaurantName,
      panNo: panNo ?? this.panNo,
      footerRemarks: footerRemarks ?? this.footerRemarks,
      billNo: billNo ?? this.billNo,
      date: date ?? this.date,
      tableNo: tableNo ?? this.tableNo,
      sn: sn ?? this.sn,
      particular: particular ?? this.particular,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
      customerDiscount: customerDiscount ?? this.customerDiscount,
      subTotal: subTotal ?? this.subTotal,
      discount: discount ?? this.discount,
      taxAmount: taxAmount ?? this.taxAmount,
      taxableAmount: taxableAmount ?? this.taxableAmount,
      grandTotal: grandTotal ?? this.grandTotal,
      amountInWords: amountInWords ?? this.amountInWords,
      remarks: remarks ?? this.remarks,
      paymentMode: paymentMode ?? this.paymentMode,
      kotNumber: kotNumber ?? this.kotNumber,
      billBy: billBy ?? this.billBy,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}
