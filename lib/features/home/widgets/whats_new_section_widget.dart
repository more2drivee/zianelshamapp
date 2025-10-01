import 'package:flutter/material.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';

class WhatsNewSectionWidget extends StatelessWidget {
  const WhatsNewSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;

    // ✅ طول الكارت أكبر في الموبايل + التابلت
    final double cardHeight = (isMobile || isTablet)
        ? 280 // موبايل + تابلت
        : 260; // ديسكتوب

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1200, // ✅ ماكس ويدث للسيكشن
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeLarge,
            vertical: Dimensions.paddingSizeDefault,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// العنوان الرئيسي
              Text(
                "What's New at Zain El Sham",
                style: rubikBold.copyWith(
                  fontSize: 28,
                  color: Colors.amber.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Stay updated with our latest additions, special events, and exciting culinary innovations",
                style: rubikRegular.copyWith(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              /// الكروت
              (isMobile || isTablet)
                  ? Column(
                      children: [
                        _buildCard(
                          title: "New Syrian Desserts Collection",
                          subtitle:
                              "Authentic Baklava, Kunafa, and Ma'amoul freshly made daily with traditional recipes",
                          tags: ["New", "Featured"],
                          highlight: "Just Added",
                          width: screenWidth,
                          height: cardHeight,
                        ),
                        const SizedBox(height: 16),

                        _buildCard(
                          title: "Weekend Breakfast Menu",
                          subtitle:
                              "Traditional Syrian breakfast platters available Saturday & Sunday mornings",
                          tags: ["Special"],
                          highlight: "Weekends Only",
                          width: screenWidth,
                          height: cardHeight,
                        ),
                        const SizedBox(height: 16),

                        _buildCard(
                          title: "Chef's Special Ramadan Menu",
                          subtitle:
                              "Exclusive iftar combinations and traditional dishes for the holy month",
                          tags: ["Event"],
                          highlight: "Limited Time",
                          width: screenWidth,
                          height: cardHeight,
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        /// الكارت الأول full width
                        _buildCard(
                          title: "New Syrian Desserts Collection",
                          subtitle:
                              "Authentic Baklava, Kunafa, and Ma'amoul freshly made daily with traditional recipes",
                          tags: ["New", "Featured"],
                          highlight: "Just Added",
                          width: screenWidth,
                          height: cardHeight,
                        ),
                        const SizedBox(height: 16),

                        /// الكارتين جنب بعض (للديسكتوب فقط)
                        Row(
                          children: [
                            Expanded(
                              child: _buildCard(
                                title: "Weekend Breakfast Menu",
                                subtitle:
                                    "Traditional Syrian breakfast platters available Saturday & Sunday mornings",
                                tags: ["Special"],
                                highlight: "Weekends Only",
                                width: (screenWidth / 2) - 40,
                                height: cardHeight,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildCard(
                                title: "Chef's Special Ramadan Menu",
                                subtitle:
                                    "Exclusive iftar combinations and traditional dishes for the holy month",
                                tags: ["Event"],
                                highlight: "Limited Time",
                                width: (screenWidth / 2) - 40,
                                height: cardHeight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    List<String> tags = const [],
    String? highlight,
    double? width,
    double? height,
  }) {
    return Container(
      width: width ?? 350,
      height: height, // ✅ طول الكارت ثابت حسب الجهاز
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge * 1.2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ توزيع المحتوى
        children: [
          /// Tags + Highlight
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: tags
                    .map(
                      (tag) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: tag == "New"
                              ? Colors.amber.shade100
                              : tag == "Featured"
                                  ? Colors.red.shade100
                                  : tag == "Special"
                                      ? Colors.grey.shade200
                                      : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.brown,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              if (highlight != null)
                Text(
                  highlight,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.brown,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          /// Title
          Text(
            title,
            style: rubikBold.copyWith(
              fontSize: 20,
              color: Colors.brown[900],
            ),
          ),
          const SizedBox(height: 6),

          /// Subtitle
          Expanded(
            child: Text(
              subtitle,
              style: rubikRegular.copyWith(
                fontSize: 15,
                color: Colors.grey[700],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          /// Button
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Learn More"),
            ),
          ),
        ],
      ),
    );
  }
}
