import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';

import '../constants/theme_data.dart';
import '../main.dart';
import '../screens/alarm_screen/alarm_screen.dart';
import '../services/audio_handler.dart';
import '../stores/observable_alarm/observable_alarm.dart';
import 'quiz.dart';
import 'result.dart';

class StartQuiz extends StatefulWidget {
  final ObservableAlarm? alarm;
  final MyAudioHandler audioHandler;
  const StartQuiz({Key? key, this.alarm, required this.audioHandler})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StartQuizState();
  }
}

class StartQuizState extends State<StartQuiz> {
  ObservableAlarm alarm = ObservableAlarm();

  String todayData = "";
  late final List<Map<String, Object>> _dataToday;
  var _indexQuestion = 0;
  double _totalScore = 0.00;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    //Find Today questionText
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    // String formattedTime = DateFormat('kk:mm:a').format(now);
    String formattedDate = formatter.format(now);
    print('start_quiz: Today Date = $formattedDate'); //check

    var result = _data
        .where((elem) =>
            elem['test_date']
                .toString()
                //.toLowerCase()
                .contains(formattedDate //.toLowerCase()
                    ) ||
            elem['prod_date']
                .toString()
                //.toLowerCase()
                .contains(formattedDate //.toLowerCase()
                    ))
        .toList();
    print('start_quiz: Today Question text = $result'); //check

