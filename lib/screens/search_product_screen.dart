import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maanstore/api_service/api_service.dart';
import 'package:maanstore/generated/l10n.dart' as lang;
import 'package:maanstore/widgets/product_shimmer_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../Providers/all_repo_providers.dart';
import '../const/constants.dart';
import '../models/single_product_variations_model.dart';
import '../widgets/product_greed_view_widget.dart';
import 'Theme/theme.dart';

class SearchProductScreen extends StatefulWidget {
  const SearchProductScreen({Key? key}) : super(key: key);

  @override
  State<SearchProductScreen> createState() => _SearchProductScreenState();
}

class _SearchProductScreenState extends State<SearchProductScreen> {
  APIService? apiService;

  @override
  void initState() {
    apiService = APIService();
    super.initState();
  }

  final fieldText = TextEditingController();
  String initialSearchValue = '';
  List<String> searchHistory = [];

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer(builder: (context, ref, __) {
      final searchProduct = ref.watch(getProductBySearch(initialSearchValue));
      return Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            leading: GestureDetector(
              onTap: () {
                finish(context);
              },
              child:  Icon(
                Icons.arrow_back,
                color: isDark ? darkTitleColor : lightTitleColor,
              ),
            ),
            title: MyGoogleText(
              text: lang.S.of(context).searchProduct,
              fontColor: isDark ? darkTitleColor : lightTitleColor,
              fontWeight: FontWeight.normal,
              fontSize: 18,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration:  BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    height: 125,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: TextEditingController(),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark?darkContainer:kBorderColorTextField,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(15)
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(15)
                            ),
                            prefixIcon: const Icon(
                              FeatherIcons.search,
                              color: textColors,
                            ),
                            hintText: lang.S.of(context).searchProduct,
                          ),
                          cursorColor: textColors,
                          onTap: () {
                            setState(() {
                              initialSearchValue = '';
                            });
                          },
                          onFieldSubmitted: (value) {
                            setState(() {
                              initialSearchValue = '';
                              initialSearchValue = value;
                              searchHistory.add(value);
                              TextEditingController().clear();
                            });
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MyGoogleText(
                                text: lang.S.of(context).recentSearches,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                fontColor:
                                isDark ? darkTitleColor : lightTitleColor,
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    searchHistory.clear();
                                    initialSearchValue = '';
                                  });
                                },
                                child: MyGoogleText(
                                  text: lang.S.of(context).clearAllButton,
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                  fontColor: isDark ? darkGreyTextColor : lightGreyTextColor,
                                ),
                              ),
                            ],
                          ).visible(searchHistory.isNotEmpty),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: searchHistory.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: MyGoogleText(
                                          text: searchHistory[index],
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                          fontColor: isDark ? darkGreyTextColor : lightGreyTextColor,
                                        ),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              searchHistory.removeAt(index);
                                              initialSearchValue = '';
                                            });
                                          },
                                          icon:  Icon(
                                            Icons.cancel,
                                            color: isDark ? darkGreyTextColor : lightGreyTextColor,
                                          ))
                                    ],
                                  );
                                }),
                          ),
                          searchProduct.when(data: (snapshot) {
                            if (snapshot.isNotEmpty) {
                              return GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 6.0,
                                  mainAxisSpacing: 10.0,
                                  childAspectRatio: 0.58,
                                ),
                                itemCount: snapshot.length,
                                itemBuilder: (BuildContext ctx, index) {
                                  return FutureBuilder<List<SingleProductVariations>>(
                                      future: apiService?.getSingleProductVariation(snapshot[index].id!.toInt()),
                                      builder: (context, snapData) {
                                        if (snapData.hasData) {
                                          if (snapshot[index].type != 'simple' && snapData.data!.isNotEmpty) {
                                            int discount = discountGenerator(snapData.data![0].regularPrice.toString(), snapData.data![0].salePrice.toString());
                                            return ProductGreedShow(
                                                singleProductVariations: snapData.data![0],
                                                productModel: snapshot[index],
                                                discountPercentage: discount.toString(),
                                                isSingleView: false,
                                                categoryId: 0);
                                          } else {
                                            int discount = discountGenerator(snapshot[index].regularPrice.toString(), snapshot[index].salePrice.toString());
                                            return ProductGreedShow(
                                              productModel: snapshot[index],
                                              discountPercentage: discount.toString(),
                                              isSingleView: false,
                                              categoryId: 0,
                                            );
                                          }
                                        } else {
                                          return Container();
                                        }
                                      });
                                },
                              );
                            } else {
                              return Center(
                                child: MyGoogleText(text: lang.S.of(context).noItemsFound, fontSize: 20, fontColor: textColors, fontWeight: FontWeight.normal),
                              );
                            }
                          }, error: (e, stack) {
                            return Text(e.toString());
                          }, loading: () {
                            return const ProductGridShimmerWidget();
                          }).visible(initialSearchValue != ''),
                        ],
                      ),
                    ),
                  ),

                  // FutureBuilder(
                  //       future: apiService!
                  //           .getProductBySearch(initialSearchValue.toString()),
                  //       builder: (context,
                  //           AsyncSnapshot<List<ProductModel>> snapshot) {
                  //         if (snapshot.hasData) {
                  //           if (snapshot.data!.isNotEmpty) {
                  //             return GridView.builder(
                  //               physics: const NeverScrollableScrollPhysics(),
                  //               shrinkWrap: true,
                  //               gridDelegate:
                  //                   const SliverGridDelegateWithFixedCrossAxisCount(
                  //                 crossAxisCount: 2,
                  //                 crossAxisSpacing: 10.0,
                  //                 mainAxisSpacing: 10.0,
                  //                 childAspectRatio: 0.50,
                  //               ),
                  //               itemCount: snapshot.data!.length,
                  //               itemBuilder: (BuildContext ctx, index) {
                  //                 return FutureBuilder<
                  //                         List<SingleProductVariations>>(
                  //                     future:
                  //                         apiService?.getSingleProductVariation(
                  //                             snapshot.data![index].id!.toInt()),
                  //                     builder: (context, snapData) {
                  //                       if (snapData.hasData) {
                  //                         if (snapshot.data![index].type !=
                  //                             'simple') {
                  //                           int discount = discountGenerator(
                  //                               snapData.data![0].regularPrice
                  //                                   .toString(),
                  //                               snapData.data![0].salePrice
                  //                                   .toString());
                  //                           return ProductGreedShow(
                  //                               singleProductVariations:
                  //                                   snapData.data![0],
                  //                               productModel:
                  //                                   snapshot.data![index],
                  //                               discountPercentage:
                  //                                   discount.toString(),
                  //                               isSingleView: false,
                  //                               categoryId: 0);
                  //                         } else {
                  //                           int discount = discountGenerator(
                  //                               snapshot.data![index].regularPrice
                  //                                   .toString(),
                  //                               snapshot.data![index].salePrice
                  //                                   .toString());
                  //                           return ProductGreedShow(
                  //                             productModel: snapshot.data![index],
                  //                             discountPercentage:
                  //                                 discount.toString(),
                  //                             isSingleView: false,
                  //                             categoryId: 0,
                  //                           );
                  //                         }
                  //                       } else {
                  //                         return Container();
                  //                       }
                  //                     });
                  //               },
                  //             );
                  //           } else {
                  //             return Center(
                  //               child: MyGoogleText(
                  //                   text:isRtl ? HardcodedTextArabic.noItemsFound : HardcodedTextEng.noItemsFound,
                  //                   fontSize: 20,
                  //                   fontColor: textColors,
                  //                   fontWeight: FontWeight.normal),
                  //             );
                  //           }
                  //         } else {
                  //           return const ProductGridShimmerWidget();
                  //         }
                  //       }).visible(initialSearchValue != ''),
                ],
              ),
            ),
          ),
        ),
      );
    });
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
}
