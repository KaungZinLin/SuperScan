import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UniversalWebView extends StatefulWidget {
  final String url;
  final String title;

  const UniversalWebView({super.key, required this.url, required, required this.title});

  @override
  State<UniversalWebView> createState() => _UniversalWebViewState();
}

class _UniversalWebViewState extends State<UniversalWebView> {
  late final WebViewController controller;
  bool loading = true;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() {
              loading = false;
            });
          }
        )
      )
    ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (loading)
            const Center(
              child: CircularProgressIndicator(),
            )
        ],
      ),
    );
  }
}