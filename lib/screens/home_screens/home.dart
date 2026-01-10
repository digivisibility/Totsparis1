import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:maanstore/generated/l10n.dart' as lang;
import 'package:maanstore/screens/order_screen/my_order.dart';
import 'package:maanstore/screens/profile_screen/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../const/constants.dart';
import '../../main.dart';
import '../../models/add_to_cart_model.dart';
import '../../models/wishlist_model.dart';
import '../../Providers/wishlist_provider.dart';
import '../auth_screen/auth_screen_1.dart';
import '../cart_screen/cart_screen.dart';
import '../search_product_screen.dart';
import '../wishlist_screen.dart';
import 'home_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  int customerId = 0;
  int cartItems = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> checkId() async {
    final prefs = await SharedPreferences.getInstance();
    customerId = prefs.getInt('customerId') ?? 0;
    if(mounted){
      setState(() {});
    }
  }
  
  @override
  void initState() {
    checkId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Directionality(
      textDirection:isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Consumer(
        builder: (_, ref, child) {
          final cart = ref.watch(cartNotifier);
          final wishlist = ref.watch(wishlistProvider);
          cartItems = cart.cartItems.length;
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            resizeToAvoidBottomInset: false,
            body: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop,result) async {
                await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title:  Text('Are you sure?',style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600,color: isDark?Colors.white:titleColors),),
                    content:  Text('Do you want to exit the app?',style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark?Colors.white:titleColors),),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        // onPressed: () => Navigator.of(context).pop(true),
                        onPressed: (){
                          SystemNavigator.pop();
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                );
              },
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  const HomeScreen(),
                  const SearchProductScreen(),
                  const WishlistScreen(),
                  const CartScreen(),
                  customerId != 0 ? const MyOrderScreen() : const AuthScreen(),
                  customerId != 0 ? const ProfileScreen() : const AuthScreen(),
                ],
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
              type: BottomNavigationBarType.fixed,
              elevation: 10,
              items:  <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: const Icon(IconlyLight.home),
                    label:lang.S.of(context).home
                ),
                BottomNavigationBarItem(
                  icon: const Icon(IconlyLight.search),
                  label: lang.S.of(context).search,
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    isLabelVisible: wishlist.isNotEmpty,
                    label: Text('${wishlist.length}'),
                    child: const Icon(IconlyLight.heart),
                  ),
                  label: "Wishlist",
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                      isLabelVisible: cart.cartOtherInfoList.isNotEmpty,
                      label: Text('${cart.cartOtherInfoList.length}'),
                      child: const Icon(IconlyLight.bag)),
                  label: lang.S.of(context).cart,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(IconlyLight.document),
                  label: lang.S.of(context).orders,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(IconlyLight.profile),
                  label: lang.S.of(context).profile,
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: kPrimaryColor,
              unselectedItemColor: textColors,
              unselectedLabelStyle: const TextStyle(color: textColors),
              onTap: _onItemTapped,
            ),
          );
        },
      ));
  }
}
