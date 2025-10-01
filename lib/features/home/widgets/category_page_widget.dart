import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/providers/theme_provider.dart';
import 'package:flutter_restaurant/common/widgets/custom_image_widget.dart';
import 'package:flutter_restaurant/features/category/providers/category_provider.dart';
import 'package:flutter_restaurant/features/splash/providers/splash_provider.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:provider/provider.dart';

class CategoryPageWidget extends StatefulWidget {
  
  final CategoryProvider categoryProvider;

  const CategoryPageWidget({super.key, required this.categoryProvider});

  @override
  State<CategoryPageWidget> createState() => _CategoryPageWidgetState();
}

class _CategoryPageWidgetState extends State<CategoryPageWidget> {
   bool _didPrint = false; // عشان نمنع الطباعة أكثر من مرة

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didPrint) {
      final categoryList = widget.categoryProvider.categoryList;

      if (categoryList != null) {
        for (var i = 0; i < categoryList.length; i++) {
          final category = categoryList[i];
          print("[$i] => Name: ${category}");
        }
      } else {
        print("Category list is null or still loading.");
      }

      _didPrint = true; // عشان نطبع مرة واحدة بس
    }
  }
  int categoryLength = 0;

  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _pageController = PageController(
      viewportFraction: MediaQuery.of(context).size.width < 400
          ? 0.5
          : MediaQuery.of(context).size.width < 600
              ? 0.33
              : MediaQuery.of(context).size.width < 1024
                  ? 0.25
                  : 0.2,
      initialPage: _currentPage,
    );

    final isDesktop = ResponsiveHelper.isDesktop(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    double sliderHeight = MediaQuery.of(context).size.width >= 1024
        ? 180
        : MediaQuery.of(context).size.width >= 600
            ? 140
            : 130;

    categoryLength = widget.categoryProvider.categoryList!.length;

    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(context, listen: false);

    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Center(
              child: Text(
            getTranslated('dish_discoveries', context)!,
            textAlign: TextAlign.center,
            style: rubikBold.copyWith(
                fontSize: isDesktop
                    ? Dimensions.fontSizeExtraLarge
                    : Dimensions.fontSizeDefault,
                color: themeProvider.darkTheme
                    ? Theme.of(context).primaryColor
                    : ColorResources.homePageSectionTitleColor),
          )),
          SizedBox(
              height: isDesktop
                  ? Dimensions.paddingSizeLarge
                  : Dimensions.paddingSizeSmall),
          categoryLength < 2
              ? Padding(
                  padding: const EdgeInsets.only(
                      bottom: Dimensions.paddingSizeLarge),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        widget.categoryProvider.categoryList!.map((element) {
                      String? name = element.name;
                      int index = widget.categoryProvider.categoryList!
                          .indexOf(element);

                      return _categoryItem(
                          index: index,
                          isDesktop: isDesktop,
                          context: context,
                          splashProvider: splashProvider,
                          name: name);
                    }).toList(),
                  ),
                )
              : SizedBox(
                  height: sliderHeight,
                  child: Flexible(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      controller: _pageController,
                      itemCount:
                          widget.categoryProvider.categoryList!.length,
                      // onPageChanged: (index) {
                      //   setState(() {
                      //     _currentPage = index;
                      //   });
                      // },
                      itemBuilder: (context, index) {
                        final name = widget
                            .categoryProvider.categoryList![index].name;
                        return _categoryItem(
                          index: index,
                          isDesktop: isDesktop,
                          context: context,
                          splashProvider: splashProvider,
                          name: name,
                        );
                      },
                    ),
                  ),
                ),
        ]);
  }

  // الشكل الجديد المستطيل بدون overflow:
  Widget _categoryItem({
    required int index,
    required bool isDesktop,
    required BuildContext context,
    required SplashProvider splashProvider,
    String? name,
  }) {
    double imageSize = MediaQuery.of(context).size.width >= 1024
        ? 100
        : MediaQuery.of(context).size.width >= 600
            ? 90
            : 80;

    final imageUrl = splashProvider.baseUrls != null
        ? '${splashProvider.baseUrls!.categoryImageUrl}/${widget.categoryProvider.categoryList![index].image}'
        : '';

    return InkWell(
      onTap: () {
        if (index == 7) {
          RouterHelper.getAllCategoryRoute();
        } else {
          RouterHelper.getCategoryRoute(
              widget.categoryProvider.categoryList![index]);
        }

      },
      child: Container(
        width: isDesktop ? 260 : 180, // Set a fixed width for the category item
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withAlpha(200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          index == 7 ? getTranslated("More", context)! : name ?? '',
        ),
      ),
    );
  }
}
