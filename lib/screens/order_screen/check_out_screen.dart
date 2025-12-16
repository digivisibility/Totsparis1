// ignore_for_file: unused_result

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
// import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_tap_payment/flutter_tap_payment.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:http/http.dart' as http;
import 'package:maanstore/api_service/api_service.dart';
import 'package:maanstore/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../Providers/all_repo_providers.dart';
import '../../config/config.dart';
import '../../config/paytm_config.dart';
import '../../const/constants.dart';
import '../../const/hardcoded_text.dart';
import '../../models/add_to_cart_model.dart';
import '../../models/order_create_model.dart' as lee;
import '../../models/purchase_model.dart';
import '../../models/retrieve_customer.dart';
import '../../widgets/buttons.dart';
import '../../widgets/checkout_shimmer_widget.dart';
import '../../widgets/confirmation_popup.dart';
import '../Theme/theme.dart';
import '../home_screens/home.dart';
import 'add_new_address_2.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_tap_payment/flutter_tap_payment.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({Key? key, this.couponPrice}) : super(key: key);

  final double? couponPrice;

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  List<lee.LineItems> lineItems = <lee.LineItems>[];
  RetrieveCustomer? retrieveCustomer;
  double totalAmount = 0;
  APIService? apiService;
  int initialValue = 1;
  bool isSuccess = false;
  // final plugin = PaystackPlugin();

  String whichPaymentIsChecked = 'Cash on Delivery';

  @override
  void initState() {
    apiService = APIService();
    // plugin.initialize(publicKey: paystackPublicId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
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
            text: lang.S.of(context).checkOutScreenName,
            fontColor: isDark ? darkTitleColor : lightTitleColor,
            fontWeight: FontWeight.normal,
            fontSize: 18,
          ),
        ),
        body: Stack(
          children: [
            FutureBuilder<RetrieveCustomer>(
                future: apiService!.getCustomerDetails(),
                builder: (context, snapShot) {
                  if (snapShot.hasData) {
                    if (snapShot.data!.shipping!.address1!.isEmpty ||
                        snapShot.data!.shipping!.firstName!.isEmpty ||
                        snapShot.data!.shipping!.city!.isEmpty ||
                        snapShot.data!.billing!.phone!.isEmpty) {
                      Center(
                        child: Button1(
                            buttonText: lang.S.of(context).addShippingAddressButton,
                            buttonColor: kPrimaryColor,
                            onPressFunction: () => AddNewAddressTwo(initShipping: snapShot.data!.shipping, initBilling: snapShot.data!.billing).launch(context)),
                      );
                    }
                    retrieveCustomer = snapShot.data;
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(20),
                              width: context.width(),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(30),
                                  topLeft: Radius.circular(30),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Consumer(builder: (context, ref, child) {
                                    final cart = ref.watch(cartNotifier);
                                    lineItems = cart.cartItems;
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        MyGoogleText(
                                          text: '${lang.S.of(context).totalItems} ${cart.cartOtherInfoList.length}',
                                          fontSize: 18,
                                          fontColor: isDark ? darkTitleColor : lightTitleColor,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        SizedBox(
                                          height: 130,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                  right: 8,
                                                  bottom: 8,
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                                                      border: Border.all(
                                                        width: 1,
                                                        color: secondaryColor3,
                                                      )),
                                                  child: Row(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(4.0),
                                                        child: Container(
                                                          height: 110,
                                                          width: 110,
                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                              width: 1,
                                                              color: secondaryColor3,
                                                            ),
                                                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                                                            color: secondaryColor3,
                                                            image: DecorationImage(image: NetworkImage(cart.cartOtherInfoList[index].productImage.toString())),
                                                          ),
                                                        ),
                                                      ),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.all(5.0),
                                                            child: MyGoogleText(
                                                              text: cart.cartOtherInfoList[index].productName.toString(),
                                                              fontSize: 16,
                                                              fontColor: isDark ? darkTitleColor : lightTitleColor,
                                                              fontWeight: FontWeight.normal,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: context.width() / 2.3,
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(5),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  MyGoogleText(
                                                                    text: '${cart.cartOtherInfoList[index].productPrice}\₹',
                                                                    fontSize: 16,
                                                                    fontColor: isDark ? darkTitleColor : lightTitleColor,
                                                                    fontWeight: FontWeight.normal,
                                                                  ),

                                                                  ///_____________________quantity_____________________
                                                                  Row(
                                                                    children: [
                                                                      MyGoogleText(
                                                                        text: lang.S.of(context).quantity,
                                                                        fontSize: 13,
                                                                        fontColor: isDark ? darkGreyTextColor : lightGreyTextColor,
                                                                        fontWeight: FontWeight.normal,
                                                                      ),
                                                                      const SizedBox(
                                                                        width: 5,
                                                                      ),
                                                                      MyGoogleText(
                                                                        text: cart.cartOtherInfoList[index].quantity.toString(),
                                                                        fontSize: 13,
                                                                        fontColor: isDark ? darkGreyTextColor : lightGreyTextColor,
                                                                        fontWeight: FontWeight.normal,
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            itemCount: cart.cartOtherInfoList.length,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                  const SizedBox(height: 10),
                                  MyGoogleText(
                                    text: lang.S.of(context).shippingAddress,
                                    fontSize: 20,
                                    fontColor: isDark ? darkTitleColor : lightTitleColor,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(8),
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
                                            MyGoogleText(
                                              text: '${snapShot.data!.shipping!.firstName} ${snapShot.data!.shipping!.lastName}',
                                              fontSize: 16,
                                              fontColor: isDark ? darkTitleColor : lightTitleColor,
                                              fontWeight: FontWeight.normal,
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                AddNewAddressTwo(
                                                  initShipping: snapShot.data!.shipping,
                                                  initBilling: snapShot.data!.billing,
                                                ).launch(context);
                                              },
                                              child: MyGoogleText(
                                                text: lang.S.of(context).changeButton,
                                                fontSize: 16,
                                                fontColor: secondaryColor1,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            )
                                          ],
                                        ),
                                        Flexible(
                                          child: Text(
                                            '${snapShot.data!.shipping!.address1}, ${snapShot.data!.shipping!.address2}, ${snapShot.data!.shipping!.city}, ${snapShot.data!.shipping!.state}, ${snapShot.data!.shipping!.postcode}, ${snapShot.data!.shipping!.country}, ${snapShot.data!.billing!.phone}',
                                            maxLines: 3,
                                            style: GoogleFonts.dmSans(
                                              textStyle: const TextStyle(),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  MyGoogleText(
                                    text: lang.S.of(context).paymentMethod,
                                    fontSize: 20,
                                    fontColor: isDark ? darkTitleColor : lightTitleColor,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ).visible(usePaypal),
                                  Material(
                                    elevation: 0.0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        side: BorderSide(
                                            color: whichPaymentIsChecked == 'Paypal'
                                                ? kPrimaryColor
                                                : isDark
                                                    ? darkContainer
                                                    : secondaryColor3)),
                                    color: isDark ? darkContainer : Colors.white,
                                    child: CheckboxListTile(
                                      value: whichPaymentIsChecked == 'Paypal',
                                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                      onChanged: (val) {
                                        setState(() {
                                          val == true ? whichPaymentIsChecked = 'Paypal' : whichPaymentIsChecked = 'Cash on Delivery';
                                        });
                                      },
                                      contentPadding: const EdgeInsets.all(10.0),
                                      activeColor: kPrimaryColor,
                                      title: Text(
                                        'Paypal',
                                        style: TextStyle(
                                          color: isDark ? darkTitleColor : lightTitleColor,
                                        ),
                                      ),
                                      secondary: Image.asset(
                                        'images/paypal-logo.png',
                                        height: 50.0,
                                        width: 80.0,
                                      ),
                                    ),
                                  ).visible(usePaypal),
                                  const SizedBox(
                                    height: 10.0,
                                  ).visible(useStripe),
                                  Material(
                                    elevation: 0.0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        side: BorderSide(
                                            color: whichPaymentIsChecked == 'Stripe'
                                                ? kPrimaryColor
                                                : isDark
                                                    ? darkContainer
                                                    : secondaryColor3)),
                                    color: isDark ? darkContainer : Colors.white,
                                    child: CheckboxListTile(
                                      value: whichPaymentIsChecked == 'Stripe',
                                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                      onChanged: (val) {
                                        setState(() {
                                          val == true ? whichPaymentIsChecked = 'Stripe' : whichPaymentIsChecked = 'Cash on Delivery';
                                        });
                                      },
                                      contentPadding: const EdgeInsets.all(10.0),
                                      activeColor: kPrimaryColor,
                                      title: Text(
                                        'Stripe',
                                        style: TextStyle(
                                          color: isDark ? darkTitleColor : lightTitleColor,
                                        ),
                                      ),
                                      secondary: Image.asset(
                                        'images/stripe-logo.png',
                                        height: 50.0,
                                        width: 80.0,
                                      ),
                                    ),
                                  ).visible(useStripe),
                                  const SizedBox(
                                    height: 10.0,
                                  ).visible(useTap),
                                  Material(
                                    elevation: 0.0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        side: BorderSide(
                                            color: whichPaymentIsChecked == 'Tap'
                                                ? primaryColor
                                                : isDark
                                                    ? darkContainer
                                                    : secondaryColor3)),
                                    color: isDark ? darkContainer : Colors.white,
                                    child: CheckboxListTile(
                                      value: whichPaymentIsChecked == 'Tap',
                                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                      onChanged: (val) {
                                        setState(() {
                                          val == true ? whichPaymentIsChecked = 'Tap' : whichPaymentIsChecked = 'Cash on Delivery';
                                        });
                                      },
                                      contentPadding: const EdgeInsets.all(10.0),
                                      activeColor: primaryColor,
                                      title: Text(
                                        'Tap',
                                        style: TextStyle(
                                          color: isDark ? darkTitleColor : lightTitleColor,
                                        ),
                                      ),
                                      secondary: Image.asset(
                                        'images/tap.png',
                                        height: 50.0,
                                        width: 80.0,
                                        color: isDark ? Colors.white : darkGreyTextColor,
                                      ),
                                    ),
                                  ).visible(useTap),
                                  const SizedBox(
                                    height: 10.0,
                                  ).visible(useSslCommerz),
                                  Material(
                                    elevation: 0.0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        side: BorderSide(
                                            color: whichPaymentIsChecked == 'SSLCommerz'
                                                ? primaryColor
                                                : isDark
                                                    ? darkContainer
                                                    : secondaryColor3)),
                                    color: isDark ? darkContainer : Colors.white,
                                    child: CheckboxListTile(
                                      value: whichPaymentIsChecked == 'SSLCommerz',
                                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                      onChanged: (val) {
                                        setState(() {
                                          val == true ? whichPaymentIsChecked = 'SSLCommerz' : whichPaymentIsChecked = 'Cash on Delivery';
                                        });
                                      },
                                      contentPadding: const EdgeInsets.all(10.0),
                                      activeColor: primaryColor,
                                      title: Text(
                                        'SSLCommerz',
                                        style: TextStyle(
                                          color: isDark ? darkTitleColor : lightTitleColor,
                                        ),
                                      ),
                                      secondary: Image.asset(
                                        'images/ssl.png',
                                        height: 50.0,
                                        width: 80.0,
                                      ),
                                    ),
                                  ).visible(useSslCommerz),
                                  const SizedBox(
                                    height: 10.0,
                                  ).visible(usePaytm),
                                  Material(
                                    elevation: 0.0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        side: BorderSide(
                                            color: whichPaymentIsChecked == 'Paytm'
                                                ? kPrimaryColor
                                                : isDark
                                                    ? darkContainer
                                                    : secondaryColor3)),
                                    color: isDark ? darkContainer : Colors.white,
                                    child: CheckboxListTile(
                                      value: whichPaymentIsChecked == 'Paytm',
                                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                      onChanged: (val) {
                                        setState(() {
                                          val == true ? whichPaymentIsChecked = 'Paytm' : whichPaymentIsChecked = 'Cash on Delivery';
                                        });
                                      },
                                      contentPadding: const EdgeInsets.all(10.0),
                                      activeColor: kPrimaryColor,
                                      title: Text(
                                        'Paytm',
                                        style: TextStyle(
                                          color: isDark ? darkTitleColor : lightTitleColor,
                                        ),
                                      ),
                                      secondary: Image.asset(
                                        'images/paytm-logo.png',
                                        height: 50.0,
                                        width: 80.0,
                                      ),
                                    ),
                                  ).visible(usePaytm),
                                  const SizedBox(
                                    height: 10.0,
                                  ).visible(useRazorpay),
                                  Material(
                                    elevation: 0.0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0), side: BorderSide(color: whichPaymentIsChecked == 'Razorpay' ? kPrimaryColor : isDark?darkContainer:secondaryColor3)),
                                    color: isDark ? darkContainer : Colors.white,
                                    child: CheckboxListTile(
                                      value: whichPaymentIsChecked == 'Razorpay',
                                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                      onChanged: (val) {
                                        setState(() {
                                          val == true ? whichPaymentIsChecked = 'Razorpay' : whichPaymentIsChecked = 'Cash on Delivery';
                                        });
                                      },
                                      contentPadding: const EdgeInsets.all(10.0),
                                      activeColor: kPrimaryColor,
                                      title: Text(
                                        'Razorpay',
                                        style: TextStyle(
                                          color: isDark ? darkTitleColor : lightTitleColor,
                                        ),
                                      ),
                                      secondary: Image.asset(
                                        'images/razorpay-logo.png',
                                        height: 50.0,
                                        width: 80.0,
                                      ),
                                    ),
                                  ).visible(useRazorpay),
                                  // const SizedBox(
                                  //   height: 10.0,
                                  // ).visible(usePaystack),
                                  // Material(
                                  //   elevation: 0.0,
                                  //   shape: RoundedRectangleBorder(
                                  //       borderRadius: BorderRadius.circular(10.0), side: BorderSide(color: whichPaymentIsChecked == 'Paystack' ? kPrimaryColor : secondaryColor3.withOpacity(0.1))),
                                  //   color: isDark ? darkContainer : Colors.white,
                                  //   child: CheckboxListTile(
                                  //     value: whichPaymentIsChecked == 'Paystack',
                                  //     checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                  //     onChanged: (val) {
                                  //       setState(() {
                                  //         val == true ? whichPaymentIsChecked = 'Paystack' : whichPaymentIsChecked = 'Paypal';
                                  //       });
                                  //     },
                                  //     contentPadding: const EdgeInsets.all(10.0),
                                  //     activeColor: kPrimaryColor,
                                  //     title: Text(
                                  //       'Paystack',
                                  //       style: TextStyle(
                                  //         color: isDark ? darkTitleColor : lightTitleColor,
                                  //       ),
                                  //     ),
                                  //     secondary: Image.asset(
                                  //       'images/paystack-logo.png',
                                  //       height: 50.0,
                                  //       width: 80.0,
                                  //     ),
                                  //   ),
                                  // ).visible(usePaystack),
                                  const SizedBox(
                                    height: 10.0,
                                  ).visible(useFlutterwave),
                                  Material(
                                    elevation: 0.0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        side: BorderSide(
                                            color: whichPaymentIsChecked == 'Flutterwave'
                                                ? kPrimaryColor
                                                : isDark
                                                    ? darkContainer
                                                    : secondaryColor3)),
                                    color: isDark ? darkContainer : Colors.white,
                                    child: CheckboxListTile(
                                      value: whichPaymentIsChecked == 'Flutterwave',
                                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                      onChanged: (val) {
                                        setState(() {
                                          val == true ? whichPaymentIsChecked = 'Flutterwave' : whichPaymentIsChecked = 'Paypal';
                                        });
                                      },
                                      contentPadding: const EdgeInsets.all(10.0),
                                      activeColor: kPrimaryColor,
                                      title: Text(
                                        'Flutterwave',
                                        style: TextStyle(
                                          color: isDark ? darkTitleColor : lightTitleColor,
                                        ),
                                      ),
                                      secondary: Image.asset(
                                        'images/flutterwave_logo.png',
                                        height: 50.0,
                                        width: 80.0,
                                      ),
                                    ),
                                  ).visible(useFlutterwave),
                                  const SizedBox(
                                    height: 10.0,
                                  ).visible(useWebview),
                                  Material(
                                    elevation: 0.0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        side: BorderSide(
                                            color: whichPaymentIsChecked == 'Webview'
                                                ? kPrimaryColor
                                                : isDark
                                                    ? darkContainer
                                                    : secondaryColor3)),
                                    color: isDark ? darkContainer : Colors.white,
                                    child: CheckboxListTile(
                                      value: whichPaymentIsChecked == 'Webview',
                                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                      onChanged: (val) {
                                        setState(() {
                                          val == true ? whichPaymentIsChecked = 'Webview' : whichPaymentIsChecked = 'Paypal';
                                        });
                                      },
                                      contentPadding: const EdgeInsets.all(10.0),
                                      activeColor: kPrimaryColor,
                                      title: Text(
                                        'Webview',
                                        style: TextStyle(
                                          color: isDark ? darkTitleColor : lightTitleColor,
                                        ),
                                      ),
                                      secondary: Image.asset(
                                        'images/webview_logo.png',
                                        height: 50.0,
                                        width: 80.0,
                                      ),
                                    ),
                                  ).visible(useWebview),
                                  const SizedBox(
                                    height: 10.0,
                                  ).visible(useCashOnDelivery),
                                  Material(
                                    elevation: 0.0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        side: BorderSide(
                                            color: whichPaymentIsChecked == 'Cash on Delivery'
                                                ? kPrimaryColor
                                                : isDark
                                                    ? darkContainer
                                                    : secondaryColor3)),
                                    color: isDark ? darkContainer : Colors.white,
                                    child: CheckboxListTile(
                                      value: whichPaymentIsChecked == 'Cash on Delivery',
                                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                      onChanged: (val) {
                                        setState(() {
                                          val == true ? whichPaymentIsChecked = 'Cash on Delivery' : whichPaymentIsChecked = 'Paypal';
                                        });
                                      },
                                      contentPadding: const EdgeInsets.all(10.0),
                                      activeColor: kPrimaryColor,
                                      title: Text(
                                        'Cash on Delivery',
                                        style: TextStyle(
                                          color: isDark ? darkTitleColor : lightTitleColor,
                                        ),
                                      ),
                                      secondary: Image.asset(
                                        'images/cod-logo.png',
                                        height: 50.0,
                                        width: 80.0,
                                      ),
                                    ),
                                  ).visible(useCashOnDelivery),
                                  const SizedBox(height: 20),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ///_____Cost_Section_____________
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          MyGoogleText(
                                            text: lang.S.of(context).yourOrder,
                                            fontSize: 18,
                                            fontColor: isDark ? darkTitleColor : lightTitleColor,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          const SizedBox(height: 10),
                                          Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  MyGoogleText(
                                                    text: lang.S.of(context).subtotal,
                                                    fontSize: 16,
                                                    fontColor: textColors,
                                                    fontWeight: FontWeight.normal,
                                                  ),
                                                  Consumer(builder: (_, ref, __) {
                                                    final price = ref.watch(cartNotifier);
                                                    return MyGoogleText(
                                                      text: widget.couponPrice == null
                                                          ? '\₹${(price.cartTotalPriceF(initialValue)).toStringAsFixed(2)}'
                                                          : '\₹${(price.cartTotalPriceF(initialValue) - price.promoPrice).toStringAsFixed(2)}',
                                                      fontSize: 20,
                                                      fontColor: isDark ? darkTitleColor : lightTitleColor,
                                                      fontWeight: FontWeight.normal,
                                                    );
                                                  }),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  MyGoogleText(
                                                    text: lang.S.of(context).discount,
                                                    fontSize: 16,
                                                    fontColor: isDark ? darkGreyTextColor : lightGreyTextColor,
                                                    fontWeight: FontWeight.normal,
                                                  ),
                                                  MyGoogleText(
                                                    text: '\₹${widget.couponPrice}',
                                                    fontSize: 20,
                                                    fontColor: isDark ? darkTitleColor : lightTitleColor,
                                                    fontWeight: FontWeight.normal,
                                                  )
                                                ],
                                              ).visible(widget.couponPrice != null),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            width: double.infinity,
                                            decoration: const BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(
                                              width: 1,
                                              color: textColors,
                                            ))),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              MyGoogleText(
                                                text: lang.S.of(context).totalAmount,
                                                fontSize: 18,
                                                fontColor: isDark ? darkTitleColor : lightTitleColor,
                                                fontWeight: FontWeight.normal,
                                              ),
                                              Consumer(builder: (_, ref, __) {
                                                final price = ref.watch(cartNotifier);
                                                return MyGoogleText(
                                                  text: widget.couponPrice == null
                                                      ? '\₹${(price.cartTotalPriceF(initialValue)).toStringAsFixed(2)}'
                                                      : '\₹${(price.cartTotalPriceF(initialValue) - price.promoPrice).toStringAsFixed(2)}',
                                                  fontSize: 20,
                                                  fontColor: isDark ? darkTitleColor : lightTitleColor,
                                                  fontWeight: FontWeight.normal,
                                                );
                                              }),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                      Consumer(builder: (context, ref, child) {
                                        final cart = ref.read(cartNotifier);

                                        return Button1(
                                          buttonText: lang.S.of(context).payWithWebCheckoutButton,
                                          buttonColor: kPrimaryColor,
                                          onPressFunction: () async {
                                            bool isValid = await PurchaseModel().isActiveBuyer();
                                            if (isValid) {
                                              _handlePayment(cart, ref);
                                            } else {
                                              showLicense(context: context);
                                            }
                                          },
                                        );
                                        // Button1(
                                        //   buttonText: lang.S.of(context).payWithWebCheckoutButton,
                                        //   buttonColor: primaryColor,
                                        //   onPressFunction: () {
                                        //     EasyLoading.show(
                                        //       status: lang.S.of(context).easyLoadingCreatingOrder,
                                        //     );
                                        //     apiService?.createOrder(retrieveCustomer!, lineItems, 'Cash on Delivery', false, cart.coupon).then((value) async {
                                        //       if (value) {
                                        //         var snap = await apiService!.getListOfOrder();
                                        //         if (snap.isNotEmpty) {
                                        //           // ignore: use_build_context_synchronously
                                        //           MyWebView(
                                        //             url: snap[0].paymentUrl,
                                        //             id: snap[0].id.toString(),
                                        //           ).launch(context);
                                        //         }
                                        //
                                        //         EasyLoading.dismiss(animation: true);
                                        //         cart.cartOtherInfoList.clear();
                                        //         cart.cartItems.clear();
                                        //         cart.coupon.clear();
                                        //         ref.refresh(getOrders);
                                        //       } else {
                                        //         EasyLoading.showError(lang.S.of(context).easyLoadingError);
                                        //       }
                                        //     });
                                        //   });
                                      }),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return const CheckOutShimmerWidget();
                  }
                }),
            RedeemConfirmationScreen(
              image: 'images/confirm_order_pupup.png',
              mainText: lang.S.of(context).orderSuccess,
              subText: lang.S.of(context).orderSuccessSubText,
              buttonText: lang.S.of(context).backToHomeButton,
            ).visible(isSuccess)
          ],
        ),
      ),
    );
  }

  //Handle Multiple Payment system
  _handlePayment(CartNotifier cart, WidgetRef ref) {
    switch (whichPaymentIsChecked) {
      case 'Razorpay':
        _handleRazorpayPayment(cart, ref);
        break;
      case 'Paypal':
        _handlePaypalPayment(cart, ref);
        break;
      case 'SSLCommerz':
        _handleSslCommerzPayment(cart, ref);
        break;
      // case 'Flutterwave':
      //   _handleFlutterwavePayment(cart, ref);
      //   break;
      // case 'Paystack':
      //   _handlePayStackPayment(cart, ref);
      //   break;
      case 'Stripe':
        _handleStripePayment(cart, ref);
        break;
      case 'Tap':
        _handleTapPayment(cart, ref);
        break;
      // case 'Paytm':
      //   PaytmConfig().generateTxnToken(widget.couponPrice == null ? cart.cartTotalPriceF(initialValue) : (cart.cartTotalPriceF(initialValue) - cart.promoPrice),
      //       DateTime.now().millisecondsSinceEpoch.toString());
      //   break;
      case 'Webview':
        _handleWebviewPayment(cart, ref);
        break;
      case 'Cash on Delivery':
        _handleCashOnDelivery(cart, ref);
        break;
      default:
        _handleCashOnDelivery(cart, ref);
    }
  }

  Future<void> _handleSslCommerzPayment(CartNotifier cart, WidgetRef ref) async {
    int amount = widget.couponPrice == null ? cart.cartTotalPriceF(initialValue).toInt() : (cart.cartTotalPriceF(initialValue) - cart.promoPrice).toInt();

    Sslcommerz sslcommerz = Sslcommerz(
      initializer: SSLCommerzInitialization(
        //Use the ipn if you have valid one, or it will fail the transaction.
        ipn_url: "www.ipnurl.com",
        currency: SSLCurrencyType.BDT,
        product_category: "Food",
        sdkType: sslSandbox ? SSLCSdkType.TESTBOX : SSLCSdkType.LIVE,
        store_id: storeId,
        store_passwd: storePassword,
        total_amount: amount.toDouble(),
        tran_id: DateTime.now().millisecondsSinceEpoch.toString(),
      ),
    );
    try {
      SSLCTransactionInfoModel result = await sslcommerz.payNow();

      if (result.status!.toLowerCase() == "failed") {
        Fluttertoast.showToast(
          msg: "Transaction is Failed....",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else if (result.status!.toLowerCase() == "closed") {
        Fluttertoast.showToast(
          msg: "SDK Closed by User",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        _handleOrderCreate(true, 'SSLCommerz', cart, ref);
        // Fluttertoast.showToast(
        //     msg:
        //     "Transaction is ${result.status} and Amount is ${result.amount}",
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.CENTER,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: Colors.black,
        //     textColor: Colors.white,
        //     fontSize: 16.0);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //Tap payment
  _handleTapPayment(CartNotifier cart, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => TapPayment(
            apiKey: tapApiId,
            redirectUrl: "http://your_website.com/redirect_url",
            postUrl: "http://your_website.com/post_url",
            paymentData: {
              "amount": widget.couponPrice == null ? cart.cartTotalPriceF(initialValue).toString() : (cart.cartTotalPriceF(initialValue) - cart.promoPrice).toString(),
              "currency": "OMR",
              "threeDSecure": true,
              "save_card": false,
              "description": "Grocery Order From MaanGrocery",
              "statement_descriptor": "Sample",
              "metadata": const {"udf1": "test 1", "udf2": "test 2"},
              "reference": {
                "transaction": DateTime.now().microsecondsSinceEpoch.toString(),
                "order": DateTime.now().millisecondsSinceEpoch.toString(),
              },
              "receipt": const {"email": false, "sms": true},
              "customer": {
                "first_name": retrieveCustomer?.firstName.toString() ?? 'Test',
                "middle_name": "test",
                "last_name": retrieveCustomer?.lastName.toString() ?? 'Test',
                "email": retrieveCustomer?.email.toString() ?? 'Test@test.com',
                "phone": {
                  "country_code": "965",
                  "number": retrieveCustomer?.shipping?.phone.toString() ?? 'Test',
                }
              },
              // "merchant": {"id": ""},
              "source": const {"id": "src_card"},
              // "destinations": {
              //   "destination": [
              //     {"id": "480593777", "amount": 2, "currency": "KWD"},
              //     {"id": "486374777", "amount": 3, "currency": "KWD"}
              //   ]
              // }
            },
            onSuccess: (Map params) async {
              _handleOrderCreate(true, 'Tap', cart, ref);
            },
            onError: (error) {
              EasyLoading.showError(error.toString());
            }),
      ),
    );
  }

  //Web Checkout Payment System
  _handleWebviewPayment(CartNotifier cart, WidgetRef ref) {
    EasyLoading.show(
      status: lang.S.of(context).easyLoadingCreatingOrder,
    );
    apiService?.createOrder(retrieveCustomer!, lineItems, 'Cash on Delivery', false, cart.coupon).then((value) async {
      if (value) {
        var snap = await apiService!.getListOfOrder();
        if (snap.isNotEmpty) {
          // ignore: use_build_context_synchronously
          MyWebView(
            url: snap[0].paymentUrl,
            id: snap[0].id.toString(),
          ).launch(context);
        }

        EasyLoading.dismiss(animation: true);
        cart.cartOtherInfoList.clear();
        cart.cartItems.clear();
        cart.coupon.clear();
        ref.refresh(getOrders);
      } else {
        EasyLoading.showError(lang.S.of(context).easyLoadingError);
      }
    });
  }

  //Cash on Delivery Payment
  _handleCashOnDelivery(CartNotifier cart, WidgetRef ref) {
    _handleOrderCreate(false, 'Cash On Delivery', cart, ref);
  }

  //Stripe Payment
  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': stripeCurrency,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {'Authorization': 'Bearer $stripeSecretKey', 'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  _handleStripePayment(CartNotifier cart, WidgetRef ref) async {
    try {
      int amount = widget.couponPrice == null ? cart.cartTotalPriceF(initialValue).toInt() : (cart.cartTotalPriceF(initialValue) - cart.promoPrice).toInt();
      //STEP 1: Create Payment Intent
      var paymentIntent = await createPaymentIntent((amount * 100).toString(), stripeCurrency);
      Stripe.publishableKey = stripePublishableKey;
      //STEP 2: Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent!['client_secret'], //Gotten from payment intent
              style: ThemeMode.light,
              merchantDisplayName: HardcodedTextEng.appName));

      //STEP 3: Display Payment sheet
      await Stripe.instance.presentPaymentSheet().then((value) {
        _handleOrderCreate(true, 'Stripe', cart, ref);
        paymentIntent = null;
      });
    } on StripeException catch (e) {
      EasyLoading.showError(e.error.message.toString());
    }
  }

  // Razorpay payment
  _handleRazorpayPayment(CartNotifier cart, WidgetRef ref) {
    Razorpay razorpay = Razorpay();
    var options = {
      'key': razorpayid,
      'amount': widget.couponPrice == null ? (cart.cartTotalPriceF(initialValue) * 100).toString() : ((cart.cartTotalPriceF(initialValue) - cart.promoPrice) * 100).toString(),
      "currency": razorpayCurrency,
      'name': HardcodedTextEng.appName,
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
    };
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, () {
      EasyLoading.showError('Please Try again');
    });
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
      _handleOrderCreate(true, 'Razorpay', cart, ref);
    });
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, () {});
    razorpay.open(options);
  }

  // Paypal payment
  _handlePaypalPayment(CartNotifier cart, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => UsePaypal(
            sandboxMode: sandbox,
            clientId: paypalClientId,
            secretKey: paypalClientSecret,
            returnURL: "https://samplesite.com/return",
            cancelURL: "https://samplesite.com/cancel",
            transactions: [
              {
                "amount": {
                  "total": widget.couponPrice == null ? cart.cartTotalPriceF(initialValue).toString() : (cart.cartTotalPriceF(initialValue) - cart.promoPrice).toString(),
                  "currency": paypalCurrency,
                  "details": {
                    "subtotal": widget.couponPrice == null ? cart.cartTotalPriceF(initialValue).toString() : (cart.cartTotalPriceF(initialValue) - cart.promoPrice).toString(),
                    "shipping": '0',
                    "shipping_discount": 0
                  }
                },
                "description": "Grocery Order From MaanGrocery",
                // "payment_options": {
                //   "allowed_payment_method":
                //       "INSTANT_FUNDING_SOURCE"
                // },
                "item_list": {
                  "items": [
                    {
                      "name": "Grocery Order From MaanGrocery",
                      "quantity": 1,
                      "price": widget.couponPrice == null ? cart.cartTotalPriceF(initialValue).toString() : (cart.cartTotalPriceF(initialValue) - cart.promoPrice).toString(),
                      "currency": paypalCurrency,
                    }
                  ],
                }
              }
            ],
            note: "Contact us for any questions on your order.",
            onSuccess: (Map params) async {
              _handleOrderCreate(true, 'Paypal', cart, ref);
            },
            onError: (error) {
              EasyLoading.showError(error.toString());
            },
            onCancel: (params) {
              EasyLoading.showInfo('Payment has been cancelled. Please try again');
            }),
      ),
    );
  }

  //Create an order
  _handleOrderCreate(bool payment, String methodName, CartNotifier cart, WidgetRef ref) {
    EasyLoading.show(
      status: lang.S.of(context).easyLoadingCreatingOrder,
    );
    apiService?.createOrder(retrieveCustomer!, lineItems, methodName, payment, cart.coupon).then((value) async {
      if (value) {
        setState(() {
          isSuccess = true;
        });
        EasyLoading.showSuccess('Order Placed Successfully');
        cart.cartOtherInfoList.clear();
        cart.cartItems.clear();
        cart.coupon.clear();
        ref.refresh(getOrders);
      } else {
        EasyLoading.showError(lang.S.of(context).easyLoadingError);
      }
    });
  }

  //Paystack payment
  // _handlePayStackPayment(CartNotifier cart, WidgetRef ref) async {
  //   Charge charge = Charge()
  //     ..amount = widget.couponPrice == null ? (cart.cartTotalPriceF(initialValue) * 100).toInt() : ((cart.cartTotalPriceF(initialValue) - cart.promoPrice) * 100).toInt()
  //     ..reference = DateTime.now().microsecondsSinceEpoch.toString()
  //     ..currency = payStackCurrency
  //     ..email = retrieveCustomer?.email ?? 'test@test.com';
  //   CheckoutResponse response = await plugin.checkout(
  //     context,
  //     fullscreen: true,
  //     method: CheckoutMethod.card,
  //     charge: charge,
  //   );
  //   if (response.status) {
  //     _handleOrderCreate(true, 'Paystack', cart, ref);
  //   } else {
  //     EasyLoading.showError(response.message);
  //   }
  // }

  //Flutterwave payment
  // _handleFlutterwavePayment(CartNotifier cart, WidgetRef ref) async {
  //   final Customer customer = Customer(
  //     name: "${retrieveCustomer!.shipping!.firstName ?? ''} ${retrieveCustomer!.shipping!.lastName ?? ''}",
  //     phoneNumber: retrieveCustomer!.shipping!.phone ?? '',
  //     email: retrieveCustomer!.email ?? '',
  //   );
  //   final Flutterwave flutterwave = Flutterwave(
  //       context: context,
  //       publicKey: flutterwavePublicKey,
  //       currency: flutterwaveCurrency,
  //       redirectUrl: 'https://facebook.com',
  //       txRef: DateTime.now().millisecondsSinceEpoch.toString(),
  //       amount: widget.couponPrice == null ? cart.cartTotalPriceF(initialValue).toString() : (cart.cartTotalPriceF(initialValue) - cart.promoPrice).toString(),
  //       customer: customer,
  //       paymentOptions: "card, payattitude, barter, bank transfer, ussd",
  //       customization: Customization(title: "Test Payment"),
  //       isTestMode: sandbox);
  //   final ChargeResponse response = await flutterwave.charge();
  //   if (response.success == true) {
  //     _handleOrderCreate(true, 'Flutterwave', cart, ref);
  //   } else {}
  // }
}

