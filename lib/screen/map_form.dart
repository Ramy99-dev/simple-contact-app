import 'package:contact_app/model/contact.dart';
import 'package:contact_app/shared/customTextField.dart';
import 'package:contact_app/shared/primaryButton.dart';
import 'package:contact_app/shared/search_bar.dart';
import 'package:contact_app/util/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class MapForm extends StatefulWidget {
  const MapForm({super.key});

  @override
  State<MapForm> createState() => _MapFormState();
}

class _MapFormState extends State<MapForm> {
  final TextEditingController _pseudoCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _lngCtrl = TextEditingController();
  final TextEditingController _altCtrl = TextEditingController();

  final List<String> items = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Grape',
    'Mango',
  ];

  List<ContactModel> contacts = [];
  ContactModel? selectedContact;
  String contactName = "test";

  Future<void> getContacts() async {
    List<ContactModel> retrievedContacts = await retrieveContacts();
    setState(() {
      contacts = retrievedContacts;
    });
  }

  @override
  void initState() {
    getContacts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TypeAheadFormField<ContactModel>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _pseudoCtrl, // Use the controller here
                  decoration: InputDecoration(
                    labelText: 'Select or type a contact',
                    border: OutlineInputBorder(),
                  ),
                ),
                suggestionsCallback: (pattern) {
                  // Filter contacts based on the typed pattern
                  return contacts.where((contact) => contact.username
                      .toLowerCase()
                      .contains(pattern.toLowerCase()));
                },
                itemBuilder: (context, suggestion) {
                  // Display the contact's username and number in the suggestion
                  return ListTile(
                    title: Text(suggestion.username),
                    subtitle: Text(suggestion.number),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    selectedContact = suggestion;
                    _phoneCtrl.text = selectedContact!.number;
                    _pseudoCtrl.text = selectedContact!.username;
                  });
                  print(
                      "Selected: ${suggestion.username}, ${suggestion.number}");
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select or type a contact';
                  }
                  return null;
                },
                onSaved: (value) {
                  print("Saved value: $value");
                },
              ),
              SizedBox(
                height: 10,
              ),
              customTextField("Phone Number", _phoneCtrl, null, 1, false),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child:
                            customTextField("Lng", _lngCtrl, null, 1, false)),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 2,
                      child: customTextField("Alt", _altCtrl, null, 1, false),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  primaryButton("Add", () {}),
                  SizedBox(
                    width: 10,
                  ),
                  primaryButton("Open Map", () {})
                ],
              )
            ],
          ),
        ),
      )),
    );
  }
}
