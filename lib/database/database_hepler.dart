import 'dart:async';
import 'dart:io' as io;

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:thrift/database/CartPro.dart';

class DatabaseHelper {
  static final _databaseName = "cardb.db";
  static final _databaseVersion = 1;

  static final table = 'cars_table';

  static final columnId = 'id';
  static final columnProductId = 'product_id';
  static final columnProductName = 'product_name';
  static final columnProductImage = 'product_img';
  static final columnVariationId = 'variation_id';
  static final columnVariationName = 'variation_name';
  static final columnVariationValue = 'variation_value';
  static final columnQuantity = 'quantity';
  static final columnLine_subtotal = 'line_subtotal';
  static final columnLine_total = 'line_total';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnProductId TEXT NOT NULL,
            $columnProductName TEXT NOT NULL,
            $columnProductImage TEXT NOT NULL,
            $columnVariationId TEXT NOT NULL,
            $columnVariationName TEXT NOT NULL,
            $columnVariationValue TEXT NOT NULL,            
            $columnQuantity TEXT NOT NULL,
            $columnLine_subtotal TEXT NOT NULL,
            $columnLine_total TEXT NOT NULL
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(CartPro car) async {
    Database db = await instance.database;
    return await db.insert(table, {'product_id': car.product_id,'product_name': car.product_name,'product_img': car.product_img, 'variation_id': car.variation_id, 'variation_name': car.variation_name, 'variation_value': car.variation_value,
     'quantity': car.quantity, 'line_subtotal': car.line_subtotal, 'line_total': car.line_total});
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // Queries rows based on the argument received
  Future<List<Map<String, dynamic>>> queryRows(productid) async {
    Database db = await instance.database;
    return await db.query(table, where: "$columnProductId LIKE '%$productid%'");
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(CartPro car) async {
    Database db = await instance.database;
    int id = car.toJson()['id'];
    return await db.update(table, car.toJson(), where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> cleanDatabase() async {
    try{
      Database db = await instance.database;
      return await db.delete(table);
    } catch(error){
      throw Exception('DbBase.cleanDatabase: ' + error.toString());
    }
  }

}
