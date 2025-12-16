import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:maanstore/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../api_service/api_service.dart';
import '../../const/constants.dart';
import '../../models/retrieve_customer.dart';
import '../../widgets/buttons.dart';
import '../screens/Theme/theme.dart';
import '../screens/home_screens/home.dart';

class AddNewAddress extends StatefulWidget {
  const AddNewAddress({super.key, this.initShipping, this.initBilling, this.isBilling});
  final Shipping? initShipping;
  final Billing? initBilling;
  final bool? isBilling; // true: Billing, false: Shipping, null: Both

  @override
  State<AddNewAddress> createState() => _AddNewAddressState();
}

class _AddNewAddressState extends State<AddNewAddress> {
  late APIService apiService;
  RetrieveCustomer retrieveCustomer = RetrieveCustomer();
  Shipping formAddress = Shipping(); // Using Shipping model to hold form data
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  @override
  void initState() {
    apiService = APIService();
    super.initState();
    
    // Initialize form data based on what we are editing
    if (widget.isBilling == true) {
      if (widget.initBilling != null) {
        formAddress = Shipping(
          firstName: widget.initBilling!.firstName,
          lastName: widget.initBilling!.lastName,
          address1: widget.initBilling!.address1,
          address2: widget.initBilling!.address2,
          city: widget.initBilling!.city,
          postcode: widget.initBilling!.postcode,
          country: widget.initBilling!.country,
          state: widget.initBilling!.state,
          phone: widget.initBilling!.phone,
        );
      }
    } else {
      // Default to shipping or both (usually shipping data is primary for both in simple mode)
      if (widget.initShipping != null) {
        formAddress = Shipping(
          firstName: widget.initShipping!.firstName,
          lastName: widget.initShipping!.lastName,
          address1: widget.initShipping!.address1,
          address2: widget.initShipping!.address2,
          city: widget.initShipping!.city,
          postcode: widget.initShipping!.postcode,
          country: widget.initShipping!.country,
          state: widget.initShipping!.state,
          phone: widget.initBilling?.phone, // Use billing phone as shipping phone fallback usually
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String title = lang.S.of(context).addNewAddressScreenName;
    if (widget.isBilling == true) title = 'Edit Billing Address';
    if (widget.isBilling == false) title = 'Edit Shipping Address';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(left: 20,right: 20,bottom: 20),
            child: Button1(
                buttonText: lang.S.of(context).saveButton,
                buttonColor: kPrimaryColor,
                onPressFunction: () {
                  if (validateAndSave()) {
                    EasyLoading.show(
                      status: lang.S.of(context).updateHint,
                    );
                    
                    // Construct Billing object from form data
                    Billing newBilling = Billing(
                      firstName: formAddress.firstName ?? '',
                      lastName: formAddress.lastName ?? '',
                      company: '',
                      address1: formAddress.address1 ?? '',
                      address2: formAddress.address2 ?? '',
                      city: formAddress.city ?? '',
                      postcode: formAddress.postcode ?? '',
                      country: formAddress.country ?? '',
                      phone: formAddress.phone ?? '',
                      email: widget.initBilling?.email ?? '', // Preserve email if billing
                      state: formAddress.state ?? '',
                    );

                    // Construct Shipping object from form data
                    Shipping newShipping = Shipping(
                      firstName: formAddress.firstName ?? '',
                      lastName: formAddress.lastName ?? '',
                      company: '',
                      address1: formAddress.address1 ?? '',
                      address2: formAddress.address2 ?? '',
                      city: formAddress.city ?? '',
                      postcode: formAddress.postcode ?? '',
                      country: formAddress.country ?? '',
                      state: formAddress.state ?? '',
                      phone: formAddress.phone ?? '',
                    );

                    if (widget.isBilling == true || widget.isBilling == null) {
                      retrieveCustomer.billing = newBilling;
                    }
                    if (widget.isBilling == false || widget.isBilling == null) {
                      retrieveCustomer.shipping = newShipping;
                    }

                    // Use the generic updateAddress method
                    apiService.updateAddress(retrieveCustomer).then((ret) {
                      if (ret) {
                        const Home().launch(context, isNewTask: true);
                        EasyLoading.showSuccess(lang.S.of(context).easyLoadingSuccess);
                      } else {
                        EasyLoading.showError(lang.S.of(context).easyLoadingError);
                      }
                    });
                  }
                }),
          ),
          body: PopScope(
            canPop: false,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyGoogleText(
                            text: title,
                            fontSize: 20,
                            fontColor: isDark ? darkTitleColor : lightTitleColor,
                            fontWeight: FontWeight.normal,
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
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
                                  borderSide: BorderSide(color: isDark ? secondaryColor3 : Colors.black, width: 1),
                                ),
                              ),
                              initialValue: formAddress.firstName,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return lang.S.of(context).fastNameTextFieldValidator;
                                } else if (value.length < 2) {
                                  return lang.S.of(context).fastNameTextFieldValidator;
                                }
                                return null;
                              },
                              onSaved: (value) {
                                formAddress.firstName = value!;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: lang.S.of(context).lastNameTextFieldLabel,
                                hintText: lang.S.of(context).lastNameTextFieldHint,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDark ? secondaryColor3 : Colors.black, width: 1),
                                ),
                              ),
                              initialValue: formAddress.lastName,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return lang.S.of(context).lastNameTextFieldValidator;
                                } else if (value.length < 2) {
                                  return lang.S.of(context).lastNameTextFieldValidator;
                                }
                                return null;
                              },
                              onSaved: (value) {
                                formAddress.lastName = value!;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: lang.S.of(context).strAddress1Text,
                                hintText: lang.S.of(context).strAddress1TextHint,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDark ? secondaryColor3 : Colors.black, width: 1),
                                ),
                              ),
                              initialValue: formAddress.address1,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return lang.S.of(context).strAddress1TextValid;
                                }
                                return null;
                              },
                              onSaved: (value) {
                                formAddress.address1 = value!;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: lang.S.of(context).strAddress2Text,
                                hintText: lang.S.of(context).strAddress1TextHint,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDark ? secondaryColor3 : Colors.black, width: 1),
                                ),
                              ),
                              initialValue: formAddress.address2,
                              onSaved: (value) {
                                formAddress.address2 = value!;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: lang.S.of(context).cityTown,
                                hintText: lang.S.of(context).cityTownHint,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDark ? secondaryColor3 : Colors.black, width: 1),
                                ),
                              ),
                              initialValue: formAddress.city,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return lang.S.of(context).cityTownValid;
                                }
                                return null;
                              },
                              onSaved: (value) {
                                formAddress.city = value!;
                              },
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      labelText: lang.S.of(context).postcode,
                                      hintText: lang.S.of(context).postcodeHint,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: isDark ? secondaryColor3 : Colors.black, width: 1),
                                      ),
                                    ),
                                    initialValue: formAddress.postcode,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return lang.S.of(context).postcodeValid;
                                      } else if (value.length < 4) {
                                        return lang.S.of(context).postcodeValid;
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      formAddress.postcode = value!;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      labelText: lang.S.of(context).state,
                                      hintText: lang.S.of(context).stateHint,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: isDark ? secondaryColor3 : Colors.black, width: 1),
                                      ),
                                    ),
                                    initialValue: formAddress.state,
                                    validator: (value) {
                                      return null;
                                    },
                                    onSaved: (value) {
                                      formAddress.state = value!;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: lang.S.of(context).textFieldPhoneLabel,
                                hintText: lang.S.of(context).textFieldPhoneHint,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDark ? secondaryColor3 : Colors.black, width: 1),
                                ),
                              ),
                              initialValue: widget.initBilling?.phone ?? formAddress.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return lang.S.of(context).textFieldPhoneValidator;
                                }
                                return null;
                              },
                              onSaved: (value) {
                                formAddress.phone = value.toString();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool validateAndSave() {
    FormState form = globalKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
