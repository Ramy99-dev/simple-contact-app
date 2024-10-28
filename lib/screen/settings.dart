import 'package:contact_app/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool light = false;
  @override
  void initState() {
    checkKeepConnection();
    super.initState();
  }

  Future<void> checkKeepConnection() async {
    String connected = await Storage.getStorage("connected");
    setState(() {
      if (connected == "true") {
        light = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                child: Icon(Icons.logout),
                onTap: () {
                  Storage.deleteStorage("connected");
                  Navigator.of(context).pushNamed("/login");
                },
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Remember me"),
                  Switch(
                    value: light,
                    activeColor: Colors.blue,
                    onChanged: (bool value) {
                      setState(() {
                        light = value;
                        Storage.addStorage("connected", value);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
