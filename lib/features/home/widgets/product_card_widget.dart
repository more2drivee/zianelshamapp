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
    this.imageHeight = 180,
    this.imageWidth = double.infinity,
    this.productGroup = ProductGroup.common,
    this.isShowBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);

    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    double? startingPrice = product.price;
    double? priceDiscount = PriceConverterHelper.convertDiscount(context, product.price, product.discount, product.discountType);
    bool isAvailable = ProductHelper.isProductAvailable(product: product);

    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        int cartIndex = cartProvider.getCartIndex(product);
        String productImage = '${splashProvider.baseUrls!.productImageUrl}/${product.image}';

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
              side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(isShowBorder ? 0.2 : 0)),
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            ),
            child: InkWell(
              onTap: () => ProductHelper.addToCart(cartIndex: cartIndex, product: product),
              hoverColor: Theme.of(context).primaryColor.withOpacity(0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صورة المنتج
                  Stack(
                    children: [
                      _ProductImageWidget(
                        imageHeight: imageHeight,
                        imageWidth: imageWidth,
                        productImage: productImage,
                        productGroup: productGroup,
                      ),
                      StockTagWidget(product: product, productGroup: productGroup),
                      Positioned(
                        right: localizationProvider.isLtr ? Dimensions.paddingSizeSmall : null,
                        top: Dimensions.paddingSizeSmall,
                        left: localizationProvider.isLtr ? null : Dimensions.paddingSizeSmall,
                        child: WishButtonWidget(product: product),
                      ),
                      if (product.discount != null && product.discount != 0)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: _DiscountTagWidget(product: product, productGroup: productGroup),
                        ),
                    ],
                  ),

                  // Spacer يخلي التفاصيل تنزل لتحت
                  const Spacer(),

                  // تفاصيل المنتج (الاسم + السعر)
                  _ProductDescriptionWidget(
                    product: product,
                    priceDiscount: priceDiscount,
                    startingPrice: startingPrice,
                    productGroup: productGroup,
                  ),

                  const SizedBox(height: 8),

                  // زرار Add to Cart تحت خالص
                  if (productProvider.checkStock(product) && isAvailable)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: AddToCartButtonWidget(product: product),
                    ),
                ],
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
      borderRadius: BorderRadius.zero,
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
  });

  final Product product;
  final double? priceDiscount;
  final double? startingPrice;
  final ProductGroup productGroup;

  @override
  Widget build(BuildContext context) {
    final isCenterAlign = productGroup == ProductGroup.chefRecommendation ||
        productGroup == ProductGroup.setMenu ||
        productGroup == ProductGroup.branchProduct ||
        (productGroup == ProductGroup.frequentlyBought && !ResponsiveHelper.isDesktop(context));

    final configModel = Provider.of<SplashProvider>(context, listen: false).configModel;
    final isHalalTagAvailable = (product.branchProduct?.halalStatus == 1) && (configModel?.halalTagStatus == 1);

    final isLtr = Provider.of<LocalizationProvider>(context, listen: false).isLtr;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // ✅ زودنا المسافة لتحت شوية
      child: Column(
        crossAxisAlignment: isCenterAlign
            ? CrossAxisAlignment.center
            : (isLtr ? CrossAxisAlignment.start : CrossAxisAlignment.end),
        children: [
          Row(
            mainAxisAlignment: isCenterAlign
                ? MainAxisAlignment.center
                : (isLtr ? MainAxisAlignment.start : MainAxisAlignment.end),
            children: [
              Flexible(
                child: Text(
                  product.name!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: isCenterAlign ? TextAlign.center : (isLtr ? TextAlign.left : TextAlign.right),
                  style: rubikSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
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
          const SizedBox(height: 8), // ✅ مسافة إضافية بين الاسم والتقييم
          product.rating!.isNotEmpty && product.rating![0].average! > 0.0
              ? RatingBarWidget(
                  rating: product.rating![0].average!,
                  size: 16,
                )
              : const SizedBox(),
          const SizedBox(height: 12), // ✅ مسافة إضافية قبل السعر
          Row(
            mainAxisAlignment: isCenterAlign ? MainAxisAlignment.center : (isLtr ? MainAxisAlignment.start : MainAxisAlignment.end),
            children: [
              if (priceDiscount! > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: CustomDirectionalityWidget(
                    child: Text(
                      PriceConverterHelper.convertPrice(startingPrice),
                      style: rubikRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        decoration: TextDecoration.lineThrough,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                ),
              CustomDirectionalityWidget(
                child: Text(
                  PriceConverterHelper.convertPrice(
                    startingPrice,
                    discount: product.discount,
                    discountType: product.discountType,
                  ),
                  style: rubikBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
              ),
            ],
          ),
        ],
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
        PriceConverterHelper.getDiscountType(discount: product.discount, discountType: product.discountType),
        style: rubikBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
      ),
    );
  }
}
