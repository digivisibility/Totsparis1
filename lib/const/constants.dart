import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wishlist_model.dart';

bool isRtl = false;
//Select Gateways
const bool usePaypal = false;
const bool usePaystack = false;
const bool usePaytm = false;
const bool useRazorpay = true;
const bool useFlutterwave = false;
const bool useStripe = false;
const bool useWebview = false;
const bool useTap = false;
const bool useCashOnDelivery = true;


String purchaseCode = '528cdb9a-5d37-4292-a2b5-b792d5eca03a';
//Tap Payment Settings
const String tapApiId = 'Your Api Key';

//Paypal Settings
const String paypalClientId = 'ATKxCBB49G3rPw4DG_0vDmygbZeFKubzub7jGWpeUW5jzfElK9qOzqJOfrBTYvS7RuIhoPdWHB4DIdLJ';
const String paypalClientSecret = 'EIDqVfraXlxDBMnswmhqP2qYv6rr_KPDgK269T-q1K9tB455OpPL_fc65irFiPBpiVXcoOQwpKqU3PAu';
const bool sandbox = true;
const String paypalCurrency = 'INR';

//Razorpay Settings
// Razorpay Settings
const String razorpayid = 'rzp_live_RnsN5rWhr4oKVD';     // Key ID
const String razorpaySecret = 'mtfV2lGWHk3MUOlVkHgjeKR3'; // Key Secret
const String razorpayCurrency = 'INR';


//Paystack Settings
const String paystackPublicId = 'pk_test_a0cb8b9116b87e71390dfa0a390492a6beea4097';
const String paystackSecretId = 'sk_test_83c739c2a0c8848f8b3f769ba7a3b74e0c24459f';
const String payStackCurrency = 'ZAR';

//Flutterwave Settings
const String flutterwavePublicKey = 'FLWPUBK_TEST-4732c2ce170b45e83b30bc30ea5d9385-X';
const String flutterwaveSecretKey = 'FLWSECK_TEST-9f5e80c70de84afa41bd6bba7626d897-X';
const String flutterwaveEncryptionKey = 'FLWSECK_TEST6bc8eaceedfa';
const String flutterwaveCurrency = 'ZAR';

//Stripe Settings
const String stripePublishableKey = 'pk_test_zOmNeUO71xTTP3jVPVcaQrsO';
const String stripeSecretKey = 'sk_test_MGyxDcHhKWRCAooZv4366wK1';
const String stripeCurrency = 'INR';



const String currency = '₹';
//Onesignal Settings
const String oneSignalAppId = 'a197e501-b566-44ce-a112-f6916c794e6d';

const int specialOffersID = 152;
const int bestSellingId = 142;
const int trendingProductsId = 141;
const int newArrive = 143;
const int recommendedProductId = 145;
const String currencySign = '\₹';
const String shippingCountry = 'India';

const kPrimaryColor = Color(0xFF4242DC);
const secondaryColor1 = Color(0xFFFB0B0B);
const secondaryColor2 = Color(0xFFFBFBFB);
const secondaryColor3 = Color(0xFFE5E5E5);
const titleColors = Color(0xFF1A1A1A);
const textColors = Color(0xFF828282);
const ratingColor = Color(0xFFFFB03A);
const categoryColor1 = Color(0xFFFCF3D7);
const cardColor=Color(0xff323558);
const categoryColor2 = Color(0xFFDCF7E3);
const kBorderColorTextField = Color(0xFFE3E3E3);

List<Wishlist> wishList = [];
int? wishListItems;
Future<void> addToWishList(Wishlist wishLists) async {
  wishList.add(wishLists);
  String encodedData = Wishlist.encode(wishList);
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('wishListProducts', encodedData);
  //final getData = prefs.getString('wishListProducts');
  //final decodedData = Wishlist.decode(getData!);
}

final TextStyle kTextStyle = GoogleFonts.dmSans(
  textStyle: const TextStyle(
    color: textColors,
    fontSize: 16,
  ),
);

final TextStyle sTextStyle = GoogleFonts.dmSans(
  textStyle: const TextStyle(
    color: titleColors,
  ),
);

class MyGoogleText extends StatelessWidget {
  const MyGoogleText(
      {super.key,
      required this.text,
      required this.fontSize,
      required this.fontColor,
      required this.fontWeight});
  final String text;
  final double fontSize;
  final Color fontColor;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: fontColor,
        ),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class MyGoogleTextWhitAli extends StatelessWidget {
  const MyGoogleTextWhitAli({
    super.key,
    required this.text,
    required this.fontSize,
    required this.fontColor,
    required this.fontWeight,
    required this.textAlign,
  });
  final String text;
  final double fontSize;
  final Color fontColor;
  final FontWeight fontWeight;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.dmSans(
        textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: fontColor,
        ),
      ),
    );
  }
}

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: const BorderSide(color: secondaryColor1),
  );
}

final otpInputDecoration = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);
