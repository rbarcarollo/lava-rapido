class Lavagem {
  final int? id;
  final double valor;
  final int numeroVaga;
  final bool sincronizado;

  Lavagem(this.valor, this.numeroVaga, {this.id, this.sincronizado = true});

  // Formato usado no SQLite (colunas em snake_case).
  Map<String, dynamic> toMap() {
    return {
      'valor': valor,
      'numero_vaga': numeroVaga,
      'sincronizado': sincronizado ? 1 : 0,
    };
  }

  factory Lavagem.fromMap(Map<String, dynamic> map) {
    return Lavagem(
      (map['valor'] as num).toDouble(),
      map['numero_vaga'] as int,
      id: map['id'] as int?,
      sincronizado: map['sincronizado'] == 1,
    );
  }

  // Formato enviado para a API (não inclui id local nem sincronizado).
  Map<String, dynamic> toJson() {
    return {'valor': valor, 'numero_vaga': numeroVaga};
  }

  // Registros vindos da API já estão, por definição, sincronizados.
  factory Lavagem.fromJson(Map<String, dynamic> json) {
    return Lavagem(
      (json['valor'] as num).toDouble(),
      json['numero_vaga'] as int,
      sincronizado: true,
    );
  }

  @override
  String toString() {
    return "Lavagem{id: $id, valor: $valor, numeroVaga: $numeroVaga, sincronizado: $sincronizado}";
  }
}
