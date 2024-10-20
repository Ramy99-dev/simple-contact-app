import 'package:contact_app/shared/customTextField.dart';
import 'package:contact_app/shared/primaryButton.dart';
import 'package:contact_app/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameCtrl = new TextEditingController();
  final TextEditingController _passwordCtrl = new TextEditingController();
  bool keepConnected = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          customTextField("Username", _usernameCtrl, null, 1, false),
          SizedBox(
            height: 10,
          ),
          customTextField("Password", _passwordCtrl, null, 1, true),
          SizedBox(
            height: 10,
          ),
          primaryButton("Login", () {
            Navigator.of(context).pushReplacementNamed("/contact");
          }),
          Row(
            children: [
              Checkbox(
                value: keepConnected,
                onChanged: (val) {
                  setState(() {
                    keepConnected = val!;
                  });
                  Storage.addStorage("connected", val);
                },
              ),
              Text("Keep me connected")
            ],
          )
        ]),
      ),
    );
  }
}
