import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../../../shared/widgets/responsive_layout.dart';

class AdvertisementsSection extends StatefulWidget {
  final List<Map<String, dynamic>> ads;

  const AdvertisementsSection({
    super.key,
    required this.ads,
  });

  @override
  State<AdvertisementsSection> createState() => _AdvertisementsSectionState();
}

class _AdvertisementsSectionState extends State<AdvertisementsSection> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final compact = ResponsiveLayout.isCompact(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final carouselHeight = compact ? 190.0 : 250.0;

            return CarouselSlider(
              options: CarouselOptions(
                height: carouselHeight,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                enlargeCenterPage: true,
                viewportFraction: compact ? 0.95 : 0.85,
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
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: compact ? 14 : 16,
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
        const SizedBox(height: 12),
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
    );
  }
}
