import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/models/config_model.dart';
import 'package:flutter_restaurant/common/models/product_model.dart';
import 'package:flutter_restaurant/common/widgets/add_cart_button_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_asset_image_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_directionality_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_image_widget.dart';
import 'package:flutter_restaurant/common/widgets/stock_tag_widget.dart';
import 'package:flutter_restaurant/common/widgets/wish_button_widget.dart';
import 'package:flutter_restaurant/features/cart/providers/cart_provider.dart';
import 'package:flutter_restaurant/features/home/enums/product_group_enum.dart';
import 'package:flutter_restaurant/features/home/enums/quantity_position_enum.dart';
import 'package:flutter_restaurant/features/language/providers/localization_provider.dart';
import 'package:flutter_restaurant/features/splash/providers/splash_provider.dart';
import 'package:flutter_restaurant/helper/price_converter_helper.dart';
import 'package:flutter_restaurant/helper/product_helper.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/common/providers/product_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:provider/provider.dart';
import '../../../common/widgets/rating_bar_widget.dart';

class ProductCardWidget extends StatelessWidget {
  final Product product;
  final QuantityPosition quantityPosition;
  final double imageHeight;
  final double imageWidth;
  final ProductGroup productGroup;
  final bool isShowBorder;

  const ProductCardWidget({
    super.key,
    required this.product,
    this.quantityPosition = QuantityPosition.left,
    this.imageHeight = 100,
    this.imageWidth = 220,
    this.productGroup = ProductGroup.common,
    this.isShowBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);

    final bool isLtr = localizationProvider.isLtr;
    double? startingPrice = product.price;
    double? priceDiscount = PriceConverterHelper.convertDiscount(
        context, product.price, product.discount, product.discountType);
    bool isAvailable = ProductHelper.isProductAvailable(product: product);

    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        int cartIndex = cartProvider.getCartIndex(product);
        String productImage =
            '${splashProvider.baseUrls!.productImageUrl}/${product.image}';

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.15),
                blurRadius: 6,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Material(
            color: Theme.of(context).cardColor,
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context)
                    .primaryColor
                    .withOpacity(isShowBorder ? 0.2 : 0),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () => ProductHelper.addToCart(
                  cartIndex: cartIndex, product: product),
              hoverColor: Theme.of(context).primaryColor.withOpacity(0.03),
              child: Directionality(
                textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
                child: Stack(
                  children: [
                    // صورة + تفاصيل المنتج
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            _ProductImageWidget(
                              imageHeight: imageHeight,
                              imageWidth: imageWidth,
                              productImage: productImage,
                              productGroup: productGroup,
                            ),
                            StockTagWidget(
                                product: product, productGroup: productGroup),
                            Positioned(
                              right: isLtr
                                  ? Dimensions.paddingSizeSmall
                                  : null,
                              top: Dimensions.paddingSizeSmall,
                              left: isLtr
                                  ? null
                                  : Dimensions.paddingSizeSmall,
                              child: WishButtonWidget(product: product),
                            ),
                            if (product.discount != null && product.discount != 0)
                              Positioned(
                                top: 12,
                                left: 12,
                                child: _DiscountTagWidget(
                                    product: product,
                                    productGroup: productGroup),
                              ),
                          ],
                        ),
                        _ProductDescriptionWidget(
                          product: product,
                          priceDiscount: priceDiscount,
                          startingPrice: startingPrice,
                          productGroup: productGroup,
                          isLtr: isLtr,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),

                    // ✅ السعر + البلص في الزاوية السفلية
                    Positioned(
                      bottom: 8,
                      left: isLtr ? 12 : null,
                      right: isLtr ? null : 12,
                      child: CustomDirectionalityWidget(
                        child: Text(
                          PriceConverterHelper.convertPrice(
                            startingPrice,
                            discount: product.discount,
                            discountType: product.discountType,
                          ),
                          textAlign:
                              isLtr ? TextAlign.left : TextAlign.right,
                          style: rubikBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge),
                        ),
                      ),
                    ),

                   if (productProvider.checkStock(product) && isAvailable)
  Positioned(
    bottom: 2, // ⬅️ قرب أكتر من الحافة السفلية
    right: isLtr ? 2 : null, // ⬅️ قرب أكتر من الحافة اليمنى
    left: isLtr ? null : 2,  // ⬅️ في حالة اللغة العربية
    child: InkWell(
      onTap: () => ProductHelper.addToCart(
          cartIndex: cartIndex, product: product),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 28, // ⬅️ صغّرها سنة كمان
        width: 28,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.15),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.add, color: Colors.white, size: 16),
      ),
    ),
  ),

                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProductImageWidget extends StatelessWidget {
  const _ProductImageWidget({
    required this.imageHeight,
    required this.imageWidth,
    required this.productImage,
    required this.productGroup,
  });

  final double imageHeight;
  final double imageWidth;
  final String productImage;
  final ProductGroup productGroup;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: CustomImageWidget(
        placeholder: Images.placeholderRectangle,
        fit: BoxFit.cover,
        height: imageHeight,
        width: imageWidth,
        image: productImage,
      ),
    );
  }
}

class _ProductDescriptionWidget extends StatelessWidget {
  const _ProductDescriptionWidget({
    required this.product,
    required this.priceDiscount,
    required this.startingPrice,
    required this.productGroup,
    required this.isLtr,
  });

  final Product product;
  final double? priceDiscount;
  final double? startingPrice;
  final ProductGroup productGroup;
  final bool isLtr;

  @override
  Widget build(BuildContext context) {
    final isCenterAlign = productGroup == ProductGroup.chefRecommendation ||
        productGroup == ProductGroup.setMenu ||
        productGroup == ProductGroup.branchProduct ||
        (productGroup == ProductGroup.frequentlyBought &&
            !ResponsiveHelper.isDesktop(context));

    final configModel =
        Provider.of<SplashProvider>(context, listen: false).configModel;
    final isHalalTagAvailable =
        (product.branchProduct?.halalStatus == 1) &&
            (configModel?.halalTagStatus == 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Directionality(
        textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
        child: Column(
          crossAxisAlignment: isCenterAlign
              ? CrossAxisAlignment.center
              : (isLtr ? CrossAxisAlignment.start : CrossAxisAlignment.end),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: isCenterAlign
                  ? MainAxisAlignment.center
                  : (isLtr ? MainAxisAlignment.start : MainAxisAlignment.end),
              children: [
                Expanded(
                  child: Text(
                    product.name ?? '',
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: isCenterAlign
                        ? TextAlign.center
                        : (isLtr ? TextAlign.left : TextAlign.right),
                    style:
                        rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                ),
                if (isHalalTagAvailable) const SizedBox(width: 6),
                if (isHalalTagAvailable)
                  CustomAssetImageWidget(
                    Images.halalIconSvg,
                    height: 18,
                    width: 18,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            product.rating!.isNotEmpty && product.rating![0].average! > 0.0
                ? RatingBarWidget(
                    rating: product.rating![0].average!,
                    size: 16,
                  )
                : const SizedBox(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DiscountTagWidget extends StatelessWidget {
  const _DiscountTagWidget({required this.product, required this.productGroup});

  final Product product;
  final ProductGroup productGroup;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        PriceConverterHelper.getDiscountType(
            discount: product.discount, discountType: product.discountType),
        style: rubikBold.copyWith(
            color: Colors.white, fontSize: Dimensions.fontSizeSmall),
      ),
    );
  }
}
