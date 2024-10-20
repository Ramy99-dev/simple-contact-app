import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();

  static Future getStorage(k) async {
    final SharedPreferences prefs = await _prefs;
    return await prefs.getString(k);
  }

  static deleteStorage(k) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(k);
  }

  static addStorage(k, val) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(k, val.toString());
  }
}
