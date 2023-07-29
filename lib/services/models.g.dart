// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyUser _$MyUserFromJson(Map<String, dynamic> json) => MyUser(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      pfpUrl: json['pfpUrl'] as String? ?? '',
      household: json['household'] as String? ?? '',
    );

Map<String, dynamic> _$MyUserToJson(MyUser instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'email': instance.email,
      'pfpUrl': instance.pfpUrl,
      'household': instance.household,
    };

Household _$HouseholdFromJson(Map<String, dynamic> json) => Household(
      userId1: json['userId1'] as String? ?? '',
      userId2: json['userId2'] as String? ?? '',
      expensesIdsUser1: (json['expensesIdsUser1'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      expensesIdsUser2: (json['expensesIdsUser2'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$HouseholdToJson(Household instance) => <String, dynamic>{
      'userId1': instance.userId1,
      'userId2': instance.userId2,
      'expensesIdsUser1': instance.expensesIdsUser1,
      'expensesIdsUser2': instance.expensesIdsUser2,
    };

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      categoryIndex: json['categoryIndex'] as int? ?? 0,
      split: (json['split'] as num?)?.toDouble() ?? 0.5,
      date: json['date'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
    );

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
      'description': instance.description,
      'amount': instance.amount,
      'categoryIndex': instance.categoryIndex,
      'split': instance.split,
      'date': instance.date,
      'userId': instance.userId,
    };
