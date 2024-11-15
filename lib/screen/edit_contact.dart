import 'package:contact_app/model/contact.dart';
import 'package:contact_app/screen/contacts.dart';
import 'package:contact_app/shared/customTextField.dart';
import 'package:contact_app/shared/primaryButton.dart';
import 'package:contact_app/util/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class EditContact extends StatefulWidget {
  final ContactModel contact;

  const EditContact({super.key, required this.contact});

  @override
  State<EditContact> createState() => _EditContactState();
}

class _EditContactState extends State<EditContact> {
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  String? errMsgUsername;
  String? errMsgPhone;

  @override
  void initState() {
    super.initState();
    _usernameCtrl.text = widget.contact.username;
    _phoneCtrl.text = widget.contact.number;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text("Edit Contact", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              primaryButton("Update Contact", () async {
                if (_usernameCtrl.text != "" && _phoneCtrl.text != "") {
                  bool success = await updateContact(
                      widget.contact.id, _usernameCtrl.text, _phoneCtrl.text);
                  if (success) {
                    ContactModel updatedContact = ContactModel(
                        id: widget.contact.id,
                        username: _usernameCtrl.text,
                        number: _phoneCtrl.text);
                    Navigator.pop(context, updatedContact);
                  }
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
            ],
          ),
        ),
      ),
    );
  }
}
