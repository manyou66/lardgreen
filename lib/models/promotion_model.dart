// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class PromotionModel {
  final String name;
  final String url;
  final Timestamp timeAdd;
  PromotionModel({
    required this.name,
    required this.url,
    required this.timeAdd,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'url': url,
      'timeAdd': timeAdd,
    };
  }

  factory PromotionModel.fromMap(Map<String, dynamic> map) {
    return PromotionModel(
      name: map['name'] as String,
      url: map['url'] as String,
      timeAdd: (map['timeAdd']),
    );
  }

  String toJson() => json.encode(toMap());

  factory PromotionModel.fromJson(String source) => PromotionModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
