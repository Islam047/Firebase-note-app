import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class RemoteService {
  static final remoteConfig = FirebaseRemoteConfig.instance;

  static final Map<String, dynamic> availableBackgroundColors = {
    "red": Colors.red,
    "yellow": Colors.yellow,
    "blue": Colors.blue,
    "green": Colors.green,
    "white": Colors.white
  };
  static final Map<String, dynamic> availableIcons = {
    "ramazan": Icons.dark_mode,
    "not ramazan": Icons.sunny,
  };

  static String backgroundColor = "blue";
  static String iconMy = "not ramazan";


  static Future<void> initConfig() async {
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      // a fetch will wait up to 10 seconds before timing out
      minimumFetchInterval: const Duration(
          seconds:
              10), // fetch parameters will be cached for a maximum of 1 hour
    ));

    await remoteConfig
        .setDefaults(const {"background_color": "blue", "icon": "not ramazan"});
    await fetchConfig();
  }

  static Future<void> fetchConfig() async {
    await remoteConfig.fetchAndActivate().then(
          (value) => {
            backgroundColor =
                remoteConfig.getString('background_color').isNotEmpty
                    ? remoteConfig.getString('background_color')
                    : "blue",
            iconMy = remoteConfig.getString("icon").isNotEmpty
                ? remoteConfig.getString("icon")
                : "not ramazan",
            debugPrint("Remote config is worked: $value"),
          },
        );
  }
}
