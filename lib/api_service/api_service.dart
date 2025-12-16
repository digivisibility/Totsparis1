import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Banner;
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'package:maanstore/models/category_model.dart';
import 'package:maanstore/models/customer.dart';
import 'package:maanstore/models/product_review_model.dart';
import 'package:maanstore/models/single_product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/config.dart';
import '../models/banner.dart';
import '../models/list_of_orders.dart';
import '../models/order_create_model.dart' as order_create;
import '../models/product_model.dart';
import '../models/retrieve_an_order.dart';
import '../models/retrieve_coupon.dart';
import '../models/retrieve_customer.dart';
import '../models/single_product_variations_model.dart';
import '../screens/auth_screen/otp_verification_screen.dart';
import '../screens/home_screens/home.dart';
import '../screens/auth_screen/sign_up.dart';

class APIService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        if (kDebugMode) {
          print("Google Sign-In cancelled by user.");
        }
        return null; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        int? customerId = await getCustomerIdByEmail(user.email!);
        final prefs = await SharedPreferences.getInstance();

        if (customerId != null) {
          await prefs.setInt('customerId', customerId);
        } else {
          CustomerModel newCustomer = CustomerModel(
            email: user.email!,
            userName: user.email!.split('@')[0],
            password: 'password',
            firstName: user.displayName?.split(' ').first,
            lastName: user.displayName?.split(' ').last,
          );

          bool created = await createCustomer(newCustomer);
          if (!created) {
            throw Exception("Failed to create customer account on backend.");
          }
        }
      }
      return user;
    } catch (e) {
      if (kDebugMode) {
        print("Error during Google Sign-In: $e");
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('customerId');
    await prefs.remove('token');
  }

  Future<int?> getCustomerIdByEmail(String email) async {
    String url = '${Config.url}${Config.customerURL}?email=$email&consumer_key=${Config.key}&consumer_secret=${Config.secret}';
    try {
      var response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          return data[0]['id'];
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching customer by email: $e");
      }
    }
    return null;
  }

  Future<int?> getCustomerIdByPhone(String phone) async {
    // Search using the provided phone string
    String url = '${Config.url}${Config.customerURL}?search=$phone&consumer_key=${Config.key}&consumer_secret=${Config.secret}';
    try {
      var response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          for (var customer in data) {
            // Check username or billing phone
            if (customer['username'] == phone || 
                (customer['billing'] != null && customer['billing']['phone'] == phone)) {
              return customer['id'];
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching customer by phone: $e");
      }
    }
    return null;
  }

  Future<bool> createCustomer(CustomerModel model) async {
    final prefs = await SharedPreferences.getInstance();

    var authToken = base64Encode(
      utf8.encode('${Config.key}:${Config.secret}'),
    );
    bool ret = false;
    try {
      var response = await Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      ).post(
        Config.url + Config.customerURL,
        data: model.toJson(),
        options: Options(headers: {HttpHeaders.authorizationHeader: 'Basic $authToken', HttpHeaders.contentTypeHeader: 'application/json'}),
      );
      if (response.statusCode == 201) {
        ret = true;
        await prefs.setInt('customerId', response.data['id']);
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print("Error creating customer: $e");
      }
      ret = false;
    }
    return ret;
  }

  Future<bool> loginCustomer(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Clear old session
    await prefs.remove('customerId');
    await prefs.remove('token');

    bool ret = false;

    try {
      var response = await Dio().post(Config.tokenURL,
          data: {
            'username': email,
            'password': password,
          },
          options: Options(headers: {HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'}));

      if (response.statusCode == 200) {
        await prefs.setInt('customerId', response.data['data']['id']);
        await prefs.setString('token', response.data['data']['token'].toString());

        ret = true;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        ret = false;
      } else {
        ret = false;
      }
    }
    return ret;
  }

  Future<bool> forgetPassword(String email) async {
    bool ret = false;
    try {
      var response = await Dio().post(
        Config.url + 'customers/reset_password',
        data: {'email': email},
      );
      if (response.statusCode == 200) {
        ret = true;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        ret = false;
      } else {
        ret = false;
      }
    }
    return ret;
  }

  Future<List<CategoryModel>> getCategory() async {
    List<CategoryModel> category = [];
    String url = '${Config.url}${Config.categoryURL}?consumer_key=${Config.key}&consumer_secret=${Config.secret}&per_page=100';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (Map i in data) {
          category.add(CategoryModel.fromJson(i));
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return category;
  }

  Future<List<ProductModel>> getProductOfCategory(int categoryId) async {
    List<ProductModel> productsOfCategory = [];
    String url = '${Config.url}${Config.productsURL}?category=$categoryId&consumer_key=${Config.key}&consumer_secret=${Config.secret}&per_page=100';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (Map i in data) {
          productsOfCategory.add(ProductModel.fromJson(i));
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return productsOfCategory;
  }

  Future<SingleProductModel> getSingleProduct(int productId) async {
    String url = '${Config.url}${Config.singleProductsURL}$productId?consumer_key=${Config.key}&consumer_secret=${Config.secret}';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SingleProductModel.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return SingleProductModel(); 
  }

  Future<List<SingleProductVariations>> getSingleProductVariation(int productID) async {
    List<SingleProductVariations> productVariation = [];
    String url = '${Config.url}products/$productID/variations?consumer_key=${Config.key}&consumer_secret=${Config.secret}&per_page=50';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (Map i in data) {
          productVariation.add(SingleProductVariations.fromJson(i));
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return productVariation;
  }

  Future<bool> createOrder(
    RetrieveCustomer retrieveCustomer,
    List<order_create.LineItems> lineItems,
    String paymentName,
    bool setPaid,
    List<order_create.CouponLines> coupons,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final int? customerId = prefs.getInt('customerId');
    var authToken = base64Encode(
      utf8.encode('${Config.key}:${Config.secret}'),
    );
    bool ret = false;
    try {
      var response = await Dio().post(
        Config.url + Config.createOrderUrl,
        data: {
          "payment_method": paymentName,
          "payment_method_title": paymentName,
          "customer_id": customerId,
          "set_paid": setPaid,
          "billing": {"phone": retrieveCustomer.billing!.phone},
          "shipping": retrieveCustomer.shipping,
          "line_items": lineItems,
          "coupon_lines": coupons
        },
        options: Options(headers: {
          HttpHeaders.authorizationHeader: 'Basic $authToken',
          HttpHeaders.contentTypeHeader: 'application/json',
        }),
      );
      if (response.statusCode == 201) {
        ret = true;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        ret = false;
      } else {
        ret = false;
      }
    }
    return ret;
  }

  Future<RetrieveCustomer> getCustomerDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final int? customerId = prefs.getInt('customerId');

    String url = '${Config.url}${Config.customerDetails}$customerId?consumer_key=${Config.key}&consumer_secret=${Config.secret}';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RetrieveCustomer.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return RetrieveCustomer();
  }

  Future<bool> updateShippingAddress(RetrieveCustomer retrieveCustomer) async {
    final prefs = await SharedPreferences.getInstance();
    final int? customerId = prefs.getInt('customerId');
    String url = '${Config.url}${Config.customerDetails}$customerId';
    var authToken = base64Encode(
      utf8.encode('${Config.key}:${Config.secret}'),
    );
    bool ret = false;
    try {
      var response = await Dio().put(
        url,
        data: {
          "first_name": retrieveCustomer.shipping!.firstName,
          "last_name": retrieveCustomer.shipping!.lastName,
          "billing": {
            "phone": retrieveCustomer.billing?.phone,
          },
          "shipping": {
            "first_name": retrieveCustomer.shipping!.firstName,
            "last_name": retrieveCustomer.shipping!.lastName,
            "address_1": retrieveCustomer.shipping!.address1,
            "address_2": retrieveCustomer.shipping!.address2,
            "city": retrieveCustomer.shipping!.city,
            "state": retrieveCustomer.shipping!.state,
            "postcode": retrieveCustomer.shipping!.postcode,
            "country": retrieveCustomer.shipping!.country
          }
        },
        options: Options(headers: {
          HttpHeaders.authorizationHeader: 'Basic $authToken',
          HttpHeaders.contentTypeHeader: 'application/json',
        }),
      );
      if (response.statusCode == 200) {
        ret = true;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        ret = false;
      } else {
        ret = false;
      }
    }
    return ret;
  }

  // Generic method to update both addresses or individually
  Future<bool> updateAddress(RetrieveCustomer retrieveCustomer) async {
    final prefs = await SharedPreferences.getInstance();
    final int? customerId = prefs.getInt('customerId');
    String url = '${Config.url}${Config.customerDetails}$customerId';
    var authToken = base64Encode(
      utf8.encode('${Config.key}:${Config.secret}'),
    );
    bool ret = false;
    
    // Construct the data map dynamically
    Map<String, dynamic> data = {};
    
    if (retrieveCustomer.billing != null) {
      data['billing'] = {
        "first_name": retrieveCustomer.billing!.firstName,
        "last_name": retrieveCustomer.billing!.lastName,
        "address_1": retrieveCustomer.billing!.address1,
        "address_2": retrieveCustomer.billing!.address2,
        "city": retrieveCustomer.billing!.city,
        "state": retrieveCustomer.billing!.state,
        "postcode": retrieveCustomer.billing!.postcode,
        "country": retrieveCustomer.billing!.country,
        "email": retrieveCustomer.billing!.email,
        "phone": retrieveCustomer.billing!.phone,
      };
    }
    
    if (retrieveCustomer.shipping != null) {
      data['shipping'] = {
        "first_name": retrieveCustomer.shipping!.firstName,
        "last_name": retrieveCustomer.shipping!.lastName,
        "address_1": retrieveCustomer.shipping!.address1,
        "address_2": retrieveCustomer.shipping!.address2,
        "city": retrieveCustomer.shipping!.city,
        "state": retrieveCustomer.shipping!.state,
        "postcode": retrieveCustomer.shipping!.postcode,
        "country": retrieveCustomer.shipping!.country,
        "phone": retrieveCustomer.shipping!.phone // Some implementations put phone in shipping too
      };
    }

    // Ensure we have at least something to update
    if (data.isEmpty) return false;

    try {
      var response = await Dio().put(
        url,
        data: data,
        options: Options(headers: {
          HttpHeaders.authorizationHeader: 'Basic $authToken',
          HttpHeaders.contentTypeHeader: 'application/json',
        }),
      );
      if (response.statusCode == 200) {
        ret = true;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        ret = false;
      } else {
        ret = false;
      }
    }
    return ret;
  }

  Future<Map<String, dynamic>?> uploadMedia(File file) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    String url = '${Config.websiteURL}wp-json/wp/v2/media';

    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      Options options = Options(
        headers: {
          HttpHeaders.contentTypeHeader: 'multipart/form-data',
        },
      );

      if (token != null) {
        options.headers![HttpHeaders.authorizationHeader] = 'Bearer $token';
      } else {
         var authToken = base64Encode(utf8.encode('${Config.key}:${Config.secret}'));
         options.headers![HttpHeaders.authorizationHeader] = 'Basic $authToken';
      }

      var response = await Dio().post(
        url,
        data: formData,
        options: options,
      );

      if (response.statusCode == 201) {
        return response.data;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return null;
  }

  Future<bool> updateProfile(RetrieveCustomer retrieveCustomer, String phoneNumber, {File? image}) async {
    final prefs = await SharedPreferences.getInstance();
    final int? customerId = prefs.getInt('customerId');
    String url = '${Config.url}${Config.customerDetails}$customerId';
    var authToken = base64Encode(
      utf8.encode('${Config.key}:${Config.secret}'),
    );

    Map<String, dynamic>? uploadResponse;
    if (image != null) {
      uploadResponse = await uploadMedia(image);
    }

    bool ret = false;
    try {
      Map<String, dynamic> data = {
        "first_name": retrieveCustomer.firstName,
        "last_name": retrieveCustomer.lastName,
        "email": retrieveCustomer.email,
        "billing": {
          "phone": phoneNumber,
        }
      };

      if (uploadResponse != null) {
        String imageUrl = uploadResponse['source_url'];
        int imageId = uploadResponse['id'];

        data['avatar_url'] = imageUrl;
        data['meta_data'] = [
          {"key": "avatar_url", "value": imageUrl},
          {"key": "profile_pic_url", "value": imageUrl},
          {"key": "wp_user_avatar", "value": imageId},
          {"key": "_wp_user_avatar", "value": imageId},
        ];
      }

      var response = await Dio().put(
        url,
        data: data,
        options: Options(headers: {
          HttpHeaders.authorizationHeader: 'Basic $authToken',
          HttpHeaders.contentTypeHeader: 'application/json',
        }),
      );
      if (response.statusCode == 200) {
        ret = true;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        ret = false;
      } else {
        ret = false;
      }
    }
    return ret;
  }

  Future<bool> changePassword(String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final int? customerId = prefs.getInt('customerId');
    if (customerId == null) return false;

    String url = '${Config.url}${Config.customerDetails}$customerId';
    var authToken = base64Encode(
      utf8.encode('${Config.key}:${Config.secret}'),
    );

    bool ret = false;
    try {
      var response = await Dio().put(
        url,
        data: {
          "password": newPassword,
        },
        options: Options(headers: {
          HttpHeaders.authorizationHeader: 'Basic $authToken',
          HttpHeaders.contentTypeHeader: 'application/json',
        }),
      );
      if (response.statusCode == 200) {
        ret = true;
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print("Error changing password: $e");
      }
      ret = false;
    }
    return ret;
  }

  Future<List<ListOfOrders>> getListOfOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final int? customerId = prefs.getInt('customerId');

    List<ListOfOrders>? listOfOrders = [];

    String url = '${Config.url}orders?consumer_key=${Config.key}&consumer_secret=${Config.secret}';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (Map i in data) {
          if (i['customer_id'] == customerId) {
            listOfOrders.add(ListOfOrders.fromJson(i));
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return listOfOrders ?? [];
  }

  Future<RetrieveAnOrder> getAnOrder(int id) async {
    String url = '${Config.url}${Config.anOrderUrl}$id?consumer_key=${Config.key}&consumer_secret=${Config.secret}';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RetrieveAnOrder.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return RetrieveAnOrder();
  }

  Future<bool> updateOrder(int orderId, String reason) async {
    String url = '${Config.url}${Config.anOrderUrl}$orderId';
    var authToken = base64Encode(
      utf8.encode('${Config.key}:${Config.secret}'),
    );
    bool ret = false;
    try {
      var response = await Dio().put(
        url,
        data: {
          "status": "cancelled",
          "customer_note": reason,
        },
        options: Options(headers: {
          HttpHeaders.authorizationHeader: 'Basic $authToken',
          HttpHeaders.contentTypeHeader: 'application/json',
        }),
      );
      if (response.statusCode == 200) {
        ret = true;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        ret = false;
      } else {
        ret = false;
      }
    }
    return ret;
  }

  Future<List<ProductModel>> getProductBySearch(String name) async {
    List<ProductModel> products = [];
    String url = '${Config.url}${Config.productsURL}?search=$name&consumer_key=${Config.key}&consumer_secret=${Config.secret}';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (Map i in data) {
          products.add(ProductModel.fromJson(i));
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return products;
  }

  Future<double> retrieveCoupon(String couponCode, double totalAmount) async {
    RetrieveCoupon coupons = RetrieveCoupon();
    double amount = 0;
    String url = '${Config.url}${Config.coupons}?consumer_key=${Config.key}&consumer_secret=${Config.secret}&code=$couponCode';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (Map i in data) {
          coupons = RetrieveCoupon.fromJson(i);
        }
        if (coupons.discountType == 'percent') {
          amount = ((totalAmount * double.parse(coupons.amount.toString()) / 100));
        } else if (coupons.discountType == 'fixed_cart') {
          amount = double.parse(coupons.amount.toString());
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return amount;
  }

  Future<List<Banner>> getBanner() async {
    List<Banner> banner = [];
    String url = '${Config.websiteURL}wp-json/wp/v2/media?search=banner&per_page=100';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (Map i in data) {
          banner.add(Banner.fromJson(i));
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return banner;
  }

  Future<List<RetrieveCoupon>> retrieveAllCoupon() async {
    List<RetrieveCoupon> coupons = [];
    String url = '${Config.url}${Config.coupons}?consumer_key=${Config.key}&consumer_secret=${Config.secret}';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (Map i in data) {
          coupons.add(RetrieveCoupon.fromJson(i));
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return coupons;
  }

  Future<bool> createReview(String review, int rating, int productId, String reviewer, String reviewerEmail) async {
    var authToken = base64Encode(
      utf8.encode('${Config.key}:${Config.secret}'),
    );
    bool ret = false;
    try {
      var response = await Dio().post(
        Config.url + Config.createReviewUrl,
        data: {
          "product_id": productId,
          "review": review,
          "reviewer": reviewer,
          "reviewer_email": reviewerEmail,
          "rating": rating,
        },
        options: Options(headers: {
          HttpHeaders.authorizationHeader: 'Basic $authToken',
          HttpHeaders.contentTypeHeader: 'application/json',
        }),
      );
      if (response.statusCode == 201) {
        ret = true;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        ret = false;
      } else {
        ret = false;
      }
    }
    return ret;
  }

  Future<List<ProductReviewModel>> getRetrieveAllReview(int productId) async {
    List<ProductReviewModel> review = [];
    String url = '${Config.url}${Config.createReviewUrl}?consumer_key=${Config.key}&consumer_secret=${Config.secret}&product=$productId';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (Map i in data) {
          review.add(ProductReviewModel.fromJson(i));
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return review;
  }

  Future<void> sentOtp(String phoneNumber, BuildContext context, {int? forceResendingToken}) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: forceResendingToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        const Home().launch(context, isNewTask: true);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (kDebugMode) {
          print("Verification Failed: ${e.code} - ${e.message}");
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Verification Failed: ${e.message}")));
      },
      codeSent: (String verificationId, int? resendToken) {
        OtpVerificationScreen(
          verificationId: verificationId,
          phoneNumber: phoneNumber,
          resendToken: resendToken,
        ).launch(context);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> verifyOtp(String verificationId, String otp, BuildContext context) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otp);
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Checking account status...")));

        final prefs = await SharedPreferences.getInstance();
        
        // Clear previous session data just in case
        await prefs.remove('customerId');
        await prefs.remove('token');

        // Generate a unique identifier for the backend based on phone number
        String phoneNumber = user.phoneNumber ?? '';
        String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\w]'), ''); 
        
        // Try searching with clean phone
        int? customerId = await getCustomerIdByPhone(cleanPhone);
        
        // If not found, try raw phone if different
        if (customerId == null && phoneNumber != cleanPhone) {
           customerId = await getCustomerIdByPhone(phoneNumber);
        }

        if (customerId != null) {
          await prefs.setInt('customerId', customerId);
           if (context.mounted) {
             const Home().launch(context, isNewTask: true);
           }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User not found. Please register.")));
            SignUp(phoneNumber: phoneNumber).launch(context);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("OTP Verification Error: $e");
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid OTP or Verification Failed")));
      }
    }
  }
}
