import 'package:contact_app/shared/customTextField.dart';
import 'package:contact_app/shared/primaryButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customTextField("Pseudo", _pseudoCtrl, null, 1, false),
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
                      child: customTextField("Lng", _lngCtrl, null, 1, false)),
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
      )),
    );
  }
}
