// ignore_for_file: unused_result

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maanstore/api_service/api_service.dart';
import 'package:maanstore/generated/l10n.dart' as lang;
import 'package:maanstore/models/retrieve_customer.dart';
import 'package:maanstore/widgets/buttons.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../Providers/all_repo_providers.dart';
import '../../const/constants.dart';
import '../../main.dart';
import '../Theme/theme.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key, required this.retrieveCustomer});

  final RetrieveCustomer retrieveCustomer;

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  APIService? apiService;
  String? phoneNumber;

  @override
  void initState() {
    apiService = APIService();
    super.initState();
    // Initialize updateProfile with current customer data so fields are not null if not edited
    updateProfile = widget.retrieveCustomer;
  }

  RetrieveCustomer updateProfile = RetrieveCustomer();
  XFile? imageFile;
  final ImagePicker picker = ImagePicker();

  void _getFromGallery() async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer(builder: (context, ref, __) {
      return Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: isDark ? darkTitleColor : lightTitleColor,
              ),
            ),
            title: MyGoogleText(
              text: lang.S.of(context).myProfileScreenName,
              fontColor: isDark ? darkTitleColor : lightTitleColor,
              fontWeight: FontWeight.normal,
              fontSize: 20,
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(30),
                  width: context.width(),
                  height: context.height() - (AppBar().preferredSize.height + 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _getFromGallery();
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: imageFile != null
                                      ? FileImage(File(imageFile!.path))
                                      : (widget.retrieveCustomer.avatarUrl != null &&
                                              widget.retrieveCustomer.avatarUrl!.isNotEmpty)
                                          ? NetworkImage(
                                              widget.retrieveCustomer.avatarUrl!)
                                          : const AssetImage(
                                                  'images/profile_image.png')
                                              as ImageProvider,
                                ),
                              ),
                            ),
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: globalKey,
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: lang.S.of(context).fastNameTextFieldLabel,
                                hintText: lang.S.of(context).fastNameTextFieldHint,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  borderSide: BorderSide(color: isDark ? darkGreyTextColor : lightGreyTextColor, width: 1),
                                ),
                                labelStyle: kTextStyle.copyWith(color: isDark ? darkTitleColor : lightTitleColor),
                                hintStyle: kTextStyle.copyWith(color: isDark ? darkGreyTextColor : lightGreyTextColor),
                              ),
                              initialValue: widget.retrieveCustomer.firstName,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return lang.S.of(context).fastNameTextFieldValidator;
                                }
                                return null;
                              },
                              onSaved: (value) {
                                updateProfile.firstName = value!;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: lang.S.of(context).lastNameTextFieldLabel,
                                hintText: lang.S.of(context).lastNameTextFieldHint,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  borderSide: BorderSide(color: isDark ? darkGreyTextColor : lightGreyTextColor, width: 1),
                                ),
                                labelStyle: kTextStyle.copyWith(color: isDark ? darkTitleColor : lightTitleColor),
                                hintStyle: kTextStyle.copyWith(color: isDark ? darkGreyTextColor : lightGreyTextColor),
                              ),
                              initialValue: widget.retrieveCustomer.lastName,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return lang.S.of(context).lastNameTextFieldValidator;
                                }
                                return null;
                              },
                              onSaved: (value) {
                                updateProfile.lastName = value!;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: lang.S.of(context).textFieldEmailLabelText,
                                hintText: lang.S.of(context).textFieldEmailHintText,
                                labelStyle: kTextStyle.copyWith(color: isDark ? darkTitleColor : lightTitleColor),
                                hintStyle: kTextStyle.copyWith(color: isDark ? darkGreyTextColor : lightGreyTextColor),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  borderSide: BorderSide(color: isDark ? darkGreyTextColor : lightGreyTextColor, width: 1),
                                ),
                              ),
                              initialValue: widget.retrieveCustomer.email,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return lang.S.of(context).textFieldEmailValidatorText1;
                                } else if (!value.contains('@')) {
                                  return lang.S.of(context).textFieldEmailValidatorText2;
                                }
                                return null;
                              },
                              onSaved: (value) {
                                updateProfile.email = value!;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: lang.S.of(context).textFieldPhoneLabel,
                                hintText: lang.S.of(context).textFieldPhoneHint,
                                labelStyle: kTextStyle.copyWith(color: isDark ? darkTitleColor : lightTitleColor),
                                hintStyle: kTextStyle.copyWith(color: isDark ? darkGreyTextColor : lightGreyTextColor),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  borderSide: BorderSide(color: isDark ? darkGreyTextColor : lightGreyTextColor, width: 1),
                                ),
                              ),
                              initialValue: widget.retrieveCustomer.billing!.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return lang.S.of(context).textFieldPhoneValidator;
                                }
                                return null;
                              },
                              onSaved: (value) {
                                phoneNumber = value.toString();
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Button1(
                        buttonText: lang.S.of(context).updateProfileButton,
                        buttonColor: const Color(0xFFFF7F00),
                        onPressFunction: () async {
                          if (validateAndSave()) {
                            final successText = lang.S.of(context).easyLoadingSuccess;
                            final errorText = lang.S.of(context).easyLoadingError;
                            
                            EasyLoading.show(status: lang.S.of(context).updateHint);
                            // Call apiService inside try-catch to handle potential errors
                            try {
                              bool value = await apiService!.updateProfile(
                                  updateProfile,
                                  phoneNumber ?? widget.retrieveCustomer.billing!.phone.toString(),
                                  image: imageFile != null ? File(imageFile!.path) : null
                              );

                              if (value) {
                                EasyLoading.showSuccess(successText);
                                ref.refresh(getCustomerDetails);
                                if (context.mounted) {
                                  Navigator.pop(context); // Go back to profile
                                }
                              } else {
                                EasyLoading.showError(errorText);
                              }
                            } catch (e) {
                              EasyLoading.showError(errorText);
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
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
