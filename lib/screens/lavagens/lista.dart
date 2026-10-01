import 'package:flutter/material.dart';
import '../../models/lavagem.dart';
import 'formulario.dart';
import 'package:intl/intl.dart';

class ListaLavagens extends StatefulWidget {
  final List<Lavagem> _lavagens = [
    Lavagem(35.0, 12),
    Lavagem(60.0, 7),
  ];

  @override
  State<StatefulWidget> createState() {
    return ListaLavagensState();
  }
}

class ListaLavagensState extends State<ListaLavagens> {
  static const _tituloAppBar = "Lava-Rápido";

  void _atualiza(Lavagem? lavagemRecebida) {
    if (lavagemRecebida != null) {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          widget._lavagens.add(lavagemRecebida);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_tituloAppBar)),
      body: ListView.builder(
        itemCount: widget._lavagens.length,
        itemBuilder: (context, indice) {
          final lavagem = widget._lavagens[indice];
          return ItemLavagem(lavagem);
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("Botão + pressionado");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return FormularioLavagem();
              },
            ),
          ).then((lavagemRecebida) => _atualiza(lavagemRecebida));
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class ItemLavagem extends StatelessWidget {
  final Lavagem _lavagem;

  ItemLavagem(this._lavagem);

  @override
  Widget build(BuildContext context) {
    NumberFormat formato = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return Card(
      child: ListTile(
        leading: Icon(Icons.local_car_wash),
        title: Text(formato.format(_lavagem.valor)),
        subtitle: Text("Vaga: ${_lavagem.numeroVaga}"),
      ),
    );
  }
}
