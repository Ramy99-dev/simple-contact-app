import 'package:contact_app/model/contact.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

Future<Database> initializeDB() async {
  String path = await getDatabasesPath();
  return openDatabase(
    join(path, 'contact_app.db'),
    onCreate: (database, version) async {
      await database.execute(
        "CREATE TABLE contacts(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, phone TEXT NOT NULL)",
      );
    },
    version: 1,
  );
}

Future<int> insertContact(String name, String phone) async {
  final Database db = await initializeDB();

  
  int id = await db.insert(
    'contacts',
    {'name': name, 'phone': phone},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  return id;
}

Future<List<ContactModel>> retrieveContacts() async {
  List<ContactModel> contacts = [];

  final Database db = await initializeDB();
  List data = await db.query('contacts');

  if (data.isNotEmpty) {
    for (var i = 0; i < data.length; i++) {
      Map<String, dynamic> map = data[i];
      print(data[i]);
      contacts.add(ContactModel.fromJson(map));
    }
  }

  return contacts;
}

Future<void> deleteContact(int id) async {
  final Database db = await initializeDB();

  await db.delete(
    'contacts',
    where: "id = ?",
    whereArgs: [id],
  );
}
