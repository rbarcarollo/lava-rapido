import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/lavagem.dart';

// Abre (ou cria) o banco local SQLite.
Future<Database> getDatabase() async {
  final String path = join(await getDatabasesPath(), 'lava_rapido.db');

  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      // sincronizado: 1 -> já enviado para a API | 0 -> pendente
      await db.execute('''
        create table lavagens(
          id integer primary key autoincrement,
          valor real,
          numero_vaga integer,
          sincronizado integer default 1
        )
      ''');
    },
  );
}

Future<int> salvarLavagem(Lavagem lavagem, {bool sincronizado = true}) async {
  final Database db = await getDatabase();

  final Map<String, dynamic> mapa = lavagem.toMap();
  mapa['sincronizado'] = sincronizado ? 1 : 0;

  return db.insert('lavagens', mapa);
}

Future<List<Lavagem>> buscarLavagens() async {
  final Database db = await getDatabase();
  final List<Map<String, dynamic>> resultado = await db.query('lavagens');
  return resultado.map(Lavagem.fromMap).toList();
}

Future<List<Lavagem>> buscarLavagensPendentes() async {
  final Database db = await getDatabase();
  final List<Map<String, dynamic>> resultado = await db.query(
    'lavagens',
    where: 'sincronizado = ?',
    whereArgs: [0],
  );
  return resultado.map(Lavagem.fromMap).toList();
}

Future<int> marcarLavagemComoSincronizada(int id) async {
  final Database db = await getDatabase();
  return db.update(
    'lavagens',
    {'sincronizado': 1},
    where: 'id = ?',
    whereArgs: [id],
  );
}
