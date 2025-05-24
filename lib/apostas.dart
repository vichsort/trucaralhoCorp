import 'package:flutter/material.dart';
import 'fichas.dart';

class BetPage extends StatefulWidget {
  const BetPage({Key? key}) : super(key: key);

  @override
  _BetPageState createState() => _BetPageState();
}

class _BetPageState extends State<BetPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apostas')),
      body: Center(
        child: ListView.builder(
          itemCount: fichas.length,
          itemBuilder: (context, index) {
            final ficha = fichas[index];
            return ListTile(
              title: Text(ficha.nome),
              subtitle: Text('Valor: ${ficha.valor}'),
            );
          },
        ),
      ),
    );
  }
}
