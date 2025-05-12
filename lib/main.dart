import 'package:flutter/material.dart';

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
      }
    });
  }

  void _incrementRight() {
    setState(() {
      _rightCount += up;

      if (_rightCount >= 12) {
        _rightCount = 0;
        _rightWins++;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trucaralho'), centerTitle: true),
      body: Row(
        children: [
          // nos
          ElevatedButton(onPressed: _changeUp, child: Text('$up')),
          Expanded(
            child: GestureDetector(
              onTap: _incrementLeft,
              child: Container(
                color: Colors.blue.withOpacity(0.1),
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
                      const SizedBox(height: 8),
                      const Icon(Icons.favorite, size: 48, color: Colors.blue),

                      Text(
                        '$_leftWins',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // linha
          const VerticalDivider(width: 1, thickness: 2, color: Colors.black54),

          // eles
          Expanded(
            child: GestureDetector(
              onTap: _incrementRight,
              child: Container(
                color: Colors.red.withOpacity(0.1),
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
                      const SizedBox(height: 8),
                      const Icon(Icons.favorite, size: 48, color: Colors.red),

                      Text(
                        '$_rightWins',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
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
    );
  }
}
