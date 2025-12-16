import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:maanstore/api_service/api_service.dart';
import 'package:maanstore/const/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../widgets/buttons.dart';
import '../../widgets/confirmation_popup.dart';
import '../Theme/theme.dart';

class ChangePassScreen extends StatefulWidget {
  const ChangePassScreen({super.key});

  @override
  State<ChangePassScreen> createState() => _ChangePassScreenState();
}

class _ChangePassScreenState extends State<ChangePassScreen> {
  bool password = true;
  bool hidePassword = true;
  APIService? apiService;
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyGoogleText(
                    fontSize: 26,
                    fontColor: isDark ? darkTitleColor : lightTitleColor,
                    text: 'Change Password',
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 15),
                  MyGoogleText(
                    fontSize: 16,
                    fontColor: isDark ? darkGreyTextColor : lightGreyTextColor,
                    text: 'The Password should have at least 6 characters',
                    fontWeight: FontWeight.normal,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: password,
                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          suffixIcon: InkWell(
                              onTap: () {
                                setState(() {
                                  password = !password;
                                });
                              },
                              child: Icon(password
                                  ? Icons.visibility_off
                                  : Icons.visibility)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: isDark
                                    ? const Color(0xff555671)
                                    : Colors.black,
                                width: 1),
                          ),
                          labelText: 'Password',
                          border: const OutlineInputBorder()),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: hidePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  hidePassword = !hidePassword;
                                });
                              },
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              )),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: isDark
                                    ? const Color(0xff555671)
                                    : Colors.black,
                                width: 1),
                          ),
                          labelText: 'Confirm Password',
                          border: const OutlineInputBorder()),
                    ),
                    const SizedBox(height: 30),
                    Button1(
                        buttonText: 'Submit',
                        buttonColor: kPrimaryColor,
                        onPressFunction: () async {
                          if (_formKey.currentState!.validate()) {
                            EasyLoading.show(status: 'Updating...');
                            try {
                              bool success = await apiService!
                                  .changePassword(newPasswordController.text);
                              EasyLoading.dismiss();
                              if (success) {
                                if (context.mounted) {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      opaque: false,
                                      pageBuilder:
                                          (BuildContext context, _, __) =>
                                              const RedeemConfirmationScreen(
                                        image:
                                            'images/password_change_image.png',
                                        mainText: 'Password Changed',
                                        subText:
                                            'Your password has been successfully changed!',
                                        buttonText: 'Done',
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                EasyLoading.showError(
                                    'Failed to change password. Please try again.');
                              }
                            } catch (e) {
                              EasyLoading.dismiss();
                              EasyLoading.showError(
                                  'An error occurred. Please try again.');
                            }
                          }
                        }),
                    const SizedBox(height: 200),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
