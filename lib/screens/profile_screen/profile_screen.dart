import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maanstore/api_service/api_service.dart';
import 'package:maanstore/screens/profile_screen/settings_screen.dart';
import 'package:maanstore/screens/search_product_screen.dart';
import 'package:maanstore/screens/notification_screen/notificition_screen.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../Providers/all_repo_providers.dart';
import '../../widgets/profile_shimmer_widget.dart';
import '../Theme/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    } catch (e) {}

    return Consumer(builder: (context, ref, __) {
      final customerDetails = ref.watch(getCustomerDetails);

      return Scaffold(
        backgroundColor: isDark ? Colors.black : const Color(0xffF1F2F6),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          automaticallyImplyLeading: false, // Don't show back button on tab
          title: Text(
            "Profile",
            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SearchProductScreen()));
              },
            ),
             IconButton(
              icon: Icon(Icons.notifications, color: isDark ? Colors.white : Colors.black),
              onPressed: () {
                 Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NotificationsScreen()));
              },
            ),
          ],
        ),
        body: customerDetails.when(
          data: (snapShot) {
            String name = "User";
            String email = "";
            String avatarUrl = "";

            if (snapShot.firstName != null) {
              name = "${snapShot.firstName} ${snapShot.lastName ?? ''}";
            }
            if (snapShot.email != null) {
              email = snapShot.email!;
            }
            if (snapShot.avatarUrl != null) {
              avatarUrl = snapShot.avatarUrl!;
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Profile Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                          image: avatarUrl.isNotEmpty
                              ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                              : const DecorationImage(image: AssetImage('images/profile_image.png'), fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              email,
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Link to Settings
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: const Icon(Icons.settings, color: Colors.black, size: 28),
                    title: const Text(
                      "Settings", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)
                    ),
                    subtitle: const Text("Profile, Address, Orders, App Settings"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                    onTap: () {
                      const SettingsScreen().launch(context);
                    },
                  ),
                ),
              ],
            );
          },
          error: (e, stack) => Center(child: Text("Error: $e")),
          loading: () => const ProfileShimmerWidget(),
        ),
      );
    });
  }
}
