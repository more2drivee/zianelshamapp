import 'package:flutter/material.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_restaurant/features/home/providers/banner_provider.dart';
import 'package:flutter_restaurant/common/widgets/custom_image_widget.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/common/models/product_model.dart';
import 'package:flutter_restaurant/features/splash/providers/splash_provider.dart';
import 'package:flutter_restaurant/features/category/domain/category_model.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/features/home/widgets/cart_bottom_sheet_widget.dart';
import 'package:flutter_restaurant/helper/custom_snackbar_helper.dart';

class NewItemsWidget extends StatelessWidget {
  const NewItemsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Consumer2<BannerProvider, SplashProvider>(
      builder: (context, bannerProvider, splashProvider, child) {
        final banners = bannerProvider.bannerList ?? [];
        if (banners.isEmpty || splashProvider.baseUrls == null) {
          return const SizedBox();
        }

        final String baseUrl = splashProvider.baseUrls!.bannerImageUrl!;

        final String targetDimension =
            ResponsiveHelper.isDesktop(context) ? 'desktop' : 'mobile';
        final ads = banners
            .where((b) => (b.bannerType == 'ads')
                && (b.dimensionType == targetDimension)
                && ((b.status ?? 1) == 1))
            .toList();
        if (ads.isEmpty) {
          return const SizedBox();
        }

        String resolveImage(String? img) {
          if (img == null) return '';
          return img.startsWith('http') ? img : '$baseUrl/$img';
        }

        return Center(
          child: Container(
            width: Dimensions.webMaxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? Dimensions.paddingSizeLarge : 10,
                    20,
                    isDesktop ? Dimensions.paddingSizeLarge : 10,
                    10,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getTranslated("our_new", context)!,
                            style: rubikBold.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 60,
                            height: 2,
                            color: Colors.red,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: isDesktop ? 220 : 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? Dimensions.paddingSizeLarge : 10,
                    ),
                    itemCount: ads.length,
                    itemBuilder: (context, index) {
                      final banner = ads[index];
                      final imageUrl = resolveImage(banner.image);
                      return _buildBannerCard(
                        context,
                        imageUrl,
                        isDesktop: isDesktop,
                        onTap: () async {
                          if (banner.productId != null) {
                            Product? product = banner.product;
                            product ??= await Provider.of<BannerProvider>(context, listen: false)
                                .getProductDetails('${banner.productId}');
                            if (product != null && (product.branchProduct?.isAvailable ?? false)) {
                              ResponsiveHelper.showDialogOrBottomSheet(
                                context,
                                CartBottomSheetWidget(
                                  product: product,
                                  fromSetMenu: true,
                                  callback: (_) {
                                    showCustomSnackBarHelper(
                                      getTranslated('added_to_cart', context),
                                      isError: false,
                                    );
                                  },
                                ),
                              );
                            }
                          } else if (banner.categoryId != null) {
                            final category = CategoryModel(
                              id: banner.categoryId,
                              name: banner.title,
                              bannerImage: null,
                            );
                            RouterHelper.getCategoryRoute(category);
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBannerCard(BuildContext context, String imageUrl, {bool isDesktop = false, VoidCallback? onTap}) {
    return Container(
      width: isDesktop ? 200 : 160,
      height: isDesktop ? 200 : 160,
      margin: EdgeInsets.only(right: isDesktop ? 20 : 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: CustomImageWidget(
              image: imageUrl,
              placeholder: Images.placeholderBanner,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
