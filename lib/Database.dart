import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'Songs.dart';

class DB {
  Future<Database> initDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, "MYDB.db"),
      onCreate: (database, verison) async {
        await database.execute("""
          CREATE TABLE MYTable(
          id INTEGER PRIMERY KEY AUTOINCREMENT,
          displayNameWOExt TEXT NOT NULL,
          artist TEXT NOT NULL,
          img TEXT NOT NULL
          )
          """);
      },
      version: 1,
    );
  }

  Future<bool> insertData(Songs songs) async {
    final Database db = await initDB();
    db.insert("MYTable", songs.toMap());
    return true;
  }
  Future<List<Songs>> getData()async{
    final Database db=await initDB();
final List<Map<String,Object?>> datas=await db.query("MYTable");

   return datas.map((e) => Songs.fromMap(e)).toList();
  }
}
