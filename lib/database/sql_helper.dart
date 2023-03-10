import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE notes(
      noteid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      body TEXT,
      createdAt  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP 
    
    )""");
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'dbnote.db', //check if exist or create
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database); // check if table exists or create
      },
    );
  }

  // called from a button click

  static Future<int> createnote(String title, String? body) async {
    final db = await SQLHelper.db(); // open db connection

    final data = {'title': title, 'body': body}; // put data in map
    final noteid = await db.insert(
        //insert items in table (map format)
        'notes', //table name
        data, // data
        conflictAlgorithm:
            sql.ConflictAlgorithm.replace); //prevent duplicate entry
    return noteid; // return id of row
  }

// getting all items from database
  static Future<List<Map<String, dynamic>>> getNotes() async {
    // data received has to be in a map
    final db = await SQLHelper.db();
    return db.query(
      'notes',
      orderBy: 'createdAt',
    ); //db.query whn you need an item
  }

// get single item
  static Future<List<Map<String, dynamic>>> getNote(int noteid) async {
    // data received has to be in a map
    final db = await SQLHelper.db();
    return db.query('notes',
        where: 'noteid = ?', whereArgs: [noteid], limit: 1); // only one
  }

// update data
  static Future<int> updateNote(int noteid, String title, String? body) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'body': body,
      'createdAt': DateTime.now().toString()
    };
    final result = await db
        .update('notes', data, where: "noteid = ?", whereArgs: [noteid]);
    return result;
  }

  static Future<void> deleteItem(int noteid) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('notes', where: "noteid = ?", whereArgs: [noteid]);
    } catch (e) {
      debugPrint('Something went wrong when deleting an Item:  $e');
    }
  }
}
