import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:maanstore/const/constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../Providers/language_change_provider.dart';
import '../generated/l10n.dart' as lang;
import '../widgets/buttons.dart';
import 'Theme/theme.dart';
import 'home_screens/home.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  Future<void> saveData(bool data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRtl', data);
  }

  List<String> languageList = [
    'English',
    'Hindi',
    'Kannada',
    'Marathi',
    'Tamil',
  ];
  String isSelected = 'English';

  List<String> baseFlagsCode = [
    'us',
    'in',
    'IN',
    'IN',
    'IN',
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
          child: Button1(
            buttonColor: const Color(0xFFFF7F00),
            buttonText: lang.S.of(context).saveButton,
            onPressFunction: () {
              saveData(!isRtl && isRtl);
              const Home().launch(context, isNewTask: true);
            },
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: GestureDetector(
            onTap: () {
              const Home().launch(context, isNewTask: true);
            },
            child:  Icon(
              Icons.arrow_back,
              color: isDark ? darkTitleColor : lightTitleColor,
            ),
          ),
          title: MyGoogleText(
            text: lang.S.of(context).language,
            fontColor: isDark ? darkTitleColor : lightTitleColor,
            fontWeight: FontWeight.normal,
            fontSize: 20,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: languageList.length,
                  itemBuilder: (_, i) {
                    return ListTile(
                      onTap: () {
                        setState(() {
                          isSelected = languageList[i];
                          if(isSelected == 'Hindi'){
                            context.read<LanguageChangeProvider>().changeLocale("hi");
                          } else if (isSelected == 'Kannada'){
                            context.read<LanguageChangeProvider>().changeLocale("kn");
                          } else if (isSelected == 'Marathi'){
                            context.read<LanguageChangeProvider>().changeLocale("mr");
                          } else if (isSelected == 'Tamil'){
                            context.read<LanguageChangeProvider>().changeLocale("ta");
                          } else {
                            context.read<LanguageChangeProvider>().changeLocale("en");
                          }
                          
                          isSelected == 'Arabic' ? isRtl = true : isRtl = false;
                        });
                      },
                      title: Row(
                        children: [
                          SizedBox(
                            height: 20,
                            width: 25,
                            child: Flag.fromString(
                              baseFlagsCode[i],
                            ),
                          ),
                          const SizedBox(width: 20.0),
                          Expanded(
                            child: Text(
                              languageList[i],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      trailing: isSelected == languageList[i]
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFFFF7F00),
                            )
                          : const Icon(
                              Icons.circle_outlined,
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
