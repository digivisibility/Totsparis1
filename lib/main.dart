import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:maanstore/screens/Theme/theme.dart';
import 'package:maanstore/screens/splash_screen/splash_screen_one.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart' as pro;
import 'package:shared_preferences/shared_preferences.dart';

import 'Providers/language_change_provider.dart';
import 'const/constants.dart';
import 'generated/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase
  try {
    await Firebase.initializeApp();
    
    // Pass all uncaught errors to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
  }

  // 2. Stripe Configuration
  Stripe.publishableKey = stripePublishableKey;
  await Stripe.instance.applySettings();

  // 3. OneSignal Configuration
  OneSignal.Debug.setLogLevel(OSLogLevel.none);
  OneSignal.initialize(oneSignalAppId);
  OneSignal.Notifications.requestPermission(true);

  // 4. Load Theme
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String savedTheme = prefs.getString('theme') ?? 'light';
  if (savedTheme == 'dark') {
    _themeManager.toggleTheme(true);
  } else {
    _themeManager.toggleTheme(false);
  }

  // 5. Lock Orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const ProviderScope(child: MyApp()));
}

ThemeManager _themeManager = ThemeManager();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    _themeManager.addListener(themeListener);
    super.initState();
  }

  @override
  void dispose() {
    _themeManager.removeListener(themeListener);
    super.dispose();
  }

  themeListener() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return pro.ChangeNotifierProvider<LanguageChangeProvider>(
      create: (context) => LanguageChangeProvider(),
      child: Builder(
        builder: (context) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: _themeManager.themeMode,
          locale: pro.Provider.of<LanguageChangeProvider>(context, listen: true).currentLocale,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: const SplashScreenOne(),
          builder: EasyLoading.init(),
        ),
      ),
    );
  }
}
