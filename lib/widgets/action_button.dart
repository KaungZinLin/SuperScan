import 'package:flutter/material.dart';
import 'package:super_scan/constants.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({super.key, this.onPressed, required this.icon});

  final VoidCallback? onPressed;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: kAccentColor,
      child: IconButton(
          onPressed: onPressed,
          icon: icon
      ),
    );
  }
}
