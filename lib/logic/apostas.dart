import 'package:flutter/material.dart';
import 'fichas.dart';

class BetPage extends StatefulWidget {
  const BetPage({Key? key}) : super(key: key);

  @override
  _BetPageState createState() => _BetPageState();
}

class BetController {
  BetController._privateConstructor();

  static final BetController instance = BetController._privateConstructor();

  Map<int, int> selectedIndices = {};
  int selectedValues = 0;

  final ValueNotifier<int> selectedValuesNotifier = ValueNotifier<int>(0);

  void save(Map<int, int> indices, int values) {
    selectedIndices = Map<int, int>.from(indices);
    selectedValues = values;
    selectedValuesNotifier.value = values;
  }

  void clear() {
    selectedIndices.clear();
    selectedValues = 0;
  }
}

class BetControllerManager {
  BetControllerManager._privateConstructor();

  static final BetControllerManager instance =
      BetControllerManager._privateConstructor();

  final Map<String, BetController> _controllers = {};

  BetController getController(String id) {
    return _controllers.putIfAbsent(
      id,
      () => BetController._privateConstructor(),
    );
  }

  void clearAll() {
    _controllers.clear();
  }
}

class _BetPageState extends State<BetPage> {
  final Map<int, int> selectedIndices = {};
  int selectedValues = 0;

  @override
  void initState() {
    super.initState();
    // salvos do controller (quando inicia)
    selectedIndices.addAll(BetController.instance.selectedIndices);
    selectedValues = BetController.instance.selectedValues;
  }

  @override
  void dispose() {
    // salva no controller (quando fecha)
    BetController.instance.save(selectedIndices, selectedValues);
    super.dispose();
  }

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
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: fichas.length,
                itemBuilder: (context, index) {
                  final ficha = fichas[index];
                  int count = selectedIndices[index] ?? 0;

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
                                          if (selectedIndices[index] != null &&
                                              selectedIndices[index]! > 1) {
                                            selectedIndices[index] =
                                                selectedIndices[index]! - 1;
                                          } else {
                                            selectedIndices.remove(index);
                                          }
                                          selectedValues -= fichas[index].valor;
                                          BetController.instance.save(
                                            selectedIndices,
                                            selectedValues,
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
                                  selectedIndices[index] =
                                      (selectedIndices[index] ?? 0) + 1;
                                  selectedValues += fichas[index].valor;
                                  BetController.instance.save(
                                    selectedIndices,
                                    selectedValues,
                                  );
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
