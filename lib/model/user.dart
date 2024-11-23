import 'package:contact_app/model/location.dart';

class AppUser {
  final String name;
  final String phone;
  int? id;
  final Location location;
  AppUser({
    id,
    required this.name,
    required this.phone,
    required this.location,
  });

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      id: data['id'],
      name: data['name'] as String,
      phone: data['phone'],
      location: Location.fromMap(data['location'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'location': location.toMap(),
    };
  }
}
