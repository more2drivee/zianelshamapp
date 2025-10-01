import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/providers/product_provider.dart';
import 'package:flutter_restaurant/common/providers/theme_provider.dart';
import 'package:flutter_restaurant/common/widgets/custom_asset_image_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_single_child_list_widget.dart';
import 'package:flutter_restaurant/common/widgets/product_shimmer_widget.dart';
import 'package:flutter_restaurant/common/widgets/title_widget.dart';
import 'package:flutter_restaurant/features/home/enums/product_group_enum.dart';
import 'package:flutter_restaurant/features/home/enums/quantity_position_enum.dart';
import 'package:flutter_restaurant/features/home/widgets/product_card_widget.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:provider/provider.dart';

class ChefsRecommendationWidget extends StatefulWidget {
  const ChefsRecommendationWidget({super.key});

  @override
  State<ChefsRecommendationWidget> createState() =>
      _ChefsRecommendationWidgetState();
}

class _ChefsRecommendationWidgetState extends State<ChefsRecommendationWidget> {
  final CarouselSliderController sliderController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final ThemeProvider themeProvider =
        Provider.of<ThemeProvider>(context, listen: false);

    return Column(children: [
      Consumer<ProductProvider>(builder: (context, productProvider, _) {
        return (productProvider.recommendedProductModel == null)
            ? Center(
                child: Container(
                  width: Dimensions.webScreenWidth,
                  padding: EdgeInsets.only(
                      left: !isDesktop ? Dimensions.paddingSizeLarge : 0),
                  child: ProductShimmerWidget(
                    isEnabled:
                        productProvider.popularLocalProductModel == null,
                    isList: true,
                  ),
                ),
              )
            : (productProvider.recommendedProductModel?.products?.isEmpty ??
                    true)
                ? const SizedBox()
                : Column(children: [
                if (!isDesktop)
  Container(
    padding: const EdgeInsets.symmetric(
      vertical: Dimensions.paddingSizeSmall,
      horizontal: Dimensions.paddingSizeSmall,
    ),
    width: Dimensions.webScreenWidth,
    child: Text(
      getTranslated('chefs_recommendation', context)!,
      style: rubikBold.copyWith(
        fontSize: Dimensions.fontSizeOverLarge,
        color: Theme.of(context).primaryColor,
      ),
    ),
  ),
if (isDesktop)
  Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          getTranslated('chefs_recommendation', context)!,
          style: rubikBold.copyWith(
            fontSize: Dimensions.fontSizeExtraLarge,
            color: themeProvider.darkTheme
                ? Theme.of(context).colorScheme.onSecondary
                : ColorResources.homePageSectionTitleColor,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
       
      ],
    ),
  ),
                     
                    if (isDesktop)
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                    /// ✅ السلايدر مع الأسهم برا
                    Center(
                      child: Container(
                        width: Dimensions.webScreenWidth,
                        padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeLarge),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isDesktop &&
                                (productProvider.recommendedProductModel
                                            ?.products?.length ??
                                        0) >
                                    3)
                              IconButton(
                                icon: const Icon(Icons.arrow_back_rounded,
                                    size: 40),
                                color: Theme.of(context).primaryColor,
                                onPressed: () =>
                                    sliderController.previousPage(),
                              ),

                            /// ✅ السلايدر في النص
                            Expanded(
                              child: CarouselSlider.builder(
                                itemCount: productProvider
                                        .recommendedProductModel
                                        ?.products
                                        ?.length ??
                                    0,
                                carouselController: sliderController,
                                options: CarouselOptions(
                                  height: 360,
                                  viewportFraction: isDesktop
                                      ? 0.32 // 3 كروت كبار على الديسكتوب
                                      : ResponsiveHelper.isTab(context)
                                          ? 0.45
                                          : 0.8,
                                  enlargeCenterPage: false,
                                  enableInfiniteScroll: true,
                                  autoPlay: true,
                                  scrollDirection: Axis.horizontal,
                                ),
                                itemBuilder: (context, index, realIndex) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.paddingSizeSmall),
                                    child: ProductCardWidget(
                                      product: productProvider
                                          .recommendedProductModel!
                                          .products![index],
                                      imageHeight: 180,
                                      imageWidth: double.infinity,
                                      quantityPosition: QuantityPosition.center,
                                      productGroup:
                                          ProductGroup.chefRecommendation,
                                    ),
                                  );
                                },
                              ),
                            ),

                            if (isDesktop &&
                                (productProvider.recommendedProductModel
                                            ?.products?.length ??
                                        0) >
                                    3)
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_rounded,
                                    size: 40),
                                color: Theme.of(context).primaryColor,
                                onPressed: () => sliderController.nextPage(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ]);
      }),
    ]);
  }
}
