import 'package:contact_app/model/contact.dart';
import 'package:contact_app/screen/edit_contact.dart';
import 'package:contact_app/shared/editButton.dart';
import 'package:contact_app/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:animated_background/animated_background.dart';
import 'package:flip_card/flip_card.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ContactScreen extends StatefulWidget {
  ContactModel contact;

  ContactScreen({super.key, required this.contact});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen>
    with TickerProviderStateMixin {
  late Widget svgCode;

  @override
  void initState() {
    svgCode = randomAvatar(widget.contact.username, height: 250, width: 250);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          title: Text(
            widget.contact.username,
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0.3,
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
        body: AnimatedBackground(
          behaviour: RandomParticleBehaviour(),
          vsync: this,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: EditButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditContact(contact: widget.contact),
                      ),
                    ).then((updatedContact) {
                      if (updatedContact != null) {
                        setState(() {
                          widget.contact = updatedContact;
                        });
                      }
                    });
                  },
                ),
              ),
              Expanded(
                  flex: 2,
                  child: FlipCard(
                    direction: FlipDirection.HORIZONTAL,
                    side: CardSide.FRONT,
                    speed: 1000,
                    onFlipDone: (status) {
                      print(status);
                    },
                    back: Container(
                      margin: EdgeInsets.only(
                          left: 30, top: 10, right: 30, bottom: 50),
                      height: double.infinity,
                      width: double.infinity,
                      child: SizedBox(
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: QrImage(
                              data: widget.contact.number,
                              version: QrVersions.auto,
                              size: 200.0,
                            ),
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                    ),
                    front: Container(
                      margin: EdgeInsets.only(
                          left: 30, top: 10, right: 30, bottom: 50),
                      height: double.infinity,
                      width: double.infinity,
                      child: SizedBox(
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                svgCode,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "ID : ${widget.contact.id.toString()}"),
                                    Text(
                                        "Username : ${widget.contact.username}"),
                                    Text(
                                        "Phone Number :${widget.contact.number}"),
                                  ],
                                )
                              ]),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                    ),
                  ))
            ],
          ),
        ));
  }
}
