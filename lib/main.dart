// lib/main.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Android-specific WebView init
  if (Platform.isAndroid) WebView.platform = AndroidWebView();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // आपकी वेबसाइट URL
  final String initialUrl = 'https://www.mahamayastationery.com/shop';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mahamaya Stationery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WebAppHome(url: initialUrl),
    );
  }
}

class WebAppHome extends StatefulWidget {
  final String url;
  const WebAppHome({Key? key, required this.url}) : super(key: key);

  @override
  State<WebAppHome> createState() => _WebAppHomeState();
}

class _WebAppHomeState extends State<WebAppHome> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // controller setup in build via WebView
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mahamaya Stationery'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
          IconButton(
            tooltip: 'Open in browser',
            icon: Icon(Icons.open_in_browser),
            onPressed: () async {
              final url = await _controller.currentUrl() ?? widget.url;
              // open external browser
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('बाहर खोलने में समस्या')),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (controller) {
              _controller = controller;
            },
            navigationDelegate: (nav) {
              // अगर चाहिए तो कुछ डोमेन ब्लॉक/खास हैंडल कर सकते हैं
              return NavigationDecision.navigate;
            },
            onPageStarted: (_) => setState(() => _isLoading = true),
            onPageFinished: (_) => setState(() => _isLoading = false),
            gestureNavigationEnabled: true,
          ),
          if (_isLoading)
            Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

// helper functions for external browser
import 'package:url_launcher/url_launcher.dart';

Future<bool> canLaunchUrl(Uri uri) async {
  return await canLaunch(uri.toString());
}

Future<void> launchUrl(Uri uri) async {
  await launch(uri.toString());
}
