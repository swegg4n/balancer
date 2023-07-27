import 'dart:io';

import 'package:Balancer/shared/button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:Balancer/profile/profile_state.dart';
import 'package:Balancer/services/firestore.dart';
import 'package:Balancer/services/models.dart';
import 'package:Balancer/shared/input.dart';
import 'package:Balancer/shared/loading.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();

    var user = Provider.of<MyUser>(context);
    var profileState = Provider.of<ProfileState>(context);

    nameController.text = profileState.chosenName ?? user.name;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit profile'),
          leading: IconButton(
            icon: const Icon(FontAwesomeIcons.xmark),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 15),
              child: MultiValueListenableBuilder(
                valueListenables: [
                  nameController,
                ],
                builder: (context, values, child) {
                  bool nameChanged = nameController.text.trim() != user.name;
                  bool pfpChanged = profileState.chosenImage != null;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Loader(
                        size: 25,
                        running: profileState.saving,
                      ),
                      Visibility(
                        visible: !profileState.saving,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: ButtonText(
                          text: 'Save',
                          onPressed: () async {
                            profileState.saving = true;
                            FocusManager.instance.primaryFocus?.unfocus();
                            await FirestoreService().updateUserInfo(nameController.text.trim(), profileState.chosenImage);
                            profileState.chosenName = null;
                            profileState.chosenImage = null;
                            profileState.saving = false;
                          },
                          fontSize: 21,
                          disabled: !(nameChanged || pfpChanged),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
          backgroundColor: Colors.grey[850],
        ),
        resizeToAvoidBottomInset: false,
        body: Container(
          margin: const EdgeInsets.only(left: 50, right: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      profileState.chosenName = nameController.text;
                      profileState.selectPicture();
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        shape: BoxShape.circle,
                        image: user.pfpUrl.isEmpty
                            ? null
                            : DecorationImage(
                                fit: BoxFit.cover,
                                image: profileState.chosenImage != null
                                    ? Image.file(File(profileState.chosenImage!.path)).image
                                    : NetworkImage(user.pfpUrl),
                              ),
                      ),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.bottomRight,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 7.5, right: 7.5),
                            child: Icon(
                              FontAwesomeIcons.folderOpen,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Text(
                'Name',
                style: TextStyle(fontSize: 20),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2)),
              TextFieldPrimary(label: 'Name', icon: FontAwesomeIcons.solidUser, controller: nameController, autofocus: false),
              const Spacer(),
              const Text(
                'Email',
                style: TextStyle(fontSize: 20),
              ),
              Container(
                  margin: const EdgeInsets.only(left: 15, top: 3),
                  child: Text(
                    user.email,
                    style: const TextStyle(fontSize: 20, color: Colors.grey),
                  )),
              const Spacer(flex: 10),
              // const Padding(padding: EdgeInsets.only(bottom: 15)),
              // Text(
              //   AppPreferences.appVersion,
              //   style: const TextStyle(fontSize: 16, color: Color(0xffcccccc)),
              //   textAlign: TextAlign.center,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
