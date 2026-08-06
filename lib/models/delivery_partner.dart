import 'package:flutter/material.dart';

/// A delivery channel listed on the Delivery Service > Delivery Partners tab.
/// Built-in channels (Direct Order, Website) are always active and have no
/// enable/disable switch; third-party platforms (FoodMandu, Pathao Food, or
/// any custom platform added later) can be toggled on/off and carry a
/// commission percentage.
class DeliveryPartner {
  final String name;
  final String description;
  final IconData icon;
  final Color iconBackground;
  final bool isBuiltIn;
  int commissionPercent;
  bool enabled;

  DeliveryPartner({
    required this.name,
    required this.description,
    required this.icon,
    required this.iconBackground,
    this.isBuiltIn = false,
    this.commissionPercent = 0,
    this.enabled = true,
  });

  static List<DeliveryPartner> defaultPartners() => [
    DeliveryPartner(
      name: 'Direct Order',
      description: 'Manages incoming orders from phone calls and direct messages (WhatsApp).',
      icon: Icons.call,
      iconBackground: Colors.black,
      isBuiltIn: true,
    ),
    DeliveryPartner(
      name: 'Website',
      description: 'A digital storefront provided by us for your restaurant to take orders online.',
      icon: Icons.language,
      iconBackground: const Color(0xFF3B5FE0),
      isBuiltIn: true,
    ),
    DeliveryPartner(
      name: 'FoodMandu',
      description: 'The primary delivery network in Nepal for premium and established restaurants.',
      icon: Icons.restaurant_menu,
      iconBackground: const Color(0xFFF4C430),
      enabled: false,
    ),
    DeliveryPartner(
      name: 'Pathao Food',
      description: 'High-speed delivery service in Nepal focused on volume and quick logistics.',
      icon: Icons.pedal_bike,
      iconBackground: const Color(0xFFDC3939),
      enabled: false,
    ),
  ];
}
