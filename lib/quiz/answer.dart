import 'package:flutter/material.dart';
import '../constants/theme_data.dart';
import '../utils/widget_helper.dart';

class Answer extends StatelessWidget {
  final VoidCallback selectHandler;
  final String answerText;

  const Answer(this.selectHandler, this.answerText, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: selectHandler,
      child: Text(
        answerText,
        style: boldTextStyle(
            size: 16, textColor: CustomColors.sdTextPrimaryColor, letterSpacing: 2),
      ),

      style: ElevatedButton.styleFrom(primary: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
      // NeumorphicButton(
      // //padding with: left, top, right, bottom
      // padding: EdgeInsets.all(20),
      // margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
      // style: NeumorphicStyle(
      //   shape: NeumorphicShape.flat,
      //   boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
      //   depth: 3,
      //   intensity: 0.7,
      // ),
      // child: Text(
      //   answerText,
      //   style: boldTextStyle(
      //       size: 16, textColor: CustomColors.sdTextPrimaryColor, letterSpacing: 2),
      // ),
      // onPressed: selectHandler,
    // );

    //   SimpleButton(
    //     answerText,
    //     onPressed: selectHandler,
    // );
    //
    //   ElevatedButton(
    //   style: ButtonStyle(
    //       backgroundColor: MaterialStateProperty.all(HexColor("#915C53"))),
    //   onPressed: selectHandler,
    //   child: SizedBox(
    //     width: 200,
    //     child: Text(
    //       answerText,
    //       textAlign: TextAlign.center,
    //       style: TextStyle(
    //         fontWeight: FontWeight.w400,
    //         color: HexColor("#FEFEFE"),
    //       ),
    //     ),
    //   ),
    // );

  }
}
