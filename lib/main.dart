import 'package:flutter/material.dart';
import 'black.dart';
import 'truco.dart';

void main() {
  runApp(const TrucaralhoApp()); // 🔧 Correto agora
}

class TrucaralhoApp extends StatelessWidget {
  const TrucaralhoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trucaralho | Jogos',
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const HomePage(), // Aqui você usa sua HomePage normalmente
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trucaralho')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Jogar Truco'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TrucoPage()),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Jogar Blackjack'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BlackJackPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
