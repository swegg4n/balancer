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
      households: (json['households'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MyUserToJson(MyUser instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'email': instance.email,
      'pfpUrl': instance.pfpUrl,
      'households': instance.households,
    };
