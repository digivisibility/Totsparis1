import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maanstore/const/constants.dart';
import 'package:maanstore/generated/l10n.dart' as lang;
import 'package:maanstore/screens/splash_screen/splash_screen_two.dart';
import 'package:maanstore/screens/home_screens/home.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../Providers/all_repo_providers.dart';
import '../../models/purchase_model.dart';

class SplashScreenOne extends StatefulWidget {
  const SplashScreenOne({super.key});

  @override
  State<SplashScreenOne> createState() => _SplashScreenOneState();
}

class _SplashScreenOneState extends State<SplashScreenOne> {
  Future<void> pageNavigation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final int? customerId = prefs.getInt('customerId');
    isRtl = prefs.getBool('isRtl') ?? false;
    await Future.delayed(
      const Duration(seconds: 3),
    );
    bool isValid = await PurchaseModel().isActiveBuyer();
    if (isValid) {
      if (customerId != null) {
        if (!mounted) return;
        const Home().launch(context, isNewTask: true);
      } else {
        if (!mounted) return;
        const SplashScreenTwo().launch(context, isNewTask: true);
      }
    } else {
      showLicense(context: context);
    }
  }

  @override
  void initState() {
    pageNavigation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: kPrimaryColor,
        body: Center(
          child: Column(
            children: [
              SizedBox(height: size.height / 3),

              // App Logo
              Container(
                height: 210,
                width: 210,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(180),
                ),
                child: const Image(
                  image: AssetImage('images/storelogo.png'),
                ),
              ),

              const Spacer(),
              Column(
                children: [
                   Text(
                    'Tots Paris',
                    style: GoogleFonts.dmSans(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                   Text(
                    'Version 1.0.0',
                    style: GoogleFonts.dmSans(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }
}
