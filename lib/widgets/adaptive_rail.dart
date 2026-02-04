import 'package:flutter/material.dart';

class AdaptiveNavigationRail extends StatelessWidget {
  const AdaptiveNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<NavigationRailDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      labelType: NavigationRailLabelType.all,
      destinations: destinations,
    );
  }
}