import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:Balancer/services/auth.dart';
import 'package:Balancer/services/bottom_modal.dart';
import 'package:Balancer/services/firestore.dart';
import 'package:Balancer/shared/button.dart';
import 'package:Balancer/shared/input.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
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
            top: 50,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFieldPrimary(
                  label: 'Name',
                  icon: FontAwesomeIcons.solidUser,
                  controller: nameController,
                  inputType: TextInputType.name,
                  textInputAction: TextInputAction.next),
              const Padding(padding: EdgeInsets.only(bottom: 10)),
              TextFieldPrimary(
                  label: 'email',
                  icon: FontAwesomeIcons.solidEnvelope,
                  controller: emailController,
                  inputType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next),
              const Padding(padding: EdgeInsets.only(bottom: 20)),
              TextFieldPrimary(
                label: 'password',
                icon: FontAwesomeIcons.key,
                controller: passwordController,
                inputType: TextInputType.text,
                textInputAction: TextInputAction.next,
                obscure: true,
              ),
              const Padding(padding: EdgeInsets.only(bottom: 10)),
              TextFieldPrimary(
                label: 'confirm password',
                icon: FontAwesomeIcons.key,
                controller: confirmPasswordController,
                inputType: TextInputType.text,
                obscure: true,
              ),
              const Spacer(),
              MultiValueListenableBuilder(
                  valueListenables: [nameController, emailController, passwordController, confirmPasswordController],
                  builder: (context, values, child) {
                    bool nameProvided = (values.elementAt(0) as TextEditingValue).text.isNotEmpty;
                    bool emailProvided = (values.elementAt(1) as TextEditingValue).text.isNotEmpty;
                    bool passwordProvided = (values.elementAt(2) as TextEditingValue).text.isNotEmpty;
                    bool confirmPasswordProvided = (values.elementAt(3) as TextEditingValue).text.isNotEmpty;

                    return Button(
                      text: 'Register',
                      fontSize: 18,
                      color: Theme.of(context).primaryColor,
                      disabled: !(nameProvided && emailProvided && passwordProvided && confirmPasswordProvided),
                      onPressed: () async {
                        try {
                          if (passwordController.text == confirmPasswordController.text) {
                            await AuthService().createUser(emailController.text.trim(), passwordController.text);

                            debugPrint('user created!');
                            await FirestoreService().createUser(nameController.text.trim(), null);

                            AuthService().sendVerificationEmail();
                            Navigator.pop(context);
                          } else {
                            BottomModal.showErrorModal(context, 'Failed to Register', 'Passwords do not match');
                          }
                        } on FirebaseException catch (e) {
                          debugPrint('ERROR: ' + e.code);
                          String errorMessage = e.code;

                          FocusManager.instance.primaryFocus?.unfocus();
                          if (e.code == 'invalid-email') {
                            errorMessage = 'Invalid email address';
                          } else if (e.code == 'email-already-in-use') {
                            errorMessage = 'An account for this email already exists';
                          } else if (e.code == 'weak-password') {
                            errorMessage = 'Password must be at least 6 characters long';
                          }

                          BottomModal.showErrorModal(context, 'Failed to Register', errorMessage);
                        }
                      },
                      paddingVertical: 15,
                    );
                  }),
              const Spacer(flex: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class RegisterVerifyScreen extends StatelessWidget {
  Timer? timer;

  RegisterVerifyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      bool verified = await AuthService().isEmailVerified();
      debugPrint('is verified? >>> ' + verified.toString());

      if (verified) {
        timer?.cancel();
        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const RegisterSuccessScreen()));
      }
    });

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
            const Spacer(flex: 5),
            const Text('Verify your email address', style: TextStyle(fontSize: 24)),
            const Padding(padding: EdgeInsets.only(bottom: 15)),
            Text('Please follow the link in the email we sent to ${FirebaseAuth.instance.currentUser!.email}', style: const TextStyle(fontSize: 18)),
            const Padding(padding: EdgeInsets.only(bottom: 50)),
            const Text('No email?\nCheck your spam folder or request to resend the email.', style: TextStyle(fontSize: 18, color: Color(0xffcccccc))),
            const Padding(padding: EdgeInsets.only(bottom: 15)),
            Container(
              margin: const EdgeInsets.only(left: 50, right: 50),
              child: Button(
                text: 'Resend email',
                paddingVertical: 15,
                paddingHorizontal: 5,
                color: Colors.grey[850],
                textColor: const Color(0xffcccccc),
                borderColor: Colors.grey[700],
                onPressed: () {
                  AuthService().sendVerificationEmail();
                },
              ),
            ),
            const Spacer(flex: 10),
            Button(
              text: 'Back to Sign in',
              onPressed: () {
                timer?.cancel();
                AuthService().signOut();
              },
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}

class RegisterSuccessScreen extends StatelessWidget {
  const RegisterSuccessScreen({Key? key}) : super(key: key);

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
            const Text('Success!', style: TextStyle(fontSize: 24)),
            const Padding(padding: EdgeInsets.only(bottom: 15)),
            const Text('Your Balancer account was successfully created.', style: TextStyle(fontSize: 18)),
            const Spacer(flex: 2),
            Button(
                text: 'Continue',
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  Navigator.popAndPushNamed(context, '/');
                }),
            const Spacer(flex: 20),
          ],
        ),
      ),
    );
  }
}
