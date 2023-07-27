import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:Balancer/login/reset_password.dart';
import 'package:Balancer/services/auth.dart';
import 'package:Balancer/services/bottom_modal.dart';
import 'package:Balancer/shared/button.dart';
import 'package:Balancer/shared/input.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign in'),
          leading: IconButton(
            icon: const Icon(FontAwesomeIcons.xmark),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.grey[850],
        ),
        resizeToAvoidBottomInset: false,
        body: Container(
          margin: const EdgeInsets.only(
            left: 40,
            right: 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 3),
              const Text(
                'Welcome back',
                style: TextStyle(fontSize: 24),
              ),
              const Text(
                'Sign in to mange your expenses',
                style: TextStyle(fontSize: 18),
              ),
              const Spacer(),
              TextFieldPrimary(
                  label: 'email',
                  icon: FontAwesomeIcons.solidEnvelope,
                  controller: emailController,
                  inputType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next),
              const Padding(padding: EdgeInsets.only(bottom: 10)),
              TextFieldPrimary(
                label: 'password',
                icon: FontAwesomeIcons.key,
                controller: passwordController,
                inputType: TextInputType.text,
                obscure: true,
              ),
              const Padding(padding: EdgeInsets.only(bottom: 10)),
              MultiValueListenableBuilder(
                  valueListenables: [emailController, passwordController],
                  builder: (context, values, child) {
                    bool emailProvided = (values.elementAt(0) as TextEditingValue).text.isNotEmpty;
                    bool passwordProvided = (values.elementAt(1) as TextEditingValue).text.isNotEmpty;

                    return Button(
                      text: 'Sign in',
                      fontSize: 18,
                      color: Theme.of(context).primaryColor,
                      disabled: !(emailProvided && passwordProvided),
                      onPressed: () async {
                        try {
                          User? user = await AuthService().emailPassLogin(emailController.text, passwordController.text);

                          if (user != null) {
                            debugPrint(user.email);
                            Navigator.pop(context);
                          }
                        } on FirebaseException catch (e) {
                          debugPrint('ERROR: ' + e.code);
                          String errorMessage = e.code;

                          FocusManager.instance.primaryFocus?.unfocus();
                          if (e.code == 'invalid-email') {
                            errorMessage = 'Invalid email address';
                          } else if (e.code == 'wrong-password') {
                            errorMessage = 'Incorrect email address or password';
                          } else if (e.code == 'user-not-found') {
                            errorMessage = 'No user with this email address';
                          }
                          BottomModal.showErrorModal(context, 'Failed to Sign in', errorMessage);
                        }
                      },
                      paddingVertical: 12,
                    );
                  }),
              const Spacer(),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 17),
                    children: [
                      const TextSpan(text: 'Forgot your password?  '),
                      TextSpan(
                        text: 'reset password',
                        style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 17),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const ResetPasswordScreen()));
                          },
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 20),
            ],
          ),
        ),
      ),
    );
  }
}
