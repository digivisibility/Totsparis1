import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maanstore/generated/l10n.dart' as lang;
import 'package:maanstore/screens/auth_screen/log_in_screen.dart';
import 'package:maanstore/screens/auth_screen/sign_up.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../const/constants.dart';
import '../../widgets/buttons.dart';
import '../Theme/theme.dart';
import '../home_screens/home.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: () {
                const Home().launch(context, isNewTask: true);
              },
              child: Text(
                lang.S.of(context).skipText,
                style: kTextStyle.copyWith(
                  color: isDark ? darkGreyTextColor : lightGreyTextColor
                ),
              ),
            ),
          ],
        ),
        body: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            Column(
              children: [
                const Image(image: AssetImage('images/store.png',),height: 100,width: 100,),
                SizedBox(height: 5,),
                Text('Tots Paris',style: kTextStyle.copyWith(color: isDark?Colors.white:const Color(0xff3E3E70),fontWeight: FontWeight.bold,fontSize: 24),)
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(30),
              width: double.infinity,
              decoration:  BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    lang.S.of(context).authScreenWelcomeText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      textStyle: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    'Tots Paris', // Changed from lang.S.of(context).storeName to hardcoded "Tots Paris" as requested by user
                    style: GoogleFonts.dmSans(
                      textStyle: const TextStyle(
                        color: secondaryColor1,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    lang.S.of(context).authScreenSubTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      textStyle:  TextStyle(
                        color: isDark ? darkGreyTextColor : lightGreyTextColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Button1(
                    buttonColor: kPrimaryColor,
                    buttonText: lang.S.of(context).registerButtonText,
                    onPressFunction: () {
                      const SignUp().launch(
                        context,
                        //pageRouteAnimation: PageRouteAnimation.Fade,
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  ButtonType2(
                    buttonColor: kPrimaryColor,
                    buttonText: lang.S.of(context).signInButtonText,
                    onPressFunction: () {
                      const LogInScreen().launch(
                        context,
                        //pageRouteAnimation: PageRouteAnimation.Fade,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
