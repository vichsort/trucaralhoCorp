import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:lottie/lottie.dart';
import 'black.dart';

class TrucoPage extends StatefulWidget {
  const TrucoPage({Key? key}) : super(key: key);

  @override
  State<TrucoPage> createState() => _TrucoPageState();
}

class _TrucoPageState extends State<TrucoPage> {
  int _leftCount = 0;
  int _leftWins = 0;
  int _rightCount = 0;
  int _rightWins = 0;
  int up = 1;
  bool mostraBotaoDir = false;
  bool hideDir = false;
  bool mostraBotaoEsq = false;
  bool hideEsq = false;
  String pedido = "TRUCO!";
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  bool customeDialRoot = false;
  bool extend = false;
  bool showWinAnimation = false;

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

  void _incrementLeft() {
    setState(() {
      _leftCount += up;
      up = 1;
      if (_leftCount >= 12) {
        _leftCount = 0;
        _rightCount = 0;
        _leftWins++;
        showAnimation();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Eles ganharam!'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _decreaseLeft() {
    setState(() {
      _leftCount--;
      if (_leftCount <= 0) {
        _leftCount = 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Não pode diminuir mais!'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _decreaseRight() {
    setState(() {
      _rightCount--;
      if (_rightCount <= 0) {
        _rightCount = 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Não pode diminuir mais!'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _incrementRight() {
    setState(() {
      _rightCount += up;
      up = 1;

      if (_rightCount >= 12) {
        _leftCount = 0;
        _rightCount = 0;
        _rightWins++;
        showAnimation();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Eles ganharam!'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _changeUp(String lado, bool trucado) {
    setState(() {
      final pedidos = ["TRUCO!", "SEIS!", "NOVE!", "DOZE!"];
      final ups = [1, 3, 6, 9, 12];

      int currentIndex = pedidos.indexOf(pedido);

      // Se for trucado aumenta a aposta
      if (trucado) {
        if (currentIndex < pedidos.length - 1) {
          // mostra aceitar/correr no outro lado
          if (lado == "esq") {
            mostraBotaoDir = true;
            mostraBotaoEsq = false;
            hideEsq = true;
            hideDir = false;
          } else {
            mostraBotaoEsq = true;
            mostraBotaoDir = false;
            hideDir = true;
            hideEsq = false;
          }
          up = ups[currentIndex + 1];
          pedido = pedidos[currentIndex + 1];
        } else {
          // não sobe depois de doze
          up = 12;
          pedido = pedidos.last;
          mostraBotaoDir = false;
          mostraBotaoEsq = false;
          hideDir = true;
          hideEsq = true;
        }
        return;
      }

      // este loop refere quando se aceita o trucado
      // dai escondemos os aceitar/correr para pode aumentar a aposta
      if (lado == "esq") {
        mostraBotaoDir = false;
        mostraBotaoEsq = false;
        hideDir = true;
        hideEsq = false;
      } else {
        mostraBotaoEsq = false;
        mostraBotaoDir = false;
        hideEsq = true;
        hideDir = false;
      }
    });
  }

  void _reset() {
    setState(() {
      _leftCount = 0;
      _rightCount = 0;
      _leftWins = 0;
      _rightWins = 0;
    });
  }

  void _correr(lado) {
    setState(() {
      if (lado == "esq") {
        _rightCount += up;
        mostraBotaoEsq = false;
      } else {
        _leftCount += up;
        mostraBotaoDir = false;
      }
      up = 1;
    });
  }

  void _resetLeft() {
    setState(() {
      _leftCount = 0;
    });
  }

  void _resetRight() {
    setState(() {
      _rightCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trucaralho'),

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
              // how to play 'em games (trooco)
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Como jogar Truco?'),
                    content: const Text(
                      'Truco é um jogo de cartas jogado com um baralho espanhol. '
                      'O objetivo é ser o primeiro a alcançar 12 pontos. '
                      'Os jogadores podem pedir "truco" para aumentar a aposta. '
                      'O jogo envolve blefes e estratégias para enganar o adversário.',
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
          // nos
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _incrementLeft,
                  onDoubleTap: _decreaseLeft,
                  onLongPress: _resetLeft,
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
                            '$_leftCount',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            "Nós",
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
                            '$_leftWins',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),

                          SizedBox(height: 100),

                          if (mostraBotaoEsq == false && hideEsq == false)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Color(0xFF1f1d1e),
                                minimumSize: Size(120, 66),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                _changeUp("esq", true);
                              },
                              child: Text(pedido),
                            ),

                          if (mostraBotaoEsq)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    print('CORREU!');
                                    _correr("esq");
                                  },
                                  child: Text('CORRER'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                                SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    _changeUp("esq", false);
                                  },
                                  child: Text('ACEITAR'),
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

              // Meio
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Valendo: $up"),
                  SizedBox(height: 60),
                  ElevatedButton(onPressed: _reset, child: Icon(Icons.refresh)),
                ],
              ),

              // eles
              Expanded(
                child: GestureDetector(
                  onTap: _incrementRight,
                  onDoubleTap: _decreaseRight,
                  onLongPress: _resetRight,
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
                            '$_rightCount',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            "Eles",
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
                            '$_rightWins',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),

                          SizedBox(height: 100),

                          if (mostraBotaoDir == false && hideDir == false)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Color(0xFF1f1d1e),
                                minimumSize: Size(120, 66),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                _changeUp("dir", true);
                              },
                              child: Text(pedido),
                            ),

                          if (mostraBotaoDir)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _correr("dir");
                                  },
                                  child: Text('CORRER'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                                SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    _changeUp("dir", false);
                                  },
                                  child: Text('ACEITAR'),
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
            child: const Icon(Icons.card_giftcard),
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
        ],
      ),
    );
  }
}
