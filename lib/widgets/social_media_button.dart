import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:maanstore/api_service/api_service.dart';
import 'package:maanstore/const/constants.dart';
import 'package:maanstore/const/hardcoded_text.dart';
import 'package:maanstore/generated/l10n.dart' as lang;
import 'package:maanstore/screens/home_screens/home.dart';
import 'package:nb_utils/nb_utils.dart';

class SocialMediaButtons extends StatelessWidget {
  const SocialMediaButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 1,
              width: 70,
              color: textColors,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
              ),
              child: MyGoogleText(
                fontSize: 20,
                fontColor: Colors.black,
                text: lang.S.of(context).otherSignIn,
                fontWeight: FontWeight.normal,
              ),
            ),
            Container(
              height: 1,
              width: 70,
              color: textColors,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                EasyLoading.show(status: 'Signing in with Google...');
                APIService apiService = APIService();
                try {
                  final user = await apiService.signInWithGoogle();
                  if (user != null) {
                    EasyLoading.showSuccess('Sign in successful');
                    const Home().launch(context, isNewTask: true);
                  } else {
                    EasyLoading.dismiss();
                    // EasyLoading.showError('Sign in failed');
                  }
                } catch (e) {
                  EasyLoading.dismiss();
                  // EasyLoading.showError('Error: $e');
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                height: 60,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.5,
                    color: textColors,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                child: Image(
                  image: AssetImage(HardcodedImages.google),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
