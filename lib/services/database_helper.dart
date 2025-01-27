import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import '../models/tenant.dart';
import 'package:sqflite/sqflite.dart';
import './web_database.dart';

// Type alias to handle both SQLite Database and our WebDatabase
typedef DatabaseType = dynamic;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static DatabaseType? _database;

  DatabaseHelper._init();

  Future<DatabaseType> get database async {
    if (_database != null) return _database!;
    
    if (kIsWeb) {
      _database = WebDatabase.instance;
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'kiraya.db');
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    }
    
    return _database!;
  }

  Future<void> _createDB(Database db, int version) async {
    if (kIsWeb) return;
    await db.execute('''
      CREATE TABLE tenants(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        roomNumber TEXT NOT NULL,
        rentAmount REAL NOT NULL,
        paymentStatus TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        lastPaymentDate TEXT NOT NULL
      )
    ''');
  }

  Future<Tenant> create(Tenant tenant) async {
    final db = await instance.database;
    if (kIsWeb) {
      return await db.createTenant(tenant);
    } else {
      final id = await db.insert('tenants', tenant.toMap());
      return tenant.copyWith(id: id);
    }
  }

  Future<List<Tenant>> getAllTenants() async {
    try {
      final db = await instance.database;
      if (kIsWeb) {
        return await db.getAllTenants();
      } else {
        final result = await db.query('tenants');
        return result.map((json) => Tenant.fromMap(json)).toList();
      }
    } catch (e) {
      debugPrint('Error getting tenants: $e');
      return [];
    }
  }

  Future<Tenant?> getTenant(int id) async {
    final db = await instance.database;
    if (kIsWeb) {
      return await db.getTenant(id);
    } else {
      final result = await db.query(
        'tenants',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return Tenant.fromMap(result.first);
      }
      return null;
    }
  }

  Future<void> update(Tenant tenant) async {
    final db = await instance.database;
    if (kIsWeb) {
      await db.updateTenant(tenant);
    } else {
      await db.update(
        'tenants',
        tenant.toMap(),
        where: 'id = ?',
        whereArgs: [tenant.id],
      );
    }
  }

  Future<void> delete(int id) async {
    final db = await instance.database;
    if (kIsWeb) {
      await db.deleteTenant(id);
    } else {
      await db.delete(
        'tenants',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<List<Tenant>> searchTenants(String query) async {
    final db = await instance.database;
    if (kIsWeb) {
      return await db.searchTenants(query);
    } else {
      final result = await db.query(
        'tenants',
        where: 'name LIKE ? OR roomNumber LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
      );
      return result.map((json) => Tenant.fromMap(json)).toList();
    }
  }

  Future<void> close() async {
    if (!kIsWeb) {
      final db = await instance.database;
      await db.close();
    }
  }
}
