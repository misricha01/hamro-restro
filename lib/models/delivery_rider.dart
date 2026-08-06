enum VehicleType { twoWheeler, fourWheeler }

extension VehicleTypeLabel on VehicleType {
  String get label => this == VehicleType.twoWheeler ? 'Two Wheeler' : 'Four Wheeler';
}

class DeliveryRider {
  final String name;
  final String? imageSource;
  final String? phoneNumber;
  final String? vehicleNumber;
  final VehicleType? vehicleType;

  DeliveryRider({
    required this.name,
    this.imageSource,
    this.phoneNumber,
    this.vehicleNumber,
    this.vehicleType,
  });
}
