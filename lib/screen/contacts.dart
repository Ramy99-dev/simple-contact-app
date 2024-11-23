import 'dart:convert';
import 'dart:ui';

import 'package:contact_app/model/contact.dart';
import 'package:contact_app/screen/contact.dart';
import 'package:contact_app/screen/map_form.dart';
import 'package:contact_app/screen/map_screen.dart';
import 'package:contact_app/screen/map_users.dart';
import 'package:contact_app/shared/customTextField.dart';
import 'package:contact_app/util/db.dart';
import 'package:contact_app/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sms_receiver/sms_receiver.dart' as inbox;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

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
  int _selectedIndex = 0;
  bool showMap = false;

  GlobalKey searchButtonKey = GlobalKey();
  GlobalKey addButtonKey = GlobalKey();
  GlobalKey contactsButtonKey = GlobalKey();
  GlobalKey mapButtonKey = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;

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
        return i.username.contains(username);
      }).toList();
      print(tmpContact);
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
    createTutorial();
    tutorialCoachMark.show(context: context);

    // _smsReceiver = inbox.SmsReceiver(onSmsReceived, onTimeout: onTimeout);
    // _startListening();
    getContacts();
  }

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.blue,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
        print("finish");
      },
      onClickTarget: (target) {
        print('onClickTarget: $target');
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        print("target: $target");
        print(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        print('onClickOverlay: $target');
      },
      onSkip: () {
        print("skip");
        return true;
      },
    );
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "addButtonKey",
        keyTarget: addButtonKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add button",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "An Add Button allows users to insert new items or data into a list, form, or application. It triggers an action to include the specified content.",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "searchButtonKey",
        keyTarget: searchButtonKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Search button",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "A Search Button allows users to quickly find relevant information by entering keywords or queries. It triggers the search functionality to deliver results based on the input.",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "contactsButtonKey",
        keyTarget: contactsButtonKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Contacts Tab",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "The Contacts section provides access to a list of saved contacts. It allows users to view, add, edit, or manage contact information efficiently.",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "mapButtonKey",
        keyTarget: mapButtonKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Map Tab",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "The Map section enables users to explore locations visually. It can display routes, pinpoint specific locations, or provide navigation features.",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    return targets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 1) {
              showMap = true;
            } else {
              showMap = false;
            }
          });
        },
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(key: contactsButtonKey, Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(key: mapButtonKey, Icons.map),
            label: 'Map',
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        title: Text(
          "Contact",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed("/settings");
                },
                child: Icon(
                  Icons.settings,
                  color: Colors.black,
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              child: Icon(
                Icons.logout,
                color: Colors.black,
              ),
              onTap: () {
                Storage.deleteStorage("connected");
                Navigator.of(context).pushNamed("/login");
              },
            ),
          )
        ],
      ),
      floatingActionButton: showMap
          ? null
          : FloatingActionButton(
              key: addButtonKey,
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
      body: showMap
          ? MapUsers()
          : RefreshIndicator(
              onRefresh: () async {
                getContacts();
              },
              child: Padding(
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
                            key: searchButtonKey,
                            child: Icon(Icons.search),
                            onTap: () {
                              print("test");
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
                                    FlutterPhoneDirectCaller.callNumber(
                                        c.number);
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
                                          width:
                                              MediaQuery.of(context).size.width,
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
                                                      sendSms(c.number,
                                                          messageWord);
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
