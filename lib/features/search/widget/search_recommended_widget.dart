import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_image_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_single_child_list_widget.dart';
import 'package:flutter_restaurant/features/search/providers/search_provider.dart';
import 'package:flutter_restaurant/features/splash/providers/splash_provider.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class SearchRecommendedWidget extends StatelessWidget {
  const SearchRecommendedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, _) {
        return SingleChildScrollView(
          primary: true,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: Dimensions.paddingSizeDefault),

            /// Recent searches
            if (searchProvider.historyList.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated('recent_searches', context)!,
                    style: rubikBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  InkWell(
                    onTap: searchProvider.clearSearchAddress,
                    child: Text(
                      getTranslated('clear_all', context)!,
                      style: rubikSemiBold.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ],

            /// Recent search list
            if (searchProvider.historyList.isNotEmpty) ...[
              ListView.builder(
                itemCount: min(searchProvider.historyList.length, 10),
                primary: false,
                shrinkWrap: true,
                reverse: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => Column(children: [
                  InkWell(
                    onTap: () {
                      searchProvider.searchProduct(
                        name: searchProvider.historyList[index],
                        offset: 1,
                        context: context,
                      );
                      RouterHelper.getSearchResultRoute(
                        searchProvider.historyList[index].replaceAll(' ', '-'),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            searchProvider.historyList[index],
                            style: rubikSemiBold.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              searchProvider.removeHistoryItemByIndex(index);
                            },
                            child: Icon(
                              Icons.close,
                              size: Dimensions.fontSizeExtraLarge,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 0, color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
                ]),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
            ],

            /// Popular tags
            _RecommendedCuisinesWidget(searchProvider: searchProvider),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            /// Recommended categories
            _RecommendedCategoryWidget(searchProvider: searchProvider),
          ]),
        );
      },
    );
  }
}

class _RecommendedCategoryWidget extends StatelessWidget {
  const _RecommendedCategoryWidget({required this.searchProvider});

  final SearchProvider searchProvider;

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

    if (searchProvider.searchRecommendModel == null) {
      return const _RecommendedCategoryShimmerWidget();
    }

    if (searchProvider.searchRecommendModel?.categories.isEmpty ?? false) {
      return const SizedBox.shrink();
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        getTranslated('recommended', context)!,
        style: rubikBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
      ),
      const SizedBox(height: Dimensions.paddingSizeDefault),

      /// Grid with 3 cards per row
      GridView.builder(
        primary: false,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 👈 3 كروت في الصف
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          mainAxisExtent: 150, // 👈 ارتفاع الكارت
        ),
        itemCount: searchProvider.searchRecommendModel?.categories.length ?? 0,
        itemBuilder: (context, index) {
          final category = searchProvider.searchRecommendModel!.categories[index];
          return Material(
            shape: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColorLight),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () => RouterHelper.getCategoryRoute(category),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    shadowColor: Theme.of(context).shadowColor.withValues(alpha: 0.15),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: CustomImageWidget(
                        image:
                            '${splashProvider.baseUrls?.categoryImageUrl}/${category.image}',
                        placeholder: Images.placeholderImage,
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        category.name ?? '',
                        style: rubikSemiBold.copyWith(fontSize: 14),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      const SizedBox(height: Dimensions.paddingSizeLarge),
    ]);
  }
}

class _RecommendedCuisinesWidget extends StatelessWidget {
  const _RecommendedCuisinesWidget({required this.searchProvider});

  final SearchProvider searchProvider;

  @override
  Widget build(BuildContext context) {
    if (searchProvider.searchRecommendModel == null) {
      return const _RecommendedCuisinesShimmerWidget();
    }

    return (searchProvider.searchRecommendModel?.cuisines.isNotEmpty ?? false)
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getTranslated('popular_cuisines', context)!,
                style: rubikBold.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              CustomSingleChildListWidget(
                isWrap: true,
                wrapSpacing: Dimensions.paddingSizeSmall,
                itemCount:
                    min(searchProvider.searchRecommendModel?.cuisines.length ?? 0, 8),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                    child: InkWell(
                      onTap: () {
                        searchProvider.searchProduct(
                          name: searchProvider.searchRecommendModel?.cuisines[index] ?? '',
                          offset: 1,
                          context: context,
                        );
                        RouterHelper.getSearchResultRoute(
                          searchProvider.searchRecommendModel?.cuisines[index]
                                  .replaceAll(' ', '-') ??
                              '',
                        );
                      },
                      highlightColor: Colors.transparent,
                      child: Chip(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        backgroundColor: Colors.transparent,
                        label: Text(
                          searchProvider.searchRecommendModel?.cuisines[index] ?? '',
                          style: rubikRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        surfaceTintColor: Colors.transparent,
                        side: BorderSide(
                          color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                          width: 0.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          )
        : const SizedBox.shrink();
  }
}

class _RecommendedCuisinesShimmerWidget extends StatelessWidget {
  const _RecommendedCuisinesShimmerWidget();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Shimmer(
          interval: const Duration(seconds: 1),
          colorOpacity: 0.1,
          enabled: true,
          child: Container(
            height: 20.0,
            width: 150.0,
            color: Theme.of(context).shadowColor.withValues(alpha: 0.2),
          ),
        ),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),
      Row(
        children: List.generate(
          4,
          (_) => Padding(
            padding:
                const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
            child: Shimmer(
              duration: const Duration(seconds: 2),
              interval: const Duration(seconds: 1),
              colorOpacity: 0.1,
              enabled: true,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                height: 40.0,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
        ).toList(),
      ),
    ]);
  }
}

class _RecommendedCategoryShimmerWidget extends StatelessWidget {
  const _RecommendedCategoryShimmerWidget();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Shimmer(
        interval: const Duration(seconds: 1),
        color: Theme.of(context).shadowColor.withValues(alpha: 0.2),
        colorOpacity: 0.1,
        enabled: true,
        child: Container(
          height: 20,
          width: 150,
          color: Theme.of(context).shadowColor.withValues(alpha: 0.2),
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
        ),
      ),
      GridView.builder(
        primary: false,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 👈 نفس عدد الكروت
          mainAxisExtent: 150, // 👈 نفس الارتفاع
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => Shimmer(
          duration: const Duration(seconds: 2),
          interval: const Duration(milliseconds: 300),
          color: Theme.of(context).shadowColor.withValues(alpha: 0.2),
          colorOpacity: 0.5,
          enabled: true,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            margin: const EdgeInsets.all(Dimensions.paddingSizeDefault / 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 15,
                  width: 70,
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.2),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}
