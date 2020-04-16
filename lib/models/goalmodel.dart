import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

GoalModel goalmodelFromJson(String str) => GoalModel.fromJson(json.decode(str));

String goalmodelToJson(GoalModel data) => json.encode(data.toJson());

class GoalModel {
  String goalCategory;
  String goalName;
  String goalClass;
  String goalType;
  double goalAmount;
  double goalAmountSaved;
  Timestamp goalCreateDate;
  Timestamp goalEndDate;
  double goalAllocation;
  bool isGoalDeletable;

  GoalModel(
      {this.goalCategory,
      this.goalName,
      this.goalClass,
      this.goalType,
      this.goalAmount,
      this.goalAmountSaved,
      this.goalCreateDate,
      this.goalEndDate,
      this.goalAllocation,
      this.isGoalDeletable});

  factory GoalModel.fromJson(Map<String, dynamic> json) => GoalModel(
      goalCategory: json["goalCategory"],
      goalName: json["goalName"],
      goalClass: json["goalClass"],
      goalType: json["goalType"],
      goalAmount: json["goalAmount"],
      goalAmountSaved: json["goalAmountSaved"],
      goalCreateDate: json["goalCreateDate"],
      goalEndDate: json["goalEndDate"],
      goalAllocation: json["goalAllocation"],
      isGoalDeletable: json["isGoalDeletable"]);

  Map<String, dynamic> toJson() => {
        "goalCategory": goalCategory,
        "goalName": goalName,
        "goalClass": goalClass,
        "goalType": goalType,
        "goalAmount": goalAmount,
        "goalAmountSaved": goalAmountSaved,
        "goalCreateDate": goalCreateDate,
        "goalEndDate": goalEndDate,
        "goalAllocation": goalAllocation,
        "isGoalDeletable": isGoalDeletable
      };
}
