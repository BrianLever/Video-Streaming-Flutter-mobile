
import 'package:americonictv_mobile/data/auth/user_data.dart';
import 'package:americonictv_mobile/logic/cache/prefs.dart';
import 'package:americonictv_mobile/ui/elements/eula_agreement_dialog.dart';
import 'package:americonictv_mobile/ui/screens/home/home_screen.dart';
import 'package:americonictv_mobile/ui/shared/custom_app_bar.dart';
import 'package:americonictv_mobile/ui/shared/custom_nav_bar/custom_nav_bar.dart';

import 'bloc/view_controller.dart';
import 'categories/categories_screen.dart';
import 'user_auth/auth_screen.dart';
import 'package:flutter/material.dart';

class MainView extends StatefulWidget {
  static _MainViewState state;

  @override
  State<StatefulWidget> createState() {
    state = _MainViewState();
    return state;
  }
}

class _MainViewState extends State<MainView> {
  @override
  void initState() {
    super.initState();
    ViewController.init();
    if (!(Prefs.instance.getBool('eulaAccepted') ?? false))
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Theme.of(context).primaryColor,
          builder: (context) => AgreementDialog(),
        ),
      );
  }

  bool _loggedIn = User.loggedIn;

  void _authSuccessful() => setState(() => _loggedIn = true);

  int _authPage = 1;
  void showAuthScreen(int page) {
    Navigator.pop(context);
    setState(() {
      _authPage = page;
      _loggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loggedIn
          ? Column(
              children: [
                CustomAppBar(showAuthScreen),
                StreamBuilder(
                  stream: ViewController.stream,
                  initialData: CategoriesScreen(),
                  builder: (context, view) => Expanded(child: view.data),
                ),
                CustomNavBar(),
              ],
            )
          : AuthScreen(_authPage, authSuccessful: _authSuccessful),
    );
  }

  @override
  void dispose() {
    ViewController.dispose();
    super.dispose();
  }
}
