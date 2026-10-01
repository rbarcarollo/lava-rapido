import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lava_rapido/main.dart';

void main() {
  testWidgets('Lista de lavagens exibe os registros iniciais e o botão de adicionar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(LavaRapidoApp());

    expect(find.text('Lava-Rápido'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(2));
  });
}
