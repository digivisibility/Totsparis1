import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:maanstore/api_service/api_service.dart';
import 'package:maanstore/generated/l10n.dart' as lang;
import 'package:maanstore/screens/auth_screen/change_pass_screen.dart';
import 'package:maanstore/screens/notification_screen/notificition_screen.dart';
import 'package:maanstore/screens/order_screen/my_order.dart';
import 'package:maanstore/screens/order_screen/shipping_address.dart';
import 'package:maanstore/screens/splash_screen/splash_screen_one.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../Providers/all_repo_providers.dart';
import '../../const/constants.dart';
import '../../const/hardcoded_text.dart';
import '../Theme/theme.dart';
import '../language_screen.dart';
import 'my_profile_screen.dart';
import 'package:maanstore/screens/wishlist_screen.dart'; 
import '../../models/add_to_cart_model.dart';
import '../../Providers/wishlist_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local theme manager instance to avoid compilation errors if global one is missing
  final ThemeManager _themeManager = ThemeManager();
  APIService? apiService;

  @override
  void initState() {
    apiService = APIService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = false;
    try {
      isDark = Theme.of(context).brightness == Brightness.dark;
    } catch (e) {
      // ignore
    }

    return Consumer(builder: (context, ref, __) {
      final customerDetails = ref.watch(getCustomerDetails);

      return Scaffold(
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
          title: Text(
            "Settings",
            style: TextStyle(color: isDark ? darkTitleColor : lightTitleColor, fontSize: 20),
          ),
        ),
        body: customerDetails.when(
          data: (snapShot) {
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _buildSectionHeader("Account"),
                _buildSettingTile(
                  icon: Icons.person_outline,
                  title: lang.S.of(context).myProfile,
                  onTap: () => MyProfileScreen(retrieveCustomer: snapShot).launch(context),
                ),
                _buildSettingTile(
                  icon: Icons.location_on_outlined,
                  title: "Address",
                  onTap: () => const ShippingAddress().launch(context),
                ),
                _buildSettingTile(
                  icon: Icons.favorite_border,
                  title: "Wishlist",
                  onTap: () => const WishlistScreen().launch(context),
                ),
                _buildSettingTile(
                  icon: Icons.lock_outline,
                  title: HardcodedTextEng.changePassword,
                  onTap: () => const ChangePassScreen().launch(context),
                ),

                const SizedBox(height: 20),
                _buildSectionHeader("General"),
                _buildSettingTile(
                  icon: IconlyLight.document,
                  title: lang.S.of(context).myOrderScreenName,
                  onTap: () => const MyOrderScreen().launch(context),
                ),
                _buildSettingTile(
                  icon: IconlyLight.notification,
                  title: "Notification",
                  onTap: () => const NotificationsScreen().launch(context),
                ),
                _buildSettingTile(
                  icon: CommunityMaterialIcons.translate,
                  title: lang.S.of(context).language,
                  onTap: () => const LanguageScreen().launch(context),
                ),
                ListTile(
                  leading: Icon(Icons.dark_mode_outlined, color: isDark ? Colors.white : Colors.black),
                  title: Text("Dark Theme", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                  trailing: Switch(
                    value: isDark, 
                    onChanged: (val) async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        val ? await prefs.setString('theme', 'dark') : await prefs.setString('theme', 'light');
                        // Note: This only affects local instance if global is not hooked up, but prevents crash
                        setState(() {
                          _themeManager.toggleTheme(val);
                        });
                    }
                  ),
                ),

                const SizedBox(height: 20),
                _buildSectionHeader("Support"),
                _buildSettingTile(
                  icon: IconlyLight.danger,
                  title: "Help & Info",
                  onTap: () {},
                ),
                _buildSettingTile(
                  icon: IconlyLight.logout,
                  title: lang.S.of(context).signOut,
                  onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('customerId');
                      await prefs.remove('token');
                      await apiService?.signOut();
                      
                      ref.invalidate(getCustomerDetails);
                      ref.invalidate(getOrders);
                      ref.read(cartNotifier.notifier).clearCart();
                      ref.read(wishlistProvider.notifier).clearWishlist();
                      
                      if (!mounted) return;
                      const SplashScreenOne().launch(context, isNewTask: true);
                  },
                ),
              ],
            );
          },
          error: (e, stack) => Center(child: Text("Error: $e")),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingTile({required IconData icon, required String title, required VoidCallback onTap}) {
    // Get theme again for local usage
    bool isDark = false;
    try {
      isDark = Theme.of(context).brightness == Brightness.dark;
    } catch (e) {}

    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.white : Colors.black),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.grey : Colors.grey),
      onTap: onTap,
    );
  }
}
