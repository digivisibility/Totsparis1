import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maanstore/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Providers/all_repo_providers.dart';
import '../../const/constants.dart';
import '../../widgets/add_new_address.dart';

class ShippingAddress extends StatefulWidget {
  const ShippingAddress({Key? key, this.isBilling}) : super(key: key);
  final bool? isBilling;

  @override
  State<ShippingAddress> createState() => _ShippingAddressState();
}

class _ShippingAddressState extends State<ShippingAddress> {
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
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: isDark ? darkTitleColor : lightTitleColor,
              ),
            ),
            title: MyGoogleText(
              text: 'My Addresses',
              fontColor: isDark ? darkTitleColor : lightTitleColor,
              fontWeight: FontWeight.normal,
              fontSize: 18,
            ),
          ),
          body: customerDetails.when(
            data: (snapShot) {
              return SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  width: context.width(),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///____________Shipping_address__________________________
                      MyGoogleText(
                        text: lang.S.of(context).shippingAddress,
                        fontSize: 20,
                        fontColor: isDark ? darkTitleColor : lightTitleColor,
                        fontWeight: FontWeight.normal,
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: secondaryColor3),
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: MyGoogleText(
                                      text: '${snapShot.shipping?.firstName ?? ''} ${snapShot.shipping?.lastName ?? ''}',
                                      fontSize: 16,
                                      fontColor: isDark ? darkTitleColor : lightTitleColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                       AddNewAddress(
                                          initShipping: snapShot.shipping,
                                          initBilling: snapShot.billing,
                                          isBilling: false, // Edit Shipping
                                        ).launch(context);
                                    },
                                    child: const MyGoogleText(
                                      text: 'Edit',
                                      fontSize: 16,
                                      fontColor: secondaryColor1,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 5),
                              MyGoogleText(
                                text: '${snapShot.shipping?.address1 ?? ''}, ${snapShot.shipping?.city ?? ''}, ${snapShot.shipping?.state ?? ''}, ${snapShot.shipping?.postcode ?? ''}, ${snapShot.shipping?.country ?? ''}',
                                fontSize: 16,
                                fontColor: isDark ? darkGreyTextColor : lightGreyTextColor,
                                fontWeight: FontWeight.normal,
                              ),
                              const SizedBox(height: 5),
                              MyGoogleText(
                                text: snapShot.shipping?.phone ?? snapShot.billing?.phone ?? '', // Fallback to billing phone if shipping empty
                                fontSize: 16,
                                fontColor: isDark ? darkGreyTextColor : lightGreyTextColor,
                                fontWeight: FontWeight.normal,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                       ///____________Billing_address__________________________
                      MyGoogleText(
                        text: 'Billing Address', // Can move to lang file
                        fontSize: 20,
                        fontColor: isDark ? darkTitleColor : lightTitleColor,
                        fontWeight: FontWeight.normal,
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: secondaryColor3),
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: MyGoogleText(
                                      text: '${snapShot.billing?.firstName ?? ''} ${snapShot.billing?.lastName ?? ''}',
                                      fontSize: 16,
                                      fontColor: isDark ? darkTitleColor : lightTitleColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                       AddNewAddress(
                                          initShipping: snapShot.shipping,
                                          initBilling: snapShot.billing,
                                          isBilling: true, // Edit Billing
                                        ).launch(context);
                                    },
                                    child: const MyGoogleText(
                                      text: 'Edit',
                                      fontSize: 16,
                                      fontColor: secondaryColor1,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 5),
                              MyGoogleText(
                                text: '${snapShot.billing?.address1 ?? ''}, ${snapShot.billing?.city ?? ''}, ${snapShot.billing?.state ?? ''}, ${snapShot.billing?.postcode ?? ''}, ${snapShot.billing?.country ?? ''}',
                                fontSize: 16,
                                fontColor: isDark ? darkGreyTextColor : lightGreyTextColor,
                                fontWeight: FontWeight.normal,
                              ),
                              const SizedBox(height: 5),
                              MyGoogleText(
                                text: snapShot.billing?.phone ?? '',
                                fontSize: 16,
                                fontColor: isDark ? darkGreyTextColor : lightGreyTextColor,
                                fontWeight: FontWeight.normal,
                              ),
                               const SizedBox(height: 5),
                              MyGoogleText(
                                text: snapShot.billing?.email ?? '',
                                fontSize: 16,
                                fontColor: isDark ? darkGreyTextColor : lightGreyTextColor,
                                fontWeight: FontWeight.normal,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            error: (e, stack) {
              return Text(e.toString());
            },
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      );
    });
  }
}
