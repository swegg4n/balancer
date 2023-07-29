import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:Balancer/services/auth.dart';
import 'package:Balancer/services/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream<Match> streamMatch() {
  //   return AuthService().userStream.switchMap((user) {
  //     if (user != null) {
  //       var ref = _db.collection('matches').doc(user.uid);
  //       return ref.snapshots().map((doc) => Match.fromJson(doc.data()!));
  //     } else {
  //       return Stream.fromIterable([Match()]);
  //     }
  //   });
  // }
  // Stream<Match> streamHosehold() {
  //   return AuthService().userStream.switchMap((user) {
  //     if (user != null) {
  //       var ref = _db.collection('households').doc(user.uid);
  //       return ref.snapshots().map((doc) => Match.fromJson(doc.data()!));
  //     } else {
  //       return Stream.fromIterable([Match()]);
  //     }
  //   });
  // }

  Future<bool> createExpense(Expense expense) async {
    User user = AuthService().user!;
    expense.userId = user.uid;

    var doc = await _db.collection('users').doc(user.uid).get();
    String householdId = doc.get('household');

    doc = await _db.collection('households').doc(householdId).get();
    String userId1 = doc.get('userId1');
    String userId2 = doc.get('userId2');

    bool isUser1 = false;
    bool isUser2 = false;

    if (userId1 == user.uid) {
      isUser1 = true;
    } else if (userId2 == user.uid) {
      isUser2 = true;
    } else {
      debugPrint('[ERROR] User is not part of this household');
      return false;
    }

    if (isUser2) {
      expense.split = 1 - expense.split;
    }

    var expense_data = {
      'description': expense.description,
      'amount': expense.amount,
      'categoryIndex': expense.categoryIndex,
      'split': expense.split,
      'date': expense.date,
      'userId': expense.userId,
    };

    var ref = _db.collection('expenses').doc();
    String expense_id = ref.id;

    try {
      if (isUser1 || isUser2) {
        await ref.set(expense_data, SetOptions(merge: true));

        ref = _db.collection('households').doc(householdId);
        if (isUser1) {
          var data = {
            'expensesIdsUser1': FieldValue.arrayUnion([expense_id])
          };
          ref.update(data);
        } else {
          var data = {
            'expensesIdsUser2': FieldValue.arrayUnion([expense_id])
          };
          ref.update(data);
        }
      }
    } catch (e) {
      return false;
    }

    return true;
  }

  Stream<MyUser> streamUser() {
    return AuthService().userStream.switchMap((user) {
      if (user != null) {
        var ref = _db.collection('users').doc(user.uid);
        return ref.snapshots().map((doc) => MyUser.fromJson(doc.data()!));
      } else {
        return Stream.fromIterable([MyUser()]);
      }
    });
  }

  Future<void> createUser(String name, String? pfpUrl) async {
    User user = AuthService().user!;
    var doc = await _db.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      var ref = _db.collection('users').doc(user.uid);

      if (pfpUrl == null) {
        // pfpUrl =
        //     'https://www.gravatar.com/avatar/0?s=200&r=pg&d=mp'; //default icon
        var hash = md5.convert(utf8.encode(user.uid)).toString();
        pfpUrl = 'https://www.gravatar.com/avatar/$hash?s=200&r=pg&d=robohash'; //robot icon
      }

      var data = {
        'name': name,
        'email': user.email,
        'uid': user.uid,
        'pfpUrl': pfpUrl,
        'household': '',
      };

      return await ref.set(data, SetOptions(merge: true));
    }
  }

  Future<void> updateUserInfo(String? name, XFile? pfp) async {
    User user = AuthService().user!;

    String? pfpUrl;
    if (pfp != null) {
      final path = 'userData/${user.uid}/pfp.jpg';
      final file = File(pfp.path);

      final ref = FirebaseStorage.instance.ref().child(path);
      final uploadTask = ref.putFile(file);

      final snapshot = await uploadTask.whenComplete(() {});
      pfpUrl = await snapshot.ref.getDownloadURL();
      debugPrint('uploaded profile picture to url: ' + pfpUrl);
    }

    var ref = _db.collection('users').doc(user.uid);

    var data = {
      if (name != null) 'name': name,
      if (pfp != null) 'pfpUrl': pfpUrl,
    };

    return await ref.update(data);
  }

  Future<void> deleteUserInfo() async {
    User user = AuthService().user!;

    try {
      var userDataRef = FirebaseStorage.instance.ref().child('userData/${user.uid}/pfp.jpg');
      await userDataRef.delete();
    } catch (_) {}

    try {
      var ref = _db.collection('users').doc(user.uid);
      var data = {
        'name': '[deleted user]',
        'email': '',
        'uid': '',
        'pfpUrl': '',
        'household': '',
      };
      await ref.update(data);
    } catch (_) {}
  }
}
