import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/models/config_model.dart';
import 'package:flutter_restaurant/common/widgets/custom_asset_image_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_pop_scope_widget.dart';
import 'package:flutter_restaurant/common/widgets/third_party_chat_widget.dart';
import 'package:flutter_restaurant/features/address/providers/location_provider.dart';
import 'package:flutter_restaurant/features/branch/providers/branch_provider.dart';
import 'package:flutter_restaurant/features/branch/screens/branch_list_screen.dart';
import 'package:flutter_restaurant/features/auth/providers/auth_provider.dart';
import 'package:flutter_restaurant/features/cart/providers/cart_provider.dart';
import 'package:flutter_restaurant/features/cart/screens/cart_screen.dart';
import 'package:flutter_restaurant/features/dashboard/widgets/bottom_nav_item_widget.dart';
import 'package:flutter_restaurant/features/home/screens/home_screen.dart';
import 'package:flutter_restaurant/features/menu/screens/menu_screen.dart';
import 'package:flutter_restaurant/features/order/providers/order_provider.dart';
import 'package:flutter_restaurant/features/order/screens/order_screen.dart';
import 'package:flutter_restaurant/features/profile/providers/profile_provider.dart';
import 'package:flutter_restaurant/features/refer_and_earn/widgets/refer_use_bottom_sheet_widget.dart';
import 'package:flutter_restaurant/features/splash/providers/splash_provider.dart';
import 'package:flutter_restaurant/features/wishlist/screens/wishlist_screen.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/app_localization.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  const DashboardScreen({super.key, required this.pageIndex});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();



  @override
  void initState() {
    super.initState();

    _pageIndex = widget.pageIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showReferUseBottomSheet();
    });


    
    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final LocationProvider locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);



    if(splashProvider.policyModel == null) {
      Provider.of<SplashProvider>(context, listen: false).getPolicyPage();
    }

    if(authProvider.getGuestId() != null || authProvider.isLoggedIn()) {
      Provider.of<LocationProvider>(context, listen: false).initAddressList();
    }

    if(!kIsWeb) {
       locationProvider.onSelectCurrentLocation(context);
    }





    Provider.of<OrderProvider>(context, listen: false).changeStatus(true);


    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      Provider.of<BranchProvider>(context, listen: false).getBranchId() != -1
          ? const HomeScreen(false) : const BranchListScreen(),
      Provider.of<BranchProvider>(context, listen: false).getBranchId() != -1
          ? const WishListScreen() : const BranchListScreen(),
      Provider.of<BranchProvider>(context, listen: false).getBranchId() != -1
          ? const CartScreen() :  const BranchListScreen(),
      Provider.of<BranchProvider>(context, listen: false).getBranchId() != -1
          ? const OrderScreen() : const BranchListScreen(),
      MenuScreen(onTap: (int pageIndex) {
         _setPage(pageIndex);
      }),
    ];
  }


  void _showReferUseBottomSheet() {

    ConfigModel ? config = Provider.of<SplashProvider>(context, listen: false).configModel;
    final  profileProvider = Provider.of<ProfileProvider>(Get.context!, listen: false);
    final  authProvider = Provider.of<AuthProvider>(Get.context!, listen: false);

    if(authProvider.isLoggedIn() && (config?.referEarnStatus ?? false) && (config?.customerReferredDiscountStatus ?? false)){
      profileProvider.getUserInfo(true, isUpdate: true).then((value) async {
        var userData = profileProvider.userInfoModel;
        double discountAmount = userData?.referralCustomerDetails?.customerDiscountAmount ?? 0;
        if( userData !=null && discountAmount > 0 && userData.referralCustomerDetails != null && userData.referralCustomerDetails!.isChecked == 0 && userData.referralCustomerDetails!.isUsed == 0){
          ResponsiveHelper.showDialogOrBottomSheet(Get.context!,
              ReferUseBottomSheetWidget(referralDetails: userData.referralCustomerDetails!));
        }
      });
    }

  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return CustomPopScopeWidget(
      isExit: _pageIndex == 0,
      onPopInvoked: () async {
        if (_pageIndex != 0) {
          _setPage(0);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        floatingActionButton: null,



      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _screens.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _screens[index];
            },
          ),

          const SizedBox.shrink(),

        ],
      ),
    ));
  }



  void _setPage(int pageIndex) {
    _pageController?.jumpToPage(pageIndex);
    setState(() {
      _pageIndex = pageIndex;
    });

  }
  
}


