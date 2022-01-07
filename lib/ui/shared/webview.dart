import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WebviewScreenState();
  }
}

class _WebviewScreenState extends State<WebviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Purchase subscription'),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: WebView(
        initialUrl:
            'https://video.americonictv.com/plugin/Subscription/showPlans.php',
      ),
    );
  }
}
