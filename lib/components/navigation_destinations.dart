import 'package:flutter/material.dart';
import 'platform_helper.dart';
import 'package:super_scan/constants.dart';

List<NavigationDestination> get bottomDestinations => [
  NavigationDestination(
    icon: Icon(PlatformHelper.isDesktop ? Icons.sync : Icons.home),
    label: PlatformHelper.isDesktop ? 'Sync' : 'Home',
  ),
  const NavigationDestination(
    icon: Icon(Icons.settings),
    label: 'Settings',
  ),
];

List<NavigationRailDestination> get railDestinations => [
  NavigationRailDestination(
    icon: Icon(PlatformHelper.isDesktop ? Icons.sync : Icons.home),
    label: Text(
      PlatformHelper.isDesktop ? 'Sync' : 'Home',
      style: kNavigationBarLabelStyle,
    ),
  ),
  const NavigationRailDestination(
    icon: Icon(Icons.settings),
    label: Text('Settings', style: kNavigationBarLabelStyle),
  ),
];


