import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatefulWidget {
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
              Text('SuperScan', style: TextStyle(fontSize: 50.0, fontWeight: FontWeight.w600),),
              const SizedBox(height: 30),
              const SpinKitDualRing(color: Colors.indigo, size: 70.0),
            ],
        )
      )
    );
  }
}
