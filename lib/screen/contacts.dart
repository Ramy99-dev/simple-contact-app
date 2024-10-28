import 'dart:convert';

import 'package:contact_app/model/contact.dart';
import 'package:contact_app/screen/contact.dart';
import 'package:contact_app/shared/customTextField.dart';
import 'package:contact_app/util/db.dart';
import 'package:contact_app/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_v2/generated/i18n.dart';
import 'package:sms_v2/sms.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sms_receiver/sms_receiver.dart' as inbox;

import '../model/message.dart';

class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  final TextEditingController _searchCtrl = new TextEditingController();
  final messageWord = "Hello my freind send me your location";
  static const eventChannel = EventChannel('app/native-code-event');
  static const MethodChannel channel = MethodChannel('app/native-code');
  String _messages = "Listening for messages...";

  List<ContactModel> contacts = [];
  List<ContactModel> allContact = [];

  String? _textContent = 'Waiting for messages...';
  inbox.SmsReceiver? _smsReceiver;

  Future<void> sendSms(String phoneNumber, String message) async {
    try {
      final result = await channel.invokeMethod('sendSms', {
        'phoneNumber': phoneNumber,
        'message': message,
      });
      print(result);
    } on PlatformException catch (e) {
      print("Failed to send SMS: '${e.message}'.");
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> getContacts() async {
    List<ContactModel> retrievedContacts = await retrieveContacts();
    setState(() {
      contacts = retrievedContacts;
      allContact = contacts;
    });
  }

  void searchContact(username) {
    setState(() {
      List<ContactModel> tmpContact = contacts.where((i) {
        return i.username == username;
      }).toList();
      setState(() {
        if (tmpContact.isNotEmpty) {
          contacts = tmpContact;
        } else {
          contacts = allContact;
        }
      });
    });
  }

  void deleteContactScreen(id) {
    List<ContactModel> tmpContact = contacts.where((i) {
      return i.id != id;
    }).toList();
    setState(() {
      contacts = tmpContact;
    });
  }

  Future<void> sendLocation(MessageModel message) async {
    var status = await Permission.sms.status;
    dynamic location = await _determinePosition();

    sendSms(message.number, location.toString());
  }

  void _startListeningForMessages() {
    eventChannel.receiveBroadcastStream().listen(
      (message) {
        setState(() {
          MessageModel data = MessageModel.fromJson(jsonDecode(message));
          if (data.body == "FindFreind") {
            sendLocation(data);
          }
        });
      },
      onError: (error) {
        print("Error receiving messages: $error");
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _startListeningForMessages();
    // _smsReceiver = inbox.SmsReceiver(onSmsReceived, onTimeout: onTimeout);
    // _startListening();
    getContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed("/settings");
                },
                child: Icon(Icons.settings)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          ContactModel? newContact = await Navigator.of(context)
              .pushNamed("/addContact") as ContactModel?;
          if (newContact != null) {
            setState(() {
              contacts.add(newContact);
            });
          }
        },
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: customTextField(
                      "Search Contact", _searchCtrl, null, 1, false),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    child: Icon(Icons.search),
                    onTap: () {
                      searchContact(_searchCtrl.text);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: contacts
                    .map((c) => Dismissible(
                          confirmDismiss: (direction) async {
                            FlutterPhoneDirectCaller.callNumber(c.number);
                            return false;
                          },
                          background: Container(color: Colors.blue),
                          key: Key(c.id.toString()),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ContactScreen(contact: c),
                                ),
                              );
                            },
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(c.username),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              _showMyDialog(context, c,
                                                  deleteContactScreen);
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          InkWell(
                                            onTap: () async {
                                              sendSms(c.number, messageWord);
                                            },
                                            child: Icon(
                                              Icons.message,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showMyDialog(context, c, deleteFun) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Contact'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Are use sure ?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              deleteContact(c.id);
              deleteFun(c.id);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
