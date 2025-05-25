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
  // CALL - APOSTAR UMA FICHA CADA
  // CHECK - SEGUIR A APOSTA
  // FOLD - DAR SUA FICHA PRO ADVERSÁRIO
  // RAISE - AUMENTAR APOSTA
  // ALL IN - COLOCAR TODAS AS FICHAS

  // RESPOSTA PADRÃO ELSE: DO NOTHING

  // o jogador pode chamar a aposta com um botão call (como do truco)
  // o call vai pedir a quantidade de fichas que ele vai colocar
  // Cada um dos usuários coloca a quantidade de fichas específicas
  // então, a aposta vai ser o valor do pot.

  // clicou de um lado -> confirmar "jogador ganhou aposta?"
  // se sim: playerValue += pot
  // se sim: playerWins += 1

  // depois do call, cada um dos usuários pode dar um raise
  // pediu o raise? quem pediu bota a quantidade de fichas
  // o outro usuário decide de quer aceitar (raise)
  // ou se quer dar a sua quantidade de fichas para o outro,
  // fold -> confirmar "você quer dar um fold?"
  // se sim: playerValue += pot
  // se sim: playerWins += 1

  // vai ter a opção de ir ALL IN - que coloca 10 fichas do
  // maior tipo que você tem colocado na mesa
  // all in -> confirmar "você quer dar um all in? Isso colocará
  // 10 fichas {cor da ficha}, equivalente a {valor}"
  // se sim: playerInTable += valor

  // fold e accept ficam então disponíveis, sendo fold a mesma
  // coisa que já era e accept nivela a quantidade de playerInTable

  // se possível colocar um histórico

  // posto na mesa
  int leftInTable = 0;
  int rightInTable = 0;

  // vitórias
  int leftWins = 0;
  int rightWins = 0;

  // valor ganho - valor perdido
  int leftValue = 0;
  int rightValue = 0;

  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  bool customeDialRoot = false;
  bool extend = false;
  bool showWinAnimation = false;
  // referente ao jogo
  bool actionDetect = false;
  int pot = 0;

  void showAnimation() {
    setState(() {
      showWinAnimation = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showWinAnimation = false;
        });
      }
    });
  }

  Future<void> showBetModal(BuildContext context, String controllerId) async {
    final controller = BetControllerManager.instance.getController(
      controllerId,
    );
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        final indices = Map<int, int>.from(controller.selectedIndices);
        int values = controller.selectedValues;

        return StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: Column(
                children: [
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
                      itemBuilder: (context, index) {
                        final ficha = fichas[index];
                        int count = indices[index] ?? 0;

                        return Card(
                          color:
                              count > 0 ? Colors.blue[900] : Colors.grey[700],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (ficha.caminho_imagem.isNotEmpty)
                                Image.asset(
                                  ficha.caminho_imagem,
                                  height: 60,
                                  fit: BoxFit.contain,
                                ),
                              const SizedBox(height: 8),
                              Text(
                                ficha.nome,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Valor: \$: ${ficha.valor}'),
                              const SizedBox(height: 8),
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
                                                if (indices[index] != null &&
                                                    indices[index]! > 1) {
                                                  indices[index] =
                                                      indices[index]! - 1;
                                                } else {
                                                  indices.remove(index);
                                                }
                                                values -= fichas[index].valor;
                                                controller.save(
                                                  indices,
                                                  values,
                                                );
                                              });
                                            }
                                            : null,
                                  ),
                                  Text(
                                    '$count',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    color: Colors.white,
                                    onPressed: () {
                                      setState(() {
                                        print(controllerId);
                                        indices[index] =
                                            (indices[index] ?? 0) + 1;
                                        values += fichas[index].valor;
                                        controller.save(indices, values);
                                        if (controllerId == "left") {
                                          leftValue += values;
                                        } else {
                                          rightValue += values;
                                        }
                                        pot += values;
                                      });
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
                  Text('Total adicionado: $values'),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokaralho'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.question_mark_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Como jogar Blackjack?'),
                    content: const Text(
                      'Blackjack é um jogo de cartas jogado com um baralho comum. '
                      'O objetivo do jogo é chegar o mais próximo possível de 21 pontos, '
                      'sem ultrapassar esse valor, se ultrapassado, o convidado perde.'
                      'Na mesa, o jogador da casa irá distrubuir as cartas que serão reveladas ao longo do jogo.',
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
          Row(
            children: [
              // você
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    showBetModal(context, "left");
                  },
                  onLongPress: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[Color(0xFF1f1d1e), Color(0xFF383838)],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$leftValue',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            "Convidado",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF534d36),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Image(
                            image: AssetImage('images/paus.png'),
                            height: 150,
                            width: 150,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$leftWins',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          if (actionDetect)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text('ACEITAR 1'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                                SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text('ACEITAR 11'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                              ],
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
                  ValueListenableBuilder<int>(
                    valueListenable:
                        BetController.instance.selectedValuesNotifier,
                    builder: (context, value, child) {
                      return Text('Na mesa: ${pot}');
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: () {}, child: Text('aa')),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: () {}, child: Icon(Icons.refresh)),
                ],
              ),

              // casa
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    showBetModal(context, "right");
                  },
                  onLongPress: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[Color(0xFF1f1d1e), Color(0xFF383838)],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$rightValue',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            "Casa",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF534d36),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Image(
                            image: AssetImage('images/copas.png'),
                            height: 150,
                            width: 150,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$rightWins',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          if (actionDetect)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text('ACEITAR 1'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                                SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text('ACEITAR 11'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
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

      floatingActionButton: SpeedDial(
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
                  MaterialPageRoute(
                    builder: (context) => const BlackJackPage(),
                  ),
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
      ),
    );
  }
}
