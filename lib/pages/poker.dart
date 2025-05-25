import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'truco.dart';
import 'blackjack.dart';
import 'fodinha.dart';
import '../logic/apostas.dart';
import '../logic/fichas.dart';

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
  int leftValue = 1000; // Valor inicial dos jogadores
  int rightValue = 1000; // Valor inicial dos jogadores
  bool actionDetect = false;
  bool showWinAnimation = false;
  int pot = 0;
  int currentBet = 0; // Aposta atual na mesa
  String gamePhase = 'betting'; // 'betting', 'called', 'showdown'
  String lastAction = ''; // Para mostrar a última ação
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  // Adicionado: Histórico do jogo e número da rodada
  List<Map<String, dynamic>> gameHistory = [];
  int roundNumber = 1;

  // Adicionar ação ao histórico
  void addToHistory(
    String action,
    String player, {
    int? amount,
    String? details,
  }) {
    setState(() {
      gameHistory.add({
        'round': roundNumber,
        'timestamp': DateTime.now(),
        'action': action,
        'player': player,
        'amount': amount,
        'details': details,
        'potAfter': pot,
        'leftValueAfter': leftValue,
        'rightValueAfter': rightValue,
      });
    });
  }

  // Mostrar histórico
  Future<void> showGameHistory() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.history, color: Colors.white, size: 28),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Histórico da Partida',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),

                      // Stats resumo
                      Container(
                        padding: EdgeInsets.all(16),
                        color: Colors.grey[850],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Rodada Atual',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                Text(
                                  '$roundNumber',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Total de Ações',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                Text(
                                  '${gameHistory.length}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Pot Atual',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                Text(
                                  '\$${pot}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Lista do histórico
                      Expanded(
                        child:
                            gameHistory.isEmpty
                                ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.history,
                                        size: 64,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Nenhuma ação ainda',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                      Text(
                                        'Faça sua primeira jogada!',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : ListView.builder(
                                  controller: scrollController,
                                  itemCount: gameHistory.length,
                                  reverse:
                                      true, // Mostrar mais recente primeiro
                                  itemBuilder: (context, index) {
                                    final historyIndex =
                                        gameHistory.length - 1 - index;
                                    final entry = gameHistory[historyIndex];
                                    return historyTile(entry, historyIndex);
                                  },
                                ),
                      ),

                      // Footer com botões
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          border: Border(
                            top: BorderSide(color: Colors.grey[700]!),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: clearHistory,
                                icon: Icon(Icons.delete_sweep),
                                label: Text('Limpar Histórico'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[700],
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(Icons.check),
                                label: Text('Fechar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[700],
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  // Widget para cada item do histórico
  Widget historyTile(Map<String, dynamic> entry, int index) {
    String actionText = entry['action'];
    String playerName = entry['player'];
    int? amount = entry['amount'];
    String? details = entry['details'];
    DateTime timestamp = entry['timestamp'];

    // Cores baseadas na ação
    Color actionColor = Colors.white;
    IconData actionIcon = Icons.circle;

    switch (actionText.toUpperCase()) {
      case 'CALL':
        actionColor = Colors.green;
        actionIcon = Icons.add_circle;
        break;
      case 'CHECK':
        actionColor = Colors.blue;
        actionIcon = Icons.check_circle;
        break;
      case 'RAISE':
        actionColor = Colors.orange;
        actionIcon = Icons.trending_up;
        break;
      case 'FOLD':
        actionColor = Colors.red;
        actionIcon = Icons.cancel;
        break;
      case 'ALL IN':
        actionColor = Colors.purple;
        actionIcon = Icons.all_inclusive;
        break;
      case 'ACCEPT':
        actionColor = Colors.teal;
        actionIcon = Icons.thumb_up;
        break;
      case 'WIN':
        actionColor = Colors.amber;
        actionIcon = Icons.emoji_events;
        break;
      case 'NEW ROUND':
        actionColor = Colors.cyan;
        actionIcon = Icons.refresh;
        break;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: actionColor.withOpacity(0.2),
          child: Icon(actionIcon, color: actionColor, size: 20),
        ),
        title: Row(
          children: [
            Text(
              playerName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: actionColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                actionText,
                style: TextStyle(
                  color: actionColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            if (amount != null) ...[
              SizedBox(width: 8),
              Text(
                '\${amount}',
                style: TextStyle(
                  color: Colors.green[300],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (details != null)
              Text(
                details,
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
            SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Rodada ${entry['round']}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                SizedBox(width: 12),
                Text(
                  '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                SizedBox(width: 12),
                Text(
                  'Pot: \$${entry['potAfter']}',
                  style: TextStyle(color: Colors.green[400], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        dense: true,
      ),
    );
  }

  // Limpar histórico
  void clearHistory() {
    setState(() {
      gameHistory.clear();
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Histórico limpo com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Exibir animação de vitória
  void showAnimation() {
    setState(() => showWinAnimation = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => showWinAnimation = false);
    });
  }

  // CALL - Apostar fichas
  Future<void> showCallModal(BuildContext context, String side) async {
    final controller = BetControllerManager.instance.getController(side);

    await showModalBottomSheet(
      context: context,
      builder: (_) {
        final indices = Map<int, int>.from(controller.selectedIndices);
        int betAmount = controller.selectedValues;

        return StatefulBuilder(
          builder:
              (_, setState) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'CALL - Fazer Aposta',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    'Seu saldo: \$${side == 'left' ? leftValue : rightValue}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Valor da aposta: \$${betAmount}',
                    style: TextStyle(fontSize: 20, color: Colors.blue),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3 / 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: fichas.length,
                      itemBuilder: (_, index) {
                        final ficha = fichas[index];
                        int count = indices[index] ?? 0;
                        return Card(
                          color:
                              count > 0 ? Colors.blue[900] : Colors.grey[700],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                ficha.caminho_imagem,
                                height: 60,
                                fit: BoxFit.contain,
                              ),
                              Text(
                                ficha.nome,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Valor: \$${ficha.valor}'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    color: Colors.white,
                                    onPressed:
                                        count > 0
                                            ? () {
                                              setState(() {
                                                indices[index] =
                                                    (indices[index]! > 1)
                                                        ? indices[index]! - 1
                                                        : 0;
                                                betAmount -= ficha.valor;
                                                controller.save(
                                                  indices,
                                                  betAmount,
                                                );
                                              });
                                            }
                                            : null,
                                  ),
                                  Text(
                                    '$count',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    color: Colors.white,
                                    onPressed: () {
                                      int playerValue =
                                          side == 'left'
                                              ? leftValue
                                              : rightValue;
                                      if (betAmount + ficha.valor <=
                                          playerValue) {
                                        setState(() {
                                          indices[index] =
                                              (indices[index] ?? 0) + 1;
                                          betAmount += ficha.valor;
                                          controller.save(indices, betAmount);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                betAmount > 0
                                    ? () => handleCall(side, betAmount)
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(
                              'CALL - Apostar \$${betAmount}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        );
      },
    );
  }

  // Processar CALL
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
          '${side == 'left' ? 'Convidado' : 'Casa'} fez CALL de \${amount}';
      actionDetect = true;
    });

    // Adicionar ao histórico
    addToHistory(
      'CALL',
      side == 'left' ? 'Convidado' : 'Casa',
      amount: amount,
      details: 'Aposta inicial de \${amount}',
    );

    Navigator.pop(context);
  }

  // CHECK - Seguir a aposta
  void handleCheck(String side) {
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
  Future<void> showFoldConfirmation(String side) async {
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
      side == 'left' ? 'Convidado' : 'Casa',
      details: 'Desistiu da rodada, perdendo \$${pot}',
    );

    _win(winner);
  }

  // RAISE - Aumentar aposta
  Future<void> showRaiseModal(BuildContext context, String side) async {
    final controller = BetControllerManager.instance.getController(
      '${side}_raise',
    );

    await showModalBottomSheet(
      context: context,
      builder: (_) {
        final indices = Map<int, int>.from(controller.selectedIndices);
        int raiseAmount = controller.selectedValues;

        return StatefulBuilder(
          builder:
              (_, setState) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'RAISE - Aumentar Aposta',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Aposta atual: ${currentBet}',
                          style: TextStyle(fontSize: 18, color: Colors.yellow),
                        ),
                        Text(
                          'Seu saldo: \$${side == 'left' ? leftValue : rightValue}',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Valor do raise: \$${raiseAmount}',
                          style: TextStyle(fontSize: 20, color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3 / 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: fichas.length,
                      itemBuilder: (_, index) {
                        final ficha = fichas[index];
                        int count = indices[index] ?? 0;
                        return Card(
                          color:
                              count > 0 ? Colors.orange[900] : Colors.grey[700],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                ficha.caminho_imagem,
                                height: 60,
                                fit: BoxFit.contain,
                              ),
                              Text(
                                ficha.nome,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Valor: \$${ficha.valor}'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    color: Colors.white,
                                    onPressed:
                                        count > 0
                                            ? () {
                                              setState(() {
                                                indices[index] =
                                                    (indices[index]! > 1)
                                                        ? indices[index]! - 1
                                                        : 0;
                                                raiseAmount -= ficha.valor;
                                                controller.save(
                                                  indices,
                                                  raiseAmount,
                                                );
                                              });
                                            }
                                            : null,
                                  ),
                                  Text(
                                    '$count',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    color: Colors.white,
                                    onPressed: () {
                                      int playerValue =
                                          side == 'left'
                                              ? leftValue
                                              : rightValue;
                                      int totalCost =
                                          currentBet +
                                          raiseAmount +
                                          ficha.valor;
                                      if (totalCost <= playerValue) {
                                        setState(() {
                                          indices[index] =
                                              (indices[index] ?? 0) + 1;
                                          raiseAmount += ficha.valor;
                                          controller.save(indices, raiseAmount);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                raiseAmount > 0
                                    ? () => _raise(side, raiseAmount)
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(
                              'RAISE +${raiseAmount} (Total: ${currentBet + raiseAmount})',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        );
      },
    );
  }

  void _raise(String side, int raiseAmount) {
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
      actionDetect = false; // Oponente precisa responder
    });
    Navigator.pop(context);

    addToHistory(
      'RAISE',
      side == 'left' ? 'Convidado' : 'Casa',
      details:
          'Aumentou a aposta em \$${side == 'left' ? leftValue : rightValue}',
    );
  }

  // ALL IN - Colocar todas as fichas (10 fichas do maior tipo)
  Future<void> showAllInConfirmation(String side) async {
    // Encontrar a ficha de maior valor que o jogador pode usar
    int playerValue = side == 'left' ? leftValue : rightValue;

    // Encontrar qual é a maior ficha que cabe 10 vezes no saldo
    var fichasDisponiveis =
        fichas.where((f) => f.valor * 10 <= playerValue).toList();
    if (fichasDisponiveis.isEmpty) {
      // Se não consegue nem 10 da menor ficha, usar tudo que tem
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
        side == 'left' ? 'Convidado' : 'Casa',
        details: 'Aumentou o valor em \$${amount}',
      );
    });
  }

  // ACCEPT - Aceitar raise ou all in
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

      // Adicionar ao histórico
      addToHistory(
        'ACCEPT',
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
      // Reset do jogo
      pot = 0;
      currentBet = 0;
      leftInTable = 0;
      rightInTable = 0;
      actionDetect = false;
      gamePhase = 'betting';
      lastAction =
          '${winner == 'left' ? 'Convidado' : 'Casa'} ganhou a rodada!';

      // Limpar controllers
      BetControllerManager.instance.getController('left').clear();
      BetControllerManager.instance.getController('right').clear();
      BetControllerManager.instance.getController('left_raise').clear();
      BetControllerManager.instance.getController('right_raise').clear();
      BetControllerManager.instance.getController('left_raise').clear();
      BetControllerManager.instance.getController('right_raise').clear();

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

      // Limpar controllers
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
            onPressed: showGameHistory,
            tooltip: 'Histórico',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: resetGame,
            tooltip: 'Novo Jogo',
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
                        leftValue,
                        leftWins,
                        'Convidado',
                      ),
                    ),
                    Container(width: 2, color: Colors.white24),
                    Expanded(
                      child: playerArea('right', rightValue, rightWins, 'Casa'),
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
      floatingActionButton: actionDial(),
    );
  }

  Widget playerArea(String id, int value, int wins, String label) {
    int inTable = id == 'left' ? leftInTable : rightInTable;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1f1d1e), Color(0xFF383838)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '\$${value}',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(fontSize: 24)),
          Text('Vitórias: $wins', style: const TextStyle(fontSize: 20)),
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
                                ? () => showCallModal(context, id)
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
                            gamePhase != 'showdown' && gamePhase != 'all_in'
                                ? () => handleCheck(id)
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
                                ? () => showRaiseModal(context, id)
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
                                ? () => showFoldConfirmation(id)
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
                            ? () => showAllInConfirmation(id)
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
                    child: const Text('GANHOU'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget actionDial() {
    return SpeedDial(
      openCloseDial: isDialOpen,
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: Colors.blue,
      childPadding: EdgeInsets.all(5),
      activeLabel: Text('Fechar'),
      onOpen: () => isDialOpen.value = true,
      onClose: () => isDialOpen.value = false,
      closeManually: false,
      renderOverlay: false,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.card_membership_outlined),
          backgroundColor: Colors.deepPurple,
          label: 'Truco Paulista',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrucoPage()),
              ),
        ),
        SpeedDialChild(
          child: const Icon(Icons.card_membership_outlined),
          backgroundColor: Colors.red,
          label: 'BlackJack',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BlackJackPage()),
              ),
        ),
        SpeedDialChild(
          child: const Icon(Icons.card_membership_outlined),
          backgroundColor: Colors.blue,
          label: 'Fodinha',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FodinhaPage()),
              ),
        ),
      ],
    );
  }
}
