import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/enums/data_source_enum.dart';
import 'package:flutter_restaurant/common/providers/product_provider.dart';
import 'package:flutter_restaurant/common/widgets/custom_asset_image_widget.dart';
import 'package:flutter_restaurant/common/widgets/footer_widget.dart';
import 'package:flutter_restaurant/common/widgets/sliver_delegate_widget.dart';
import 'package:flutter_restaurant/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_restaurant/common/providers/theme_provider.dart';
import 'package:flutter_restaurant/features/address/providers/location_provider.dart';
import 'package:flutter_restaurant/features/auth/providers/auth_provider.dart';
import 'package:flutter_restaurant/features/branch/providers/branch_provider.dart';
import 'package:flutter_restaurant/features/cart/providers/frequently_bought_provider.dart';
import 'package:flutter_restaurant/features/category/providers/category_provider.dart';
import 'package:flutter_restaurant/features/home/providers/banner_provider.dart';
import 'package:flutter_restaurant/features/home/widgets/banner_widget.dart';
import 'package:flutter_restaurant/features/home/widgets/category_productview_widget.dart';
import 'package:flutter_restaurant/features/home/widgets/category_web_widget.dart';
import 'package:flutter_restaurant/features/home/widgets/product_view_widget.dart';
import 'package:flutter_restaurant/features/home/widgets/whats_new_section_widget.dart'
    show WhatsNewSectionWidget;
import 'package:flutter_restaurant/features/menu/widgets/options_widget.dart';
import 'package:flutter_restaurant/features/order/providers/order_provider.dart';
import 'package:flutter_restaurant/features/profile/providers/profile_provider.dart';
import 'package:flutter_restaurant/features/notification/providers/notification_provider.dart';
import 'package:flutter_restaurant/features/cart/providers/cart_provider.dart';
import 'package:flutter_restaurant/features/search/providers/search_provider.dart';
import 'package:flutter_restaurant/features/splash/providers/splash_provider.dart';
import 'package:flutter_restaurant/features/wishlist/providers/wishlist_provider.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:provider/provider.dart';
import 'mobile_home_screen.dart';
import 'package:flutter_restaurant/features/home/widgets/chefs_recommendation_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_image_widget.dart';
import 'package:flutter_restaurant/features/language/providers/language_provider.dart';
import 'package:flutter_restaurant/features/language/providers/localization_provider.dart';
import 'package:flutter_restaurant/common/widgets/new_item_widget.dart';

