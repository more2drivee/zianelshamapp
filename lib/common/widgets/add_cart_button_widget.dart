import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/models/product_model.dart';
import 'package:flutter_restaurant/features/cart/providers/cart_provider.dart';
import 'package:flutter_restaurant/helper/product_helper.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:provider/provider.dart';

class AddToCartButtonWidget extends StatelessWidget {
  const AddToCartButtonWidget({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        int quantity = cartProvider.getCartProductQuantityCount(product);
        int cartIndex = cartProvider.getCartIndex(product);

        const double buttonHeight = 44;

        return SizedBox(
          height: buttonHeight,
          width: double.infinity,
          child: Material(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).primaryColor,
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: quantity == 0
                  ? () => ProductHelper.addToCart(
                        cartIndex: cartIndex,
                        product: product,
                      )
                  : null,
child: Center(
  child: quantity == 0
      ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 26,
              width: 26,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: Icon(Icons.add, size: 18, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 8),
            Text(
              'Add',
              style: rubikBold.copyWith(
                color: Colors.white,
                fontSize: isDesktop ? Dimensions.fontSizeLarge : Dimensions.fontSizeDefault,
                letterSpacing: 0.3,
              ),
            ),
          ],
        )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => cartProvider.onUpdateCartQuantity(
                              index: cartIndex,
                              product: product,
                              isRemove: true,
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.remove,
                                  size: 18,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(quantity.toString(), style: rubikBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => cartProvider.onUpdateCartQuantity(
                              index: cartIndex,
                              product: product,
                              isRemove: false,
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add,
                                  size: 18,
                                  color: Theme.of(context).primaryColor),
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
