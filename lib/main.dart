import 'package:flutter/material.dart';

void main() {
  runApp(const Trucaralho());
}

class Trucaralho extends StatelessWidget {
  const Trucaralho({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trucaralho',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const TrucoPage(title: 'Truco'),
    );
  }
}

class TrucoPage extends StatefulWidget {
  const TrucoPage({super.key, required this.title});

  final String title;

  @override
  State<TrucoPage> createState() => _TrucoPageState();
}

class _TrucoPageState extends State<TrucoPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.card_giftcard),
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.abc))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Trco ne viado',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
