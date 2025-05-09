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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
  int _rightCount = 0;

  void _incrementLeft() {
    setState(() {
      _leftCount++;
    });
  }

  void _incrementRight() {
    setState(() {
      _rightCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trucaralho Click Counter'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _incrementLeft,
              child: Container(
                color: Colors.blue.withOpacity(0.1),
                child: Center(
                  child: Text(
                    'Esquerda: $_leftCount',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _incrementRight,
              child: Container(
                color: Colors.red.withOpacity(0.1),
                child: Center(
                  child: Text(
                    'Direita: $_rightCount',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
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
