import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../logic/historico.dart';
import '../logic/speedDial.dart';
import '../logic/howTo.dart';

class FodinhaPage extends StatefulWidget {
  const FodinhaPage({Key? key}) : super(key: key);

  @override
  State<FodinhaPage> createState() => _FodinhaPageState();
}

class _FodinhaPageState extends State<FodinhaPage> {
  int numberOfPlayers = 5;
  int initialLives = 5;
  List<int> vidas = [];
  List<int> vitorias = [];
  bool showWinAnimation = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void showAnimation() {
    setState(() {
      showWinAnimation = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showWinAnimation = false;
        });
        showRestartDialog(); // chama o diálogo depois da animação
      }
    });
  }

  void showRestartDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reiniciar Jogo?'),
            content: const Text(
              'Deseja reiniciar o jogo para uma nova partida?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // fecha o diálogo
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // fecha o diálogo
                  _resetGame(); // reinicia o jogo
                },
                child: const Text('Reiniciar'),
              ),
            ],
          ),
    );
  }

  void _initializeGame() {
    vidas = List.filled(numberOfPlayers, initialLives);
    vitorias = List.filled(numberOfPlayers, 0);
  }

  void _incrementVida(int index) {
    if (vidas[index] > 0) {
      setState(() {
        vidas[index]++;
      });
    }
  }

  void _decrementVida(int index) {
    if (vidas[index] > 0) {
      setState(() {
        vidas[index]--;
      });
      _checkForWinner();
    }
  }

  void _checkForWinner() {
    int vivos = vidas.where((v) => v > 0).length;
    if (vivos == 1) {
      int winnerIndex = vidas.indexWhere((v) => v > 0);
      setState(() {
        vitorias[winnerIndex]++;
      });
      showAnimation();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jogador ${winnerIndex + 1} venceu!'),
          duration: Duration(seconds: 2),
        ),
      );
      addToHistory(
        'WIN',
        'FODINHA',
        'Jogador ${winnerIndex + 1}',
        details: 'O jogador${winnerIndex + 1} levou a rodada!',
      );
    }
  }

  void _resetGame() {
    setState(() {
      vidas = List.filled(numberOfPlayers, initialLives);
    });
    addToHistory('RESET', 'FODINHA', 'Jogo', details: 'Um novo jogo começou!');
  }

  void _setDefault() {
    setState(() {
      numberOfPlayers = 5;
      initialLives = 5;
      _initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fodaralho'),
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
            onPressed: () => FodinhaDialog(),
            tooltip: "Como jogar",
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('Jogadores:'),
                        DropdownButton<int>(
                          value: numberOfPlayers,
                          items:
                              List.generate(6, (index) => index + 2)
                                  .map(
                                    (e) => DropdownMenuItem(
                                      child: Text('$e'),
                                      value: e,
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              numberOfPlayers = value!;
                              _initializeGame();
                            });
                          },
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Vidas:'),
                        DropdownButton<int>(
                          value: initialLives,
                          items:
                              List.generate(10, (index) => index + 1)
                                  .map(
                                    (e) => DropdownMenuItem(
                                      child: Text('$e'),
                                      value: e,
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              initialLives = value!;
                              _initializeGame();
                            });
                          },
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _resetGame,
                      child: const Icon(Icons.refresh),
                    ),
                    ElevatedButton(
                      onPressed: _setDefault,
                      child: const Icon(Icons.settings_backup_restore),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: numberOfPlayers,
                  itemBuilder: (context, index) {
                    bool isDead = vidas[index] == 0;

                    Color? cardColor;
                    if (isDead) {
                      cardColor = Colors.grey[400];
                    } else {
                      switch (index % 3) {
                        case 0:
                          cardColor = Colors.blue[200];
                          break;
                        case 1:
                          cardColor = Colors.cyan[200];
                          break;
                        case 2:
                          cardColor = Colors.white;
                          break;
                      }
                    }

                    return Card(
                      color: cardColor,
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(
                          'Vidas: ${vidas[index]}',
                          style: TextStyle(
                            color: isDead ? Colors.grey : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          'Vitórias: ${vitorias[index]}',
                          style: TextStyle(
                            color: isDead ? Colors.grey : Colors.black,
                          ),
                        ),
                        onTap: () {
                          if (isDead != true) {
                            _decrementVida(index);
                          }
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              color: Colors.red,
                              onPressed:
                                  isDead ? null : () => _decrementVida(index),
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              color: Colors.deepPurple,
                              onPressed:
                                  isDead ? null : () => _incrementVida(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
      floatingActionButton: actionDial(context, "fodinha"),
    );
  }
}
