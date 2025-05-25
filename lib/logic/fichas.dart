final default_path = 'images/fichas';

class Ficha {
  String nome;
  String caminho_imagem;
  int valor;

  Ficha({
    required this.nome,
    required this.caminho_imagem,
    required this.valor,
  });
}

List<Ficha> fichas = [
  Ficha(nome: "Branca", caminho_imagem: '$default_path/white.png', valor: 1),
  Ficha(nome: "Vermelha", caminho_imagem: '$default_path/red.png', valor: 5),
  Ficha(nome: "Laranja", caminho_imagem: '$default_path/orange.png', valor: 10),
  Ficha(nome: "Amarela", caminho_imagem: '$default_path/yellow.png', valor: 20),
  Ficha(nome: "Verde", caminho_imagem: '$default_path/green.png', valor: 25),
  Ficha(nome: "Preta", caminho_imagem: '$default_path/black.png', valor: 100),
  Ficha(nome: "Roxa", caminho_imagem: '$default_path/purple.png', valor: 500),
  Ficha(nome: "Marrom", caminho_imagem: '$default_path/brown.png', valor: 1000),
];
