import 'package:flutter/material.dart';

import '../models/lavagem.dart';
import 'configuracao_persistencia.dart';
import '../database/app_database.dart' as banco_local;
import '../services/api_service.dart';

abstract class LavagemRepository {
  Future<List<Lavagem>> buscarLavagens();

  Future<void> salvarLavagem(Lavagem lavagem);

  // Retorna quantos registros pendentes foram enviados.
  Future<int> sincronizarPendentes();
}

class LavagemRepositoryLocal implements LavagemRepository {
  @override
  Future<List<Lavagem>> buscarLavagens() => banco_local.buscarLavagens();

  @override
  Future<void> salvarLavagem(Lavagem lavagem) async {
    await banco_local.salvarLavagem(lavagem);
  }

  @override
  Future<int> sincronizarPendentes() async => 0;
}

class LavagemRepositoryRemoto implements LavagemRepository {
  @override
  Future<List<Lavagem>> buscarLavagens() => ApiService.buscarLavagens();

  @override
  Future<void> salvarLavagem(Lavagem lavagem) =>
      ApiService.salvarLavagem(lavagem);

  @override
  Future<int> sincronizarPendentes() async => 0;
}

class LavagemRepositoryOfflineFirst implements LavagemRepository {
  @override
  Future<List<Lavagem>> buscarLavagens() async {
    final pendentes = await banco_local.buscarLavagensPendentes();

    try {
      final remotas = await ApiService.buscarLavagens();
      // A API ainda não conhece os pendentes; eles continuam visíveis na lista.
      return [...remotas, ...pendentes];
    } catch (erro) {
      debugPrint('falha ao buscar lavagens remotas: $erro');
      return banco_local.buscarLavagens();
    }
  }

  @override
  Future<void> salvarLavagem(Lavagem lavagem) async {
    try {
      await ApiService.salvarLavagem(lavagem);
      await banco_local.salvarLavagem(lavagem, sincronizado: true);
    } on ApiValidacaoException {
      // Erro de validação não é problema de conexão: avisa o usuário.
      rethrow;
    } catch (erro) {
      debugPrint('falha ao salvar lavagem remota: $erro');
      await banco_local.salvarLavagem(lavagem, sincronizado: false);
    }
  }

  @override
  Future<int> sincronizarPendentes() async {
    final pendentes = await banco_local.buscarLavagensPendentes();
    var enviados = 0;

    for (final lavagem in pendentes) {
      await ApiService.salvarLavagem(lavagem);
      if (lavagem.id != null) {
        await banco_local.marcarLavagemComoSincronizada(lavagem.id!);
      }
      enviados++;
    }

    return enviados;
  }
}

class RepositorioLavagem {
  static LavagemRepository get instancia {
    switch (ConfiguracaoPersistencia.origem) {
      case OrigemPersistencia.local:
        return LavagemRepositoryLocal();
      case OrigemPersistencia.remota:
        return LavagemRepositoryRemoto();
      case OrigemPersistencia.offlineFirst:
        return LavagemRepositoryOfflineFirst();
    }
  }
}
