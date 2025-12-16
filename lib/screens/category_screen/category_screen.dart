import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maanstore/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Providers/all_repo_providers.dart';
import '../../const/constants.dart';
import '../../models/category_model.dart';
import '../../widgets/order_page_shimmer.dart';
import '../Theme/theme.dart';
import '../product_details_screen/product_detail_screen.dart';
import '../search_product_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, required this.allSubCategoryList});

  final List<CategoryModel> allSubCategoryList ;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedIndex = widget.allSubCategoryList.first.id ?? 0;
  }
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer(
      builder: (_,ref,__){
        final allProducts = ref.watch(getProductOfSingleCategory(selectedIndex));
        return Directionality(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: isDark?darkContainer:secondaryColor3,
                        borderRadius: const BorderRadius.all(Radius.circular(30)),
                      ),
                      child: IconButton(
                        onPressed: () {
                          const SearchProductScreen().launch(context);
                        },
                        icon:  Icon(
                          FeatherIcons.search,
                          color: isDark ? darkTitleColor : lightTitleColor,
                        ),
                      ),
                    ),
                  ),
                ],
                iconTheme: IconThemeData(color: isDark ? darkTitleColor : lightTitleColor,),
                title: MyGoogleText(
                  text: lang.S.of(context).categories,
                  fontColor: isDark ? darkTitleColor : lightTitleColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        decoration:  BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10))
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListView.builder(
                                    itemCount: widget.allSubCategoryList.length,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context,index){
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          InkWell(
                                            onTap: (){
                                              setState(() {
                                                selectedIndex = widget.allSubCategoryList[index].id ?? 0;
                                              });
                                            },
                                            child: Container(
                                              width: 200,
                                              decoration:  BoxDecoration(
                                                  color: widget.allSubCategoryList[index].id==selectedIndex?primaryColor:Colors.transparent
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Text(widget.allSubCategoryList[index].name.toString(),style: sTextStyle.copyWith(color: widget.allSubCategoryList[index].id==selectedIndex?Colors.white:isDark ? darkTitleColor : lightTitleColor),),
                                              ),
                                            ),
                                          )
                                        ],
                                      );
                                    }),
                              ],
                          ),

                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                      child:  allProducts.when(data: (snapShot) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 62/80,
                                  ),
                                  itemCount: snapShot.length,
                                  itemBuilder: (context,index){
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
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 70,
                                                width: 70,
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
                                            ],
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
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 70,
                                                width: 70,
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
                                                    textAlign: TextAlign.center,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: GoogleFonts.dmSans(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }, error: (e, stack) {
                                      return Text(e.toString());
                                    }, loading: () {
                                      return Container();
                                    });
                                    // return Padding(
                                    //   padding: const EdgeInsets.only(left: 10,right: 10),
                                    //   child: GestureDetector(
                                    //     onTap: (){
                                    //
                                    //     },
                                    //     child: Column(
                                    //       mainAxisAlignment: MainAxisAlignment.start,
                                    //       children: [
                                    //         Container(
                                    //           height: 70,
                                    //           width: 70,
                                    //           decoration: BoxDecoration(
                                    //               borderRadius: BorderRadius.circular(5),
                                    //               image:  DecorationImage(
                                    //                   fit: BoxFit.cover,
                                    //                   image: NetworkImage(snapShot[index].images?.first.src.toString() ?? ''))
                                    //           ),
                                    //         ),
                                    //         const SizedBox(height: 8,),
                                    //         Text(snapShot[index].name ?? '',style: const TextStyle(fontSize: 11,color: Color(0xff06071B),overflow: TextOverflow.ellipsis,),maxLines: 1,)
                                    //       ],
                                    //     ),
                                    //   ),
                                    // );
                                  })
                            ],
                          );
                        }, error: (e, stack) {
                          return Text(e.toString());
                        }, loading: () {
                          return const CategoryPageShimmer();
                        }),
                      ),
                    )
                  ],
                ),
              ),
            ));
      },
    );
  }
}
