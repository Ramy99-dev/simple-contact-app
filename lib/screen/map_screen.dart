import 'dart:async';
import 'dart:convert';

import 'package:contact_app/model/message.dart';
import 'package:contact_app/model/user.dart';
import 'package:contact_app/service/firestore_service.dart';
import 'package:contact_app/service/stream_location_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const eventChannel = EventChannel('app/native-code-event');
  static const MethodChannel channel = MethodChannel('app/native-code');
  String _messages = "Listening for messages...";

  Position? location;

  CameraPosition? _initialPosition;
  Marker? marker;
  Marker? freindMarker;

  late StreamSubscription<Position>? locationStreamSubscription;

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

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
  );

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _startListeningForMessages();

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      print("posssssssl : ${position!.latitude}");
      setState(() {
        marker = Marker(
          markerId: MarkerId('moving_marker'),
          position: LatLng(position!.latitude, position!.longitude),
          infoWindow: InfoWindow(title: 'Initial Position'),
        );
      });
    });

    // locationStreamSubscription =
    //     StreamLocationService.onLocationChanged?.listen(
    //   (position) async {
    //     print("pos : ${position}");
    //     await FirestoreService.updateUserLocation(
    //       'Wy6I0BLMKsJF7D65yeCd',
    //       LatLng(position.latitude, position.longitude),
    //     );
    //   },
    // );
  }

  getCurrentLocation() async {
    location = await _determinePosition();

    setState(() {
      _initialPosition = CameraPosition(
        target: LatLng(location!.latitude, location!.longitude),
        zoom: 14.4746,
      );
      marker = Marker(
        markerId: MarkerId('moving_marker'),
        position: LatLng(location!.latitude, location!.longitude),
        infoWindow: InfoWindow(title: 'Initial Position'),
      );
    });
  }

  void _startListeningForMessages() {
    eventChannel.receiveBroadcastStream().listen(
      (message) {
        setState(() {
          MessageModel data = MessageModel.fromJson(jsonDecode(message));

          // freindMarker = Marker(
          //   markerId: MarkerId('moving_marker'),
          //   position: LatLng(position!.latitude, position!.longitude),
          //   infoWindow: InfoWindow(title: 'Initial Position'),
          // );

          print("MESSAGE: ${data}");
        });
      },
      onError: (error) {
        print("Error receiving messages: $error");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppUser>>(
      stream: FirestoreService.userCollectionStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final Set<Marker> markers = {};
        for (var i = 0; i < snapshot.data!.length; i++) {
          final user = snapshot.data![i];
          markers.add(
            Marker(
              markerId: MarkerId('${user.name} position $i'),
              icon: user.name == 'stekphano'
                  ? BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    )
                  : BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueYellow,
                    ),
              position: LatLng(user.location.lat, user.location.lng),
              onTap: () => {},
            ),
          );
        }
        return location != null
            ? GoogleMap(
                initialCameraPosition: _initialPosition!,
                markers: {marker!},
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              )
            : Text("Loading");
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    locationStreamSubscription?.cancel();
  }
}
