import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

class BannerShimmerWidget extends StatelessWidget {
  const BannerShimmerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return HorizontalList(
        itemCount: 10,
        itemBuilder: (_, i) {
          return Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 120,
                width: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.white,
                ),
              ));
        });
  }
}
