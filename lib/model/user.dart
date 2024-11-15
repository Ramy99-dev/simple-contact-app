import 'package:contact_app/model/location.dart';

class AppUser {
  final String name;
  final Location location;
  AppUser({
    required this.name,
    required this.location,
  });

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      name: data['name'] as String,
      location: Location.fromMap(data['location'] as Map<String, dynamic>),
    );
  }
}
