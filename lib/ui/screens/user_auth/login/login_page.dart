import 'dart:convert';

import 'package:americonictv_mobile/data/auth/user_data.dart';
import 'package:americonictv_mobile/logic/api/auth.dart';
import 'package:americonictv_mobile/logic/api/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:americonictv_mobile/logic/api/social.dart';

class LoginPage extends StatefulWidget {
  final Function(int) goToPage;
  final Function authSuccessful;

  LoginPage({
    @required this.goToPage,
    @required this.authSuccessful,
  });

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _verifying = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Image.asset(
                      'assets/images/atv_logo.png',
                      width: MediaQuery.of(context).size.width / 2.2,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      enabled: !_verifying,
                      controller: _usernameController,
                      decoration:
                          InputDecoration(labelText: 'Email or username'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: TextField(
                        obscureText: true,
                        enabled: !_verifying,
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: 'Password'),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 16,
                            height: 48,
                            child: Center(
                              child: Text(
                                'REGISTER',
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        onTap: _verifying ? null : () => widget.goToPage(0),
                      ),
                      GestureDetector(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context).accentColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 16,
                            height: 48,
                            child: Center(
                              child: _verifying
                                  ? SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'LOGIN',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        onTap: _verifying
                            ? null
                            : () async {
                                setState(() => _verifying = true);
                                try {
                                  final response = await Auth.login(
                                    _usernameController.text,
                                    _passwordController.text,
                                  );
                                  final decoded = jsonDecode(response.body);
                                  if (decoded['id'] != null) {
                                    // Login successful
                                    final data = UserData.fromJson(decoded);
                                    await User.setInstance(data, true);
                                    await Social.getSaved();
                                    widget.authSuccessful();
                                  } else
                                    // Login failed
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          decoded['error'] != null &&
                                                  decoded['error']
                                                          .runtimeType ==
                                                      String
                                              ? decoded['error']
                                              : 'Login unsuccessful. Please check your details.',
                                        ),
                                      ),
                                    );
                                } catch (e) {
                                  // Error making request
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Username or password incorrect.')));
                                }
                                if (mounted) setState(() => _verifying = false);
                              },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: GestureDetector(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 48,
                        child: Center(
                          child: Text(
                            'Anonymous Login',
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                        ),
                      ),
                      onTap: _verifying ? null : () => widget.authSuccessful(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