class MyWebView extends StatefulWidget {
  const MyWebView({super.key, required this.url, required this.id});
  final String url;
  final String id;

  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  bool isPaf = false;
  WebViewController? _controller;

  Future<bool> _willPopCallback() async {
    bool canNavigate = await _controller!.canGoBack();
    if (canNavigate) {
      _controller!.goBack();
      return false;
    } else {
      Future.delayed(const Duration(milliseconds: 1)).then((value) => const Home().launch(context));
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(currentUrl?.indexOf('?'));
    // print(currentUrl?.substring(0, currentUrl?.indexOf('?')));
    // print(Config.orderConfirmUrl + widget.id.toString());
    return Scaffold(
      body: Stack(
        children: [
          WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setBackgroundColor(const Color(0x00000000))
              ..setNavigationDelegate(
                NavigationDelegate(
                  onProgress: (int progress) {
                    // Update loading bar.
                  },
                  onPageStarted: (String url) {},
                  onPageFinished: (url) {
                    int position = url.indexOf('?') - 1;
                    if (url.substring(0, position) == (Config.orderConfirmUrl + widget.id)) {
                      setState(() {
                        isPaf = true;
                      });
                    }
                  },
                  onWebResourceError: (WebResourceError error) {},
                  onNavigationRequest: (NavigationRequest request) {
                    return NavigationDecision.navigate;
                  },
                ),
              )
              ..loadRequest(Uri.parse(widget.url)),
          ),
          RedeemConfirmationScreen(
            image: 'images/confirm_order_pupup.png',
            mainText: lang.S.of(context).orderSuccess,
            subText: lang.S.of(context).orderSuccessSubText,
            buttonText: lang.S.of(context).backToHomeButton,
          ).visible(isPaf),
        ],
      ),
    );
  }
}
