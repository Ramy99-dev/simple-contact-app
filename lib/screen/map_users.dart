import 'package:contact_app/model/location.dart';
import 'package:contact_app/model/user.dart';
import 'package:contact_app/screen/map_form.dart';
import 'package:contact_app/screen/map_screen.dart';
import 'package:contact_app/service/firestore_service.dart';
import 'package:contact_app/shared/animatedFloatingActionButton.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

class MapUsers extends StatefulWidget {
  const MapUsers({super.key});

  @override
  State<MapUsers> createState() => _MapUsersState();
}

class _MapUsersState extends State<MapUsers> {
  late Future<List<Map<String, dynamic>>> _usersFuture;
  bool addUsersScreen = false;

  @override
  void initState() {
    super.initState();
    _usersFuture = FirestoreService.getAllUsersWithDocIds();
  }

  void _deleteUser(String docId) async {
    await FirestoreService.deleteUser(docId); // Call Firestore deletion logic
    setState(() {
      _usersFuture =
          FirestoreService.getAllUsersWithDocIds(); // Refresh the user list
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User deleted successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return addUsersScreen
        ? MapForm()
        : Scaffold(
            floatingActionButton: AnimatedFloatingActionButton(
              icon: Icons.map,
              onPressed: () {
                setState(() {
                  addUsersScreen = true;
                });
              },
            ),
            body: FutureBuilder<List<Map<String, dynamic>>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'An error occurred: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No users found.',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                } else {
                  final users = snapshot.data!;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final docId = user['docId']; // Get document ID
                      final appUser = AppUser.fromMap(
                          user['data']); // Convert map to AppUser
                      return Dismissible(
                        key: Key(docId), // Unique key using document ID
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _deleteUser(docId); // Delete user by document ID
                        },
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapScreen(
                                  currentLocation: false,
                                  position: Location(
                                    lat: appUser.location.lat,
                                    lng: appUser.location.lng,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                  child: randomAvatar(appUser.name,
                                      height: 250, width: 250)),
                              title: Text(appUser.name),
                              subtitle: Text('Phone: ${appUser.phone}\n'
                                  'Location: (${appUser.location.lat}, ${appUser.location.lng})'),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          );
  }
}
