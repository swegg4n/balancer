import 'package:json_annotation/json_annotation.dart';
part 'models.g.dart';

@JsonSerializable()
class MyUser {
  final String uid;
  final String name;
  final String email;
  final String pfpUrl;
  final String household;

  MyUser({this.uid = '', this.name = '', this.email = '', this.pfpUrl = '', this.household = ''});

  factory MyUser.fromJson(Map<String, dynamic> json) => _$MyUserFromJson(json);
  Map<String, dynamic> toJson() => _$MyUserToJson(this);
}

@JsonSerializable()
class Household {
  final String userId1;
  final String userId2;
  final List<String> expensesIdsUser1;
  final List<String> expensesIdsUser2;

  Household({this.userId1 = '', this.userId2 = '', this.expensesIdsUser1 = const [], this.expensesIdsUser2 = const []});

  factory Household.fromJson(Map<String, dynamic> json) => _$HouseholdFromJson(json);
  Map<String, dynamic> toJson() => _$HouseholdToJson(this);
}

@JsonSerializable()
class Expense {
  final String description;
  final double amount;
  final int categoryIndex;
  double split;
  final String date;
  String userId;

  Expense({this.description = '', this.amount = 0, this.categoryIndex = 0, this.split = 0.5, this.date = '', this.userId = ''});

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}

// flutter pub run build_runner build