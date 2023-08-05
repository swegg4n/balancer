import 'package:Balancer/expenses/expenses.dart';
import 'package:Balancer/profile/edit_profile.dart';
import 'package:Balancer/profile/profile_state.dart';
import 'package:Balancer/shared/button.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var profileState = Provider.of<ProfileState>(context);

    return Scaffold(
      floatingActionButton: const NewExpenseButton(heroTag: "floating_profile"),
      body: Container(
        margin: EdgeInsets.only(top: 60, left: 50, right: 50, bottom: 75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Button(
              text: 'Edit profile',
              onPressed: () {
                profileState.chosenImage = null;
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const EditProfileScreen()));
              },
              color: Colors.grey[850],
              borderColor: Colors.grey[800],
              borderSize: 2,
              paddingVertical: 17,
            ),
            const Padding(padding: EdgeInsets.only(bottom: 10)),
            Button(
              text: 'Household settings',
              onPressed: () {},
              color: Colors.grey[850],
              borderColor: Colors.grey[800],
              borderSize: 2,
              paddingVertical: 17,
              disabled: true,
            ),
            const Padding(padding: EdgeInsets.only(bottom: 30)),
            Button(
              text: 'sign out',
              onPressed: () async {
                await AuthService().signOut();
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              color: Colors.grey[850],
              textColor: Colors.red[400],
              borderColor: Colors.red[400],
              borderSize: 2,
              paddingVertical: 17,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
