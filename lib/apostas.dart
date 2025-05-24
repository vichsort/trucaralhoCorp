import 'package:flutter/material.dart';
import 'fichas.dart';

class BetPage extends StatefulWidget {
  const BetPage({Key? key}) : super(key: key);

  @override
  _BetPageState createState() => _BetPageState();
}

class _BetPageState extends State<BetPage> {
  final Set<int> selectedIndices = {};
  int selectedValues = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apostas')),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Ajuste conforme necessário
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: fichas.length,
                itemBuilder: (context, index) {
                  final ficha = fichas[index];
                  int count = selectedIndices.where((i) => i == index).length;

                  return Card(
                    color: count > 0 ? Colors.blue[900] : Colors.grey[700],
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                                          selectedIndices.remove(index);
                                          selectedValues -= fichas[index].valor;
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
                                  selectedIndices.add(index);
                                  selectedValues += fichas[index].valor;
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

            Text('Total adicionado: $selectedValues'),
          ],
        ),
      ),
    );
  }
}
