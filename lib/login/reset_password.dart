import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:Balancer/services/auth.dart';
import 'package:Balancer/shared/button.dart';
import 'package:Balancer/shared/input.dart';
import 'package:Balancer/services/bottom_modal.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reset password'),
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
              const Spacer(flex: 2),
              const Text(
                'Reset your password',
                style: TextStyle(fontSize: 24),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 5)),
              const Text(
                'Enter the email address you used to register your Racket Buddy account',
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
              ValueListenableBuilder<TextEditingValue>(
                  valueListenable: emailController,
                  builder: (context, value, child) {
                    bool emailProvided = value.text.isNotEmpty;

                    return Button(
                      text: 'Reset password',
                      fontSize: 18,
                      color: Theme.of(context).primaryColor,
                      disabled: !emailProvided,
                      onPressed: () async {
                        try {
                          await AuthService().resetPassword(email: emailController.text);

                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (BuildContext context) => ResetPasswordSuccessScreen(email: emailController.text)));
                        } on FirebaseException catch (e) {
                          debugPrint('ERROR: ' + e.code);
                          String errorMessage = e.code;

                          FocusManager.instance.primaryFocus?.unfocus();
                          if (e.code == 'invalid-email') {
                            errorMessage = 'Invalid email address';
                          } else if (e.code == 'user-not-found') {
                            errorMessage = 'No user with this email registered';
                          }

                          BottomModal.showErrorModal(context, 'Request failed', errorMessage);
                        }
                      },
                      paddingVertical: 12,
                    );
                  }),
              const Spacer(flex: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class ResetPasswordSuccessScreen extends StatelessWidget {
  final String email;

  const ResetPasswordSuccessScreen({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        margin: const EdgeInsets.only(
          left: 40,
          right: 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 4),
            const Text('Almost done', style: TextStyle(fontSize: 24)),
            const Spacer(),
            Text('An email has been sent to $email\nwith instructions on how to reset your password.', style: const TextStyle(fontSize: 18)),
            const Spacer(),
            const Text('After you have chosen a new password, you may sign with your new password.', style: TextStyle(fontSize: 18)),
            const Spacer(flex: 2),
            Button(
              text: 'Back to Sign in',
              color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            const Spacer(flex: 3),
            const Text('No email?\nEnsure the aforementioned email address is correct and check your spam folder.',
                style: TextStyle(fontSize: 18, color: Color(0xffcccccc))),
            const Spacer(flex: 10),
          ],
        ),
      ),
    );
  }
}
