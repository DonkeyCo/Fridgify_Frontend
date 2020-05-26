import 'package:flutter/cupertino.dart';
import 'package:fridgify/data/content_repository.dart';
import 'package:fridgify/model/user.dart';
import 'package:fridgify/utils/permission_helper.dart';

class Fridge {
  int fridgeId;
  String name;
  Map<String, dynamic> content;
  Map<User, Permissions> members = Map();

  ContentRepository contentRepository;

  Fridge({
    @required this.fridgeId,
    @required this.name,
    @required this.content,
  });

  Fridge.create({
    this.fridgeId,
    @required this.name,
  });

  Map<String, double> contentForPieChart() {
    return {
      'Fresh': this.content['fresh'].toDouble(),
      'Due soon': this.content['dueSoon'].toDouble(),
      'Over due': this.content['overDue'].toDouble(),
    };
  }
}
