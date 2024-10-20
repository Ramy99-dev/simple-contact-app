import 'package:contact_app/model/contact.dart';
import 'package:contact_app/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:random_avatar/random_avatar.dart';

class ContactScreen extends StatefulWidget {
  final ContactModel contact;

  const ContactScreen({super.key, required this.contact});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  late Widget svgCode;

  @override
  void initState() {
    svgCode = randomAvatar(widget.contact.username, height: 250, width: 250);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact.username),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.settings),
          ),
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
      body: Center(
        child: Container(
          color: Color.fromARGB(255, 218, 217, 217),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              svgCode,
              Text("ID : ${widget.contact.id.toString()}"),
              Text("Username : ${widget.contact.username}"),
              Text("Phone Number :${widget.contact.number}"),
            ]),
          ),
        ),
      ),
    );
  }
}