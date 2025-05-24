import 'package:flutter/material.dart';
import 'truco.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class BlackJackPage extends StatefulWidget {
  const BlackJackPage({Key? key}) : super(key: key);

  @override
  State<BlackJackPage> createState() => _BlackJackPageState();
}

class _BlackJackPageState extends State<BlackJackPage> {
  int _leftCount = 0;
  int _leftWins = 0;
  int _rightCount = 0;
  int _rightWins = 0;
  int up = 2;
  String carta = "2";
  bool aceDetect = false;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  bool customeDialRoot = false;
  bool extend = false;
  bool showWinAnimation = false;

  void showAnimation() {
    setState(() {
      showWinAnimation = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showWinAnimation = false;
        });
      }
    });
  }

  void _incrementLeft() {
    setState(() {
      _leftCount += up;
      up = 2;
      carta = "2";
      if (_leftCount >= 21) {
        _leftCount = 0;
        _rightCount = 0;
        _leftWins++;
        showAnimation();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('O convidado ganhou!'),
            duration: const Duration(seconds: 1),
          ),
        );
      } else if (_leftCount > 21) {
        _leftCount = 0;
        _rightCount = 0;
        _rightWins++;
        showAnimation();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('O convidado passou de 21!'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _decreaseLeft() {
    setState(() {
      _leftCount--;
      if (_leftCount <= 0) {
        _leftCount = 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Não pode diminuir mais!'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _decreaseRight() {
    setState(() {
      _rightCount--;
      if (_rightCount <= 0) {
        _rightCount = 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Não pode diminuir mais!'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _incrementRight() {
    setState(() {
      _rightCount += up;
      up = 2;
      carta = "2";

      if (_rightCount == 21) {
        _leftCount = 0;
        _rightCount = 0;
        _rightWins++;
        showAnimation();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('O dealer ganhou!'),
            duration: const Duration(seconds: 1),
          ),
        );
      } else if (_rightCount > 21) {
        _leftCount = 0;
        _rightCount = 0;
        _leftWins++;
        showAnimation();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('O dealer passou de 21!'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _changeUp() {
    setState(() {
      Map<String, int> cartado = {
        "2": 2,
        "3": 3,
        "4": 4,
        "5": 5,
        "6": 6,
        "7": 7,
        "8": 8,
        "9": 9,
        "10": 10,
        "Rainha": 10,
        "Valete": 10,
        "Rei": 10,
        "Ás": 11,
      };

      List<String> keys = cartado.keys.toList();
      int currentIndex = keys.indexOf(carta);
      currentIndex = (currentIndex + 1) % keys.length;
      carta = keys[currentIndex];
      up = cartado[carta]!;

      up == 11 ? aceDetect = true : aceDetect = false;
    });
  }

  void _reset() {
    setState(() {
      _leftCount = 0;
      _rightCount = 0;
      _leftWins = 0;
      _rightWins = 0;
      up = 2;
      carta = "2";
    });
  }

  void _aceVal(String lado, bool total) {
    total ? up = 11 : up = 1;
    if (lado == "esq") {
      _incrementLeft();
    } else {
      _incrementRight();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blackaralho'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.question_mark_outlined),
            onPressed: () {
              // how to play 'em games (trooco)
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Como jogar Blackjack?'),
                    content: const Text(
                      'Blackjack é um jogo de cartas jogado com um baralho comum. '
                      'O objetivo do jogo é chegar o mais próximo possível de 21 pontos, '
                      'sem ultrapassar esse valor, se ultrapassado, o convidado perde.'
                      'Na mesa, o jogador da casa irá distrubuir as cartas que serão reveladas ao longo do jogo.',
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Fechar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Row(
            children: [
              // você
              Expanded(
                child: GestureDetector(
                  onTap: _incrementLeft,
                  onLongPress: _decreaseLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[Color(0xFF1f1d1e), Color(0xFF383838)],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_leftCount',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            "Convidado",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF534d36),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Image(
                            image: AssetImage('images/paus.png'),
                            height: 150,
                            width: 150,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_leftWins',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          if (aceDetect)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _aceVal("esq", false);
                                  },
                                  child: Text('ACEITAR 1'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                                SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    _aceVal("esq", true);
                                  },
                                  child: Text('ACEITAR 11'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // linha
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: _changeUp, child: Text('$carta')),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: _reset, child: Icon(Icons.refresh)),
                ],
              ),

              // casa
              Expanded(
                child: GestureDetector(
                  onTap: _incrementRight,
                  onLongPress: _decreaseRight,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[Color(0xFF1f1d1e), Color(0xFF383838)],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_rightCount',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            "Dealer",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF534d36),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Image(
                            image: AssetImage('images/copas.png'),
                            height: 150,
                            width: 150,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_rightWins',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          if (aceDetect)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _aceVal("dir", false);
                                  },
                                  child: Text('ACEITAR 1'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                                SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    _aceVal("dir", true);
                                  },
                                  child: Text('ACEITAR 11'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (showWinAnimation)
            Center(
              child: Lottie.network(
                'https://lottie.host/0e03df0c-be10-4f75-835f-0e5c6715129d/vw87WFVoOy.json',
                repeat: false,
                height: 400,
                width: 400,
              ),
            ),
        ],
      ),

      floatingActionButton: SpeedDial(
        openCloseDial: isDialOpen,
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.blue,
        childPadding: EdgeInsets.all(5),
        activeLabel: Text('Fechar'),
        onOpen: () => isDialOpen.value = true,
        onClose: () => isDialOpen.value = false,
        closeManually: false,
        renderOverlay: false,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.card_membership_outlined),
            backgroundColor: Colors.deepPurple,
            label: 'Trucaralho',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TrucoPage()),
                ),
          ),
        ],
      ),
    );
  }
}
