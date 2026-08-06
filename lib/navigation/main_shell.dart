import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/manage/manage_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../widgets/common/custom_bottom_nav.dart';
import '../widgets/common/quick_actions_sheet.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 1; // Order tab default (jaisa screenshot mein hai)

  final List<Widget> _screens = const [
    HomeScreen(),
    OrdersScreen(),
    AnalyticsScreen(),
    ManageScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _onCenterButtonTapped() {
    QuickActionsSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
        onCenterButtonTapped: _onCenterButtonTapped,
      ),
    );
  }
}