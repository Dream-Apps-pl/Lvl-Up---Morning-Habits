import 'dart:async';
import 'dart:io';

import 'package:bringtoforeground/bringtoforeground.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import '../constants/theme_data.dart';
import '../main.dart';
import '../screens/main/clock_screen.dart';
import '../utils/widget_helper.dart';
import './question.dart';
import 'package:hexcolor/hexcolor.dart';

class Result extends StatelessWidget {
  final double resultScore;
  final VoidCallback resetHandler;

  const Result(this.resultScore, this.resetHandler, {Key? key}) : super(key: key);

  String get resultPhrase {
    String resultText;
    final score = num.parse(resultScore.toStringAsFixed(2));

    if (score <= 5.00) {
      resultText =
      'Next time, you should \n cheat, we wan\'t tell \n \n Have a great day!';
    }
    // else if (score > 15.00 && score <= 25.00) {
    //   resultText =
    //   'You did it and scored $score points! \n Want to try again?';
    // }
    else if (score > 5.00 && score <= 2000.00) {
      resultText =
      'You\'r smarter than \n you look. \n \n Have a great day!';
    }
    else {
      resultText =
      'You nailed it and scored $score points! \n Want to try again?';
    }

    return resultText;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: SizedBox(
                      width: 360,
                      child: Question(
                        resultPhrase,
                      ),
                    )),
        ElevatedButton(
          onPressed: () async {
            //resetHandler,
            //SystemNavigator.pop();
            //Navigator.push(context, MaterialPageRoute(builder: (context) => ClockScreen()),);
            //Phoenix.rebirth(context);
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            exit(0);
            // restartApp();
            // Timer(Duration(seconds: 1), () {
            //   Bringtoforeground.bringAppToForeground();
            // });

          },
          child: Text(
            'Close',
            style: boldTextStyle(
                size: 16, textColor: CustomColors.sdTextPrimaryColor, letterSpacing: 2),
          ),

          style: ElevatedButton.styleFrom(primary: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
    // ElevatedButton(
    //   style: ButtonStyle(
    //       backgroundColor:
    //       MaterialStateProperty.all(HexColor("#915C53"))),
    //   onPressed: resetHandler,
    //   child: SizedBox(
    //     width: 200,
    //     child: Text(
    //       'Try again',
    //       textAlign: TextAlign.center,
    //       style: TextStyle(
    //         fontWeight: FontWeight.w400,
    //         color: HexColor("#FEFEFE"),
    //       ),
    //     ),
    //   ),
    // )
    ],
    )));
    }
}
