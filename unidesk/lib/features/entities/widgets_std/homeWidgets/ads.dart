import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../core/constants/constants.dart';

class AdvertisementsSection extends StatefulWidget {
  final List<Map<String, dynamic>> ads;

  const AdvertisementsSection({
    super.key,
    required this.ads,
  });

  @override
  State<AdvertisementsSection> createState() =>
      _AdvertisementsSectionState();
}

class _AdvertisementsSectionState extends State<AdvertisementsSection> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingHorizontal,
        vertical: AppSizes.spacingSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CarouselSlider(
                  options: CarouselOptions(
                    height:250,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    enlargeCenterPage: true,
                    viewportFraction: 0.85,
                    onPageChanged: (index, reason) {
                      setState(() => currentIndex = index);
                    },
                  ),
                  items: widget.ads.map((ad) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            ad['imageUrl'] ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                Container(color: Colors.grey.shade300),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.center,
                                colors: [
                                  Colors.black.withValues(alpha: 0.4),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          if (ad['title'] != null)
                            Positioned(
                              bottom: 12,
                              left: 12,
                              right: 12,
                              child: Text(
                                ad['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          /// DOT INDICATOR — fixed height, stays at bottom
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.ads.asMap().entries.map((entry) {
              final isActive = currentIndex == entry.key;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 10 : 6,
                height: isActive ? 10 : 6,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? Colors.black : Colors.grey,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}  