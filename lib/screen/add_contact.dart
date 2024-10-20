import 'package:contact_app/model/contact.dart';
import 'package:contact_app/screen/contacts.dart';
import 'package:contact_app/shared/customTextField.dart';
import 'package:contact_app/shared/primaryButton.dart';
import 'package:contact_app/util/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class AddContact extends StatefulWidget {
  const AddContact({super.key});

  @override
  State<AddContact> createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  final TextEditingController _usernameCtrl = new TextEditingController();
  final TextEditingController _phoneCtrl = new TextEditingController();

  String? errMsgUsername;
  String? errMsgPhone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            customTextField("Username", _usernameCtrl, null, 1, false),
            errMsgUsername != null
                ? Text(
                    errMsgUsername!,
                    style: TextStyle(color: Colors.red),
                  )
                : Container(),
            SizedBox(
              height: 10,
            ),
            customTextField(
                "Phone Number", _phoneCtrl, TextInputType.number, 1, false),
            errMsgPhone != null
                ? Text(
                    errMsgPhone!,
                    style: TextStyle(color: Colors.red),
                  )
                : Container(),
            SizedBox(
              height: 10,
            ),
            primaryButton("Add Contact", () async {
              if (_usernameCtrl.text != "" && _phoneCtrl.text != "") {
                int id =
                    await insertContact(_usernameCtrl.text, _phoneCtrl.text);
                ContactModel newContact = ContactModel(
                    id: id,
                    username: _usernameCtrl.text,
                    number: _phoneCtrl.text);
                Navigator.pop(context, newContact);
              } else {
                setState(() {
                  if (errMsgUsername == null) {
                    errMsgUsername = "Empty username";
                  }
                  if (errMsgPhone == null) {
                    errMsgPhone = "Empty phone number";
                  }
                });
              }
            })
          ]),
        ),
      ),
    );
  }
}
