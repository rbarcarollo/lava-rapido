// local        -> usa apenas SQLite.
// remota       -> usa apenas a API.
// offlineFirst -> tenta a API; se falhar, salva no SQLite como pendente.
enum OrigemPersistencia { local, remota, offlineFirst }

class ConfiguracaoPersistencia {
  static const OrigemPersistencia origem = OrigemPersistencia.offlineFirst;
}
