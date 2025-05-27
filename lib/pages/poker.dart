import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../logic/apostas.dart';
import '../logic/fichas.dart';
import '../logic/historico.dart';
import '../logic/speedDial.dart';

class PokerPage extends StatefulWidget {
  const PokerPage({Key? key}) : super(key: key);

  @override
  State<PokerPage> createState() => _PokerPageState();
}

class _PokerPageState extends State<PokerPage> {
  int leftInTable = 0;
  int rightInTable = 0;
  int leftWins = 0;
  int rightWins = 0;
  int leftValue = 1000;
  int rightValue = 1000;
  bool actionDetect = false;
  bool showWinAnimation = false;
  int pot = 0;
  int currentBet = 0;
  String gamePhase = 'betting';
  String lastAction = '';

  void showAnimation() {
    setState(() => showWinAnimation = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => showWinAnimation = false);
    });
  }

  Future<void> _modalCall(BuildContext context, String side) async {
    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return PokerCall(
          (int betAmount) => handleCall(side, betAmount),
          side,
          leftValue,
          rightValue,
        );
      },
    );
  }

  void handleCall(String side, int amount) {
    setState(() {
      if (side == 'left') {
        leftValue -= amount;
        leftInTable = amount;
      } else {
        rightValue -= amount;
        rightInTable = amount;
      }
      pot += amount;
      currentBet = amount;
      gamePhase = 'called';
      lastAction =
          '${side == 'left' ? 'Convidado' : 'Casa'} fez CALL de \$${amount}';
      actionDetect = true;
    });

    // Adicionar ao histórico
    addToHistory(
      'CALL',
      'Poker',
      side == 'left' ? 'Convidado' : 'Casa',
      amount: amount,
      details: 'Aposta inicial de \$${amount}',
    );

    Navigator.pop(context);
  }

  // CHECK - Seguir a aposta
  void _check(String side) {
    if (currentBet == 0) {
      // Se não há aposta na mesa, CHECK é gratuito
      setState(() {
        lastAction = '${side == 'left' ? 'Convidado' : 'Casa'} fez CHECK';
        gamePhase = 'checked';
      });
    } else {
      // Se há aposta na mesa, CHECK significa igualar a aposta
      int playerValue = side == 'left' ? leftValue : rightValue;
      if (playerValue >= currentBet) {
        setState(() {
          if (side == 'left') {
            leftValue -= currentBet;
            leftInTable = currentBet;
          } else {
            rightValue -= currentBet;
            rightInTable = currentBet;
          }
          pot += currentBet;
          lastAction =
              '${side == 'left' ? 'Convidado' : 'Casa'} fez CHECK (${currentBet})';
          gamePhase = 'showdown';
          actionDetect = true;
        });
      }
    }
  }

  // FOLD - Desistir e dar fichas ao oponente
  Future<void> _confirmFold(String side) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar FOLD'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Você tem certeza que quer dar FOLD?'),
                SizedBox(height: 10),
                Text(
                  'Isso significa que você vai desistir e o oponente ganhará o pot de \${pot}.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Confirmar FOLD',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _fold(side);
              },
            ),
          ],
        );
      },
    );
  }

  void _fold(String side) {
    String winner = side == 'left' ? 'right' : 'left';
    setState(() {
      lastAction = '${side == 'left' ? 'Convidado' : 'Casa'} deu FOLD';
    });

    // Adicionar ao histórico
    addToHistory(
      'FOLD',
      'Poker',
      side == 'left' ? 'Convidado' : 'Casa',
      details: 'Desistiu da rodada, perdendo \$${pot}',
    );

    _win(winner);
  }

  // RAISE - Aumentar aposta
  Future<void> _modalRaise(BuildContext context, String side) async {
    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return PokerRaise(
          (int raiseAmount) => handleRaise(side, raiseAmount),
          currentBet,
          side,
          leftValue,
          rightValue,
        );
      },
    );
  }

  void handleRaise(String side, int raiseAmount) {
    int totalBet = currentBet + raiseAmount;
    setState(() {
      if (side == 'left') {
        leftValue -= totalBet;
        leftInTable = totalBet;
      } else {
        rightValue -= totalBet;
        rightInTable = totalBet;
      }
      pot += totalBet;
      currentBet = totalBet;
      gamePhase = 'raised';
      lastAction =
          '${side == 'left' ? 'Convidado' : 'Casa'} fez RAISE para \$${totalBet}';
      actionDetect = false;
    });
    Navigator.pop(context);

    addToHistory(
      'RAISE',
      'Poker',
      side == 'left' ? 'Convidado' : 'Casa',
      details:
          'Aumentou a aposta em \$${side == 'left' ? leftValue : rightValue}',
    );
  }

  Future<void> allInConfirm(String side) async {
    int playerValue = side == 'left' ? leftValue : rightValue;

    var fichasDisponiveis =
        fichas.where((f) => f.valor * 10 <= playerValue).toList();
    if (fichasDisponiveis.isEmpty) {
      return showDialog<void>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Saldo Insuficiente'),
              content: Text(
                'Você não tem saldo suficiente para fazer ALL IN com 10 fichas.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
      );
    }

    var fichaMaior = fichasDisponiveis.reduce(
      (a, b) => a.valor > b.valor ? a : b,
    );
    int allInAmount = fichaMaior.valor * 10;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar ALL IN'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Você tem certeza que quer dar ALL IN?'),
                SizedBox(height: 10),
                Text('Isso colocará 10 fichas ${fichaMaior.nome}.'),
                Text('Equivalente a \$${allInAmount}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Confirmar ALL IN',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _allIn(side, allInAmount, fichaMaior.nome);
              },
            ),
          ],
        );
      },
    );
  }

  void _allIn(String side, int amount, String fichaName) {
    setState(() {
      if (side == 'left') {
        leftValue -= amount;
        leftInTable = amount;
      } else {
        rightValue -= amount;
        rightInTable = amount;
      }
      pot += amount;
      currentBet = amount;
      gamePhase = 'all_in';
      lastAction =
          '${side == 'left' ? 'Convidado' : 'Casa'} fez ALL IN: \$${amount} (10x ${fichaName})';

      addToHistory(
        'ALL IN',
        'Poker',
        side == 'left' ? 'Convidado' : 'Casa',
        details: 'Aumentou o valor em \$${amount}',
      );
    });
  }

  void _accept(String side) {
    int opponentBet = side == 'left' ? rightInTable : leftInTable;
    int playerValue = side == 'left' ? leftValue : rightValue;

    if (playerValue >= opponentBet) {
      setState(() {
        if (side == 'left') {
          leftValue -= opponentBet;
          leftInTable = opponentBet;
        } else {
          rightValue -= opponentBet;
          rightInTable = opponentBet;
        }
        pot += opponentBet;
        lastAction =
            '${side == 'left' ? 'Convidado' : 'Casa'} aceitou a aposta';
        gamePhase = 'showdown';
        actionDetect = true;
      });

      addToHistory(
        'ACCEPT',
        'Poker',
        side == 'left' ? 'Convidado' : 'Casa',
        amount: opponentBet,
        details: 'Aceitou a aposta de \$${opponentBet}',
      );
    }
  }

  void _win(String winner) {
    setState(() {
      if (winner == 'left') {
        leftValue += pot;
        leftWins++;
      } else {
        rightValue += pot;
        rightWins++;
      }
      addToHistory(
        'WIN',
        'Poker',
        winner == 'left' ? 'Convidado' : 'Casa',
        details:
            '${winner == 'left' ? ' O Convidado' : ' A Casa'} levou a rodada valendo \$$pot',
      );

      pot = 0;
      currentBet = 0;
      leftInTable = 0;
      rightInTable = 0;
      actionDetect = false;
      gamePhase = 'betting';
      lastAction =
          '${winner == 'left' ? 'Convidado' : 'Casa'} ganhou a rodada!';

      BetControllerManager.instance.getController('left').clear();
      BetControllerManager.instance.getController('right').clear();
      BetControllerManager.instance.getController('leftraise').clear();
      BetControllerManager.instance.getController('rightraise').clear();
      BetControllerManager.instance.getController('leftraise').clear();
      BetControllerManager.instance.getController('rightraise').clear();

      showAnimation();
    });
  }

  void resetGame() {
    setState(() {
      pot = 0;
      currentBet = 0;
      leftInTable = 0;
      rightInTable = 0;
      actionDetect = false;
      gamePhase = 'betting';
      lastAction = 'Novo jogo iniciado';

      BetControllerManager.instance.getController('left').clear();
      BetControllerManager.instance.getController('right').clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokaralho'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => showGameHistory(context),
            tooltip: 'Histórico',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: resetGame,
            tooltip: 'Novo Jogo',
          ),
          IconButton(
            icon: const Icon(Icons.question_mark_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Como jogar Poker?'),
                    content: const Text(
                      'Poker é um jogo de cartas onde o objetivo é ganhar fichas apostadas pelos jogadores. '
                      'Os jogadores fazem apostas (BET), aumentar a aposta (RAISE), igualar a aposta (CALL/CHECK) ou desistir (FOLD). '
                      'O jogo é jogado em rodadas, e o jogador que ganhar a rodada leva o pot. '
                      'Os jogadores podem fazer apostas em fichas de diferentes valores, e o valor total da aposta é chamado de pot. '
                      'Além disso, os jogadores podem fazer apostas adicionais (ALL IN) colocando todas as suas fichas na mesa. '
                      'O jogo continua até que um jogador ganhe todas as fichas ou até que os jogadores decidam parar. ',
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
      body: Stack(
        children: [
          Column(
            children: [
              // Status do jogo
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                color: Colors.grey[800],
                child: Column(
                  children: [
                    Text(
                      'Pot: \$${pot}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    if (currentBet > 0)
                      Text(
                        'Aposta atual: \$${currentBet}',
                        style: TextStyle(fontSize: 18, color: Colors.yellow),
                      ),
                    if (lastAction.isNotEmpty)
                      Text(
                        lastAction,
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: playerArea(
                        'left',
                        'images/paus.png',
                        leftValue,
                        leftWins,
                        'Convidado',
                      ),
                    ),
                    Container(width: 2, color: Colors.white24),
                    Expanded(
                      child: playerArea(
                        'right',
                        'images/copas.png',
                        rightValue,
                        rightWins,
                        'Casa',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showWinAnimation)
            Center(
              child: Lottie.network(
                'https://lottie.host/0e03df0c-be10-4f75-835f-0e5c6715129d/vw87WFVoOy.json',
                height: 300,
              ),
            ),
        ],
      ),
      floatingActionButton: actionDial(context, "poker"),
    );
  }

  Widget playerArea(String id, String path, int value, int wins, String label) {
    int inTable = id == 'left' ? leftInTable : rightInTable;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF1f1d1e), Color(0xFF383838)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '\$${value}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFF534d36),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            label,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF534d36),
            ),
          ),
          const SizedBox(height: 3),
          Image(image: AssetImage(path), height: 150, width: 150),
          Text(
            '$wins',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          if (inTable > 0)
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Na mesa: \$${inTable}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

          // Botões de ação
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Linha 1: CALL e CHECK
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            gamePhase == 'betting'
                                ? () => _modalCall(context, id)
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'CALL',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            gamePhase != 'showdown' &&
                                    gamePhase != 'all_in' &&
                                    gamePhase != 'betting'
                                ? () => _check(id)
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          currentBet == 0 ? 'CHECK' : 'CHECK',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Linha 2: RAISE e FOLD
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            (gamePhase == 'betting' || gamePhase == 'called')
                                ? () => _modalRaise(context, id)
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'RAISE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            gamePhase != 'betting' && gamePhase != 'showdown'
                                ? () => _confirmFold(id)
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'FOLD',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Linha 3: ALL IN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        (gamePhase == 'betting' || gamePhase == 'called')
                            ? () => allInConfirm(id)
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'ALL IN',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Botão ACCEPT (aparece quando oponente fez raise ou all in)
                if (gamePhase == 'raised' || gamePhase == 'all_in')
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _accept(id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "ACCEPT (\$${id == 'left' ? rightInTable : leftInTable})",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Botões de resultado (quando actionDetect é true)
          if (actionDetect)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _win(id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    child: Text(
                      'Ganhou',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
