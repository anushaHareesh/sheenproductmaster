import 'package:flutter/material.dart';

// class UserModel {
//   String? id;
//   DateTime? createdAt;
//   String? name;
//   String? avatar;

//   UserModel({this.id, this.createdAt, this.name, this.avatar});

//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     // if (json == null) return null;
//     return UserModel(
//       id: json["id"],
//       createdAt:
//           json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
//       name: json["name"],
//       avatar: json["avatar"],
//     );
//   }

//   static List<UserModel> fromJsonList(List list) {
//     // if (list == null) return null;
//     return list.map((item) => UserModel.fromJson(item)).toList();
//   }

//   ///this method will prevent the override of toString
//   String userAsString() {
//     return '#${this.id} ${this.name}';
//   }

//   ///this method will prevent the override of toString
//   bool userFilterByCreationDate(String filter) {
//     return this.createdAt.toString().contains(filter);
//   }

//   ///custom comparing function to check if two users are equal
//   bool isEqual(UserModel model) {
//     return this.id == model.id;
//   }

//   @override
//   String? toString1() => name;
// }

class UserModel {
  String? name;
  String? avatar;
  String? id;

  UserModel({this.name, this.avatar, this.id});

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    avatar = json['avatar'];
    id = json['id'];
  }
  static List<UserModel> fromJsonList(List list) {
    if (list == null) return [];
    return list.map((item) => UserModel.fromJson(item)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['avatar'] = this.avatar;
    data['id'] = this.id;
    return data;
  }
}
