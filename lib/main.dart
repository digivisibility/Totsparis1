import 'package:flutter/material.dart';
import 'package:totsparis2/src/app.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // OneSignal initialization for version 5.x
  // Remove this method to stop OneSignal debug logging
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  OneSignal.initialize("a197e501-b566-44ce-a112-f6916c794e6d");

  // The requestPermission function will show the iOS push notification prompt.
  OneSignal.Notifications.requestPermission(true);

  runApp(App());
}
