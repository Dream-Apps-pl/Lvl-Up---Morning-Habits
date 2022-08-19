import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import '../constants/theme_data.dart';
import 'quiz.dart';
import 'result.dart';

class StartQuiz extends StatefulWidget {
  const StartQuiz({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
   return _StartQuizState();

  }
}

class _StartQuizState extends State<StartQuiz> {

  static const _data = [
    {
      'questionText':
      'Who was the first woman to win a Nobel Prize (in 1903)?',
      'answers': [
        {'text': 'Simone de Beauvoir', 'score': 0.00},
        {'text': 'Marie Curie', 'score': 10.00},
        {'text': 'Margaret Thatcher', 'score': 0.00},
        {'text': 'Marilyn vos Savant', 'score': 0.00},
      ]
    },
    {
      'questionText':
      'What is the rarest M&M color?',
      'answers': [
        {'text': 'Red', 'score': 0.00},
        {'text': 'Yellow', 'score': 0.00},
        {'text': 'Brown', 'score': 10.00},
        {'text': 'Green', 'score': 0.00},
      ]
    },
    {
      'questionText':
      'Which country consumes the most chocolate per capita?',
      'answers': [
        {'text': 'United States', 'score': 0.00},
        {'text': 'France', 'score': 0.00},
        {'text': 'Belgium', 'score': 0.00},
        {'text': 'Switzerland', 'score': 10.00}
      ]
    },
    {
      'questionText':
      'What was the first toy to be advertised on television?',
      'answers': [
        {'text': 'Lego', 'score': 0.00},
        {'text': 'Monopoly', 'score': 0.00},
        {'text': 'Star wars figurine', 'score': 0.00},
        {'text': 'Mr Potato Head', 'score': 10.00}
      ]
    },
    {
      'questionText':
      'What is the loudest animal on Earth?',
      'answers': [
        {'text': 'Tiger Pistol Shrimp', 'score': 0.00},
        {'text': 'Howler Monkeys', 'score': 0.00},
        {'text': 'Sperm Whale', 'score': 10.00},
        {'text': 'Elephant', 'score': 0.00}
      ]
    },
    {
      'questionText':
      'In a website browser address bar, what does “www” stand for?',
      'answers': [
        {'text': 'Web wise web', 'score': 0.00},
        {'text': 'World Wide Web', 'score': 10.00},
        {'text': 'Website wide web', 'score': 0.00},
        {'text': 'World web worker', 'score': 0.00}
      ]
    },
    {
      'questionText':
      'What percentage of a pandas diet is bamboo?',
      'answers': [
        {'text': '25%', 'score': 0.00},
        {'text': '49%', 'score': 0.00},
        {'text': '75%', 'score': 0.00},
        {'text': '99%', 'score': 10.00}
      ]
    },
    {
      'questionText':
      'What TV series showed the first interracial kiss on American network television?',
      'answers': [
        {'text': 'The office', 'score': 0.00},
        {'text': 'Saturday Night Live', 'score': 0.00},
        {'text': 'Seinfeld', 'score': 0.00},
        {'text': 'Star Trek', 'score': 10.00}
      ]
    },
    {
      'questionText':
      'How many legs does a spider have?',
      'answers': [
        {'text': '6', 'score': 0.00},
        {'text': '8', 'score': 10.00},
        {'text': '10', 'score': 0.00},
        {'text': '4', 'score': 0.00}
      ]
    },
    {
      'questionText':
      'Coconut water can be used as what in the case of medical emergencies?',
      'answers': [
        {'text': 'Blood plasma', 'score': 10.00},
        {'text': 'Disinfectant', 'score': 0.00},
        {'text': 'Rehydration', 'score': 0.00},
        {'text': 'Pain killer', 'score': 0.00}
      ]
    },
    {
      'questionText':
      'What is the most consumed manufactured drink in the world?',
      'answers': [
        {'text': 'Tea', 'score': 10.00},
        {'text': 'Soft drinks', 'score': 0.00},
        {'text': 'Alcohol', 'score': 0.00},
        {'text': 'Milk', 'score': 0.00}
      ]
    },
    {
      'questionText':
      'What animal has the longest lifespan?',
      'answers': [
        {'text': 'Greenland shark', 'score': 10.00},
        {'text': 'Galapagos Giant Tortoise', 'score': 0.00},
        {'text': 'American lobster', 'score': 0.00},
        {'text': 'Bowhead whale', 'score': 0.00}
      ]
    },
    {
      'questionText':
      'In which city was Anne Frank’s hiding place?',
      'answers': [
        {'text': 'Paris', 'score': 0.00},
        {'text': 'Amsterdam', 'score': 10.00},
        {'text': 'Berlin', 'score': 0.00},
        {'text': 'Brussels', 'score': 0.00}
      ]
    },
    {
      'questionText':
      'Which country produces the most coffee in the world?',
      'answers': [
        {'text': 'Indonesia', 'score': 0.00},
        {'text': 'Colombia', 'score': 0.00},
        {'text': 'Brazil', 'score': 10.00},
        {'text': 'Vietnam', 'score': 0.00}
      ]
    },
    {
      'questionText':
      'Who was the first female artist in history to have four consecutive singles from one album reach the top-5 in the Billboard Hot 100?',
      'answers': [
        {'text': 'Ariana Grande', 'score': 0.00},
        {'text': 'Whitney Houston', 'score': 0.00},
        {'text': 'Taylor Swift', 'score': 0.00},
        {'text': 'Cindy Lauper', 'score': 10.00}
      ]
    },
    {
      'questionText':
      'What was the name of Paris Hilton and Nicole Richie\'s reality show?',
      'answers': [
        {'text': 'The Simple Life', 'score': 10.00},
        {'text': 'Rich Girls', 'score': 0.00},
        {'text': 'Paris and Nicole: The Ultimate BFFs', 'score': 0.00},
        {'text': 'Farm work', 'score': 0.00}
      ]
    },
    {
      'questionText':
      'Which country invented ice cream?',
      'answers': [
        {'text': 'France', 'score': 0.00},
        {'text': 'Italy', 'score': 0.00},
        {'text': 'Canada', 'score': 0.00},
        {'text': 'China', 'score': 10.00}
      ]
    },
    {
      'questionText':
      'What was the name of the MP3 player that Microsoft released to rival the iPod?',
      'answers': [
        {'text': 'Zune', 'score': 10.00},
        {'text': 'Win-Player', 'score': 0.00},
        {'text': 'The M', 'score': 0.00},
        {'text': 'Mpod', 'score': 0.00}
      ]
    },
    {
      'questionText':
      'NextQuestion',
      'answers': [
        {'text': 'one', 'score': 0.00},
        {'text': 'two', 'score': 0.00},
        {'text': 'tree', 'score': 10.00},
        {'text': 'four', 'score': 0.00}
      ]
    }
  ];

  var _indexQuestion = 0;
  double _totalScore = 0.00;

  void _answerQuestion(double score) {
    _totalScore += score;

    setState(() {
      _indexQuestion += 1;
    });
  }

  void _restart() {
    setState(() {
      _indexQuestion = 0;
      _totalScore = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          backgroundColor: CustomColors.sdAppBackgroundColor, //HexColor("#C9B3AF"),
          // appBar: AppBar(
          //   title: Align(
          //     alignment: Alignment.center,
          //     child: Text(
          //       "Fluttery",
          //       style: TextStyle(
          //         color: HexColor("#F5FFF0"),
          //       ),
          //     ),
          //   ),
          //   backgroundColor: HexColor("#6B443D"),
          // ),
          body: Align(
              alignment: Alignment.center,
              child: (_indexQuestion <= 18 && _indexQuestion >= 0)
                  ? Quiz(
                  answerQuestion: _answerQuestion,
                  indexQuestion: _indexQuestion,
                  data: _data)
                  : Result(_totalScore, _restart))),
    );
  }
}

