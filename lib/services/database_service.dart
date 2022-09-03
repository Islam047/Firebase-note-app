import 'package:shared_preferences/shared_preferences.dart';

enum StorageKey {
  uid
}

class DBService {
  static Future<bool> saveUserId(String uid) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(StorageKey.uid.name, uid);
  }

  static Future<String?> loadUserId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(StorageKey.uid.name);
  }

  static Future<bool> removeUserId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.remove(StorageKey.uid.name);
  }
}