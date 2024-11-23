import 'package:contact_app/model/contact.dart';
import 'package:contact_app/model/location.dart';
import 'package:contact_app/model/user.dart';
import 'package:contact_app/screen/map_screen.dart';
import 'package:contact_app/screen/map_users.dart';
import 'package:contact_app/service/firestore_service.dart';
import 'package:contact_app/shared/animatedFloatingActionButton.dart';
import 'package:contact_app/shared/customTextField.dart';
import 'package:contact_app/shared/primaryButton.dart';
import 'package:contact_app/shared/search_bar.dart';
import 'package:contact_app/util/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;

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

  List<ContactModel> contacts = [];
  ContactModel? selectedContact;

  bool showUsersList = false;

  Future<void> getContacts() async {
    List<ContactModel> retrievedContacts = await retrieveContacts();
    setState(() {
      contacts = retrievedContacts;
    });
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

  Future<void> setLocation() async {
    Position location = await _determinePosition();
    setState(() {
      _lngCtrl.text = location.longitude.toString();
      _altCtrl.text = location.altitude.toString();
    });
  }

  @override
  void initState() {
    getContacts();
    setLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return showUsersList
        ? MapUsers()
        : Scaffold(
            floatingActionButton: AnimatedFloatingActionButton(
                icon: Icons.list,
                onPressed: () {
                  setState(() {
                    showUsersList = true;
                  });
                }),
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TypeAheadFormField<ContactModel>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _pseudoCtrl,
                      decoration: InputDecoration(
                        labelText: 'Select or type a contact',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    suggestionsCallback: (pattern) {
                      return contacts.where((contact) => contact.username
                          .toLowerCase()
                          .contains(pattern.toLowerCase()));
                    },
                    itemBuilder: (context, suggestion) {
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
                            child: customTextField(
                                "Lng", _lngCtrl, null, 1, false)),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          flex: 2,
                          child:
                              customTextField("Alt", _altCtrl, null, 1, false),
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
                      Expanded(
                          child: primaryButton("Add", () async {
                        final newUser = AppUser(
                            name: _pseudoCtrl.text,
                            phone: _phoneCtrl.text,
                            location: Location(
                                lat: double.parse(_altCtrl.text),
                                lng: double.parse(_lngCtrl.text)));

                        await FirestoreService.addUser(newUser);
                      })),
                      SizedBox(
                        width: 10,
                      ),
                      primaryButton("Open Map", () async {
                        gm.LatLng? data = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MapScreen(
                                      currentLocation: true,
                                      position: Location(
                                          lat: double.parse(_altCtrl.text),
                                          lng: double.parse(_lngCtrl.text)),
                                    )));
                        if (data != null) {
                          setState(() {
                            _lngCtrl.text = data!.longitude.toString();
                            _altCtrl.text = data!.latitude.toString();
                          });
                        }
                      })
                    ],
                  )
                ],
              ),
            ),
          );
  }
}
