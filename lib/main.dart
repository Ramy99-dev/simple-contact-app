import 'package:contact_app/screen/add_contact.dart';
import 'package:contact_app/screen/contacts.dart';
import 'package:contact_app/model/contact.dart';
import 'package:contact_app/screen/login.dart';
import 'package:contact_app/util/db.dart';
import 'package:contact_app/util/storage.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
  await initializeDB();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  dynamic homepage = Login();
  Future<void> checkConnection() async {
    String connected = await Storage.getStorage("connected");
    setState(() {
      if (connected == "true") {
        homepage = Contacts();
      }
    });
  }

  @override
  void initState() {
    checkConnection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: homepage,
        routes: {
          "/addContact": (context) => const AddContact(),
          "/login": (context) => const Login(),
          "/contact": (context) => const Contacts()
        });
  }
}
