import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_image_widget.dart';
import 'package:flutter_restaurant/features/home/widgets/product_card_widget.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/features/category/providers/category_provider.dart';
import 'package:flutter_restaurant/features/splash/providers/splash_provider.dart';
import 'package:flutter_restaurant/features/home/enums/product_group_enum.dart';
import 'package:flutter_restaurant/features/home/enums/quantity_position_enum.dart';
import 'package:flutter_restaurant/common/providers/product_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/common/widgets/title_widget.dart';
import 'package:flutter_restaurant/features/home/widgets/category_pop_up_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, category, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 0, 10),
              child: TitleWidget(title: getTranslated('all_categories', context)),
            ),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 80,
                    child: category.categoryList != null
                        ? category.categoryList!.isNotEmpty
                            ? ListView.builder(
                                itemCount: category.categoryList!.length,
                                padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  String? name = '';
                                  category.categoryList![index].name!.length > 15
                                      ? name = '${category.categoryList![index].name!.substring(0, 15)} ...'
                                      : name = category.categoryList![index].name;

                                  return Padding(
                                    padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                    child: InkWell(
                                      onTap: () {
                                        if (ResponsiveHelper.isMobile()) {
                                          // 📱 في الموبايل نفتح نص الشاشة BottomSheet
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.white,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                                            ),
                                            builder: (context) {
                                              return FractionallySizedBox(
                                                heightFactor: 0.45, // ⬅️ أصغر من النص (45% من الشاشة)
                                                child: DraggableScrollableSheet(
                                                  expand: false,
                                                  initialChildSize: 1,
                                                  minChildSize: 1,
                                                  builder: (context, scrollController) {
                                                    return Padding(
                                                      padding: const EdgeInsets.all(16.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          // 🔹 العنوان وشريط الإغلاق
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                category.categoryList![index].name ?? '',
                                                                style: rubikBold.copyWith(
                                                                  fontSize: 18,
                                                                ),
                                                              ),
                                                              IconButton(
                                                                icon: const Icon(Icons.close),
                                                                onPressed: () => Navigator.pop(context),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 8),

                                                          // 🔹 قائمة المنتجات القابلة للسكرول
                                                          Expanded(
                                                            child: Consumer<ProductProvider>(
                                                              builder: (context, productProvider, _) {
                                                                final products = productProvider
                                                                        .latestProductModel?.products
                                                                        ?.where((p) =>
                                                                            p.categoryIds?.any((c) =>
                                                                                c.id ==
                                                                                category.categoryList![index].id
                                                                                    .toString()) ??
                                                                            false)
                                                                        .toList() ??
                                                                    [];

                                                                if (products.isEmpty) {
                                                                  return const Center(
                                                                    child: Padding(
                                                                      padding: EdgeInsets.all(20),
                                                                      child: Text('No products available'),
                                                                    ),
                                                                  );
                                                                }

                                                                return ListView.builder(
                                                                  controller: scrollController, // ✅ التمرير يعمل فعليًا
                                                                  itemCount: products.length,
                                                                  itemBuilder: (context, i) {
                                                                    final product = products[i];
                                                                    return Padding(
                                                                      padding: const EdgeInsets.only(bottom: 10),
                                                                      child: ProductCardWidget(
                                                                        product: product,
                                                                        imageHeight: 110,
                                                                        imageWidth: double.infinity,
                                                                        quantityPosition: QuantityPosition.center,
                                                                        productGroup: ProductGroup.common,
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          );
                                        } else {
                                          // 💻 في الديسكتوب افتح الصفحة العادية
                                          Provider.of<CategoryProvider>(context, listen: false)
                                              .getCategoryList(true);
                                        }
                                      },
                                      child: Column(children: [
                                        ClipOval(
                                          child: CustomImageWidget(
                                            placeholder: Images.placeholderImage,
                                            width: 65,
                                            height: 65,
                                            fit: BoxFit.cover,
                                            image: Provider.of<SplashProvider>(context, listen: false).baseUrls != null
                                                ? '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.categoryImageUrl}/${category.categoryList![index].image}'
                                                : '',
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            name!,
                                            style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ]),
                                    ),
                                  );
                                },
                              )
                            : Center(child: Text(getTranslated('no_category_available', context)!))
                        : const CategoryShimmer(),
                  ),
                ),
                // زر "View All" لغير الموبايل
                ResponsiveHelper.isMobile()
                    ? const SizedBox()
                    : category.categoryList != null
                        ? Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (con) => const Dialog(
                                      child: SizedBox(
                                        height: 550,
                                        width: 600,
                                        child: CategoryPopUpWidget(),
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                  child: CircleAvatar(
                                    radius: 35,
                                    backgroundColor: Theme.of(context).primaryColor,
                                    child: Text(
                                      getTranslated('view_all', context)!,
                                      style: const TextStyle(fontSize: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          )
                        : const CategoryAllShimmer()
              ],
            ),
          ],
        );
      },
    );
  }
}

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        itemCount: 14,
        padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
            child: Shimmer(
              duration: const Duration(seconds: 2),
              enabled: Provider.of<CategoryProvider>(context).categoryList == null,
              child: Column(children: [
                Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 5),
                Container(height: 10, width: 50, color: Theme.of(context).shadowColor),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class CategoryAllShimmer extends StatelessWidget {
  const CategoryAllShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
        child: Shimmer(
          duration: const Duration(seconds: 2),
          enabled: Provider.of<CategoryProvider>(context).categoryList == null,
          child: Column(children: [
            Container(
              height: 65,
              width: 65,
              decoration: BoxDecoration(
                color: Theme.of(context).shadowColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 5),
            Container(height: 10, width: 50, color: Theme.of(context).shadowColor),
          ]),
        ),
      ),
    );
  }
}
