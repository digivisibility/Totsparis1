import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:maanstore/api_service/api_service.dart';
import 'package:maanstore/const/constants.dart';
import 'package:maanstore/generated/l10n.dart' as lang;
import 'package:maanstore/models/customer.dart';
import 'package:maanstore/widgets/add_new_address.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../const/hardcoded_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/social_media_button.dart';
import '../Theme/theme.dart';
import 'log_in_screen.dart';

class SignUp extends StatefulWidget {
  final String? phoneNumber;
  const SignUp({super.key, this.phoneNumber});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isChecked = false;
  late APIService apiService;
  late CustomerModel model;
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  bool hidePassword = true;
  String? phone;

  @override
  initState() {
    apiService = APIService();
    model = CustomerModel(email: '', userName: '', password: '', billing: widget.phoneNumber != null ? {'phone': widget.phoneNumber} : {});
    phone = widget.phoneNumber;
    super.initState();
  }

  void _showAccountExistsDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Exists'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              finish(context); // Close dialog
              const LogInScreen().launch(context);
            },
            child: const Text('Sign In'),
          ),
          TextButton(
            onPressed: () {
              finish(context); // Close dialog
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
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
                    color: textColors,
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
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 1.2,
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
                      if (widget.phoneNumber != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            "Verified Phone: ${widget.phoneNumber}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      Form(
                        key: globalKey,
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: phone,
                              readOnly: widget.phoneNumber != null,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDark ? Color(0xff555671) : Colors.black, width: 1),
                                ),
                                labelText: HardcodedTextEng.textFieldPhoneLabel,
                                hintText: HardcodedTextEng.textFieldPhoneHint,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return HardcodedTextEng.textFieldPhoneValidator;
                                }
                                return null;
                              },
                              onSaved: (value) {
                                phone = value;
                                if (model.billing == null) {
                                  model.billing = {};
                                }
                                model.billing!['phone'] = value;
                                // Also use phone as username
                                if (value != null) {
                                   String cleanPhone = value.replaceAll(RegExp(r'[^\w]'), '');
                                   model.userName = cleanPhone;
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText:lang.S.of(context).textFieldEmailLabelText,
                                hintText:lang.S.of(context).textFieldEmailHintText,
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
                                model.email = value!;
                                // Note: we are now using phone as username, so we don't set userName here
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              obscureText: hidePassword,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText:
                                lang.S.of(context).textFieldPassLabelText,
                                hintText:
                                lang.S.of(context).textFieldPassHintText,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDark ? const Color(0xff555671) : Colors.black, width: 1),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      hidePassword = !hidePassword;
                                    });
                                  },
                                  icon: Icon(hidePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility),
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
                                model.password = value!;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Button1(
                          buttonText: lang.S.of(context).registerButtonText,
                          buttonColor: kPrimaryColor,
                          onPressFunction: () async {
                            if (validateAndSave()) {
                              EasyLoading.show(
                                  status:lang.S.of(context).easyLoadingRegister);

                              // Check if phone exists
                              if (phone != null) {
                                String cleanPhone = phone!.replaceAll(RegExp(r'[^\w]'), '');
                                int? phoneId = await apiService.getCustomerIdByPhone(cleanPhone);
                                if (phoneId == null && phone != cleanPhone) {
                                   phoneId = await apiService.getCustomerIdByPhone(phone!);
                                }
                                if (phoneId != null) {
                                  EasyLoading.dismiss();
                                  _showAccountExistsDialog('An account with this phone number already exists.');
                                  return;
                                }
                              }

                              // Check if email exists
                              int? emailId = await apiService.getCustomerIdByEmail(model.email);
                              if (emailId != null) {
                                EasyLoading.dismiss();
                                _showAccountExistsDialog('An account with this email address already exists.');
                                return;
                              }

                              apiService.createCustomer(model).then((ret) {
                                globalKey.currentState?.reset();

                                if (ret) {
                                  EasyLoading.showSuccess(
                                      lang.S.of(context).easyLoadingSuccess);

                                  const AddNewAddress().launch(context);
                                } else {
                                  EasyLoading.showError(lang.S.of(context).easyLoadingError);
                                }
                              });
                            }
                          }),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                             lang.S.of(context).alreadyAccount,
                              style: kTextStyle.copyWith(
                                fontSize: 16,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w500,
                                color: textColors,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              const LogInScreen().launch(
                                context,
                                //pageRouteAnimation: PageRouteAnimation.Fade,
                              );
                            },
                            child: Text(
                              lang.S.of(context).signInButtonText,
                              style: kTextStyle.copyWith(
                                fontSize: 16,
                                color: secondaryColor1,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
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
      // Ensure username is set to clean phone number after save
      if (phone != null) {
         String cleanPhone = phone!.replaceAll(RegExp(r'[^\w]'), '');
         model.userName = cleanPhone;
      }
      return true;
    }
    return false;
  }
}
