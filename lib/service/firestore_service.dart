import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_app/model/user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirestoreService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> updateUserLocation(String userId, LatLng location) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'location': {'lat': location.latitude, 'lng': location.longitude},
      });
    } on FirebaseException catch (e) {
      print('Ann error due to firebase occured $e');
    } catch (err) {
      print('Ann error occured $err');
    }
  }

  static Stream<List<AppUser>> userCollectionStream() {
    return _firestore.collection('users').snapshots().map((snapshot) =>
        snapshot.docs.map<AppUser>((doc) => AppUser.fromMap(doc.data())).toList());
  }
}
