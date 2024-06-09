import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT,
        email TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    """);

    await database.execute("""
      CREATE TABLE tickets (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        description TEXT,
        price REAL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    """);

    await database.execute("""
      CREATE TABLE sales (
        id_client INTEGER NOT NULL,
        id_ticket INTEGER NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(id_client) REFERENCES clients(id),
        FOREIGN KEY(id_ticket) REFERENCES tickets(id)
      );
    """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      join(await sql.getDatabasesPath(), 'ticketManagement3.db'),
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createClient(String name, String? email) async {
    final db = await SQLHelper.db();

    final data = {'name': name, 'email': email};
    final id = await db.insert('clients', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getClients() async {
    final db = await SQLHelper.db();
    return db.query('clients', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getClient(int id) async {
    final db = await SQLHelper.db();
    return db.query('clients', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateClient(int id, String name, String? email) async {
    final db = await SQLHelper.db();

    final data = {
      'name': name,
      'email': email,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('clients', data, where: "id = ?", whereArgs: [id]);

    return result;
  }

  static Future<void> deleteClient(int id) async {
    final db = await SQLHelper.db();

    try {
      await db.delete('clients', where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Não foi possível apagar o cliente! $err");
    }
  }

  static Future<int> createTicket(String description, double price) async {
    final db = await SQLHelper.db();

    final data = {'description': description, 'price': price};
    final id = await db.insert('tickets', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getTickets() async {
    final db = await SQLHelper.db();
    return db.query('tickets', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getTicket(int id) async {
    final db = await SQLHelper.db();
    return db.query('tickets', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateTicket(
      int id, String description, double price) async {
    final db = await SQLHelper.db();

    final data = {
      'description': description,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('tickets', data, where: "id = ?", whereArgs: [id]);

    return result;
  }

  static Future<void> deleteTicket(int id) async {
    final db = await SQLHelper.db();

    try {
      await db.delete('tickets', where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Não foi possível apagar o bilhete! $err");
    }
  }

  static Future<int> createSale(int idClient, int idTicket) async {
    final db = await SQLHelper.db();

    final data = {'id_client': idClient, 'id_ticket': idTicket};
    final id = await db.insert('sales', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getSales() async {
    final db = await SQLHelper.db();
    return db.query('sales', orderBy: 'createdAt');
  }

  static Future<List<Map<String, dynamic>>> getSale(
      int idClient, int idTicket) async {
    final db = await SQLHelper.db();
    return db.query('sales',
        where: "id_client = ? AND id_ticket = ?",
        whereArgs: [idClient, idTicket],
        limit: 1);
  }

  static Future<int> updateSale(
      int idClient, int idTicket, int newIdClient, int newIdTicket) async {
    final db = await SQLHelper.db();

    final data = {
      'id_client': newIdClient,
      'id_ticket': newIdTicket,
      'createdAt': DateTime.now().toString()
    };

    final result = await db.update('sales', data,
        where: "id_client = ? AND id_ticket = ?",
        whereArgs: [idClient, idTicket]);

    return result;
  }

  static Future<void> deleteSale(int idClient, int idTicket) async {
    final db = await SQLHelper.db();

    try {
      await db.delete('sales',
          where: "id_client = ? AND id_ticket = ?",
          whereArgs: [idClient, idTicket]);
    } catch (err) {
      debugPrint("Não foi possível apagar a venda! $err");
    }
  }
}
