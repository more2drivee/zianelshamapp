import 'package:flutter/material.dart';
import 'package:flutter_restaurant/features/category/providers/category_provider.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class CategoryWebWidget extends StatefulWidget {
  const CategoryWebWidget({super.key});

  @override
  State<CategoryWebWidget> createState() => _CategoryWebWidgetState();
}

class _CategoryWebWidgetState extends State<CategoryWebWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(builder: (context, categoryProvider, _) {
      final categoryList = categoryProvider.categoryList;

      if (categoryList == null) {
        return const _CategoryShimmer();
      }

      // ✅ فلترة الكاتيجوريز بحيث يجيب بس اللي parent_id = 0
      final rootCategories = categoryList
          .where((c) => (c.parentId?.toString() ?? '0') == '0')
          .toList();

      return rootCategories.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 👇 العناوين اللي اتضافت
                    const Text(
                      "Menu Categories",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Select a category to explore",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 👇 Styled ExpansionPanelList as dropdown-like card
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor.withOpacity(0.15),
                            blurRadius: 14,
                            spreadRadius: 1,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            splashColor: Theme.of(context).primaryColor.withOpacity(0.05),
                            highlightColor: Theme.of(context).primaryColor.withOpacity(0.04),
                          ),
                          child: ExpansionPanelList.radio(
                            elevation: 0,
                            dividerColor: Colors.transparent,
                            expandedHeaderPadding: const EdgeInsets.symmetric(vertical: 2),
                            animationDuration: const Duration(milliseconds: 250),
                            children: List.generate(rootCategories.length, (index) {
                        final category = rootCategories[index];

                        // ✅ subCategories اللي ليها parentId = id
                        final subCategories = categoryList
                            .where((c) =>
                                (c.parentId?.toString() ?? '') ==
                                (category.id?.toString() ?? ''))
                            .toList();

                              return ExpansionPanelRadio(
                                value: category.id ?? index,
                                canTapOnHeader: true,
                                backgroundColor: Theme.of(context).cardColor,
                                headerBuilder: (context, isExpanded) {
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    leading: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.1),
                                      child: Icon(
                                        Icons.fastfood,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    title: InkWell(
                                      onTap: () {
                                        categoryProvider.getCategoryProductList(
                                            category.id.toString(), 1);
                                      },
                                      child: Text(
                                        category.name ?? "Category ${index + 1}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    subtitle: Text(
                                      "${subCategories.length} subcategories",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  );
                                },
                                body: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: subCategories.isEmpty
                                      ? const [
                                          Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Text('No subcategories found.'),
                                          ),
                                        ]
                                      : subCategories
                                          .map((sub) => Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () {
                                                    categoryProvider.getCategoryProductList(
                                                        sub.id.toString(), 1);
                                                  },
                                                  borderRadius: BorderRadius.circular(8),
                                                  overlayColor: WidgetStatePropertyAll(
                                                    Theme.of(context).primaryColor.withOpacity(0.06),
                                                  ),
                                                  child: Container(
                                                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).cardColor,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.chevron_right,
                                                          size: 18,
                                                          color: Theme.of(context).primaryColor.withOpacity(0.6),
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Expanded(
                                                          child: Text(
                                                            sub.name ?? '',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: Theme.of(context).textTheme.bodyMedium!.color,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox();
    });
  }
}

class _CategoryShimmer extends StatelessWidget {
  const _CategoryShimmer();

  @override
  Widget build(BuildContext context) {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    return SizedBox(
      height: 260,
      width: Dimensions.webScreenWidth,
      child: ListView.builder(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Shimmer(
            duration: const Duration(seconds: 2),
            enabled: categoryProvider.categoryList == null,
            child: ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundColor:
                    Theme.of(context).shadowColor.withOpacity(0.3),
              ),
              title: Container(
                height: 12,
                width: 100,
                color: Theme.of(context).shadowColor.withOpacity(0.4),
              ),
              subtitle: Container(
                margin: const EdgeInsets.only(top: 4),
                height: 10,
                width: 60,
                color: Theme.of(context).shadowColor.withOpacity(0.2),
              ),
            ),
          );
        },
      ),
    );
  }
}
