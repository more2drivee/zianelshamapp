import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_restaurant/common/widgets/product_shimmer_widget.dart';
import 'package:flutter_restaurant/common/widgets/paginated_list_widget.dart';
import 'package:flutter_restaurant/features/home/enums/product_group_enum.dart';
import 'package:flutter_restaurant/features/home/enums/quantity_position_enum.dart';
import 'package:flutter_restaurant/features/home/enums/view_change_to_enum.dart';
import 'package:flutter_restaurant/features/home/providers/sorting_provider.dart';
import 'package:flutter_restaurant/features/home/widgets/product_card_widget.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/common/providers/product_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:provider/provider.dart';

class ProductViewWidget extends StatelessWidget {
  final ScrollController scrollController;
  const ProductViewWidget({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        final products = productProvider.latestProductModel?.products;

        if (products == null) {
          return const _ProductListShimmerWidget();
        }

        if (products.isEmpty) {
          return const Center(child: Text("No products available"));
        }

        return PaginatedListWidget(
          scrollController: scrollController,
          onPaginate: (int? offset) async {
            await productProvider.getLatestProductList(offset ?? 1, false);
          },
          totalSize: productProvider.latestProductModel?.totalSize,
          offset: productProvider.latestProductModel?.offset,
          limit: productProvider.latestProductModel?.limit,
          isDisableWebLoader: !isDesktop,
          builder: (loaderWidget) {
            return Column(
              children: [
                Consumer<ProductSortProvider>(
                  builder: (context, sortingProvider, child) => GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 3 : 2,
                      crossAxisSpacing: Dimensions.paddingSizeSmall,
                      mainAxisSpacing: Dimensions.paddingSizeSmall,
                      mainAxisExtent: ResponsiveHelper.isMobile()
                          ? 360
                          : (sortingProvider.viewChangeTo == ViewChangeTo.gridView
                              ? (kIsWeb ? 300 : 340)
                              : (kIsWeb ? 260 : 280)),
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
                            ? (sortingProvider.viewChangeTo == ViewChangeTo.listView
                                ? (kIsWeb ? 130 : 150)
                                : (kIsWeb ? 160 : 180))
                            : 130,
                        imageWidth: (isDesktop || ResponsiveHelper.isTab(context)) &&
                                sortingProvider.viewChangeTo == ViewChangeTo.listView
                            ? 220
                            : double.infinity,
                      );
                    },
                  ),
                ),

              
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

class _ProductListShimmerWidget extends StatelessWidget {
  const _ProductListShimmerWidget();

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
          itemCount: 10,
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
