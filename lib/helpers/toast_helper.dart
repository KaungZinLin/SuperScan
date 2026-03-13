import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastHelper {
  static final FToast _fToast = FToast();

  static void init(BuildContext context) {
    _fToast.init(context);
  }

  static void show(String message) {
    final toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black87,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: TextStyle(
              color: Colors.white
            ),
          ),
        ],
      ),
    );

    _fToast.showToast(
      child: toast,
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2)
    );
  }
}