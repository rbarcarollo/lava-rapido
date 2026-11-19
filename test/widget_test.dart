import 'package:flutter_test/flutter_test.dart';

import 'package:lava_rapido/models/lavagem.dart';

void main() {
  test('Lavagem converte para JSON e para Map do SQLite', () {
    final lavagem = Lavagem(35.5, 12, sincronizado: false);

    expect(lavagem.toJson(), {'valor': 35.5, 'numero_vaga': 12});
    expect(lavagem.toMap()['sincronizado'], 0);
  });

  test('Lavagem criada a partir da API vem sincronizada', () {
    final lavagem = Lavagem.fromJson({'valor': 60, 'numero_vaga': 7});

    expect(lavagem.valor, 60.0);
    expect(lavagem.numeroVaga, 7);
    expect(lavagem.sincronizado, isTrue);
  });
}
