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
    return _firestore.collection('users').snapshots().map((snapshot) => snapshot
        .docs
        .map<AppUser>((doc) => AppUser.fromMap(doc.data()))
        .toList());
  }

  static Future<void> addUser(AppUser user) async {
    try {
      await _firestore.collection('users').add(user.toMap());
      print('User added successfully.');
    } on FirebaseException catch (e) {
      print('An error occurred due to Firebase: $e');
    } catch (err) {
      print('An error occurred: $err');
    }
  }

  static Future<List<AppUser>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return AppUser.fromMap(data);
      }).toList();
    } on FirebaseException catch (e) {
      print('An error occurred due to Firebase: $e');
      return [];
    } catch (err) {
      print('An error occurred: $err');
      return [];
    }
  }

  static Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      print('User deleted successfully.');
    } on FirebaseException catch (e) {
      print('An error occurred due to Firebase: $e');
    } catch (err) {
      print('An error occurred: $err');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllUsersWithDocIds() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    return querySnapshot.docs.map((doc) {
      return {
        'docId': doc.id,
        'data': doc.data(),
      };
    }).toList();
  }
}
