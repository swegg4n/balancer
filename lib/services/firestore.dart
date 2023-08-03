import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:Balancer/services/app_preferences.dart';
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

  Future<String> getHouseholdId() async {
    User user = AuthService().user!;
    var doc = await _db.collection('users').doc(user.uid).get();
    return doc.get('household');
  }

  Future<bool> starredDocumentExists(id) async {
    var ref = _db.collection('expenses_starred').doc(id);
    var data = (await ref.get()).data();
    return data != null;
  }

  Future<Query<Map<String, dynamic>>> getDocuments() async {
    AppPreferences.householdId ??= await FirestoreService().getHouseholdId();
    var collection = FirebaseFirestore.instance
        .collection('expenses')
        .where('householdId', isEqualTo: AppPreferences.householdId)
        .orderBy("epoch", descending: true)
        .limit(10);
    return collection;
  }

  Future<Query<Map<String, dynamic>>> getStarredDocuments() async {
    AppPreferences.householdId ??= await FirestoreService().getHouseholdId();
    var collection = FirebaseFirestore.instance.collection('expenses_starred').where('householdId', isEqualTo: AppPreferences.householdId);
    return collection;
  }

  Future<Query<Map<String, dynamic>>> getDocumentsNext(dynamic startAfter) async {
    AppPreferences.householdId ??= await FirestoreService().getHouseholdId();
    var collection = FirebaseFirestore.instance
        .collection('expenses')
        .where('householdId', isEqualTo: AppPreferences.householdId)
        .orderBy("epoch", descending: true)
        .startAfterDocument(startAfter)
        .limit(5);
    return collection;
  }

  Future<bool> createExpense(Expense expense, bool starred) async {
    User user = AuthService().user!;

    AppPreferences.householdId ??= await FirestoreService().getHouseholdId();

    var expenseData = {
      'description': expense.description,
      'amount': expense.amount,
      'categoryIndex': expense.categoryIndex,
      'split': expense.split,
      'epoch': expense.epoch,
      'userId': user.uid,
      'householdId': AppPreferences.householdId,
    };

    var ref = _db.collection('expenses').doc();
    String id = ref.id;
    ref.set(expenseData);

    if (starred) {
      ref = _db.collection('expenses_starred').doc(id);
      ref.set(expenseData);
    }

    return true;
  }

  Future<bool> updateExpense(Expense expense, String documentId, bool starred) async {
    var expenseData = {
      'description': expense.description,
      'amount': expense.amount,
      'categoryIndex': expense.categoryIndex,
      'split': expense.split,
      'epoch': expense.epoch,
    };

    var ref = _db.collection('expenses').doc(documentId);
    ref.update(expenseData);

    bool docExists = await starredDocumentExists(documentId);
    if (starred && !docExists) {
      ref = _db.collection('expenses_starred').doc(documentId);
      ref.set(expenseData);
    } else if (!starred && docExists) {
      deleteStarredExpense(documentId);
    }

    return true;
  }

  Future<bool> deleteExpense(String documentId) async {
    var ref = _db.collection('expenses').doc(documentId);
    await ref.delete();

    if (await starredDocumentExists(documentId)) {
      deleteStarredExpense(documentId);
    }

    return true;
  }

  Future<bool> deleteStarredExpense(String documentId) async {
    var ref = _db.collection('expenses_starred').doc(documentId);
    await ref.delete();
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
      debugPrint('uploaded profile picture to url: $pfpUrl');
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
