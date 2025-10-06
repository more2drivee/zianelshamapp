import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/providers/product_provider.dart';
import 'package:flutter_restaurant/common/widgets/custom_alert_dialog_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_asset_image_widget.dart';
import 'package:flutter_restaurant/features/auth/providers/auth_provider.dart';
import 'package:flutter_restaurant/features/category/providers/category_provider.dart' show CategoryProvider;
import 'package:flutter_restaurant/features/language/providers/localization_provider.dart';
import 'package:flutter_restaurant/features/menu/widgets/portion_widget.dart';
import 'package:flutter_restaurant/features/scaner/screens/scaner_screen.dart';
import 'package:flutter_restaurant/features/splash/providers/splash_provider.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../common/providers/theme_provider.dart';

class OptionsWidget extends StatelessWidget {
  final Function? onTap;
  const OptionsWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool isLoggedIn = authProvider.isLoggedIn();

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) => ListView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [

          // ✅ AppBar فيه Guest + Dark Mode + Language + Favourite
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeLarge),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        color: ThemeData.estimateBrightnessForColor(
                                    Theme.of(context).primaryColor) ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLoggedIn ? "User" : "Guest",
                          style: rubikSemiBold.copyWith(
                            fontSize: 16,
                            color: ThemeData.estimateBrightnessForColor(
                                        Theme.of(context).primaryColor) ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (!isLoggedIn) {
                              RouterHelper.getOtpVerificationScreen();
                            } else {
                              authProvider.clearSharedData(context);
                            }
                          },
                          child: Text(
                            isLoggedIn
                                ? getTranslated('logout', context)!
                                : getTranslated('sign_up_or_login', context)!,
                            style: rubikRegular.copyWith(
                              fontSize: 13,
                              color: ThemeData.estimateBrightnessForColor(
                                          Theme.of(context).primaryColor) ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.brightness_6,
                        size: 28,
                        color: ThemeData.estimateBrightnessForColor(
                                    Theme.of(context).primaryColor) ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      onPressed: () {
                        Provider.of<ThemeProvider>(context, listen: false)
                            .toggleTheme();
                      },
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        size: 28,
                        color: ThemeData.estimateBrightnessForColor(
                                    Theme.of(context).primaryColor) ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      onPressed: () {
                        RouterHelper.getDashboardRoute('favourite');
                      },
                    ),
                    const SizedBox(width: 20),
                    Consumer<LocalizationProvider>(
                      builder: (context, localizationProvider, __) {
                        final isArabic =
                            localizationProvider.locale.languageCode == 'ar';
                        final nextLocale = isArabic
                            ? const Locale('en', 'US')
                            : const Locale('ar', 'SA');

                        final textColor =
                            ThemeData.estimateBrightnessForColor(
                                        Theme.of(context).primaryColor) ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black;

                        return TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            await Provider.of<LocalizationProvider>(context,
                                    listen: false)
                                .setLanguage(nextLocale, isDataUpdate: true);
                            Provider.of<ProductProvider>(context, listen: false)
                                .getLatestProductList(1, true);
                            Provider.of<CategoryProvider>(context, listen: false)
                                .getCategoryList(true);
                          },
                          child: Text(
                            isArabic ? 'EN' : 'العربية',
                            style: rubikBold.copyWith(
                                fontSize: 14, color: textColor),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ✅ باقي عناصر المنيو
          Column(
            children: [
              PortionWidget(
                  imageIcon: Images.profileSvg,
                  title: getTranslated('profile', context)!,
                  onRoute: () => RouterHelper.getProfileRoute(),
                  iconSize: 28),
              PortionWidget(
                  imageIcon: Images.ordersSvg,
                  title: getTranslated('my_order', context)!,
                  onRoute: () => RouterHelper.getDashboardRoute('order'),
                  iconSize: 28),
              PortionWidget(
                  imageIcon: Images.trackOrder,
                  title: getTranslated('order_details', context)!,
                  onRoute: () => RouterHelper.getOrderSearchScreen(),
                  iconSize: 28),
              PortionWidget(
                  imageIcon: Images.notification,
                  title: getTranslated('notification', context)!,
                  onRoute: () => RouterHelper.getNotificationRoute(),
                  iconSize: 28),

              if (splashProvider.configModel?.walletStatus ?? false)
                PortionWidget(
                    imageIcon: Images.walletSvg,
                    title: getTranslated('wallet', context)!,
                    onRoute: () => RouterHelper.getWalletRoute(),
                    iconSize: 28),

              if (splashProvider.configModel?.loyaltyPointStatus ?? false)
                PortionWidget(
                    imageIcon: Images.loyaltyPointsSvg,
                    title: getTranslated('loyalty_point', context)!,
                    onRoute: () => RouterHelper.getLoyaltyScreen(),
                    iconSize: 28),

              if (!kIsWeb)
                PortionWidget(
                    imageIcon: Images.scanner,
                    title: getTranslated('qr_scan', context)!,
                    onRoute: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScannerScreen(),
                        ),
                      );
                    },
                    iconSize: 28),

              PortionWidget(
                  imageIcon: Images.addressSvg,
                  title: getTranslated('address', context)!,
                  onRoute: () => RouterHelper.getAddressRoute(),
                  iconSize: 28),

              PortionWidget(
                  imageIcon: Images.addressSvg,
                  title: getTranslated('show_branch', context) ?? 'show_branch',
                  onRoute: () => RouterHelper.getBranchListScreen(),
                  iconSize: 28),

              PortionWidget(
                  imageIcon: Images.messageSvg,
                  title: getTranslated('message', context)!,
                  onRoute: () => RouterHelper.getChatRoute(),
                  iconSize: 28),

              PortionWidget(
                  imageIcon: Images.couponSvg,
                  title: getTranslated('coupon', context)!,
                  onRoute: () => RouterHelper.getCouponRoute(),
                  iconSize: 28),

              if (splashProvider.configModel?.referEarnStatus ?? false)
                PortionWidget(
                    imageIcon: Images.usersSvg,
                    title: getTranslated('refer_and_earn', context)!,
                    onRoute: () => RouterHelper.getReferAndEarnRoute(),
                    iconSize: 28),

              PortionWidget(
                  imageIcon: Images.supportSvg,
                  title: getTranslated('help_and_support', context)!,
                  onRoute: () => RouterHelper.getSupportRoute(),
                  iconSize: 28),

              PortionWidget(
                  imageIcon: Images.documentSvg,
                  title: getTranslated('privacy_policy', context)!,
                  onRoute: () => RouterHelper.getPolicyRoute(),
                  iconSize: 28),

              PortionWidget(
                  imageIcon: Images.documentAltSvg,
                  title: getTranslated('terms_and_condition', context)!,
                  onRoute: () => RouterHelper.getTermsRoute(),
                  iconSize: 28),

              if (splashProvider.policyModel?.returnPage?.status ?? false)
                PortionWidget(
                    imageIcon: Images.invoiceSvg,
                    title: getTranslated('return_policy', context)!,
                    onRoute: () => RouterHelper.getReturnPolicyRoute(),
                    iconSize: 28),

              if (splashProvider.policyModel?.refundPage?.status ?? false)
                PortionWidget(
                    imageIcon: Images.refundSvg,
                    title: getTranslated('refund_policy', context)!,
                    onRoute: () => RouterHelper.getRefundPolicyRoute(),
                    iconSize: 28),

              if (splashProvider.policyModel?.cancellationPage?.status ?? false)
                PortionWidget(
                    imageIcon: Images.cancellationSvg,
                    title: getTranslated('cancellation_policy', context)!,
                    onRoute: () =>
                        RouterHelper.getCancellationPolicyRoute(),
                    iconSize: 28),

              PortionWidget(
                  imageIcon: Images.infoSvg,
                  title: getTranslated('about_us', context)!,
                  onRoute: () => RouterHelper.getAboutUsRoute(),
                  iconSize: 28),

              // ✅ Delete account + Logout/Login
              isLoggedIn
                  ? PortionWidget(
                      iconColor: Theme.of(context).primaryColor,
                      icon: Icons.delete,
                      imageIcon: null,
                      title: getTranslated('delete_account', context)!,
                      onRoute: () => ResponsiveHelper.showDialogOrBottomSheet(
                          context,
                          Consumer<AuthProvider>(
                              builder: (context, authProvider, _) {
                        return CustomAlertDialogWidget(
                          isLoading: authProvider.isLoading,
                          title: getTranslated(
                              'are_you_sure_to_delete_account', context),
                          subTitle: getTranslated(
                              'it_will_remove_your_all_information', context),
                          icon: Icons.question_mark_sharp,
                          isSingleButton: authProvider.isLoading,
                          leftButtonText: getTranslated('yes', context),
                          rightButtonText: getTranslated('no', context),
                          onPressLeft: () => authProvider.deleteUser(),
                        );
                      })),
                      iconSize: 28,
                    )
                  : const SizedBox(),

              InkWell(
                onTap: () {
                  if (authProvider.isLoggedIn()) {
                    ResponsiveHelper.showDialogOrBottomSheet(
                      context,
                      Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                        return CustomAlertDialogWidget(
                          isLoading: authProvider.isLoading,
                          title: getTranslated('want_to_sign_out', context),
                          icon: Icons.contact_support,
                          isSingleButton: authProvider.isLoading,
                          leftButtonText: getTranslated('yes', context),
                          rightButtonText: getTranslated('no', context),
                          onPressLeft: () {
                            authProvider.clearSharedData(context).then((_) {
                              if (context.mounted) {
                                if (ResponsiveHelper.isWeb()) {
                                  RouterHelper.getOtpVerificationScreen();
                                } else {
                                  context.pop();
                                  RouterHelper.getMainRoute();
                                }
                              }
                            });
                          },
                        );
                      }),
                    );
                  } else {
                    RouterHelper.getOtpVerificationScreen();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(
                          Dimensions.paddingSizeExtraSmall),
                      margin: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                      child: CustomAssetImageWidget(
                        isLoggedIn ? Images.logoutSvg : Images.login,
                        height: 20,
                        width: 20,
                        color: isLoggedIn
                            ? null
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                        getTranslated(
                            isLoggedIn ? 'logout' : 'login', context)!,
                        style: rubikRegular),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