class HomeScreen extends StatefulWidget {
  final bool fromAppBar;
  const HomeScreen(this.fromAppBar, {super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static Future<void> loadData(bool reload, {bool isFcmUpdate = false}) async {
    final productProvider =
        Provider.of<ProductProvider>(Get.context!, listen: false);
    final categoryProvider =
        Provider.of<CategoryProvider>(Get.context!, listen: false);
    final splashProvider =
        Provider.of<SplashProvider>(Get.context!, listen: false);
    final bannerProvider =
        Provider.of<BannerProvider>(Get.context!, listen: false);
    final profileProvider =
        Provider.of<ProfileProvider>(Get.context!, listen: false);
    final wishListProvider =
        Provider.of<WishListProvider>(Get.context!, listen: false);
    final searchProvider =
        Provider.of<SearchProvider>(Get.context!, listen: false);
    final frequentlyBoughtProvider =
        Provider.of<FrequentlyBoughtProvider>(Get.context!, listen: false);

    final isLogin =
        Provider.of<AuthProvider>(Get.context!, listen: false).isLoggedIn();

    if (isLogin) {
      profileProvider.getUserInfo(reload, isUpdate: reload);
      if (isFcmUpdate) {
        Provider.of<AuthProvider>(Get.context!, listen: false).updateToken();
      }
    } else {
      profileProvider.setUserInfoModel = null;
    }
    wishListProvider.initWishList();

    if (productProvider.latestProductModel == null || reload) {
      productProvider.getLatestProductList(1, reload);
    }

    if (reload || productProvider.popularLocalProductModel == null) {
      productProvider.getPopularLocalProductList(1, true, isUpdate: false);
    }

    if (reload) {
      splashProvider.getPolicyPage();
    }
    categoryProvider.getCategoryList(reload, source: DataSourceEnum.local);

    if (productProvider.flavorfulMenuProductMenuModel == null || reload) {
      productProvider.getFlavorfulMenuProductMenuList(1, reload);
    }

    if (productProvider.recommendedProductModel == null || reload) {
      productProvider.getRecommendedProductList(1, reload);
    }

    bannerProvider.getBannerList(reload);
    searchProvider.getCuisineList(isReload: reload);
    searchProvider.getSearchRecommendedData(isReload: reload);
    frequentlyBoughtProvider.getFrequentlyBoughtProduct(1, reload);
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> drawerGlobalKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final branchProvider =
        Provider.of<BranchProvider>(Get.context!, listen: false);
    branchProvider.getBranchValueList(context);
    HomeScreen.loadData(false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .getNotificationList(context);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);

      if (!categoryProvider.isCategorySelected) {
        productProvider.getLatestProductList(1, true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      key: drawerGlobalKey,

      //  Drawer من اليمين بعرض 60% + هيدر Guest
      endDrawer: SizedBox(
  width: MediaQuery.of(context).size.width * 0.7,
  child: const Drawer(
    child: OptionsWidget(onTap: null),
  ),
),


      endDrawerEnableOpenDragGesture: false,
      appBar: isDesktop
          ? const PreferredSize(
              preferredSize: Size.fromHeight(100), child: WebAppBarWidget())
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          Provider.of<OrderProvider>(context, listen: false)
              .changeStatus(true, notify: true);
          Provider.of<SplashProvider>(context, listen: false)
              .initConfig(context, DataSourceEnum.client)
              .then((value) {
            if (value != null) {
              HomeScreen.loadData(true);
            }
          });
        },
        backgroundColor: Theme.of(context).primaryColor,
        color: Theme.of(context).cardColor,
        child: Consumer<ProductProvider>(
          builder: (context, productProvider, _) => CustomScrollView(
            controller: _scrollController,
            slivers: [
              if (!isDesktop)
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: 90,
                  automaticallyImplyLeading: false,
                  leadingWidth: 160,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Consumer<SplashProvider>(
                      builder: (context, splash, child) {
                        return splash.baseUrls != null
                            ? ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                    Colors.white, BlendMode.srcIn),
                                child: CustomImageWidget(
                                  image:
                                      '${splash.baseUrls?.restaurantImageUrl}/${splash.configModel!.restaurantLogo}',
                                  placeholder: Images.webAppBarLogo,
                                  fit: BoxFit.contain,
                                  width: 120,
                                  height: 70,
                                ),
                              )
                            : const SizedBox();
                      },
                    ),
                  ),
                  actions: [
                    Consumer<NotificationProvider>(
                      builder: (context, notificationProvider, _) {
                        final int notifCount =
                            notificationProvider.notificationList?.length ?? 0;
                        return IconButton(
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(Icons.notifications,
                                  color: Colors.white),
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                      minWidth: 14, minHeight: 14),
                                  child: Text(
                                    '$notifCount',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onPressed: () async {
                            await Provider.of<NotificationProvider>(context,
                                    listen: false)
                                .getNotificationList(context);
                            RouterHelper.getNotificationRoute();
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    Consumer<CartProvider>(
                      builder: (context, cartProvider, _) {
                        final int cartCount = cartProvider.cartList.fold(
                            0, (sum, item) => sum + (item?.quantity ?? 0));
                        if (cartCount <= 0) return const SizedBox();
                        return IconButton(
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(Icons.shopping_cart, color: Colors.white),
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                      minWidth: 14, minHeight: 14),
                                  child: Text(
                                    '$cartCount',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            RouterHelper.getDashboardRoute('cart');
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        drawerGlobalKey.currentState?.openEndDrawer();
                      },
                    ),
                    const SizedBox(width: 12),
                  ],
                  expandedHeight: 110,
                  floating: false,
                  elevation: 0,
                  backgroundColor: Theme.of(context).primaryColor,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(40),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 12, right: 12, bottom: 8),
                      child: Consumer<LocationProvider>(
                        builder: (context, locationProvider, _) {
                          return locationProvider.isLoading
                              ? const SizedBox()
                              : InkWell(
                                  onTap: () => RouterHelper.getAddressRoute(),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          size: 18, color: Colors.white),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          locationProvider
                                                  .currentAddress?.address ??
                                              getTranslated(
                                                  'no_location_selected',
                                                  context)!,
                                          style: rubikRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeLarge,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(Icons.expand_more,
                                          size: 18, color: Colors.white),
                                    ],
                                  ),
                                );
                        },
                      ),
                    ),
                  ),
                ),

              //  Search Bar
if (!isDesktop)
  SliverPersistentHeader(
    pinned: false,
    delegate: SliverDelegateWidget(
      child: Center(
        child: Container(
          // لون الخلفية يجب أن يكون داخل BoxDecoration عندما نستخدم decoration
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
            vertical: 8,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                blurRadius: 6,
                spreadRadius: 0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            readOnly: true, // يخلي الصندوق زرار يفتح صفحة البحث
            onTap: () => RouterHelper.getSearchRoute(),
            decoration: InputDecoration(
              hintText: getTranslated('are_you_hungry', context)!,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
              prefixIcon: Icon(Icons.search,
                  color: Colors.grey.shade500, size: 22),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
              ),
            ),
          ),
        ),
      ),
    ),
  ),
              //  Banner + محتوى الصفحة
              SliverToBoxAdapter(
                child: SizedBox(
                  width: Dimensions.webScreenWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer<BannerProvider>(
                        builder: (context, bannerProvider, _) {
                          return !(bannerProvider.bannerList?.isEmpty ??
                                  true)
                              ? const BannerWidget()
                              : const SizedBox();
                        },
                      ),
                      const ChefsRecommendationWidget(),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      const NewItemsWidget(),
                      const SizedBox(
                          height: Dimensions.paddingSizeDefault),
                      if (isDesktop)
                        Consumer<CategoryProvider>(
                          builder: (context, categoryProvider, _) {
                            return Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: categoryProvider
                                              .categoryList?.isNotEmpty ??
                                          false
                                      ? const CategoryWebWidget()
                                      : const SizedBox(),
                                ),
                                const SizedBox(
                                    width:
                                        Dimensions.paddingSizeDefault),
                                Expanded(
                                  flex: 4,
                                  child: !categoryProvider
                                          .isCategorySelected
                                      ? ProductViewWidget(
                                          scrollController:
                                              _scrollController)
                                      : CategoryProductViewWidget(
                                          scrollController:
                                              _scrollController),
                                ),
                              ],
                            );
                          },
                        )
                      else
                        MobileHomeScreen(
                            scrollController: _scrollController),
                    ],
                  ),
                ),
              ),

              if (isDesktop)
                const SliverToBoxAdapter(child: FooterWidget()),
            ],
          ),
        ),
      ),
    );
  }
}
