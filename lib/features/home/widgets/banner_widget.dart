import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_image_widget.dart';
import 'package:flutter_restaurant/features/home/providers/banner_provider.dart';
import 'package:flutter_restaurant/features/splash/providers/splash_provider.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/helper/product_helper.dart';
import 'package:flutter_restaurant/features/cart/providers/cart_provider.dart';
import 'package:flutter_restaurant/features/category/domain/category_model.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:provider/provider.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double bannerHeight = ResponsiveHelper.isDesktop(context) ? 400 : 180;

    return SizedBox(
      height: bannerHeight + 40,
      width: double.infinity,
      child: Consumer2<BannerProvider, SplashProvider>(
        builder: (context, banner, splash, _) {
          final banners = banner.bannerList ?? [];
          if (banners.isEmpty || splash.baseUrls == null) {
            return const SizedBox();
          }

          final String baseUrl = splash.baseUrls!.bannerImageUrl!;

          // Filter by type and dimension
          final String targetDimension =
              ResponsiveHelper.isDesktop(context) ? 'desktop' : 'mobile';
          final filtered = banners
              .where((b) => (b.bannerType == 'banner')
                  && (b.dimensionType == targetDimension)
                  && ((b.status ?? 1) == 1))
              .toList();
          if (filtered.isEmpty) {
            return const SizedBox();
          }

          String resolveImage(String? img) {
            if (img == null) return '';
            return img.startsWith('http') ? img : '$baseUrl/$img';
          }

          return Column(
            children: [
              // 🔹 البانر نفسه
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: filtered.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final bannerItem = filtered[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () async {
                            // Navigate based on banner link
                            if (bannerItem.categoryId != null) {
                              final category = CategoryModel(
                                id: bannerItem.categoryId,
                                name: bannerItem.title,
                                bannerImage: null,
                              );
                              RouterHelper.getCategoryRoute(category);
                            } else if (bannerItem.productId != null) {
                              // Get product then open add-to-cart bottom sheet
                              final cartProvider = Provider.of<CartProvider>(context, listen: false);
                              var product = bannerItem.product;
                              if (product == null) {
                                product = await Provider.of<BannerProvider>(context, listen: false)
                                    .getProductDetails('${bannerItem.productId}');
                              }
                              if (product != null) {
                                final cartIndex = cartProvider.getCartIndex(product);
                                ProductHelper.addToCart(cartIndex: cartIndex, product: product);
                              }
                            }
                          },
                          child: CustomImageWidget(
                            image: resolveImage(bannerItem.image),
                            placeholder: Images.placeholderBanner,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 🔹 المؤشرات (Dots)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(filtered.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    width: _currentPage == index ? 12 : 8,
                    height: _currentPage == index ? 12 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