    _dataToday = result; //Question
  }

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

  todayDate() {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    // String formattedTime = DateFormat('kk:mm:a').format(now);
    String formattedDate = formatter.format(now);
    // print(formattedTime);
    print('start_quiz: $formattedDate');
  }

  setResults(String query) {
    var result = _data
        .where((elem) =>
            elem['test_date']
                .toString()
                //.toLowerCase()
                .contains(query //.toLowerCase()
                    ) ||
            elem['prod_date']
                .toString()
                //.toLowerCase()
                .contains(query //.toLowerCase()
                    ))
        .toList();
    print('start_quiz: $result');
  }

  //String convertedDateTime = "${now.year.toString()}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')} ${now.hour.toString().padLeft(2,'0')}-${now.minute.toString().padLeft(2,'0')}";

  //todayDate() == _data[_indexQuestion]['test_date'] as String

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: []); // fullscreen
    audioHandler = widget.audioHandler;
    // playing = true;

    return MaterialApp(
      home: Scaffold(
        backgroundColor:
            HexColor("#000000"), //CustomColors.sdAppBackgroundColor,
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
        body: Column(
          children: <Widget>[
            Expanded(
              child: Align(
                  alignment: Alignment.center,
                  child: (_indexQuestion == 0) // && _indexQuestion >= 0)
                      ? Quiz(
                          answerQuestion: _answerQuestion,
                          indexQuestion: _indexQuestion,
                          data: _dataToday)
                      : Result(_totalScore, _restart)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    if (playing) {
                      audioHandler.pause();
                      print('alarm_screen: playing= $playing');
                    } else {
                      audioHandler.play();
                      print('alarm_screen: playing= $playing');
                    }
                    setState(() => playing = !playing);
                  },
                  child: Icon(playing ? Icons.pause : Icons.play_arrow,
                      size: 30, color: Colors.black),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(CircleBorder()),
                    padding: MaterialStateProperty.all(EdgeInsets.all(16)),
                    backgroundColor: MaterialStateProperty.all(
                        Colors.white), // <-- Button color
                    overlayColor:
                        MaterialStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return CustomColors
                            .sdSecondaryColorYellow; // <-- Splash color
                      }
                      return CustomColors.sdAppWhite;
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const _data = [
    {
      'questionText': 'Who was the first woman to win a Nobel Prize (in 1903)?',
      'answers': [
        {'text': 'Simone de Beauvoir', 'score': 0.00},
        {'text': 'Marie Curie', 'score': 10.00},
        {'text': 'Margaret Thatcher', 'score': 0.00},
        {'text': 'Marilyn vos Savant', 'score': 0.00},
      ],
      'test_date': '2022-10-13',
      'prod_date': '2022-11-10',
      'song': 'https://drive.google.pl/file/d/1C0M0SJ7_gbyiTBQ073Bq-x1DEDvbab9m'
    },
    {
      'questionText': 'What is the rarest M&M color?',
      'answers': [
        {'text': 'Red', 'score': 0.00},
        {'text': 'Yellow', 'score': 0.00},
        {'text': 'Brown', 'score': 10.00},
        {'text': 'Green', 'score': 0.00},
      ],
      'test_date': '2022-10-14',
      'prod_date': '2022-11-11',
      'song': 'https://drive.google.pl/file/d/1Hw37_GpggK58txXv9bDyxOrc4c_k-qmj'
    },
    {
      'questionText': 'Which country consumes the most chocolate per capita?',
      'answers': [
        {'text': 'United States', 'score': 0.00},
        {'text': 'France', 'score': 0.00},
        {'text': 'Belgium', 'score': 0.00},
        {'text': 'Switzerland', 'score': 10.00}
      ],
      'test_date': '2022-10-15',
      'prod_date': '2022-11-12',
    },
    {
      'questionText': 'What was the first toy to be advertised on television?',
      'answers': [
        {'text': 'Lego', 'score': 0.00},
        {'text': 'Monopoly', 'score': 0.00},
        {'text': 'Star wars figurine', 'score': 0.00},
        {'text': 'Mr Potato Head', 'score': 10.00}
      ],
      'test_date': '2022-10-16',
      'prod_date': '2022-11-13',
    },
    {
      'questionText': 'What is the loudest animal on Earth?',
      'answers': [
        {'text': 'Tiger Pistol Shrimp', 'score': 0.00},
        {'text': 'Howler Monkeys', 'score': 0.00},
        {'text': 'Sperm Whale', 'score': 10.00},
        {'text': 'Elephant', 'score': 0.00}
      ],
      'test_date': '2022-10-17',
      'prod_date': '2022-11-14',
    },
    {
      'questionText':
          'In a website browser address bar, what does “www” stand for?',
      'answers': [
        {'text': 'Web wise web', 'score': 0.00},
        {'text': 'World Wide Web', 'score': 10.00},
        {'text': 'Website wide web', 'score': 0.00},
        {'text': 'World web worker', 'score': 0.00}
      ],
      'test_date': '2022-10-18',
      'prod_date': '2022-11-15',
    },
    {
      'questionText': 'What percentage of a pandas diet is bamboo?',
      'answers': [
        {'text': '25%', 'score': 0.00},
        {'text': '49%', 'score': 0.00},
        {'text': '75%', 'score': 0.00},
        {'text': '99%', 'score': 10.00}
      ],
      'test_date': '2022-10-19',
      'prod_date': '2022-11-16',
    },
    {
      'questionText':
          'What TV series showed the first interracial kiss on American network television?',
      'answers': [
        {'text': 'The office', 'score': 0.00},
        {'text': 'Saturday Night Live', 'score': 0.00},
        {'text': 'Seinfeld', 'score': 0.00},
        {'text': 'Star Trek', 'score': 10.00}
      ],
      'test_date': '2022-10-20',
      'prod_date': '2022-11-17',
    },
    {
      'questionText': 'How many legs does a spider have?',
      'answers': [
        {'text': '6', 'score': 0.00},
        {'text': '8', 'score': 10.00},
        {'text': '10', 'score': 0.00},
        {'text': '4', 'score': 0.00}
      ],
      'test_date': '2022-10-21',
      'prod_date': '2022-11-18',
    },
    {
      'questionText':
          'Coconut water can be used as what in the case of medical emergencies?',
      'answers': [
        {'text': 'Blood plasma', 'score': 10.00},
        {'text': 'Disinfectant', 'score': 0.00},
        {'text': 'Rehydration', 'score': 0.00},
        {'text': 'Pain killer', 'score': 0.00}
      ],
      'test_date': '2022-10-22',
      'prod_date': '2022-11-19',
    },
    {
      'questionText':
          'What is the most consumed manufactured drink in the world?',
      'answers': [
        {'text': 'Tea', 'score': 10.00},
        {'text': 'Soft drinks', 'score': 0.00},
        {'text': 'Alcohol', 'score': 0.00},
        {'text': 'Milk', 'score': 0.00}
      ],
      'test_date': '2022-10-23',
      'prod_date': '2022-11-20',
    },
    {
      'questionText': 'What animal has the longest lifespan?',
      'answers': [
        {'text': 'Greenland shark', 'score': 10.00},
        {'text': 'Galapagos Giant Tortoise', 'score': 0.00},
        {'text': 'American lobster', 'score': 0.00},
        {'text': 'Bowhead whale', 'score': 0.00}
      ],
      'test_date': '2022-10-24',
      'prod_date': '2022-11-21',
    },
    {
      'questionText': 'In which city was Anne Frank’s hiding place?',
      'answers': [
        {'text': 'Paris', 'score': 0.00},
        {'text': 'Amsterdam', 'score': 10.00},
        {'text': 'Berlin', 'score': 0.00},
        {'text': 'Brussels', 'score': 0.00}
      ],
      'test_date': '2022-10-25',
      'prod_date': '2022-11-22',
    },
    {
      'questionText': 'Which country produces the most coffee in the world?',
      'answers': [
        {'text': 'Indonesia', 'score': 0.00},
        {'text': 'Colombia', 'score': 0.00},
        {'text': 'Brazil', 'score': 10.00},
        {'text': 'Vietnam', 'score': 0.00}
      ],
      'test_date': '2022-10-26',
      'prod_date': '2022-11-23',
    },
    {
      'questionText':
          'Who was the first female artist in history to have four consecutive singles from one album reach the top-5 in the Billboard Hot 100?',
      'answers': [
        {'text': 'Ariana Grande', 'score': 0.00},
        {'text': 'Whitney Houston', 'score': 0.00},
        {'text': 'Taylor Swift', 'score': 0.00},
        {'text': 'Cindy Lauper', 'score': 10.00}
      ],
      'test_date': '2022-10-27',
      'prod_date': '2022-11-24',
    },
    {
      'questionText':
          'What was the name of Paris Hilton and Nicole Richie\'s reality show?',
      'answers': [
        {'text': 'The Simple Life', 'score': 10.00},
        {'text': 'Rich Girls', 'score': 0.00},
        {'text': 'Paris and Nicole: The Ultimate BFFs', 'score': 0.00},
        {'text': 'Farm work', 'score': 0.00}
      ],
      'test_date': '2022-10-28',
      'prod_date': '2022-11-25',
    },
    {
      'questionText': 'Which country invented ice cream?',
      'answers': [
        {'text': 'France', 'score': 0.00},
        {'text': 'Italy', 'score': 0.00},
        {'text': 'Canada', 'score': 0.00},
        {'text': 'China', 'score': 10.00}
      ],
      'test_date': '2022-10-29',
      'prod_date': '2022-11-26',
    },
    {
      'questionText': 'Acrophobia is the phobia of?',
      'answers': [
        {'text': 'Fear of Snakes', 'score': 0.00},
        {'text': 'Fear of crowds', 'score': 0.00},
        {'text': 'Fear of Heights', 'score': 10.00},
        {'text': 'Fear of Walking', 'score': 0.00}
      ],
      'test_date': '2022-10-30',
      'prod_date': '2022-11-27',
    },
    {
      'questionText':
          'What was the name of the MP3 player that Microsoft released to rival the iPod?',
      'answers': [
        {'text': 'Zune', 'score': 10.00},
        {'text': 'Win-Player', 'score': 0.00},
        {'text': 'The M', 'score': 0.00},
        {'text': 'Mpod', 'score': 0.00}
      ],
      'test_date': '2022-10-31',
      'prod_date': '2022-11-28',
    },
    {
      'questionText': 'What’s the most expensive home in the world?',
      'answers': [
        {'text': 'Orchid House', 'score': 0.00},
        {'text': 'Mar de Amor', 'score': 0.00},
        {'text': '18-19 Kensington Palace Gardens', 'score': 0.00},
        {'text': 'Buckingham Palace', 'score': 10.00}
      ],
      'test_date': '2022-11-01',
      'prod_date': '2022-11-29',
    },
    {
      'questionText': 'Where can you find the smallest bone in the human body?',
      'answers': [
        {'text': 'Pinky finger', 'score': 0.00},
        {'text': 'Middle Ear', 'score': 10.00},
        {'text': 'Hands', 'score': 0.00},
        {'text': 'Neck', 'score': 0.00}
      ],
      'test_date': '2022-11-02',
      'prod_date': '2022-11-30',
    },
    {
      'questionText':
          'Tacos are an increasingly-popular fast food that originated in which country?',
      'answers': [
        {'text': 'Mexico', 'score': 10.00},
        {'text': 'United States', 'score': 0.00},
        {'text': 'Spain', 'score': 0.00},
        {'text': 'China', 'score': 0.00}
      ],
      'test_date': '2022-11-03',
      'prod_date': '2022-12-01',
    },
    {
      'questionText':
          'Which of the following songstresses was a member of The Mickey Mouse Club early in her career?',
      'answers': [
        {'text': 'Ariana Grande', 'score': 0.00},
        {'text': 'Dua Lipa', 'score': 0.00},
        {'text': 'Britney Spear', 'score': 10.00},
        {'text': 'Katy Perry', 'score': 0.00}
      ],
      'test_date': '2022-11-04',
      'prod_date': '2022-12-02',
    },
    {
      'questionText': ' What is the name of the food that never expires?',
      'answers': [
        {'text': 'Coconut', 'score': 0.00},
        {'text': 'Sugar', 'score': 0.00},
        {'text': 'Oil', 'score': 0.00},
        {'text': 'Honey', 'score': 10.00}
      ],
      'test_date': '2022-11-05',
      'prod_date': '2022-12-03',
    },
    {
      'questionText': 'Which bone are babies born without?',
      'answers': [
        {'text': 'Coccyx', 'score': 0.00},
        {'text': 'Collar bone', 'score': 0.00},
        {'text': 'Kneecap', 'score': 10.00},
        {'text': 'Vertebra C8', 'score': 0.00}
      ],
      'test_date': '2022-11-06',
      'prod_date': '2022-12-04',
    },
    {
      'questionText':
          'What is the name of the youngest actor who won the best actor oscar?',
      'answers': [
        {'text': 'Daniel Day-Lewis', 'score': 0.00},
        {'text': 'Will Smith', 'score': 0.00},
        {'text': 'Adrien Brody', 'score': 10.00},
        {'text': 'Leonardo DiCaprio', 'score': 0.00}
      ],
      'test_date': '2022-11-07',
      'prod_date': '2022-12-05',
    },
    {
      'questionText':
          'It was illegal for women to wear what in 19th century florence?',
      'answers': [
        {'text': 'Buttons', 'score': 10.00},
        {'text': 'Shirts', 'score': 0.00},
        {'text': 'Skirts', 'score': 0.00},
        {'text': 'Hats', 'score': 0.00}
      ],
      'test_date': '2022-11-08',
      'prod_date': '2022-12-06',
    },
    {
      'questionText':
          'When held to ultraviolet light, what animal’s urine glows in the dark?',
      'answers': [
        {'text': 'Monkey', 'score': 0.00},
        {'text': 'Parrot', 'score': 0.00},
        {'text': 'Mouse', 'score': 0.00},
        {'text': 'Cat', 'score': 10.00}
      ],
      'test_date': '2022-11-09',
      'prod_date': '2022-12-07',
    }
  ];
}
