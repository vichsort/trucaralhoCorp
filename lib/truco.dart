import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'black.dart';

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
  String pedir = "truco!";

  void _incrementLeft() {
    setState(() {
      _leftCount += up;
      up = 1;
      if (_leftCount >= 12) {
        _leftCount = 0;
        _rightCount = 0;
        _leftWins++;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Nós ganhamos!'),
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
      up = 1;

      if (_rightCount >= 12) {
        _leftCount = 0;
        _rightCount = 0;
        _rightWins++;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Eles ganharam!'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _changeUp() {
    setState(() {
      if (up == 1) {
        up = 3;
        pedir = "seis!";
      } else if (up == 3) {
        up = 6;
        pedir = "nove!";
      } else if (up == 6) {
        up = 9;
        pedir = "doze!";
      } else if (up == 9) {
        up = 12;
        pedir = "truco!";
      } else {
        up = 1;
      }
    });
  }

  void _reset() {
    setState(() {
      _leftCount = 0;
      _rightCount = 0;
      _leftWins = 0;
      _rightWins = 0;
    });
  }

  void _correr() {
    setState(() {
      if (up == 1) {
        up = 3;
        pedir = "seis!";
      } else if (up == 3) {
        up = 6;
        pedir = "nove!";
      } else if (up == 6) {
        up = 9;
        pedir = "doze!";
      } else if (up == 9) {
        up = 12;
        pedir = "doze!";
      } else {
        up = 1;
      }
    });
  }

  void _resetLeft() {
    setState(() {
      _leftCount = 0;
    });
  }

  void _resetRight() {
    setState(() {
      _rightCount = 0;
    });
  }

  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

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
            icon: const Icon(Icons.question_mark_outlined),
            onPressed: () {
              // how to play 'em games (trooco)
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Como jogar Truco?'),
                    content: const Text(
                      'Truco é um jogo de cartas jogado com um baralho espanhol. '
                      'O objetivo é ser o primeiro a alcançar 12 pontos. '
                      'Os jogadores podem pedir "truco" para aumentar a aposta. '
                      'O jogo envolve blefes e estratégias para enganar o adversário.',
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
      body: Row(
        children: [
          // nos
          Expanded(
            child: GestureDetector(
              onTap: _incrementLeft,
              onDoubleTap: _decreaseLeft,
              onLongPress: _resetLeft,
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
                          color: Color(0xFF534d36),
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
              Text("Valendo: $up"),
              SizedBox(height: 60),
              ElevatedButton(onPressed: _changeUp, child: Text('$pedir')),
              SizedBox(height: 30),
              ElevatedButton(onPressed: _correr, child: Text("Correr")),
              SizedBox(height: 30),
              ElevatedButton(onPressed: _reset, child: Icon(Icons.refresh)),
            ],
          ),

          // eles
          Expanded(
            child: GestureDetector(
              onTap: _incrementRight,
              onDoubleTap: _decreaseRight,
              onLongPress: _resetRight,
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
                          color: Color(0xFF534d36),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: SpeedDial(
        openCloseDial: isDialOpen,
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.blue,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.card_giftcard),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            label: 'BlackJack',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BlackJackPage(),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
