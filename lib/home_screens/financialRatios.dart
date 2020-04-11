import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinancialRatios extends StatefulWidget {
  @override
  _FinancialRatiosState createState() => _FinancialRatiosState();
}

class _FinancialRatiosState extends State<FinancialRatios> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Networth Calculator',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
