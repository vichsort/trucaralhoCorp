import 'package:flutter/material.dart';

class Ficha {
  String nome;
  Color cor;
  int valor;

  Ficha({required this.nome, required this.cor, required this.valor});
}

List<Ficha> fichas = [
  Ficha(nome: "Branca", cor: Colors.white, valor: 1),
  Ficha(nome: "Vermelha", cor: Colors.red, valor: 5),
  Ficha(nome: "Laranja", cor: Colors.orange, valor: 10),
  Ficha(nome: "Amarela", cor: Colors.yellow, valor: 20),
  Ficha(nome: "Verde", cor: Colors.green, valor: 25),
  Ficha(nome: "Preta", cor: Colors.black, valor: 100),
  Ficha(nome: "Roxa", cor: Colors.purple, valor: 500),
  Ficha(nome: "Marrom", cor: Colors.brown, valor: 1000),
];
