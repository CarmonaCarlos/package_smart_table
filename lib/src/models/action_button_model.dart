import 'package:flutter/material.dart';
import 'package:smart_table/src/common/enum/action_type.dart';

class ActionButton {
  String title;
  Icon icon;
  dynamic action; //It can be VoidCallback or Function
  ActionButtonType? actionType;
  ActionButton({required this.title, required this.icon, required this.action, this.actionType});
}
