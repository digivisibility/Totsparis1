import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:maanstore/api_service/api_service.dart';
import 'package:maanstore/models/wishlist_model.dart';
import 'package:maanstore/screens/product_details_screen/product_detail_screen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../const/constants.dart';
import '../models/product_model.dart';
import '../Providers/wishlist_provider.dart';
import 'home_screens/home.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  APIService? apiService;

  @override
  void initState() {
    apiService = APIService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final wishList = ref.watch(wishlistProvider);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: GestureDetector(
          onTap: () {
             if(Navigator.canPop(context)){
                 Navigator.pop(context);
             } else {
                 const Home().launch(context);
             }
          },
          child: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: MyGoogleText(
          text: 'Wishlist (${wishList.length})',
          fontColor: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.normal,
          fontSize: 18,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: TextButton(
              onPressed: () {
                  ref.read(wishlistProvider.notifier).clearWishlist();
              },
              child: const MyGoogleText(
                text: 'Delete All',
                fontColor: secondaryColor1,
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            wishList.isEmpty 
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100),
                    const Icon(IconlyLight.heart, size: 100, color: Colors.grey),
                    const SizedBox(height: 20),
                    Text("Your wishlist is empty", style: GoogleFonts.dmSans(fontSize: 18, color: Colors.grey)),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(10),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: wishList.length,
                itemBuilder: (context, index) {
                   final item = wishList[index];
                   return Stack(
                      children: [
                        Container(
                           decoration: BoxDecoration(
                              color: isDark ? cardColor : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.withOpacity(0.2)),
                           ),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Expanded(
                                 child: GestureDetector(
                                   onTap: () async {
                                      try {
                                          final singleProduct = await apiService!.getSingleProduct(item.id!);
                                          final productModel = ProductModel.fromJson(singleProduct.toJson());
                                          
                                          ProductDetailScreen(
                                            productModel: productModel,
                                            categoryId: item.categoryId ?? 0,
                                          ).launch(context);
                                      } catch (e) {
                                        toast('Could not load product details');
                                      }
                                   },
                                   child: Container(
                                     decoration: BoxDecoration(
                                       borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                       image: DecorationImage(
                                         image: NetworkImage(item.img ?? ''),
                                         fit: BoxFit.cover,
                                       ),
                                     ),
                                   ),
                                 ),
                               ),
                               Padding(
                                 padding: const EdgeInsets.all(8.0),
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                       item.name ?? '',
                                       maxLines: 1,
                                       overflow: TextOverflow.ellipsis,
                                       style: GoogleFonts.dmSans(
                                         fontSize: 14,
                                         fontWeight: FontWeight.bold,
                                         color: isDark ? Colors.white : Colors.black,
                                       ),
                                     ),
                                     const SizedBox(height: 5),
                                     Text(
                                       '₹${item.price}',
                                       style: GoogleFonts.dmSans(
                                         fontSize: 14,
                                         fontWeight: FontWeight.normal,
                                         color: isDark ? Colors.white : Colors.black,
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                        ),
                        Positioned(
                          right: 5,
                          top: 5,
                          child: GestureDetector(
                            onTap: (){
                               ref.read(wishlistProvider.notifier).removeWishlist(item.id!);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(Icons.delete, color: Colors.red, size: 20),
                            ),
                          ),
                        ),
                      ],
                   );
                },
            ),
          ],
        ),
      ),
    );
  }
}
