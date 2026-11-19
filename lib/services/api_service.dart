import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lavagem.dart';

// A API recusou os dados (erro 4xx). Não adianta guardar como pendente:
// o mesmo erro aconteceria na sincronização.
class ApiValidacaoException implements Exception {
  final String mensagem;
  ApiValidacaoException(this.mensagem);

  @override
  String toString() => mensagem;
}

class ApiService {
  // TROCAR pela URL publicada no Render.
  // Para simular a API indisponível (Teste 2), use uma URL inválida aqui.
  static const String baseUrl = 'https://lava-rapido-api.onrender.com';

  // O plano gratuito do Render "dorme" e a primeira chamada pode demorar.
  static const Duration _tempoLimite = Duration(seconds: 20);

  static Future<List<Lavagem>> buscarLavagens() async {
    final resposta = await http
        .get(Uri.parse('$baseUrl/lavagens'))
        .timeout(_tempoLimite);

    if (resposta.statusCode != 200) {
      throw Exception('Erro ao buscar lavagens: ${resposta.statusCode}');
    }

    final List<dynamic> lista = jsonDecode(resposta.body);
    return lista
        .map((item) => Lavagem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> salvarLavagem(Lavagem lavagem) async {
    final resposta = await http
        .post(
          Uri.parse('$baseUrl/lavagens'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(lavagem.toJson()),
        )
        .timeout(_tempoLimite);

    // Só 400/422 indicam dados inválidos. Outros códigos (404 de uma URL
    // errada, 5xx de servidor dormindo etc.) contam como API indisponível.
    if (resposta.statusCode == 400 || resposta.statusCode == 422) {
      throw ApiValidacaoException('A API recusou o cadastro: ${resposta.body}');
    }

    if (resposta.statusCode != 201) {
      throw Exception('Erro ao salvar lavagem: ${resposta.statusCode}');
    }
  }
}
