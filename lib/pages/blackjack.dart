import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'truco.dart';
import 'fodinha.dart';
import 'poker.dart';
import '../logic/apostas.dart';
import '../logic/historico.dart';

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

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

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

  _increment(String side) {
    setState(() {
      if (side == "left") {
        _leftCount += up;
        up = 2;
        carta = "2";
        if (_leftCount == 21) {
          _leftCount = 0;
          _rightCount = 0;
          _leftWins++;
          showAnimation();
          showMessage('O convidado ganhou!');
          addToHistory(
            'WIN',
            'BLACKJACK',
            'CONVIDADO',
            details: "O convidado levou a partida!",
          );
        } else if (_leftCount > 21) {
          _leftCount = 0;
          _rightCount = 0;
          _rightWins++;
          showAnimation();
          showMessage('O convidado passou de 21!');
          addToHistory(
            'PASSOU',
            'BLACKJACK',
            'CONVIDADO',
            details: "O convidado passou de 21, dando a partida para o dealer!",
          );
        }
      } else {
        _rightCount += up;
        up = 2;
        carta = "2";

        if (_rightCount == 21) {
          _leftCount = 0;
          _rightCount = 0;
          _rightWins++;
          showAnimation();
          showMessage('O dealer ganhou!');
          addToHistory(
            'WIN',
            'BLACKJACK',
            'DEALER',
            details: "O dealer levou a partida!",
          );
        } else if (_rightCount > 21) {
          _leftCount = 0;
          _rightCount = 0;
          _leftWins++;
          showAnimation();
          showMessage('O dealer passou de 21!');
          addToHistory(
            'PASSOU',
            'BLACKJACK',
            'DEALER',
            details: "O dealer passou de 21, dando a partida para o convidado!",
          );
        }
      }
    });
  }

  void _decrease(String side) {
    setState(() {
      if (side == "left") {
        _leftCount--;
        if (_leftCount <= 0) {
          _leftCount = 0;
          showMessage('Não pode diminuir mais!');
        }
      } else {
        _rightCount--;
        if (_rightCount <= 0) {
          _rightCount = 0;
          showMessage('Não pode diminuir mais!');
        }
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
      addToHistory(
        'RESET',
        'BLACKJACK',
        'Jogo',
        details: 'Um novo jogo começou!',
      );
    });
  }

  void _aceVal(String side, bool total) {
    total ? up = 11 : up = 1;
    if (side == "left") {
      _increment("left");
    } else {
      _increment("right");
    }
  }

  void _openModal() {
    showModalBottomSheet(context: context, builder: (context) => BetPage());
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
            icon: Icon(Icons.history),
            onPressed: () => showGameHistory(context),
            tooltip: 'Histórico',
          ),
          IconButton(
            onPressed: _openModal,
            icon: Icon(Icons.attach_money_sharp),
          ),
          IconButton(
            icon: const Icon(Icons.question_mark_outlined),
            onPressed: () {
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
            tooltip: "Como jogar",
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
                  onTap: () => _increment("left"),
                  onLongPress: () => _decrease("left"),
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
                                    _aceVal("left", false);
                                  },
                                  child: Text('ACEITAR 1'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                                SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    _aceVal("left", true);
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
                  ValueListenableBuilder<int>(
                    valueListenable:
                        BetController.instance.selectedValuesNotifier,
                    builder: (context, value, child) {
                      return Text('Na mesa: ${value * 2}');
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: _changeUp, child: Text('$carta')),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: _reset, child: Icon(Icons.refresh)),
                ],
              ),

              // casa
              Expanded(
                child: GestureDetector(
                  onTap: () => _increment("right"),
                  onLongPress: () => _decrease("right"),
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
            label: 'Truco Paulista',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TrucoPage()),
                ),
          ),
          SpeedDialChild(
            child: const Icon(Icons.card_membership_outlined),
            backgroundColor: Colors.blue,
            label: 'Fodinha',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FodinhaPage()),
                ),
          ),
          SpeedDialChild(
            child: const Icon(Icons.card_membership_outlined),
            backgroundColor: Colors.orange,
            label: 'Poker Clássico',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PokerPage()),
                ),
          ),
        ],
      ),
    );
  }
}
