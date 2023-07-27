import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:Balancer/login/sign_in.dart';
import 'package:Balancer/services/auth.dart';
import 'package:Balancer/shared/button.dart';
import 'package:Balancer/login/register.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          margin: const EdgeInsets.only(
            left: 40,
            right: 40,
            top: 50,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Spacer(flex: 4),
            Image.asset('assets/logo_t.png', width: 170, height: 170, color: Colors.white),
            const Spacer(flex: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Button(
                  text: 'Sign in',
                  fontSize: 22,
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const SignInScreen()));
                  },
                ),
                const Padding(padding: EdgeInsets.only(bottom: 15)),
                Button(
                    text: 'Register',
                    fontSize: 22,
                    color: Colors.grey[850],
                    borderColor: Colors.grey[700],
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const RegisterScreen()));
                    }),
              ],
            ),
            const Spacer(flex: 5),
          ]),
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final String text;
  final Color textColor;
  final Function? loginMethod;

  const LoginButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.textColor,
    required this.backgroundColor,
    required this.loginMethod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Container(
        margin: const EdgeInsets.only(right: 10),
        child: Icon(
          icon,
          color: textColor,
          size: 25,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(13),
        backgroundColor: backgroundColor,
      ),
      onPressed: loginMethod != null ? () async => await loginMethod!() : null,
      label: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
        ),
      ),
    );
  }
}
