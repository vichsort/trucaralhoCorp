import 'package:flutter/material.dart';
import 'pages/blackjack.dart';
import 'pages/truco.dart';
import 'pages/fodinha.dart';
import 'pages/poker.dart';

void main() {
  runApp(const TrucaralhoApp());
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
      home: const HomePage(),
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
            SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Jogar Fodinha'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FodinhaPage()),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Jogar Poker Clássico'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PokerPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
