import 'package:flutter/material.dart';
import '../../components/editor.dart';
import '../../models/lavagem.dart';

class FormularioLavagem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FormularioLavagemState();
  }
}

class FormularioLavagemState extends State<FormularioLavagem> {
  final TextEditingController _controladorCampoNumeroVaga =
      TextEditingController();
  final TextEditingController _controladorCampoValor = TextEditingController();

  static const _tituloAppBar = 'Nova lavagem';
  static const _rotuloCampoValor = 'Valor do serviço';
  static const _dicaCampoValor = '0,00';

  static const _rotuloCampoNumeroVaga = 'Número da vaga';
  static const _dicaCampoNumeroVaga = '00';
  static const _textoBotaoConfirmar = 'Confirmar';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_tituloAppBar),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Editor(
              controlador: _controladorCampoNumeroVaga,
              rotulo: _rotuloCampoNumeroVaga,
              dica: _dicaCampoNumeroVaga,
              icone: Icons.local_parking,
            ),

            Editor(
              controlador: _controladorCampoValor,
              rotulo: _rotuloCampoValor,
              dica: _dicaCampoValor,
              icone: Icons.local_car_wash,
            ),

            ElevatedButton(
              onPressed: () {
                debugPrint("Clicou aqui...");
                _criaLavagem(
                  context,
                  _controladorCampoNumeroVaga,
                  _controladorCampoValor,
                );
              },
              child: const Text(_textoBotaoConfirmar),
            ),
          ],
        ),
      ),
    );
  }
}

void _criaLavagem(
  BuildContext context,
  TextEditingController controladorCampoNumeroVaga,
  TextEditingController controladorCampoValor,
) {
  final int? numeroVaga = int.tryParse(controladorCampoNumeroVaga.text);
  final double? valor = double.tryParse(controladorCampoValor.text);

  if (numeroVaga != null && valor != null) {
    final lavagemCriada = Lavagem(valor, numeroVaga);

    debugPrint('$lavagemCriada'); // Teste de saída no console

    Navigator.pop(context, lavagemCriada);
  }
}
