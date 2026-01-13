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
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Initialize Firebase FIRST (CRITICAL FIX)
    await Firebase.initializeApp();
    
    // Configure Crashlytics (only in release mode)
    if (kReleaseMode) {
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    // 2. Stripe Configuration (FIXED ORDER - Must be AFTER Firebase)
    Stripe.publishableKey = stripePublishableKey;
    
    // CRITICAL: Use merchantIdentifier for iOS
    Stripe.merchantIdentifier = 'merchant.com.maanstore'; // Replace with your actual merchant ID
    
    // Apply settings (removed await - not needed)
    Stripe.instance.applySettings();

    // 3. OneSignal Configuration (AFTER Firebase)
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose); // Changed to verbose for debugging
    OneSignal.initialize(oneSignalAppId);
    
    // Request permission asynchronously (don't block startup)
    OneSignal.Notifications.requestPermission(true);

    // 4. Load Theme
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String savedTheme = prefs.getString('theme') ?? 'light';
    _themeManager.toggleTheme(savedTheme == 'dark');

    // 5. Lock Orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    runApp(const ProviderScope(child: MyApp()));
    
  } catch (e, stack) {
    debugPrint("❌ CRITICAL STARTUP ERROR: $e");
    debugPrint("Stack trace: $stack");
    
    // Log to Crashlytics if available
    try {
      FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
    } catch (_) {}
    
    // Show error screen
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text(
                    'App Initialization Failed',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Error: $e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
    super.initState();
    _themeManager.addListener(themeListener);
  }

  @override
  void dispose() {
    _themeManager.removeListener(themeListener);
    super.dispose();
  }

  void themeListener() {
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
