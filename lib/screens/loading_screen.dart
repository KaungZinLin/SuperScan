import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:super_scan/constants.dart';

class LoadingScreen extends StatefulWidget {
  static const String id = 'loading_screen';
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22), // iOS-style
                child: Image.asset(
                  'assets/images/app_icon.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 30),
              Text('SuperScan', style: TextStyle(fontSize: 50.0, fontWeight: FontWeight.w600),),
              const SizedBox(height: 30),
              const SpinKitDualRing(color: kAccentColor, size: 70.0),
            ],
        )
      )
    );
  }
}
