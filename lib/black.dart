import 'package:flutter/material.dart';
import 'truco.dart';
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
  int up = 1;

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
      } else if (up == 3) {
        up = 6;
      } else if (up == 6) {
        up = 9;
      } else if (up == 9) {
        up = 12;
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
      ),
      body: Row(
        children: [
          // convidados
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
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        "Convidados",
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
              ElevatedButton(onPressed: _changeUp, child: Text('$up')),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _reset, child: Icon(Icons.refresh)),
            ],
          ),

          // casa
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
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        "Casa",
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
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.blue,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.card_membership_outlined),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
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
