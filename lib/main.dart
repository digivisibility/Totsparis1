import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:iconly/iconly.dart';
import 'package:maanstore/screens/Theme/theme.dart';
import 'package:maanstore/screens/auth_screen/change_pass_screen.dart';
import 'package:maanstore/screens/home_screens/home.dart';
import 'package:maanstore/screens/language_screen.dart';
import 'package:maanstore/screens/notification_screen/notificition_screen.dart';
import 'package:maanstore/screens/order_screen/my_order.dart';
import 'package:maanstore/screens/profile_screen/my_profile_screen.dart';
import 'package:maanstore/screens/splash_screen/splash_screen_one.dart';
import 'package:maanstore/widgets/profile_shimmer_widget.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart' as pro;
import 'package:shared_preferences/shared_preferences.dart';

import 'Providers/all_repo_providers.dart';
import 'Providers/language_change_provider.dart';
import 'api_service/api_service.dart';
import 'const/constants.dart';
import 'generated/l10n.dart' as lang;
import 'generated/l10n.dart';
import 'models/add_to_cart_model.dart';
import 'Providers/wishlist_provider.dart';

Future<void> main() async {
  // 1. Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Initialize Firebase with a safety check
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
    // We continue so the app doesn't stay on the splash screen forever
  }

  // 3. Handle Theme (Cleaned up logic)
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String savedTheme = prefs.getString('theme') ?? 'system';
  
  if (savedTheme == 'dark') {
    _themeManager.toggleTheme(true);
  } else if (savedTheme == 'light') {
    _themeManager.toggleTheme(false);
  } else {
    // System or default handling
    _themeManager.toggleTheme(false); 
  }

  // 4. Set Orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 5. Initialize Stripe
  Stripe.publishableKey = stripePublishableKey;

  // 6. Initialize OneSignal (Slightly improved order)
  OneSignal.Debug.setLogLevel(OSLogLevel.none);
  OneSignal.initialize(oneSignalAppId);

  // Use a delay for permission to ensure the UI is rendered first
  Future.delayed(const Duration(seconds: 2), () {
    OneSignal.Notifications.requestPermission(true);
  });

  // 7. Start App
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
  void dispose() {
    _themeManager.removeListener(themeListener);
    super.dispose();
  }

  @override
  void initState() {
    _themeManager.addListener(themeListener);
    super.initState();
  }

  themeListener() {
    if (mounted) {
      setState(() {});
    }
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
          locale: pro.Provider.of<LanguageChangeProvider>(context, listen: true)
              .currentLocale,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreenOne(),
          supportedLocales: S.delegate.supportedLocales,
          builder: EasyLoading.init(),
        ),
      ),
    );
  }
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
  //..customAnimation = CustomAnimation();
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  APIService? apiService;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void getCustomerData(String name, String url) async {
    SharedPreferences preferences = await _prefs;
    preferences.setString('name', name);
    preferences.setString('url', url);
  }

  @override
  initState() {
    apiService = APIService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer(builder: (context, ref, __) {
      final customerDetails = ref.watch(getCustomerDetails);
      return Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            leading: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Home()));
              },
              child: Icon(
                Icons.arrow_back,
                color: isDark ? darkTitleColor : lightTitleColor,
              ),
            ),
            title: Text(
              lang.S.of(context).profileScreenName,
              style: kTextStyle.copyWith(
                  color: isDark ? darkTitleColor : lightTitleColor,
                  fontSize: 20.0),
            ),
          ),
          body: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: customerDetails.when(data: (snapShot) {
              String name =
                  snapShot.firstName.toString() + snapShot.lastName.toString();
              getCustomerData(name, snapShot.avatarUrl.toString());
              return Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 20, right: 30, top: 30, bottom: 20),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(30),
                        topLeft: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(50)),
                                image: DecorationImage(
                                  fit: BoxFit.fitWidth,
                                  image: NetworkImage(
                                      snapShot.avatarUrl.toString()),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyGoogleText(
                                      text:
                                          '${snapShot.firstName} ${snapShot.lastName}',
                                      fontSize: 24,
                                      fontColor: isDark
                                          ? darkTitleColor
                                          : lightTitleColor,
                                      fontWeight: FontWeight.normal),
                                  const SizedBox(height: 8),
                                  MyGoogleText(
                                      text: snapShot.email.toString(),
                                      fontSize: 14,
                                      fontColor: isDark
                                          ? darkGreyTextColor
                                          : lightGreyTextColor,
                                      fontWeight: FontWeight.normal),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        ///_____My_profile_____________________________
                        Container(
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1, color: secondaryColor3))),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyProfileScreen(
                                            retrieveCustomer: snapShot,
                                          )));
                            },
                            shape: const Border(
                                bottom:
                                    BorderSide(width: 1, color: textColors)),
                            leading: Icon(
                              IconlyLight.profile,
                              color: isDark
                                  ? darkGreyTextColor
                                  : lightGreyTextColor,
                            ),
                            title: MyGoogleText(
                                text: lang.S.of(context).myProfile,
                                fontSize: 16,
                                fontColor:
                                    isDark ? darkTitleColor : lightTitleColor,
                                fontWeight: FontWeight.normal),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: isDark
                                  ? darkGreyTextColor
                                  : lightGreyTextColor,
                            ),
                          ),
                        ),

                        ///_____Change_password_____________________________
                        Visibility(
                          visible: true,
                          child: Container(
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 1, color: secondaryColor3))),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ChangePassScreen()));
                              },
                              shape: const Border(
                                  bottom:
                                      BorderSide(width: 1, color: textColors)),
                              leading: const Icon(IconlyLight.password),
                              title: MyGoogleText(
                                  text: 'Change Password',
                                  fontSize: 16,
                                  fontColor:
                                      isDark ? darkTitleColor : lightTitleColor,
                                  fontWeight: FontWeight.normal),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                            ),
                          ),
                        ),

                        ///_____My_Order____________________________
                        Container(
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1, color: secondaryColor3))),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MyOrderScreen()));
                            },
                            shape: const Border(
                                bottom:
                                    BorderSide(width: 1, color: textColors)),
                            leading: Icon(
                              IconlyLight.document,
                              color: isDark
                                  ? darkGreyTextColor
                                  : lightGreyTextColor,
                            ),
                            title: MyGoogleText(
                                text: lang.S.of(context).myOrderScreenName,
                                fontSize: 16,
                                fontColor:
                                    isDark ? darkTitleColor : lightTitleColor,
                                fontWeight: FontWeight.normal),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: isDark
                                  ? darkGreyTextColor
                                  : lightGreyTextColor,
                            ),
                          ),
                        ),

                        ///__________payment_method______________________-
                        // Visibility(
                        //   visible: false,
                        //   child: Container(
                        //     decoration: const BoxDecoration(
                        //         border: Border(
                        //             bottom: BorderSide(
                        //                 width: 1, color: secondaryColor3))),
                        //     child: ListTile(
                        //       onTap: () {
                        //         Navigator.push(
                        //             context,
                        //             MaterialPageRoute(
                        //                 builder: (context) =>
                        //                     const PaymentMethodScreen()));
                        //       },
                        //       shape: const Border(
                        //           bottom:
                        //               BorderSide(width: 1, color: textColors)),
                        //       leading: const Icon(IconlyLight.wallet),
                        //       title: MyGoogleText(
                        //           text: 'Payment Method',
                        //           fontSize: 16,
                        //           fontColor:
                        //               isDark ? darkTitleColor : lightTitleColor,
                        //           fontWeight: FontWeight.normal),
                        //       trailing: const Icon(
                        //         Icons.arrow_forward_ios,
                        //         size: 16,
                        //       ),
                        //     ),
                        //   ),
                        // ),

                        ///_________Notification___________________________
                        Visibility(
                          visible: false,
                          child: Container(
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 1, color: secondaryColor3))),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const NotificationsScreen()));
                              },
                              shape: const Border(
                                  bottom:
                                      BorderSide(width: 1, color: textColors)),
                              leading: const Icon(IconlyLight.notification),
                              title: MyGoogleText(
                                  text: 'Notification',
                                  fontSize: 16,
                                  fontColor:
                                      isDark ? darkTitleColor : lightTitleColor,
                                  fontWeight: FontWeight.normal),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                            ),
                          ),
                        ),

                        ///_____________Language________________________
                        Container(
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1, color: secondaryColor3))),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LanguageScreen()));
                            },
                            shape: const Border(
                                bottom:
                                    BorderSide(width: 1, color: textColors)),
                            leading: Icon(
                              CommunityMaterialIcons.translate,
                              color: isDark
                                  ? darkGreyTextColor
                                  : lightGreyTextColor,
                            ),
                            title: MyGoogleText(
                                text: lang.S.of(context).language,
                                fontSize: 16,
                                fontColor:
                                    isDark ? darkTitleColor : lightTitleColor,
                                fontWeight: FontWeight.normal),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: isDark
                                  ? darkGreyTextColor
                                  : lightGreyTextColor,
                            ),
                          ),
                        ),

                        ///___________________Help___________________________
                        Visibility(
                          visible: false,
                          child: Container(
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 1, color: secondaryColor3))),
                            child: ListTile(
                              onTap: null,
                              shape: const Border(
                                  bottom:
                                      BorderSide(width: 1, color: textColors)),
                              leading: const Icon(IconlyLight.danger),
                              title: MyGoogleText(
                                  text: 'Help & Info',
                                  fontSize: 16,
                                  fontColor:
                                      isDark ? darkTitleColor : lightTitleColor,
                                  fontWeight: FontWeight.normal),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                            ),
                          ),
                        ),

                        ///-------------theme---------------
                        Container(
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1, color: secondaryColor3))),
                          child: ListTile(
                            leading: Icon(
                              CommunityMaterialIcons.brightness_6,
                              color: isDark
                                  ? darkGreyTextColor
                                  : lightGreyTextColor,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            horizontalTitleGap: 10,
                            title: Text(
                              'Dark Theme',
                              style: kTextStyle.copyWith(
                                  color: isDark
                                      ? darkTitleColor
                                      : lightTitleColor),
                            ),
                            trailing: Switch(
                              activeColor: kPrimaryColor,
                              inactiveTrackColor: kBorderColorTextField,
                              value: _themeManager.themeMode == ThemeMode.dark,
                              onChanged: (newValue) async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                newValue
                                    ? await prefs.setString('theme', 'dark')
                                    : await prefs.setString('theme', 'light');
                                setState(() {
                                  _themeManager.toggleTheme(newValue);
                                });
                              },
                            ),
                          ),
                        ),

                        ///______________SignOut_________________________
                        Container(
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1, color: secondaryColor3))),
                          child: ListTile(
                            onTap: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.remove('customerId');
                              await prefs.remove('token');
                              await apiService?.signOut();
                              
                              ref.invalidate(getCustomerDetails);
                              ref.invalidate(getOrders);
                              ref.read(cartNotifier.notifier).clearCart();
                              ref.read(wishlistProvider.notifier).clearWishlist();

                              if (!mounted) return;
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SplashScreenOne()), (route) => false);
                            },
                            shape: const Border(
                                bottom:
                                    BorderSide(width: 1, color: textColors)),
                            leading: Icon(
                              IconlyLight.logout,
                              color: isDark
                                  ? darkGreyTextColor
                                  : lightGreyTextColor,
                            ),
                            title: MyGoogleText(
                                text: lang.S.of(context).signOut,
                                fontSize: 16,
                                fontColor:
                                    isDark ? darkTitleColor : lightTitleColor,
                                fontWeight: FontWeight.normal),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: isDark
                                  ? darkGreyTextColor
                                  : lightGreyTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }, error: (e, stack) {
              return Text(e.toString());
            }, loading: () {
              return const ProfileShimmerWidget();
            }),
          ),
        ),
      );
    });
  }
}

class SwitchButton extends StatefulWidget {
  const SwitchButton({super.key});

  @override
  State<SwitchButton> createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<SwitchButton> {
  @override
  Widget build(BuildContext context) {
    return Switch(
      activeColor: kPrimaryColor,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: kBorderColorTextField,
      value: _themeManager.themeMode == ThemeMode.dark,
      onChanged: (newValue) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        newValue
            ? await prefs.setString('theme', 'dark')
            : await prefs.setString('theme', 'light');
        setState(() {
          _themeManager.toggleTheme(newValue);
        });
      },
    );
  }
}
