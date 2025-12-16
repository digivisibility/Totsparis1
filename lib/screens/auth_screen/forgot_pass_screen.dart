import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:maanstore/const/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api_service/api_service.dart';
import '../../widgets/buttons.dart';
import '../Theme/theme.dart';
import 'log_in_screen.dart';
import 'package:maanstore/screens/webview_screen.dart';

class ForgotPassScreen extends StatefulWidget {
  const ForgotPassScreen({super.key});

  @override
  State<ForgotPassScreen> createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  bool isChecked = false;
  late APIService apiService;
  String email = '';

  @override
  void initState() {
    apiService = APIService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: GestureDetector(
          onTap: () {
            finish(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                border: Border.all(
                  width: 1,
                  color: isDark ? darkGreyTextColor : lightGreyTextColor,
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                color: isDark ? darkTitleColor : lightTitleColor,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 30),
            child: SizedBox(
              height: 100,
              width: 248,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyGoogleText(
                    fontSize: 26,
                    fontColor: isDark ? darkTitleColor : lightTitleColor,
                    text: 'Forgot Password',
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 15),
                  MyGoogleText(
                    fontSize: 16,
                    fontColor: isDark ? darkGreyTextColor : lightGreyTextColor,
                    text: 'Enter your email below to receive your password',
                    fontWeight: FontWeight.normal,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(30),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30),
              ),
            ),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: isDark ? const Color(0xff555671) : Colors.black,
                          width: 1),
                    ),
                    labelText: 'Email',
                    hintText: 'Enter Your Email',
                  ),
                ),
                const SizedBox(height: 30),
                Button1(
                    buttonText: 'Send New Password',
                    buttonColor: kPrimaryColor,
                    onPressFunction: () {
                      if (email.isEmpty) {
                        EasyLoading.showError('Please Enter Your Email');
                      } else {
                        EasyLoading.show(status: 'Sending Email');
                        apiService.forgetPassword(email).then((value) {
                          if (value) {
                            EasyLoading.showSuccess('Email Sent Successfully');
                            const LogInScreen().launch(context);
                          } else {
                            EasyLoading.dismiss();
                            // Fallback to WebView if API fails
                            const WebViewScreen(
                              url: 'https://totsparis.com/my-account/lost-password/',
                              title: 'Reset Password',
                            ).launch(context);
                          }
                        });
                      }
                    }),
                const SizedBox(height: 300),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
