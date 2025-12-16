import 'dart:ui';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:maanstore/api_service/api_service.dart';
import 'package:maanstore/generated/l10n.dart' as lang;
import 'package:maanstore/main.dart';
import 'package:maanstore/screens/Theme/theme.dart';
import 'package:maanstore/screens/category_screen/category_screen.dart';
import 'package:maanstore/screens/category_screen/single_category_screen.dart';
import 'package:maanstore/screens/product_details_screen/product_detail_screen.dart';
import 'package:maanstore/screens/search_product_screen.dart';
import 'package:maanstore/widgets/banner_shimmer_widget.dart';
import 'package:maanstore/widgets/product_shimmer_widget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

import '../../Providers/all_repo_providers.dart';
import '../../const/constants.dart';
import '../../const/hardcoded_text.dart';
import '../../models/category_model.dart';
import '../../widgets/product_greed_view_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late APIService apiService;
  String? name;
  String? url;

  // Future<void> initMessaging() async {
  //   await OneSignal.shared.setAppId(oneSignalAppId);
  //   OneSignal.shared.setInAppMessageClickedHandler((action) {
  //     if (action.clickName == 'successPage') {
  //       toast(lang.S.of(context).easyLoadingSuccess);
  //     }
  //   });
  // }

  @override
  void initState() {
    apiService = APIService();
    // initMessaging();
    super.initState();
  }

  int price = 0;

  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 7200;
  DateTime time = DateTime.now();
  bool isLoaded = false;

  List<String> exclusiveImage = ['images/girl.png', 'images/cosmetics.png', 'images/man.png', 'images/kid.png'];
  List<String> exclusiveName = ['Women', 'Cosmetics', 'Men', 'Kids'];
  bool isSearch = true;

  int count = 7;
  bool showmore = false;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Consumer(builder: (_, ref, __) {
        final newProduct = ref.watch(getProductOfSingleCategory(newArrive));
        final bestSellingProducts = ref.watch(getProductOfSingleCategory(bestSellingId));
        final trendingProducts = ref.watch(getProductOfSingleCategory(trendingProductsId));
        final recommendedProducts = ref.watch(getProductOfSingleCategory(recommendedProductId));
        final specialOffers = ref.watch(getProductOfSingleCategory(specialOffersID));
        final allCategory = ref.watch(getAllCategories);
        final allBanner = ref.watch(getBanner);
        final allCoupons = ref.watch(getCoupon);

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            titleSpacing: 0.0,
            leading: Padding(
              padding: const EdgeInsets.all(4),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(0),
                      ),
                      image: DecorationImage(image: AssetImage('images/lead.png'))),
                ),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchProductScreen()));
                },
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.primaryContainer,
                    prefixIcon: Icon(
                      IconlyLight.search,
                      color: isDark ? darkGreyTextColor : lightGreyTextColor,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: primaryColor), borderRadius: BorderRadius.circular(30)),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: primaryColor), borderRadius: BorderRadius.circular(30)),
                    hintText: 'Search...',
                    hintStyle: kTextStyle.copyWith(color: isDark ? darkGreyTextColor : lightGreyTextColor)),
              ),
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.all(6.0),
                child: SwitchButton(),
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                /// Build Horizontal List widget without giving specific height to it.
                // Padding(
                //   padding: const EdgeInsets.all(15.0),
                //   child: allBanner.when(data: (snapShot) {
                //     return ImageSlideshow(
                //         width: double.infinity,
                //         indicatorBackgroundColor: primaryColor.withOpacity(0.5),
                //         indicatorRadius: 4,
                //         isLoop: true,
                //         autoPlayInterval: 3000,
                //         indicatorColor: primaryColor,
                //         children: List.generate(snapShot.length, (index) {
                //           return Container(
                //             height: 252,
                //             width: double.infinity,
                //             decoration: BoxDecoration(
                //               borderRadius: BorderRadius.circular(10),
                //               image: DecorationImage(
                //                 fit: BoxFit.cover,
                //                 image: NetworkImage(
                //                   snapShot[index].guid!.rendered.toString(),
                //                 ),
                //               ),
                //             ),
                //           );
                //         }));
                //   }, error: (e, stack) {
                //     return Text(e.toString());
                //   }, loading: () {
                //     return const BannerShimmerWidget();
                //   }),
                // ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: allBanner.when(
                    data: (snapShot) {
                      if (snapShot.isEmpty) {
                        // Prevent integer division by zero
                        return Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: const DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(
                                'https://totsparis.com/banner/1.png',
                              ),
                            ),
                          ),
                        );
                      }
                      return ImageSlideshow(
                        width: double.infinity,
                        indicatorBackgroundColor: primaryColor.withOpacity(0.5),
                        indicatorRadius: 4,
                        isLoop: true,
                        autoPlayInterval: 3000,
                        indicatorColor: primaryColor,
                        children: List.generate(snapShot.length, (index) {
                          final imageUrl = snapShot[index].guid?.rendered;

                          return Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  imageUrl?.isNotEmpty == true
                                      ? imageUrl!
                                      : 'https://totsparis.com/banner/2.png',
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                    error: (e, stack) => Text(e.toString()),
                    loading: () => const BannerShimmerWidget(),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          ///___________Category__________________________________________
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      'images/bc.png',
                                      width: 140,
                                      color: isDark ? darkContainer : const Color(0xffF4EBFF),
                                    ),
                                    MyGoogleText(
                                      text: lang.S.of(context).categories,
                                      fontSize: 20,
                                      fontColor: isDark ? darkTitleColor : lightTitleColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    // TextButton(
                                    //   onPressed: () {
                                    //     const CategoryScreen().launch(context);
                                    //   },
                                    //   child: MyGoogleText(
                                    //     text: lang.S.of(context).showAll,
                                    //     fontSize: 13,
                                    //     fontColor: textColors,
                                    //     fontWeight: FontWeight.normal,
                                    //   ),
                                    // )
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                allCategory.when(data: (snapShot) {
                                  return Column(
                                    children: [
                                      _buildCategoryList(snapShot),
                                      const SizedBox(height: 10.0),
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Image.asset(
                                            'images/bc.png',
                                            width: 180,
                                            color: isDark ? darkContainer : const Color(0xffF4EBFF),
                                          ),
                                          Text(
                                            lang.S.of(context).exclusiveForYor,
                                            style: kTextStyle.copyWith(fontSize: 20, color: isDark ? darkTitleColor : lightTitleColor, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      _buildCategoryList2(snapShot),
                                      // StaggeredGrid.count(
                                      //   crossAxisCount: 2,
                                      //   mainAxisSpacing: 9,
                                      //   crossAxisSpacing: 9,
                                      //   children: [
                                      //     Container(
                                      //       height: 137,
                                      //       width: 179,
                                      //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      //       decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.cover, image: NetworkImage(snapShot[0].image?.src ?? ''))),
                                      //       child: Text(
                                      //         snapShot[0].name ?? '',
                                      //       ),
                                      //     ).onTap(() {
                                      //       SingleCategoryScreen(
                                      //         categoryId: snapShot[0].id!.toInt(),
                                      //         categoryName: snapShot[0].name.toString(),
                                      //         categoryList: snapShot,
                                      //         categoryModel: snapShot[0],
                                      //       ).launch(context);
                                      //     }),
                                      //     Container(
                                      //       height: 192,
                                      //       width: 179,
                                      //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      //       decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.cover, image: NetworkImage(snapShot[1].image?.src ?? ''))),
                                      //       child: Text(snapShot[1].name ?? ''),
                                      //     ).onTap(() {
                                      //       SingleCategoryScreen(
                                      //         categoryId: snapShot[1].id!.toInt(),
                                      //         categoryName: snapShot[1].name.toString(),
                                      //         categoryList: snapShot,
                                      //         categoryModel: snapShot[1],
                                      //       ).launch(context);
                                      //     }),
                                      //     Container(
                                      //       height: 137,
                                      //       width: 179,
                                      //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      //       decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.cover, image: NetworkImage(snapShot[2].image?.src ?? ''))),
                                      //       child: Text(snapShot[2].name ?? ''),
                                      //     ).onTap(() {
                                      //       SingleCategoryScreen(
                                      //         categoryId: snapShot[2].id!.toInt(),
                                      //         categoryName: snapShot[2].name.toString(),
                                      //         categoryList: snapShot,
                                      //         categoryModel: snapShot[2],
                                      //       ).launch(context);
                                      //     }),
                                      //     Container(
                                      //       height: 82,
                                      //       width: 179,
                                      //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      //       decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.cover, image: NetworkImage(snapShot[3].image?.src ?? ''))),
                                      //       child: Text(snapShot[3].name ?? ''),
                                      //     ).onTap(() {
                                      //       SingleCategoryScreen(
                                      //         categoryId: snapShot[3].id!.toInt(),
                                      //         categoryName: snapShot[3].name.toString(),
                                      //         categoryList: snapShot,
                                      //         categoryModel: snapShot[3],
                                      //       ).launch(context);
                                      //     }),
                                      //   ],
                                      // ),
                                    ],
                                  );
                                }, error: (e, stack) {
                                  return Text(e.toString());
                                }, loading: () {
                                  return Column(
                                    children: [
                                      HorizontalList(
                                          padding: EdgeInsets.zero,
                                          spacing: 10.0,
                                          itemCount: 5,
                                          itemBuilder: (_, i) {
                                            return Shimmer.fromColors(
                                                baseColor: Colors.grey.shade300,
                                                highlightColor: Colors.grey.shade100,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.only(left: 5.0, right: 10.0, top: 5.0, bottom: 5.0),
                                                      height: 60.0,
                                                      width: 60.0,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(50),
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8.0),
                                                    Container(
                                                      height: 12.0,
                                                      width: 60.0,
                                                      decoration: BoxDecoration(
                                                          color: black,
                                                          borderRadius: BorderRadius.circular(
                                                            30.0,
                                                          )),
                                                    ),
                                                  ],
                                                ));
                                          }),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),

                          ///-----------------Exclusive_for_you_____________________________
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                              children: [
                                ///___________Offers__________________________________________
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        lang.S.of(context).specialOffer,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: kTextStyle.copyWith(
                                          fontSize: 18,
                                          color: isDark ? darkTitleColor : lightTitleColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    ///____countDown_timer___________________________________
                                    CountdownTimer(
                                      endTime: endTime,
                                      widgetBuilder: (_, time) {
                                        if (time == null) {
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: Text(
                                              lang.S.of(context).closingTime,
                                            ),
                                          );
                                        }
                                        return Row(
                                          children: [
                                            MyGoogleText(
                                              text: lang.S.of(context).closingTime,
                                              fontSize: 13,
                                              fontColor: isDark ? darkGreyTextColor : lightGreyTextColor,
                                              fontWeight: FontWeight.normal,
                                            ),
                                            const SizedBox(width: 5),
                                            Container(
                                              height: 25,
                                              width: 25,
                                              decoration: const BoxDecoration(
                                                color: primaryColor,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                              ),
                                              child: Center(
                                                child: MyGoogleText(
                                                  text: time.hours.toString(),
                                                  fontSize: 14,
                                                  fontColor: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Container(
                                              height: 25,
                                              width: 25,
                                              decoration: const BoxDecoration(
                                                color: primaryColor,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                              ),
                                              child: Center(
                                                child: MyGoogleText(
                                                  text: time.min.toString(),
                                                  fontSize: 14,
                                                  fontColor: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Container(
                                              height: 25,
                                              width: 25,
                                              decoration: const BoxDecoration(
                                                color: primaryColor,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                              ),
                                              child: Center(
                                                child: MyGoogleText(
                                                  text: time.sec.toString(),
                                                  fontSize: 14,
                                                  fontColor: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                specialOffers.when(data: (snapShot) {
                                  return HorizontalList(
                                    itemCount: snapShot.length,
                                    spacing: 10,
                                    itemBuilder: (BuildContext context, int index) {
                                      final productVariation = ref.watch(getSingleProductVariation(snapShot[index].id!.toInt()));

                                      return productVariation.when(data: (snapData) {
                                        if (snapShot[index].type != 'simple' && snapData.isNotEmpty) {
                                          return GestureDetector(
                                            onTap: () {
                                              ProductDetailScreen(
                                                singleProductsVariation: snapData[index],
                                                productModel: snapShot[index],
                                                categoryId: specialOffersID,
                                              ).launch(context);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                color: isDark ? cardColor : Colors.transparent,
                                                border: Border.all(
                                                  width: 1,
                                                  color: isDark ? darkContainer : secondaryColor3,
                                                ),
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(8),
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    height: 100,
                                                    width: 128,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                          snapShot[index].images![0].src.toString(),
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ),
                                                      borderRadius: const BorderRadius.all(
                                                        Radius.circular(8),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: SizedBox(
                                                      width: 120,
                                                      child: Text(
                                                        snapShot[index].name.toString(),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: GoogleFonts.dmSans(color: isDark ? darkTitleColor : lightTitleColor),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 8),
                                                    child: MyGoogleText(
                                                      text: snapShot[index].type == 'simple' ? '\₹ ${snapShot[index].salePrice}' : '\₹ ${snapData[0].salePrice}',
                                                      fontSize: 14,
                                                      fontColor: isDark ? darkTitleColor : lightTitleColor,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        } else {
                                          return GestureDetector(
                                            onTap: () {
                                              ProductDetailScreen(
                                                productModel: snapShot[index],
                                                categoryId: specialOffersID,
                                              ).launch(context);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                border: Border.all(
                                                  width: 1,
                                                  color: secondaryColor3,
                                                ),
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(8),
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    height: 100,
                                                    width: 128,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                          snapShot[index].images![0].src.toString(),
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ),
                                                      borderRadius: const BorderRadius.all(
                                                        Radius.circular(8),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: SizedBox(
                                                      width: 120,
                                                      child: Text(
                                                        snapShot[index].name.toString(),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: GoogleFonts.dmSans(),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 8),
                                                    child: MyGoogleText(
                                                      text: snapShot[index].type == 'simple'
                                                          ? snapShot[index].salePrice.toInt() <= 0
                                                              ? '\₹ ${snapShot[index].regularPrice}'
                                                              : '\₹${snapShot[index].salePrice}'
                                                          : snapData[0].salePrice!.toInt() <= 0
                                                              ? '\₹${snapData[0].regularPrice}'
                                                              : '\₹${snapData[0].salePrice}',
                                                      fontSize: 14,
                                                      fontColor: isDark ? darkTitleColor : lightTitleColor,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                      }, error: (e, stack) {
                                        return Text(e.toString());
                                      }, loading: () {
                                        return Container();
                                      });
                                    },
                                  );
                                }, error: (e, stack) {
                                  return Text(e.toString());
                                }, loading: () {
                                  return const Center(child: ProductShimmerWidget());
                                }),
                                const SizedBox(height: 10),

                                ///__________Trending_Products_________________________________________
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      lang.S.of(context).trendingFashion,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: kTextStyle.copyWith(
                                        fontSize: 16,
                                        color: isDark ? darkTitleColor : lightTitleColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Flexible(
                                      child: TextButton(
                                        onPressed: () {
                                          SingleCategoryScreen(
                                            categoryId: trendingProductsId,
                                            categoryName: lang.S.of(context).trendingFashion,
                                            categoryList: const [],
                                            categoryModel: CategoryModel(),
                                          ).launch(context);
                                        },
                                        child: Text(
                                          lang.S.of(context).showAll,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: kTextStyle.copyWith(
                                            fontSize: 13,
                                            color: primaryColor,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                trendingProducts.when(data: (snapShot) {
                                  return HorizontalList(
                                      spacing: 0,
                                      itemCount: snapShot.length,
                                      itemBuilder: (_, index) {
                                        final productVariation = ref.watch(getSingleProductVariation(snapShot[index].id!.toInt()));

                                        return productVariation.when(data: (dataSnap) {
                                          if (snapShot[index].type != 'simple' && dataSnap.isNotEmpty) {
                                            int discount = discountGenerator(dataSnap[0].regularPrice.toString(), dataSnap[0].salePrice.toString());
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 15),
                                              child: ProductGreedShow(
                                                singleProductVariations: dataSnap[0],
                                                productModel: snapShot[index],
                                                discountPercentage: discount.toString(),
                                                isSingleView: false,
                                                categoryId: trendingProductsId,
                                              ),
                                            );
                                          } else {
                                            int discount = discountGenerator(snapShot[index].regularPrice.toString(), snapShot[index].salePrice.toString());
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 15),
                                              child: ProductGreedShow(
                                                productModel: snapShot[index],
                                                discountPercentage: discount.toString(),
                                                isSingleView: false,
                                                categoryId: trendingProductsId,
                                              ),
                                            );
                                          }
                                        }, error: (e, stack) {
                                          return Text(e.toString());
                                        }, loading: () {
                                          return Container();
                                        });
                                      });
                                }, error: (e, stack) {
                                  return Text(e.toString());
                                }, loading: () {
                                  return const Center(child: ProductShimmerWidget());
                                }),
                                const SizedBox(
                                  height: 10,
                                ),

                                ///-----------------Recomanded--------------
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    MyGoogleText(
                                      text: lang.S.of(context).recommended,
                                      fontSize: 16,
                                      fontColor: isDark ? darkTitleColor : lightTitleColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    Flexible(
                                      child: TextButton(
                                        onPressed: () {
                                          SingleCategoryScreen(
                                            categoryId: recommendedProductId,
                                            categoryName: lang.S.of(context).trendingFashion,
                                            categoryList: const [],
                                            categoryModel: CategoryModel(),
                                          ).launch(context);
                                        },
                                        child: Text(
                                          lang.S.of(context).showAll,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: kTextStyle.copyWith(
                                            fontSize: 13,
                                            color: primaryColor,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                recommendedProducts.when(data: (snapShot) {
                                  return HorizontalList(
                                      spacing: 0,
                                      itemCount: snapShot.length,
                                      itemBuilder: (_, index) {
                                        final productVariation = ref.watch(getSingleProductVariation(snapShot[index].id!.toInt()));

                                        return productVariation.when(data: (dataSnap) {
                                          if (snapShot[index].type != 'simple' && dataSnap.isNotEmpty) {
                                            int discount = discountGenerator(dataSnap[0].regularPrice.toString(), dataSnap[0].salePrice.toString());
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 15),
                                              child: ProductGreedShow(
                                                singleProductVariations: dataSnap[0],
                                                productModel: snapShot[index],
                                                discountPercentage: discount.toString(),
                                                isSingleView: false,
                                                categoryId: recommendedProductId,
                                              ),
                                            );
                                          } else {
                                            int discount = discountGenerator(snapShot[index].regularPrice.toString(), snapShot[index].salePrice.toString());
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 15),
                                              child: ProductGreedShow(
                                                productModel: snapShot[index],
                                                discountPercentage: discount.toString(),
                                                isSingleView: false,
                                                categoryId: recommendedProductId,
                                              ),
                                            );
                                          }
                                        }, error: (e, stack) {
                                          return Text(e.toString());
                                        }, loading: () {
                                          return Container();
                                        });
                                      });
                                }, error: (e, stack) {
                                  return Text(e.toString());
                                }, loading: () {
                                  return const Center(child: ProductShimmerWidget());
                                }),
                                const SizedBox(
                                  height: 10,
                                ),

                                ///-----------------Best_sales--------------
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    MyGoogleText(
                                      text: lang.S.of(context).bestSelling,
                                      fontSize: 16,
                                      fontColor: isDark ? darkTitleColor : lightTitleColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        SingleCategoryScreen(
                                          categoryId: bestSellingId,
                                          categoryName: lang.S.of(context).trendingFashion,
                                          categoryList: const [],
                                          categoryModel: CategoryModel(),
                                        ).launch(context);
                                      },
                                      child: MyGoogleText(
                                        text: lang.S.of(context).showAll,
                                        fontSize: 13,
                                        fontColor: primaryColor,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    )
                                  ],
                                ),
                                bestSellingProducts.when(data: (snapShot) {
                                  return HorizontalList(
                                      spacing: 0,
                                      itemCount: snapShot.length,
                                      itemBuilder: (_, index) {
                                        final productVariation = ref.watch(getSingleProductVariation(snapShot[index].id!.toInt()));

                                        return productVariation.when(data: (dataSnap) {
                                          if (snapShot[index].type != 'simple' && dataSnap.isNotEmpty) {
                                            int discount = discountGenerator(dataSnap[0].regularPrice.toString(), dataSnap[0].salePrice.toString());
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 15),
                                              child: ProductGreedShow(
                                                singleProductVariations: dataSnap[0],
                                                productModel: snapShot[index],
                                                discountPercentage: discount.toString(),
                                                isSingleView: false,
                                                categoryId: bestSellingId,
                                              ),
                                            );
                                          } else {
                                            int discount = discountGenerator(snapShot[index].regularPrice.toString(), snapShot[index].salePrice.toString());
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 15),
                                              child: ProductGreedShow(
                                                productModel: snapShot[index],
                                                discountPercentage: discount.toString(),
                                                isSingleView: false,
                                                categoryId: bestSellingId,
                                              ),
                                            );
                                          }
                                        }, error: (e, stack) {
                                          return Text(e.toString());
                                        }, loading: () {
                                          return Container();
                                        });
                                      });
                                }, error: (e, stack) {
                                  return Text(e.toString());
                                }, loading: () {
                                  return const Center(child: ProductShimmerWidget());
                                }),
                                const SizedBox(
                                  height: 10,
                                ),

                                ///___________Promo__________________________________________

                                allCoupons.when(data: (snapShot) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                                    child: HorizontalList(
                                      padding: EdgeInsets.zero,
                                      spacing: 10.0,
                                      itemCount: snapShot.length,
                                      itemBuilder: (_, i) {
                                        return Container(
                                          height: 130,
                                          width: context.width() / 1.05,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(image: AssetImage(HardcodedImages.couponBackgroundImage), fit: BoxFit.fill),
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(15),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              MyGoogleText(
                                                text: '${snapShot[i].amount}% OFF',
                                                fontSize: 24,
                                                fontColor: Colors.white,
                                                fontWeight: FontWeight.normal,
                                              ),
                                              const SizedBox(height: 10),
                                              MyGoogleText(
                                                text: 'USE CODE: ${snapShot[i].code.toString()}',
                                                fontSize: 16,
                                                fontColor: Colors.white,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }, error: (e, stack) {
                                  return Text(e.toString());
                                }, loading: () {
                                  return const BannerShimmerWidget();
                                }),

                                ///___________New_Arrivals__________________________________________
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    MyGoogleText(
                                      text: lang.S.of(context).newArrival,
                                      fontSize: 16,
                                      fontColor: isDark ? darkTitleColor : lightTitleColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        SingleCategoryScreen(
                                          categoryId: newArrive,
                                          categoryName: lang.S.of(context).newArrival,
                                          categoryList: const [],
                                          categoryModel: CategoryModel(),
                                        ).launch(context);
                                      },
                                      child: MyGoogleText(
                                        text: lang.S.of(context).showAll,
                                        fontSize: 13,
                                        fontColor: primaryColor,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    )
                                  ],
                                ),

                                newProduct.when(data: (snapShot) {
                                  return HorizontalList(
                                      itemCount: snapShot.length,
                                      spacing: 0,
                                      itemBuilder: (_, index) {
                                        final productVariation = ref.watch(getSingleProductVariation(snapShot[index].id!.toInt()));

                                        return productVariation.when(data: (dataSnap) {
                                          if (snapShot[index].type != 'simple' && dataSnap.isNotEmpty) {
                                            int discount = discountGenerator(dataSnap[0].regularPrice.toString(), dataSnap[0].salePrice.toString());
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 15),
                                              child: ProductGreedShow(
                                                singleProductVariations: dataSnap[0],
                                                productModel: snapShot[index],
                                                discountPercentage: discount.toString(),
                                                isSingleView: false,
                                                categoryId: newArrive,
                                              ),
                                            );
                                          } else {
                                            int discount = discountGenerator(snapShot[index].regularPrice.toString(), snapShot[index].salePrice.toString());
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 15),
                                              child: ProductGreedShow(
                                                productModel: snapShot[index],
                                                discountPercentage: discount.toString(),
                                                isSingleView: false,
                                                categoryId: newArrive,
                                              ),
                                            );
                                          }
                                        }, error: (e, stack) {
                                          return Text(e.toString());
                                        }, loading: () {
                                          return Container();
                                        });
                                      });
                                }, error: (e, stack) {
                                  return Text(e.toString());
                                }, loading: () {
                                  return const Center(child: ProductShimmerWidget());
                                }),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  int discountGenerator(String regularPrice, String sellingPrice) {
    double discount;

    if (regularPrice.isEmpty || sellingPrice.isEmpty) {
      return 202;
    } else {
      discount = ((double.parse(sellingPrice) * 100) / double.parse(regularPrice)) - 100;
    }

    return discount.toInt();
  }

  Widget _buildCategoryList(List<CategoryModel> categories) {
    print("------------- Entered _buildCategoryList -----------------");
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Lists for filtering categories
    final List<CategoryModel> finalList = [];
    final List<CategoryModel> allSubCategoryList = [];

    // Filtering categories where parent is not zero
    for (var element in categories) {
      print('------------- Looping through categories -------------');
      if (element.parent != 0) {
        if (finalList.length < 8) {
          finalList.add(element);
        }
        allSubCategoryList.add(element); // Add to subcategories regardless
      }
    }

    // If there are no valid categories, return an empty container or handle as needed
    if (finalList.isEmpty) {
      return const Center(child: Text("No sub-categories available"));
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 5,
        childAspectRatio: 0.72,
        crossAxisSpacing: 8,
      ),
      itemCount: finalList.length,
      itemBuilder: (context, index) {
        String? image = finalList[index].image?.src.toString();
        print('-----------------Category Image URL: ${image}-------');

        return InkWell(
          onTap: () {
            if (index >= 7) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryScreen(allSubCategoryList: allSubCategoryList),
                ),
              );
            } else {
              SingleCategoryScreen(
                categoryId: finalList[index].id!.toInt(),
                categoryName: finalList[index].name.toString(),
                categoryList: categories,
                categoryModel: finalList[index],
              ).launch(context);
            }
          },
          child: index >= 7
              ? Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 75,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(image ?? '', fit: BoxFit.cover),
                              ClipRRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                                  child: Container(
                                    color: Colors.grey.withOpacity(0.1),
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          CommunityMaterialIcons.dots_horizontal_circle_outline,
                          color: Colors.white,
                          size: 50,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'View More',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: kTextStyle.copyWith(
                        fontSize: 12,
                        color: isDark ? darkTitleColor : lightTitleColor,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Container(
                      height: 75,
                      width: 75,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(image ?? ''),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      finalList[index].name.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: kTextStyle.copyWith(
                        fontSize: 12,
                        color: isDark ? darkTitleColor : lightTitleColor,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  // Widget _buildCategoryList(List<CategoryModel> categories) {
  //   bool isDark = Theme.of(context).brightness == Brightness.dark;
  //   final List<CategoryModel> finalList = [];
  //   final List<CategoryModel> allSubCategoryList = [];
  //   for (var element in categories) {
  //     if (element.parent != 0) {
  //     finalList.length <8 ? {finalList.add(element),allSubCategoryList.add(element)} : allSubCategoryList.add(element);
  //     }
  //   }
  //   return GridView.builder(
  //     physics: const NeverScrollableScrollPhysics(),
  //     shrinkWrap: true,
  //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 5, childAspectRatio: 0.72, crossAxisSpacing: 8),
  //     itemCount: finalList.length,
  //     itemBuilder: (context, index) {
  //       print('-----------------category----------${finalList[index].image?.src.toString()}-------');
  //       String? image = finalList[index].image?.src.toString();
  //       return InkWell(
  //         onTap: () {
  //           index >= 7
  //               ? Navigator.push(context, MaterialPageRoute(builder: (context) =>  CategoryScreen(allSubCategoryList: allSubCategoryList,)))
  //               : SingleCategoryScreen(
  //                   categoryId: finalList[index].id!.toInt(),
  //                   categoryName: finalList[index].name.toString(),
  //                   categoryList: categories,
  //                   categoryModel: finalList[index],
  //                 ).launch(context);
  //         },
  //         child: index >= 7
  //             ? Column(
  //                 children: [
  //                   Stack(
  //                     alignment: Alignment.center,
  //                     children: [
  //                       SizedBox(
  //                         height: 75,
  //                         child: Stack(
  //                           fit: StackFit.expand,
  //                           children: [
  //                             Image.network(image??''),
  //                             ClipRRect(
  //                               child: BackdropFilter(
  //                                 filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
  //                                 child: Container(
  //                                   color: Colors.grey.withOpacity(0.1),
  //                                   alignment: Alignment.center,
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       const Icon(
  //                         CommunityMaterialIcons.dots_horizontal_circle_outline,
  //                         color: Colors.white,
  //                         size: 50,
  //                       )
  //                     ],
  //                   ),
  //                   const SizedBox(height: 4),
  //                   Text(
  //                     'View More',
  //                     maxLines: 1,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: kTextStyle.copyWith(fontSize: 12, color: isDark ? darkTitleColor : lightTitleColor),
  //                   )
  //                 ],
  //               )
  //             : Column(
  //                 children: [
  //                   Container(height: 75, width: 75, decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.cover, image: NetworkImage(image ?? '')))),
  //                   const SizedBox(height: 4),
  //                   Text(
  //                     finalList[index].name.toString(),
  //                     maxLines: 1,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: kTextStyle.copyWith(fontSize: 12, color: isDark ? darkTitleColor : lightTitleColor),
  //                   )
  //                 ],
  //               ),
  //       );
  //     },
  //   );
  // }
  Widget _buildCategoryList2(List<CategoryModel> categories) {
    final List<CategoryModel> finalList = [];

    for (var element in categories) {
      if (element.parent == 0 && finalList.length < 4) {
        finalList.add(element);
      }
    }

    if (finalList.isEmpty) {
      return const SizedBox(); // safe fallback
    }

    return StaggeredGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 9,
      crossAxisSpacing: 9,
      children: List.generate(finalList.length, (index) {
        final item = finalList[index];

        // auto height pattern based on index
        double height;
        if (index == 0 || index == 2) {
          height = 137;
        } else if (index == 1) {
          height = 192;
        } else {
          height = 82;
        }

        return Container(
          height: height,
          width: MediaQuery.of(context).size.width / 2.3,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(item.image?.src ?? ''),
            ),
          ),
          child: Text(item.name ?? ''),
        ).onTap(() {
          SingleCategoryScreen(
            categoryId: item.id!.toInt(),
            categoryName: item.name.toString(),
            categoryList: finalList,
            categoryModel: item,
          ).launch(context);
        });
      }),
    );
  }
}
