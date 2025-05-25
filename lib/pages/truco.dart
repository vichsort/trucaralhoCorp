import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:lottie/lottie.dart';
import '../logic/historico.dart';
import 'blackjack.dart';
import 'fodinha.dart';
import 'poker.dart';

class TrucoPage extends StatefulWidget {
  const TrucoPage({Key? key}) : super(key: key);

  @override
  State<TrucoPage> createState() => _TrucoPageState();
}

class _TrucoPageState extends State<TrucoPage> {
  int _leftCount = 0;
  int _leftWins = 0;
  int _rightCount = 0;
  int _rightWins = 0;
  int up = 1;
  bool rightDetect = false;
  bool hideRight = false;
  bool leftDetect = false;
  bool hideLeft = false;
  String words = "TRUCO!";
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

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  void _increment(String side) {
    setState(() {
      if (side == "left") {
        _leftCount += up;
        _microReset();
        if (_leftCount >= 12) {
          _leftCount = 0;
          _rightCount = 0;
          _leftWins++;
          showAnimation();
          showMessage('Nós ganhamos!');
          addToHistory('WIN', 'TRUCO', 'NÓS', details: 'Nós levamos a rodada!');
        }
      } else {
        _rightCount += up;
        _microReset();
        if (_rightCount >= 12) {
          _leftCount = 0;
          _rightCount = 0;
          _rightWins++;
          showAnimation();
          showMessage('Eles ganharam!');
          addToHistory(
            'WIN',
            'TRUCO',
            'ELES',
            details: 'Eles levaram a rodada!',
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

  void _resetSide(String side) {
    setState(() {
      if (side == "left") {
        _leftCount = 0;
      } else {
        _rightCount = 0;
      }
    });
  }

  void _changeUp(String side, bool trucado) {
    setState(() {
      final wordss = ["TRUCO!", "SEIS!", "NOVE!", "DOZE!"];
      final ups = [1, 3, 6, 9, 12];

      int currentIndex = wordss.indexOf(words);

      // Se for trucado aumenta a aposta
      if (trucado) {
        if (currentIndex < wordss.length - 1) {
          // mostra aceitar/correr no outro side
          if (side == "left") {
            rightDetect = true;
            leftDetect = false;
            hideLeft = true;
            hideRight = false;
          } else {
            leftDetect = true;
            rightDetect = false;
            hideRight = true;
            hideLeft = false;
          }
          up = ups[currentIndex + 1];
          words = wordss[currentIndex + 1];
        } else {
          // não sobe depois de doze
          up = 12;
          words = wordss.last;
          rightDetect = false;
          leftDetect = false;
          hideRight = true;
          hideLeft = true;
        }
        addToHistory(
          'TRUCOU',
          'TRUCO',
          side == "left" ? "NÓS" : "ELES",
          details: '${side == "left" ? "Nós pedimos" : "Eles pediram"} $words',
        );
        return;
      }

      // este loop refere quando se aceita o trucado
      // dai escondemos os aceitar/correr para pode aumentar a aposta
      if (side == "left") {
        rightDetect = false;
        leftDetect = false;
        hideRight = true;
        hideLeft = false;
      } else {
        leftDetect = false;
        rightDetect = false;
        hideLeft = true;
        hideRight = false;
      }
    });
  }

  void _reset() {
    setState(() {
      _leftCount = 0;
      _rightCount = 0;
      _leftWins = 0;
      _rightWins = 0;
      _microReset();
      addToHistory('RESET', 'TRUCO', 'Jogo', details: 'Um novo jogo começou!');
    });
  }

  void _correr(side) {
    setState(() {
      if (side == "left") {
        _rightCount += up;
        leftDetect = false;
      } else {
        _leftCount += up;
        rightDetect = false;
      }

      if (_leftCount >= 12) {
        _increment("left");
      } else if (_rightCount >= 12) {
        _increment("right");
      }
      addToHistory(
        'CORREU',
        'TRUCO',
        side == "left" ? "NÓS" : "ELES",
        details:
            '${side == "left" ? "Nós corremos" : "Eles correram"} do trucado, dando $up pontos para ${side != "left" ? "nós" : "eles"}',
      );
      _microReset();
    });
  }

  void _microReset() {
    setState(() {
      up = 1;
      words = "TRUCO!";
      hideRight = false;
      hideLeft = false;
      rightDetect = false;
      leftDetect = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trucaralho'),

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
            icon: const Icon(Icons.question_mark_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Como jogar Truco?'),
                    content: const Text(
                      'Truco é um jogo de cartas jogado com um baralho espanhol. '
                      'Os jogadores podem pedir "truco" para aumentar a aposta. '
                      'O jogo envolve blefes e estratégias para enganar o adversário. '
                      'Um "Truco" faz com que a rodada passe a valer 3 pontos, o adversário pode'
                      'aceitar ou correr, se correr o adversário ganha 1 ponto, se aceitar o truco a aposta aumenta para 6 pontos. '
                      'O mesmo se aplica para 9 e 12 pontos. '
                      'O jogo termina quando um jogador/dupla atinge 12 pontos.',
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
            tooltip: 'Como jogar',
          ),
        ],
      ),
      body: Stack(
        children: [
          // nos
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _increment("left"),
                  onDoubleTap: () => _decrease("left"),
                  onLongPress: () => _resetSide("left"),
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
                            "Nós",
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

                          SizedBox(height: 100),

                          if (leftDetect == false && hideLeft == false)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Color(0xFF1f1d1e),
                                minimumSize: Size(120, 66),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                _changeUp("left", true);
                              },
                              child: Text(words),
                            ),

                          if (leftDetect)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _correr("left");
                                  },
                                  child: Text('CORRER'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                                SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    _changeUp("left", false);
                                  },
                                  child: Text('ACEITAR'),
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

              // Meio
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Valendo: $up"),
                  SizedBox(height: 60),
                  ElevatedButton(onPressed: _reset, child: Icon(Icons.refresh)),
                ],
              ),

              // eles
              Expanded(
                child: GestureDetector(
                  onTap: () => _increment("right"),
                  onDoubleTap: () => _decrease("right"),
                  onLongPress: () => _resetSide("right"),
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
                            "Eles",
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

                          SizedBox(height: 100),

                          if (rightDetect == false && hideRight == false)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Color(0xFF1f1d1e),
                                minimumSize: Size(120, 66),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                _changeUp("right", true);
                                addToHistory(
                                  'TRUCOU',
                                  'TRUCO',
                                  'ELES',
                                  details: 'Eles pediram $words!',
                                );
                              },
                              child: Text(words),
                            ),

                          if (rightDetect)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _correr("right");
                                  },
                                  child: Text('CORRER'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                                SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    _changeUp("right", false);
                                  },
                                  child: Text('ACEITAR'),
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
            child: const Icon(Icons.card_giftcard),
            backgroundColor: Colors.red,
            label: 'BlackJack',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BlackJackPage(),
                  ),
                ),
          ),
          SpeedDialChild(
            child: const Icon(Icons.card_giftcard),
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
