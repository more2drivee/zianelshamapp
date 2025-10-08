import 'package:flutter/material.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:provider/provider.dart';
import 'package:flutter_restaurant/features/category/providers/category_provider.dart';
import 'package:flutter_restaurant/features/home/providers/sorting_provider.dart';
import 'package:flutter_restaurant/common/providers/product_provider.dart';
import 'package:flutter_restaurant/features/home/widgets/product_card_widget.dart';
import 'package:flutter_restaurant/features/home/enums/product_group_enum.dart';
import 'package:flutter_restaurant/features/home/enums/quantity_position_enum.dart';
import 'package:flutter_restaurant/features/home/enums/view_change_to_enum.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/common/widgets/paginated_list_widget.dart';
import 'package:flutter_restaurant/common/providers/theme_provider.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import '../../category/domain/category_model.dart';

class MobileHomeScreen extends StatelessWidget {
  final ScrollController scrollController;
  const MobileHomeScreen({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.paddingSizeLarge),

          /// ✅ Category title & filter
          Consumer<CategoryProvider>(
            builder: (context, categoryProvider, _) {
              final categoryList = categoryProvider.categoryList ?? [];
              final selectedId = categoryProvider.selectedSubCategoryId;

              final selectedCategory = categoryList.firstWhere(
                (c) => "${c.id}" == selectedId,
                orElse: () => CategoryModel(),
              );

              final categoryName = (categoryProvider.isCategorySelected)
                  ? (selectedCategory.name ??
                      getTranslated('all_products', context))
                  : getTranslated('all_products', context);

              final parents = categoryList
                  .where((c) => (c.parentId?.toString() ?? '0') == '0')
                  .toList();

              return Row(
                children: [
                  Expanded(
                    child: Text(
                      categoryName!,
                      style: rubikBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge,
                        color: themeProvider.darkTheme
                            ? Theme.of(context).colorScheme.onSecondary
                            : ColorResources.homePageSectionTitleColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (ctx) {
                          return SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: Dimensions.paddingSizeSmall,
                                right: Dimensions.paddingSizeSmall,
                                top: Dimensions.paddingSizeSmall,
                                bottom: Dimensions.paddingSizeLarge,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 40,
                                        height: 4,
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade400,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      getTranslated('all_categories', context)!,
                                      style:
                                          rubikSemiBold.copyWith(fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    ExpansionPanelList.radio(
                                      elevation: 0,
                                      expandedHeaderPadding: EdgeInsets.zero,
                                      children: parents
                                          .map<ExpansionPanelRadio>((parent) {
                                        final parentId = "${parent.id}";
                                        final subcats = categoryList
                                            .where((c) =>
                                                (c.parentId?.toString() ?? '') ==
                                                parentId)
                                            .toList();

                                        return ExpansionPanelRadio(
                                          value: parentId,
                                          headerBuilder: (context, isExpanded) {
                                            return ListTile(
                                              title: Text(
                                                  parent.name ?? "Category"),
                                              trailing: TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  categoryProvider
                                                      .getCategoryProductList(
                                                          parentId, 1);
                                                },
                                                child: Text(
                                                  getTranslated(
                                                      'view_all', context)!,
                                                ),
                                              ),
                                            );
                                          },
                                          body: Padding(
                                            padding: const EdgeInsets.only(
                                              left: Dimensions.paddingSizeSmall,
                                              right:
                                                  Dimensions.paddingSizeSmall,
                                              bottom:
                                                  Dimensions.paddingSizeSmall,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: subcats.isEmpty
                                                  ? const [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                            'No subcategories found.'),
                                                      )
                                                    ]
                                                  : subcats.map((s) {
                                                      return ListTile(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 8,
                                                                right: 8),
                                                        title: Text(
                                                            s.name ??
                                                                "Subcategory"),
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                          categoryProvider
                                                              .getCategoryProductList(
                                                                  "${s.id}", 1);
                                                        },
                                                      );
                                                    }).toList(),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          /// ✅ Products Grid
          Consumer3<CategoryProvider, ProductProvider, ProductSortProvider>(
            builder: (context, categoryProvider, productProvider,
                sortingProvider, _) {
              final isCategorySelected = categoryProvider.isCategorySelected;

              final products = isCategorySelected
                  ? categoryProvider.categoryProductModel?.products
                  : productProvider.latestProductModel?.products;

              if (products == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (products.isEmpty) {
                return const Center(child: Text("No products available"));
              }

              final totalSize = isCategorySelected
                  ? categoryProvider.categoryProductModel?.totalSize
                  : productProvider.latestProductModel?.totalSize;

              final offset = isCategorySelected
                  ? categoryProvider.categoryProductModel?.offset
                  : productProvider.latestProductModel?.offset;

              final limit = isCategorySelected
                  ? categoryProvider.categoryProductModel?.limit
                  : productProvider.latestProductModel?.limit;

              return PaginatedListWidget(
                scrollController: scrollController,
                onPaginate: (int? nextOffset) async {
                  if (isCategorySelected) {
                    await categoryProvider.getCategoryProductList(
                      categoryProvider.selectedSubCategoryId ??
                          "${categoryProvider.categoryList?.first.id}",
                      nextOffset ?? 1,
                    );
                  } else {
                    await productProvider.getLatestProductList(
                        nextOffset ?? 1, false);
                  }
                },
                totalSize: totalSize,
                offset: offset,
                limit: limit,
                isDisableWebLoader: !isDesktop,
                builder: (loaderWidget) {
                  return Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 230,
                          crossAxisSpacing: Dimensions.paddingSizeSmall,
                          mainAxisSpacing: Dimensions.paddingSizeSmall,
                          mainAxisExtent:
                              ResponsiveHelper.isMobile() ? 240 : 360,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductCardWidget(
                            product: product,
                            quantityPosition:
                                sortingProvider.viewChangeTo ==
                                        ViewChangeTo.listView
                                    ? QuantityPosition.right
                                    : isDesktop
                                        ? QuantityPosition.center
                                        : QuantityPosition.left,
                            productGroup:
                                sortingProvider.viewChangeTo ==
                                        ViewChangeTo.listView
                                    ? (ResponsiveHelper.isMobile()
                                        ? ProductGroup.common
                                        : ProductGroup.setMenu)
                                    : ProductGroup.common,
                            isShowBorder: true,
                            imageHeight: 110,
                            imageWidth: double.infinity,
                          );
                        },
                      ),
                      if (isDesktop)
                        Padding(
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeDefault),
                          child: loaderWidget,
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
