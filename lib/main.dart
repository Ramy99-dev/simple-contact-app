import 'package:contact_app/screen/add_contact.dart';
import 'package:contact_app/screen/contacts.dart';
import 'package:contact_app/model/contact.dart';
import 'package:contact_app/screen/edit_contact.dart';
import 'package:contact_app/screen/login.dart';
import 'package:contact_app/screen/settings.dart';
import 'package:contact_app/util/db.dart';
import 'package:contact_app/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeApp();

  runApp(const MyApp());
}

Future<void> initializeApp() async {
  await initializeDB();
}

Future<bool> getPermission() async {
  if (await Permission.sms.status == PermissionStatus.granted) {
    return true;
  } else {
    if (await Permission.sms.request() == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }
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
          "/contact": (context) => const Contacts(),
          "/settings": (context) => const Settings(),
          "/editContact": (context) => const EditContact()
        });
  }
}
