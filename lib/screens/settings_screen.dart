import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  static const String id = 'settings_screen';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SafeArea(
          child: Column(
            children: [
              Text('Sync')
            ],
          ),
      ),
    );
  }
}

