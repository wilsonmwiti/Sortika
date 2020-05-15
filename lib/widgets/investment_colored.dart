import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/api/auth.dart';
import 'package:wealth/models/activityModel.dart';
import 'package:wealth/models/goalmodel.dart';
import 'package:wealth/utilities/styles.dart';

class InvestmentColored extends StatefulWidget {
  final String uid;
  InvestmentColored({Key key, @required this.uid}) : super(key: key);
  @override
  _InvestmentColoredState createState() => _InvestmentColoredState();
}

class _InvestmentColoredState extends State<InvestmentColored> {
  final styleLabel =
      GoogleFonts.muli(textStyle: TextStyle(color: Colors.black, fontSize: 15));

  //Investment Asset Class
  String classInvestment;
  //Investment Goal
  String goalInvestment;
  //Placeholder of amount
  double targetAmount = 0;

  void _handleSubmittedAmount(String value) {
    targetAmount = double.parse(value.trim());
    print('Amount: ' + targetAmount.toString());
  }

  //Types Holder
  List<dynamic> typesList;

  //Set an average loan to be 30 days
  static DateTime rightNow = DateTime.now();
  static DateTime oneMonthFromNow = rightNow.add(Duration(days: 30));

  DateTime _date;
  String _dateDay = oneMonthFromNow.day.toString();
  int _dateMonth = oneMonthFromNow.month;
  String _dateYear = oneMonthFromNow.year.toString();

  Firestore _firestore = Firestore.instance;
  AuthService authService = new AuthService();
  Future<QuerySnapshot> futureTypes;

