import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

void main() {
  runApp(const TrucaralhoApp());
}

class TrucaralhoApp extends StatelessWidget {
  const TrucaralhoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trucaralho Click Counter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ClickCounterPage(),
    );
  }
}

class ClickCounterPage extends StatefulWidget {
  const ClickCounterPage({Key? key}) : super(key: key);

  @override
  State<ClickCounterPage> createState() => _ClickCounterPageState();
}

class _ClickCounterPageState extends State<ClickCounterPage> {
  int _leftCount = 0;
  int _leftWins = 0;
  int _rightCount = 0;
  int _rightWins = 0;
  int up = 1;

  void _incrementLeft() {
    setState(() {
      _leftCount += up;
      if (_leftCount >= 12) {
        _leftCount = 0;
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

      if (_rightCount >= 12) {
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
      appBar: AppBar(title: const Text('Trucaralho'), centerTitle: true),
      body: Row(
        children: [
          // nos
          Expanded(
            child: GestureDetector(
              onTap: _incrementLeft,
              onDoubleTap: _decreaseLeft,
              onLongPress: _resetLeft,
              child: Container(
                color: Colors.blue.shade100,
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
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Icon(Icons.favorite, size: 48, color: Colors.blue),
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
                color: Colors.red.shade100,
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
                          color: Colors.red.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Icon(Icons.favorite, size: 48, color: Colors.red),
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
            child: const Icon(Icons.card_giftcard),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            label: 'Fodinha',
            onTap: () {},
            onLongPress: () => debugPrint('FIRST CHILD LONG PRESS'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.card_travel_sharp),
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            label: 'BlackJack',
            onTap: () => debugPrint('SECOND CHILD'),
          ),
        ],
      ),
    );
  }
}
