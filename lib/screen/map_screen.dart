import 'dart:async';
import 'dart:convert';

import 'package:contact_app/model/location.dart';
import 'package:contact_app/model/message.dart';
import 'package:contact_app/model/user.dart';
import 'package:contact_app/service/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:random_avatar/random_avatar.dart';

class MapScreen extends StatefulWidget {
  final Location? position;
  final bool currentLocation;
  const MapScreen({super.key, this.position, required this.currentLocation});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const eventChannel = EventChannel('app/native-code-event');
  static const MethodChannel channel = MethodChannel('app/native-code');

  bool isLoading = true;

  LatLng? returnedLocation;

  Position? location;

  CameraPosition? _initialPosition;
  Marker? marker;
  Marker? freindMarker;
  Marker? clickedMarker;

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

  @override
  void initState() {
    super.initState();

    _startListeningForMessages();

    if (widget.currentLocation == false) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        _initialPosition = CameraPosition(
          target: LatLng(widget.position!.lat, widget.position!.lng),
          zoom: 14.4746,
        );
        marker = Marker(
          markerId: MarkerId('moving_marker'),
          position: LatLng(widget.position!.lat, widget.position!.lng),
          infoWindow: InfoWindow(title: 'Initial Position'),
        );
      });
    } else {
      getCurrentLocation();
    }
  }

  getCurrentLocation() async {
    location = await _determinePosition();

    if (!mounted) return;

    setState(() {
      isLoading = false;
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
        if (!mounted) return; // Check if widget is still in the tree
        setState(() {
          MessageModel data = MessageModel.fromJson(jsonDecode(message));
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
    return WillPopScope(
        onWillPop: () async {
          return true; // Return true to allow the screen to close
        },
        child: StreamBuilder<List<AppUser>>(
          stream: FirestoreService.userCollectionStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final Set<Marker> markers = {};

            return isLoading == false
                ? GoogleMap(
                    initialCameraPosition: _initialPosition!,
                    markers: {
                      marker!,
                      if (clickedMarker != null) clickedMarker!
                    }, // Include clicked marker
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    onTap: widget.currentLocation == false
                        ? null
                        : (LatLng tappedPoint) {
                            // Detect the tap on the map
                            setState(() {
                              returnedLocation = tappedPoint;
                              clickedMarker = Marker(
                                markerId: MarkerId('clicked_marker'),
                                position: tappedPoint,
                                infoWindow: InfoWindow(
                                  title: 'Clicked Location',
                                  snippet:
                                      'Lat: ${tappedPoint.latitude}, Lng: ${tappedPoint.longitude}',
                                ),
                              );
                            });

                            // Send back the location when a user taps the map
                            Navigator.pop(context, tappedPoint);
                          },
                  )
                : Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
          },
        ));
  }

  @override
  void dispose() {
    super.dispose();
    locationStreamSubscription?.cancel();
  }
}
