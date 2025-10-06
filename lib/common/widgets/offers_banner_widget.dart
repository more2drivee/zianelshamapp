/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/features/home/providers/banner_provider.dart';
import 'package:flutter_restaurant/features/splash/providers/splash_provider.dart';
import 'package:flutter_restaurant/common/widgets/custom_image_widget.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/common/models/product_model.dart';
import 'package:flutter_restaurant/features/home/widgets/cart_bottom_sheet_widget.dart';
import 'package:flutter_restaurant/helper/custom_snackbar_helper.dart';
import 'package:flutter_restaurant/features/category/domain/category_model.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';

class OffersBannerWidget extends StatelessWidget {
  const OffersBannerWidget({super.key});

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
        final String targetDimension = isDesktop ? 'desktop' : 'mobile';

        final offers = banners
            .where((b) => (b.bannerType == 'offer' || b.bannerType == 'offers')
                && (b.dimensionType == targetDimension)
                && ((b.status ?? 1) == 1))
            .toList();

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
                            getTranslated("offers", context) ?? 'Offers',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 60,
                            height: 2,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: isDesktop ? 220 : 180,
                  child: Builder(
                    builder: (context) {
                      // Static fallback cards when no backend offers are available
                      if (offers.isEmpty) {
                        final List<_StaticOffer> staticOffers = [
                          _StaticOffer(
                            image: Images.placeholderBanner,
                            title: getTranslated('offers', context) ?? 'Offers',
                          ),
                          _StaticOffer(
                            image: Images.walletBanner,
                            title: getTranslated('extra_discount', context) ?? 'Extra discount',
                          ),
                          _StaticOffer(
                            image: Images.discountBannerAvatar,
                            title: getTranslated('available_promo', context) ?? 'Available Promo',
                          ),
                        ];
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? Dimensions.paddingSizeLarge : 10,
                          ),
                          itemCount: staticOffers.length,
                          itemBuilder: (context, index) {
                            final item = staticOffers[index];
                            return _OfferCard(
                              imageUrl: item.image,
                              title: item.title,
                              isDesktop: isDesktop,
                              onTap: () {},
                            );
                          },
                        );
                      }

                      // Dynamic offers from backend
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? Dimensions.paddingSizeLarge : 10,
                        ),
                        itemCount: offers.length,
                        itemBuilder: (context, index) {
                          final banner = offers[index];
                          final imageUrl = resolveImage(banner.image);
                          return _OfferCard(
                            imageUrl: imageUrl,
                            title: banner.title,
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
}

class _StaticOffer {
  final String image;
  final String title;
  const _StaticOffer({required this.image, required this.title});
}

class _OfferCard extends StatelessWidget {
  final String imageUrl;
  final String? title;
  final bool isDesktop;
  final VoidCallback? onTap;

  const _OfferCard({
    required this.imageUrl,
    required this.title,
    required this.isDesktop,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isDesktop ? 260 : 200,
      height: isDesktop ? 240 : 200,
      margin: EdgeInsets.only(right: isDesktop ? 20 : 15),
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Material(
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
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color.fromARGB(150, 0, 0, 0),
                      Color.fromARGB(0, 0, 0, 0),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        getTranslated('offers', context) ?? 'Offers',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_offer, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/