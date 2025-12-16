import 'package:flutter/material.dart';
import 'package:maanstore/api_service/api_service.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../const/constants.dart';
import '../../widgets/buttons.dart';
import '../Theme/theme.dart';

class OtpAuthScreen extends StatefulWidget {
  const OtpAuthScreen({super.key});

  @override
  _OtpAuthScreenState createState() => _OtpAuthScreenState();
}

class _OtpAuthScreenState extends State<OtpAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final APIService _apiService = APIService();
  bool _isLoading = false;

  void _sendOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      String phoneNumber = '+91${_phoneController.text}';
      try {
        await _apiService.sentOtp(phoneNumber, context);
      } catch (e) {
        toast("Failed to send OTP: $e");
      }
      if (mounted) {
         setState(() {
          _isLoading = false;
        });
      }
    }
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
          children: [
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     MyGoogleText(
                      fontSize: 24,
                      fontColor: isDark ? darkTitleColor : lightTitleColor,
                      text: 'Login with Phone',
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 10),
                    MyGoogleText(
                      fontSize: 16,
                      fontColor: isDark ? darkGreyTextColor : lightGreyTextColor,
                      text: 'Enter your phone number to continue',
                      fontWeight: FontWeight.normal,
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Enter 10 digit number',
                        border: const OutlineInputBorder(),
                        prefixText: '+91 ',
                         enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: isDark ? const Color(0xff555671) : Colors.black, width: 1),
                          ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length != 10) {
                          return 'Phone number must be 10 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    Button1(
                      buttonText: _isLoading ? 'Sending...' : 'Send OTP',
                      buttonColor: kPrimaryColor,
                      onPressFunction: _isLoading ? null : _sendOtp,
                    ),
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
