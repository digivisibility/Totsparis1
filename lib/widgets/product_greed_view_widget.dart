import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:maanstore/screens/product_details_screen/product_detail_screen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../const/constants.dart';
import '../models/product_model.dart';
import '../models/single_product_variations_model.dart';
import '../models/wishlist_model.dart';
import '../screens/Theme/theme.dart';
import '../Providers/wishlist_provider.dart';

class ProductGreedShow extends ConsumerStatefulWidget {
  const ProductGreedShow({
    super.key,
    required this.discountPercentage,
    required this.isSingleView,
    required this.categoryId,
    required this.productModel,
    this.singleProductVariations,
  });

  final SingleProductVariations? singleProductVariations;
  final String discountPercentage;
  final bool isSingleView;
  final int categoryId;
  final ProductModel productModel;

  @override
  ConsumerState<ProductGreedShow> createState() => _ProductGreedShowState();
}

class _ProductGreedShowState extends ConsumerState<ProductGreedShow> {
  double initialRating = 0;

  void _toggleWishlist(bool isFavorite) {
    if (!isFavorite) {
      int price = 0;
      try {
        if (widget.singleProductVariations != null) {
          price = double.parse(widget.singleProductVariations!.salePrice.toString()).toInt();
        } else {
          price = double.parse(widget.productModel.salePrice.toString()).toInt();
        }
      } catch (e) {
        try {
          price = double.parse(widget.productModel.regularPrice.toString()).toInt();
        } catch (e) {
           price = 0;
        }
      }

      String img = '';
      if (widget.productModel.images != null && widget.productModel.images!.isNotEmpty) {
        img = widget.productModel.images![0].src.toString();
      }

      Wishlist item = Wishlist(
        id: widget.productModel.id,
        name: widget.productModel.name,
        img: img,
        price: price,
        categoryId: widget.categoryId,
      );

      ref.read(wishlistProvider.notifier).addWishlist(item);
    } else {
      ref.read(wishlistProvider.notifier).removeWishlist(widget.productModel.id!);
    }
  }

  // -----------------------------
  // PRICE HANDLING FIXED HERE
  // -----------------------------
  String getFinalPrice() {
    // Variation price if exists
    if (widget.singleProductVariations != null) {
      final variation = widget.singleProductVariations!;
      final sale = variation.salePrice.toString();
      final regular = variation.regularPrice.toString();

      return (sale.isEmpty || sale == "0" || sale == "null")
          ? "₹$regular"
          : "₹$sale";
    }

    // Normal product price
    final sale = widget.productModel.salePrice.toString();
    final regular = widget.productModel.regularPrice.toString();

    return (sale.isEmpty || sale == "0" || sale == "null")
        ? "₹$regular"
        : "₹$sale";
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final wishlist = ref.watch(wishlistProvider);
    bool isFavorite = wishlist.any((element) => element.id == widget.productModel.id);

    return Container(
      width: MediaQuery.of(context).size.width / 2,
      decoration: BoxDecoration(
        color: isDark ? cardColor : Colors.transparent,
        border: Border.all(
          width: 1,
          color: isDark ? darkContainer : secondaryColor3,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              widget.isSingleView
                  ? GestureDetector(
                onTap: () {
                  ProductDetailScreen(
                    productModel: widget.productModel,
                    categoryId: widget.categoryId,
                  ).launch(context);
                },
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      topLeft: Radius.circular(8),
                    ),
                    color: secondaryColor3,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        widget.productModel.images![0].src.toString(),
                      ),
                    ),
                  ),
                ),
              )
                  : GestureDetector(
                onTap: () {
                  ProductDetailScreen(
                    productModel: widget.productModel,
                    categoryId: widget.categoryId,
                  ).launch(context);
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 180,
                  width: 225,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      topLeft: Radius.circular(8),
                    ),
                    color: secondaryColor3,
                    image: DecorationImage(
                      image: NetworkImage(
                          widget.productModel.images![0].src.toString()),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // Discount badge
              widget.discountPercentage.toInt() != 202
                  ? Positioned(
                left: 7,
                top: 10,
                child: Container(
                  height: 23,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1, color: secondaryColor3),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                  child: Center(
                    child: MyGoogleText(
                      text:
                      '${widget.discountPercentage.toDouble().round()} %',
                      fontSize: 12,
                      fontColor: secondaryColor1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
                  : Container(),

              // Wishlist Icon
              Positioned(
                right: 5,
                top: 5,
                child: GestureDetector(
                  onTap: () => _toggleWishlist(isFavorite),
                  child: Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      isFavorite ? IconlyBold.heart : IconlyLight.heart,
                      color: isFavorite ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Details Section
          Padding(
            padding:
            const EdgeInsets.only(left: 15, top: 5, right: 15, bottom: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                MyGoogleText(
                  text: widget.productModel.name.toString(),
                  fontSize: 13,
                  fontColor: isDark ? darkGreyTextColor : lightGreyTextColor,
                  fontWeight: FontWeight.normal,
                ),

                // -----------------------------
                // FIXED PRICE DISPLAY
                // -----------------------------
                MyGoogleText(
                  text: getFinalPrice(),
                  fontSize: 14,
                  fontColor: isDark ? darkTitleColor : lightTitleColor,
                  fontWeight: FontWeight.normal,
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      RatingBarWidget(
                        rating: initialRating,
                        activeColor: ratingColor,
                        inActiveColor: ratingColor,
                        size: 18,
                        onRatingChanged: (aRating) {
                          setState(() {
                            initialRating = aRating;
                          });
                        },
                      ),
                      const Spacer(),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
