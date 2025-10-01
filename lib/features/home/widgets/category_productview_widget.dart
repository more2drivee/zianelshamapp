import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/product_shimmer_widget.dart';
import 'package:flutter_restaurant/common/widgets/paginated_list_widget.dart';
import 'package:flutter_restaurant/features/home/enums/product_group_enum.dart';
import 'package:flutter_restaurant/features/home/enums/quantity_position_enum.dart';
import 'package:flutter_restaurant/features/home/enums/view_change_to_enum.dart';
import 'package:flutter_restaurant/features/home/providers/sorting_provider.dart';
import 'package:flutter_restaurant/features/home/widgets/product_card_widget.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:flutter_restaurant/features/category/providers/category_provider.dart';

class CategoryProductViewWidget extends StatelessWidget {
  final ScrollController scrollController;
  const CategoryProductViewWidget({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, _) {
        return PaginatedListWidget(
          scrollController: scrollController, 
          onPaginate: (int? offset) async {
            await categoryProvider.getCategoryProductList(
              categoryProvider.selectedSubCategoryId ?? '',
              offset ?? 1,
            );
          },
          totalSize: categoryProvider.categoryProductModel?.totalSize,
          offset: categoryProvider.categoryProductModel?.offset,
          limit: categoryProvider.categoryProductModel?.limit,
          isDisableWebLoader: !isDesktop,
          builder: (loaderWidget) {
            final products = categoryProvider.categoryProductModel?.products;

            if (products == null) {
              return const _CategoryProductShimmerWidget();
            }

            if (products.isEmpty) {
              return const Center(child: Text("No products available in this category"));
            }

            return Column(
              children: [
                Consumer<ProductSortProvider>(
                  builder: (context, sortingProvider, child) => GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: Dimensions.paddingSizeSmall,
                      mainAxisSpacing: Dimensions.paddingSizeSmall,
                      mainAxisExtent: ResponsiveHelper.isMobile()
                          ? 360
                          : (sortingProvider.viewChangeTo == ViewChangeTo.gridView ? 400 : 300),
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCardWidget(
                        product: product,
                        quantityPosition: sortingProvider.viewChangeTo == ViewChangeTo.listView
                            ? QuantityPosition.right
                            : isDesktop
                                ? QuantityPosition.center
                                : QuantityPosition.left,
                        productGroup: sortingProvider.viewChangeTo == ViewChangeTo.listView
                            ? (ResponsiveHelper.isMobile()
                                ? ProductGroup.common
                                : ProductGroup.setMenu)
                            : ProductGroup.common,
                        isShowBorder: true,
                        imageHeight: !ResponsiveHelper.isMobile()
                            ? (sortingProvider.viewChangeTo == ViewChangeTo.listView ? 160 : 220)
                            : 130,
                        imageWidth: (isDesktop || ResponsiveHelper.isTab(context)) &&
                                sortingProvider.viewChangeTo == ViewChangeTo.listView
                            ? 220
                            : double.infinity,
                      );
                    },
                  ),
                ),

                // ✅ اللودر في الآخر
                if (isDesktop)
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: loaderWidget,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _CategoryProductShimmerWidget extends StatelessWidget {
  const _CategoryProductShimmerWidget();

  @override
  Widget build(BuildContext context) {
    final double realSpaceNeeded =
        (MediaQuery.sizeOf(context).width - Dimensions.webScreenWidth) / 2;
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: isDesktop
            ? EdgeInsets.symmetric(
                horizontal: realSpaceNeeded,
                vertical: Dimensions.paddingSizeSmall,
              )
            : const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 1000,
            crossAxisSpacing: Dimensions.paddingSizeSmall,
            mainAxisSpacing: Dimensions.paddingSizeSmall,
            mainAxisExtent: !isDesktop ? 240 : 300,
          ),
          itemCount: 15,
          itemBuilder: (context, index) {
            return const ProductShimmerWidget(
              isEnabled: true,
              width: double.minPositive,
              isList: false,
            );
          },
        ),
      ),
    );
  }
}