  //Month Names
  List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  Widget _investClassWidget() {
    return Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: StreamBuilder(
          stream: authService.fetchInvestmentAssetClasses(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return DropdownButton(
                items: snapshot.data.documents.map((map) {
                  return DropdownMenuItem(
                    value: map.data['title'],
                    child: Text(
                      '${map.data['title']}',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600)),
                    ),
                  );
                }).toList(),
                underline: Divider(
                  color: Colors.transparent,
                ),
                value: classInvestment,
                hint: Text(
                  '',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600)),
                ),
                icon: Icon(
                  CupertinoIcons.down_arrow,
                  color: Colors.black,
                ),
                isExpanded: true,
                onChanged: (value) async {
                  setState(() {
                    classInvestment = value;
                    //print(classInvestment);
                  });
                },
              );
            }
            return LinearProgressIndicator();
          },
        ));
  }

  Widget _investTypeWidget() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: FutureBuilder(
        future: authService.fetchInvestmentAssetTypes(classInvestment),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return DropdownButton(
              disabledHint: Text(
                'Please select a class',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(fontWeight: FontWeight.w600)),
              ),
              items: snapshot.data.documents.map((map) {
                goalInvestment = map.data['name'];
                return DropdownMenuItem(
                  value: goalInvestment,
                  child: Text(
                    '${map.data['name']} (${map.data['return']}%)',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList(),
              underline: Divider(
                color: Colors.transparent,
              ),
              value: goalInvestment,
              hint: Text(
                '',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600)),
              ),
              icon: Icon(
                CupertinoIcons.down_arrow,
                color: Colors.black,
              ),
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  goalInvestment = value;
                  print(goalInvestment);
                });
              },
            );
          } else {
            return LinearProgressIndicator();
          }
        },
      ),
    );
  }

  Widget _investAmount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        TextFormField(
            autofocus: false,
            keyboardType: TextInputType.number,
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.black,
            )),
            onFieldSubmitted: (value) {
              FocusScope.of(context).unfocus();
            },
            onChanged: _handleSubmittedAmount,
            validator: (value) {
              //Check if phone is available
              if (value.isEmpty) {
                return 'Amount is required';
              }
              return null;
            },
            autovalidate: true,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue)),
              errorBorder:
                  OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue)),
              prefixIcon: Icon(FontAwesome5.money_bill_alt, color: Colors.blue),
              suffixText: 'KES',
              suffixStyle: hintStyle,
            ))
      ],
    );
  }

  Widget _investmentDurationWidget() {
    return Container(
      child: Row(
        children: [
          Expanded(
              child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  '$_dateDay',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black)),
                ),
                Text(
                  '--',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black)),
                ),
                Text(
                  '${monthNames[_dateMonth - 1]}',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black)),
                ),
                Text(
                  '--',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black)),
                ),
                Text(
                  '$_dateYear',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          )),
          IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: Colors.black,
            ),
            onPressed: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 1000)),
              ).then((value) {
                setState(() {
                  if (value != null) {
                    _date = value;
                    _dateDay = _date.day.toString();
                    _dateMonth = _date.month;
                    _dateYear = _date.year.toString();
                    print('Investment End Date: $_date');
                  } else {
                    _date = value;
                    print('Investment End Date: $_date');
                  }
                });
              });
            },
          )
        ],
      ),
    );
  }

  Future _promptUser(String message) {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: Text(
              '$message',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(color: Colors.black, fontSize: 16)),
            ),
          );
        });
  }

  Future _promptUserSuccess() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.done,
                  size: 50,
                  color: Colors.green,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Your investment goal has been created successfully',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        });
  }

  Future _showUserProgress() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Creating your goal...',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                ),
                SizedBox(
                  height: 10,
                ),
                SpinKitDualRing(
                  color: Colors.greenAccent[700],
                  size: 100,
                )
              ],
            ),
          );
        });
  }

  Future _createInvestmentGoal(GoalModel model) async {
    /*
    Before we go to the next page we need to auto create a investment goal
    */

    //This is the name of the collection we will be reading
    final String _collectionUpper = 'users';
    final String _collectionLower = 'goals';
    var document = _firestore.collection(_collectionUpper).document(widget.uid);

    //Save goal to goals subcollection
    await document
        .collection(_collectionLower)
        .document()
        .setData(model.toJson());
  }

  void _setBtnPressed() async {
    //Check if class is non null
    if (classInvestment == null) {
      _promptUser("Please specify an investment class");
    } else if (goalInvestment == null) {
      _promptUser("Please select an investment goal");
    } else if (targetAmount == 0) {
      _promptUser("Please select your initial investment amount");
    } else if (_date == null) {
      _promptUser("You haven't selected the targeted completion date");
    }
    //Check if goal ends on the same day
    else if (_date.difference(rightNow).inDays < 1) {
      _promptUser('The goal end date is too soon');
    } else {
      GoalModel goalModel = new GoalModel(
          goalAmount: targetAmount,
          goalCreateDate: Timestamp.fromDate(DateTime.now()),
          goalEndDate: Timestamp.fromDate(_date),
          goalCategory: 'Investment',
          goalClass: classInvestment,
          goalType: goalInvestment,
          uid: widget.uid,
          isGoalDeletable: true,
          goalAmountSaved: 0,
          goalAllocation: 0);

      //Create an activity
      ActivityModel investmentAct = new ActivityModel(
          activity:
              'You created a new Investment Goal in the $classInvestment class',
          activityDate: Timestamp.fromDate(rightNow));
      await authService.postActivity(widget.uid, investmentAct);

      //Show a dialog
      _showUserProgress();

      _createInvestmentGoal(goalModel).whenComplete(() {
        //Pop that dialog
        //Show a success message for two seconds
        Timer(Duration(seconds: 3), () => Navigator.of(context).pop());

        //Show a success message for two seconds
        Timer(Duration(seconds: 4), () => _promptUserSuccess());

        //Show a success message for two seconds
        Timer(Duration(seconds: 5), () => Navigator.of(context).pop());
      }).catchError((error) {
        _promptUser(error);
      });
    }
  }

  Widget _setGoalBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      child: RaisedButton(
        elevation: 3,
        onPressed: _setBtnPressed,
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: Colors.blue,
        child: Text(
          'SET GOAL',
          style: GoogleFonts.muli(
              textStyle: TextStyle(
                  letterSpacing: 1.5,
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Setup a new investment',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              'Investment Asset Class',
              style: styleLabel,
            ),
            SizedBox(
              height: 5,
            ),
            _investClassWidget(),
            SizedBox(
              height: 30,
            ),
            Text(
              'Investment Goal',
              style: styleLabel,
            ),
            SizedBox(
              height: 5,
            ),
            _investTypeWidget(),
            SizedBox(
              height: 30,
            ),
            Text(
              'How much do you want to invest?',
              style: styleLabel,
            ),
            _investAmount(),
            SizedBox(
              height: 30,
            ),
            Text(
              'Until when?',
              style: styleLabel,
            ),
            _investmentDurationWidget(),
            _setGoalBtn()
          ],
        ),
      ),
    );
  }
}
