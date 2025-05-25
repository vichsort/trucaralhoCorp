import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../pages/truco.dart';
import '../pages/blackjack.dart';
import '../pages/fodinha.dart';
import '../pages/poker.dart';

Widget actionDial(context, String page) {
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
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
      if (page != "truco")
        SpeedDialChild(
          child: const Icon(Icons.whatshot),
          backgroundColor: Colors.deepPurple,
          label: 'Truco Paulista',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrucoPage()),
              ),
        ),
      if (page != "blackjack")
        SpeedDialChild(
          child: const Icon(Icons.pages),
          backgroundColor: Colors.red,
          label: 'BlackJack',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BlackJackPage()),
              ),
        ),
      if (page != "fodinha")
        SpeedDialChild(
          child: const Icon(Icons.web_stories),
          backgroundColor: Colors.blue,
          label: 'Fodinha',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FodinhaPage()),
              ),
        ),
      if (page != "poker")
        SpeedDialChild(
          child: const Icon(Icons.style),
          backgroundColor: Colors.orange,
          label: 'Poker',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PokerPage()),
              ),
        ),
    ],
  );
}
