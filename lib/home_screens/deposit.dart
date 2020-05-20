import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/api/helper.dart';
import 'package:wealth/deposit/bankcard.dart';
import 'package:wealth/deposit/mpesaAuto.dart';
import 'package:wealth/deposit/mpesaManual.dart';
import 'package:wealth/models/depositmethods.dart';
import 'package:wealth/models/goalmodel.dart';
import 'package:wealth/utilities/styles.dart';

class Deposit extends StatefulWidget {
  final String uid;

  Deposit({Key key, this.uid}) : super(key: key);

  @override
  _DepositState createState() => _DepositState();
}

class _DepositState extends State<Deposit> {
  PageController _controller;
  PageController _controllerPages;

  // Identifiers
  int _currentPage = 0;
  static String _destination = 'wallet';
  static String _method = 'M-PESA';
  static String userId;
  static String goalName;
  List<Widget> _pages = [
    DepositAncestor(
      userId,
      _destination,
      _method,
      goalName,
      child: MpesaAuto(),
    ),
    MpesaManual(),
    DepositAncestor(
      userId,
      _destination,
      _method,
      goalName,
      child: MpesaAuto(),
    ),
    BankCard()
  ];
  Helper _helper = new Helper();

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.85);
    _controllerPages = PageController(viewportFraction: 1);
    userId = widget.uid;
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerPages.dispose();
    super.dispose();
  }

  //Define Dropdown Menu Items
  List<DropdownMenuItem> destinations = [
    //Send Money to Wallet
    DropdownMenuItem(
      value: 'wallet',
      child: Text(
        'Wallet',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),

    //General topup
    DropdownMenuItem(
      value: 'general',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'General',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w600)),
          ),
          Text('Divide between goals based on allocation',
              style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 10),
              )),
        ],
      ),
    ),

    //Send to a specific goal
    DropdownMenuItem(
      value: 'specific',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Specific',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w600)),
          ),
          Text(
            'Deposit to a specific goal',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 10)),
          ),
        ],
      ),
    ),
  ];

  Widget _depositInfo() {
    return Container(
      child: RichText(
          text: TextSpan(children: [
        TextSpan(
            text:
                'Based on your savings target, we recommend that you deposit ',
            style: GoogleFonts.muli(textStyle: TextStyle(color: Colors.white))),
        TextSpan(
            text: '100 KES',
            style: GoogleFonts.muli(
                textStyle:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
      ])),
    );
  }

  Widget _singleGoal(DocumentSnapshot document) {
    GoalModel model = GoalModel.fromJson(document.data);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[100],
      child: ListTile(
        onTap: () {
          setState(() {
            model.goalName == null
                ? goalName = model.goalCategory
                : goalName = model.goalName;
            print(goalName);
            Navigator.of(context).pop();
          });
        },
        title: Text(
            model.goalName == null
                ? '${model.goalCategory}'
                : '${model.goalName}',
            style: GoogleFonts.muli(
              textStyle: TextStyle(color: Colors.black),
            )),
        subtitle: Text('Current: ${model.goalAmountSaved} KES',
            style: GoogleFonts.muli(
              textStyle: TextStyle(color: Colors.black),
            )),
      ),
    );
  }

  Future showGoalsPopup() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width,
              child: FutureBuilder<QuerySnapshot>(
                  future: _helper.getAllGoals(widget.uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView(
                        children: snapshot.data.documents
                            .map((map) => _singleGoal(map))
                            .toList(),
                      );
                    }
                    return SpinKitDoubleBounce(
                      color: Colors.greenAccent[700],
                      size: MediaQuery.of(context).size.height * 0.3,
                    );
                  }),
            ),
          );
        });
  }

  Widget _depositDestination() {
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
      child: DropdownButton(
        items: destinations,
        underline: Divider(
          color: Colors.transparent,
        ),
        value: _destination,
        icon: Icon(
          CupertinoIcons.down_arrow,
          color: Colors.black,
        ),
        isExpanded: true,
        onChanged: (value) {
          setState(() {
            _destination = value;

            if (value == 'specific') {
              //Show a list of all goals
              showGoalsPopup();
            }
          });
        },
      ),
    );
  }

  Widget _depositMethodWidget() {
    return Container(
      height: 80,
      child: PageView(
        scrollDirection: Axis.horizontal,
        controller: _controller,
        onPageChanged: (value) {
          setState(() {
            _currentPage = value;
            _method = methods[_currentPage].title;
            //print(_method);
            _controllerPages.animateToPage(_currentPage,
                duration: Duration(milliseconds: 100), curve: Curves.ease);
          });
        },
        children: methods
            .map((map) => _depositMethod(map.title, map.subtitle))
            .toList(),
      ),
    );
  }

  //Budget Item
  Widget _depositMethod(String title, String subtitle) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), color: Colors.white),
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              child: Icon(
                MaterialCommunityIcons.cash_multiple,
                color: Colors.white,
              ),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Color(0xFF73AEF5))),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$title',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '$subtitle',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w400)),
              ),
            ],
          ),
          SizedBox(
            width: 5,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF73AEF5),
        elevation: 0,
        title: Text(
          'Deposit',
          style: GoogleFonts.muli(
              textStyle: TextStyle(color: Colors.white, fontSize: 20)),
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              backgroundWidget(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // _depositInfo(),
                      // SizedBox(
                      //   height: 20,
                      // ),
                      Text('Where do you want to deposit?',
                          style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.white),
                          )),
                      SizedBox(
                        height: 5,
                      ),
                      _depositDestination(),
                      SizedBox(
                        height: 20,
                      ),
                      Text('How do you want to deposit?',
                          style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.white),
                          )),
                      SizedBox(
                        height: 5,
                      ),
                      _depositMethodWidget(),
                      SizedBox(
                        height: 20,
                      ),
                      LimitedBox(
                        maxHeight: double.maxFinite,
                        child: PageView(
                            controller: _controllerPages,
                            physics: NeverScrollableScrollPhysics(),
                            onPageChanged: (value) {},
                            children: _pages),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
