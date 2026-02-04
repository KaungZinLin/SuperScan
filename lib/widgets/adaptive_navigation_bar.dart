import 'package:flutter/material.dart';

class AdaptiveBottomNavigation extends StatelessWidget {
  const AdaptiveBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.destinations,
    required this.labelStyle,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<NavigationDestination> destinations;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStatePropertyAll(labelStyle),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        destinations: destinations,
      ),
    );
  }
}