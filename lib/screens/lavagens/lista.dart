import 'package:flutter/material.dart';
import '../../models/lavagem.dart';
import '../../repository/lavagem_repository.dart';
import 'formulario.dart';
import 'package:intl/intl.dart';

class ListaLavagens extends StatefulWidget {
  const ListaLavagens({super.key});

  @override
  State<StatefulWidget> createState() {
    return ListaLavagensState();
  }
}

class ListaLavagensState extends State<ListaLavagens> {
  static const _tituloAppBar = "Lava-Rápido";

  final LavagemRepository _repositorio = RepositorioLavagem.instancia;

  List<Lavagem> _lavagens = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _mostrarMensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    final lavagens = await _repositorio.buscarLavagens();
    if (!mounted) return;
    setState(() {
      _lavagens = lavagens;
      _carregando = false;
    });
  }

  Future<void> _salvar(Lavagem? lavagemRecebida) async {
    if (lavagemRecebida == null) return;

    try {
      await _repositorio.salvarLavagem(lavagemRecebida);
      _mostrarMensagem('Lavagem cadastrada');
    } catch (erro) {
      _mostrarMensagem('$erro');
    }
    await _carregar();
  }

  Future<void> _sincronizar() async {
    setState(() => _carregando = true);
    try {
      final enviados = await _repositorio.sincronizarPendentes();
      _mostrarMensagem(
        enviados == 0
            ? 'Nenhum registro pendente'
            : '$enviados registro(s) sincronizado(s)',
      );
    } catch (erro) {
      _mostrarMensagem('Erro ao sincronizar: $erro');
    }
    await _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final pendentes = _lavagens.where((l) => !l.sincronizado).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(_tituloAppBar),
        actions: [
          IconButton(
            tooltip: 'Sincronizar pendentes',
            onPressed: _carregando ? null : _sincronizar,
            icon: Badge(
              isLabelVisible: pendentes > 0,
              label: Text('$pendentes'),
              child: const Icon(Icons.sync),
            ),
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregar,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 88),
                itemCount: _lavagens.length,
                itemBuilder: (context, indice) {
                  return ItemLavagem(_lavagens[indice]);
                },
              ),
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
          ).then((lavagemRecebida) => _salvar(lavagemRecebida));
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
        trailing: _lavagem.sincronizado
            ? const Icon(Icons.cloud_done, color: Colors.green)
            : const Tooltip(
                message: 'Pendente de sincronização',
                child: Icon(Icons.cloud_off, color: Colors.orange),
              ),
      ),
    );
  }
}
