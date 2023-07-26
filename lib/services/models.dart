import 'package:json_annotation/json_annotation.dart';
part 'models.g.dart';

@JsonSerializable()
class MyUser {
  final String uid;
  final String name;
  final String email;
  final String pfpUrl;
  final List<String> households;

  MyUser({this.uid = '', this.name = '', this.email = '', this.pfpUrl = '', this.households = const []});

  factory MyUser.fromJson(Map<String, dynamic> json) => _$MyUserFromJson(json);
  Map<String, dynamic> toJson() => _$MyUserToJson(this);
}

// @JsonSerializable()
// class Match {
//   final String id;
//   final List<String> players;

//   Match({this.id = '', this.players = const []});

//   factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);
//   Map<String, dynamic> toJson() => _$MatchToJson(this);
// }


// flutter pub run build_runner build