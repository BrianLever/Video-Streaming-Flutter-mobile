import 'dart:convert';

import 'package:americonictv_mobile/data/auth/user_data.dart';
import 'package:americonictv_mobile/logic/api/auth.dart';
import 'package:americonictv_mobile/logic/api/models/user_model.dart';
import 'package:americonictv_mobile/ui/shared/overscroll_behavior.dart';

import 'logic/cache/prefs.dart';
import 'ui/screens/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: const Color(0xff1a1a1d),
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarColor: const Color(0xff1a1a1d),
    statusBarIconBrightness: Brightness.light,
  ));

  // Required by the framework
  WidgetsFlutterBinding.ensureInitialized();

  await Prefs.init();

  runApp(StreamingPlatform());
}

class StreamingPlatform extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StreamingPlatformState();
  }
}

class _StreamingPlatformState extends State<StreamingPlatform> {
  bool _loaded = false;

  String _error;

  @override
  void initState() {
    super.initState();
    if (User.instance?.id == null)
      _loaded = true;
    else
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          final response =
              await Auth.login(User.instance.user, User.instance.pass);
          final decoded = jsonDecode(response.body);
          User.setInstance(UserData.fromJson(decoded));
          setState(() => _loaded = true);
        } catch (e) {
          setState(() => _error = e.toString());
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor:
            Colors.grey.shade900, //const Color(0xff4e4e50),),
        primaryColor: const Color(0xff1a1a1d),
        accentColor: const Color(
            0xffb20000), // const Color(0xffb20000), // const Color(0xffB22234),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xff1a1a1d),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 2,
          titleSpacing: 12,
          centerTitle: false,
          brightness: Brightness.dark,
          color: Color(0xff1a1a1d),
        ),
        splashColor: Colors.transparent,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      builder: (context, child) => ScrollConfiguration(
        behavior: OverscrollRemovedBehavior(),
        child: child,
      ),
      home: _error != null || !_loaded
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xff1a1a1d),
              ),
              child: Center(
                child: _error != null
                    ? Material(
                        color: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            _error,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : CircularProgressIndicator(),
              ),
            )
          : MainView(),
    );
  }
}
