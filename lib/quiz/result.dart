import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import '../constants/theme_data.dart';
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
      'Try your best next time! \n But have a good day!';
    }
    // else if (score > 15.00 && score <= 25.00) {
    //   resultText =
    //   'You did it and scored $score points! \n Want to try again?';
    // }
    else if (score > 5.00 && score <= 2000.00) {
      resultText =
      'You answered right! \n Have a good day!';
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
                NeumorphicButton(
                    //padding with: left, top, right, bottom
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                    style: NeumorphicStyle(
                      shape: NeumorphicShape.flat,
                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                      depth: 3,
                      intensity: 0.7,
                    ),
                    child: Text(
                      'Close',
                      style: boldTextStyle(
                          size: 16, textColor: CustomColors.sdPrimaryColor, letterSpacing: 2),
                    ),
                    onPressed: () async {
                      //resetHandler,
                      //SystemNavigator.pop();
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => ClockScreen()),);
                      Phoenix.rebirth(context);

                    })
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
