/// One weekday's serving window for the Delivery service, edited on the
/// Delivery Time screen (Manage tab > "Delivery Time").
class DeliveryDaySchedule {
  final String day;
  bool isClosed;
  bool is24hrOpen;
  int openHour;
  int openMinute;
  String openMeridiem;
  int closeHour;
  int closeMinute;
  String closeMeridiem;

  DeliveryDaySchedule({
    required this.day,
    this.isClosed = false,
    this.is24hrOpen = false,
    this.openHour = 12,
    this.openMinute = 0,
    this.openMeridiem = 'AM',
    this.closeHour = 11,
    this.closeMinute = 59,
    this.closeMeridiem = 'PM',
  });

  DeliveryDaySchedule copy() => DeliveryDaySchedule(
    day: day,
    isClosed: isClosed,
    is24hrOpen: is24hrOpen,
    openHour: openHour,
    openMinute: openMinute,
    openMeridiem: openMeridiem,
    closeHour: closeHour,
    closeMinute: closeMinute,
    closeMeridiem: closeMeridiem,
  );

  static List<DeliveryDaySchedule> defaultWeek() => const [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
  ].map((d) => DeliveryDaySchedule(day: d)).toList();
}
