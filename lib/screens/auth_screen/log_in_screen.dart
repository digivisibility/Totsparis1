import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:maanstore/const/constants.dart';
import 'package:maanstore/generated/l10n.dart' as lang;
import 'package:maanstore/screens/auth_screen/forgot_pass_screen.dart';
import 'package:maanstore/screens/auth_screen/sign_up.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:maanstore/screens/auth_screen/otp_auth_screen.dart';
import '../../const/hardcoded_text.dart';

import '../../api_service/api_service.dart';
import '../../widgets/buttons.dart';
import '../../widgets/social_media_button.dart';
import '../Theme/theme.dart';
import '../home_screens/home.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  bool isChecked = false;
  late APIService apiService;
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  bool hidePassword = true;
  String email = '';
  String password = '';

  @override
  initState() {
    apiService = APIService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
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
                  borderRadius:  BorderRadius.all(Radius.circular(30)),
                  border: Border.all(
                    width: 1,
                    color: isDark ? darkGreyTextColor : lightGreyTextColor,
                  ),
                ),
                child:  Icon(
                  Icons.arrow_back,
                  color: isDark ? darkTitleColor : lightTitleColor,
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.all(30),
                  width: double.infinity,
                  decoration:  BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Form(
                        key: globalKey,
                        child: Column(
                          children: [
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: lang.S.of(context).textFieldEmailLabelText,
                                hintText: lang.S.of(context).textFieldEmailHintText,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDark ? Color(0xff555671) : Colors.black, width: 1),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return lang.S.of(context).textFieldEmailValidatorText1;
                                } else if (!value.contains('@')) {
                                  return lang.S.of(context).textFieldEmailValidatorText2;
                                }
                                return null;
                              },
                              onSaved: (value) {
                                email = value!;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              obscureText: hidePassword,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDark ? Color(0xff555671) : Colors.black, width: 1),
                                ),
                                border: const OutlineInputBorder(),
                                labelText: lang.S.of(context).textFieldPassLabelText,
                                hintText: lang.S.of(context).textFieldPassHintText,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      hidePassword = !hidePassword;
                                    });
                                  },
                                  icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return lang.S.of(context).textFieldPassValidatorText1;
                                } else if (value.length < 4) {
                                  return lang.S.of(context).textFieldPassValidatorText2;
                                }
                                return null;
                              },
                              onSaved: (value) {
                                password = value!;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                activeColor: secondaryColor1,
                                checkColor: black,
                                value: isChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isChecked = value!;
                                  });
                                },
                              ),
                              MyGoogleText(
                                text: lang.S.of(context).rememberMe,
                                fontColor: textColors,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              const ForgotPassScreen().launch(context);
                            },
                            child: MyGoogleText(
                              text: lang.S.of(context).forgetPass,
                              fontColor: textColors,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          )
                        ],
                      ).visible(true),
                      const SizedBox(height: 10),
                      Button1(
                        buttonText: lang.S.of(context).signInButtonText,
                        buttonColor: kPrimaryColor,
                        onPressFunction: () {
                          if (validateAndSave()) {
                            EasyLoading.show(status: lang.S.of(context).easyLoadingSignIn);
                            apiService.loginCustomer(email, password).then((ret) {
                              globalKey.currentState?.reset();
                              if (ret) {
                                EasyLoading.showSuccess(lang.S.of(context).easyLoadingSuccess);
                                const Home().launch(context, isNewTask: true);
                              } else {
                                EasyLoading.showError(lang.S.of(context).easyLoadingError);
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      ButtonType2(
                        buttonText: HardcodedTextEng.loginWithPhone,
                        buttonColor: kPrimaryColor,
                        onPressFunction: () {
                          const OtpAuthScreen().launch(context);
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              lang.S.of(context).notMember,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: kTextStyle.copyWith(
                                fontSize: 16,
                                color: textColors,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              const SignUp().launch(context);
                            },
                            child: Text(
                              lang.S.of(context).registerButtonText,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: kTextStyle.copyWith(
                                fontSize: 16,
                                color: secondaryColor1,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 25),
                      const SocialMediaButtons().visible(true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
