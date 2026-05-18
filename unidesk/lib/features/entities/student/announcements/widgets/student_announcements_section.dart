import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:unidesk/features/entities/student/announcements/models/student_announcement.dart';
import 'package:unidesk/features/entities/student/announcements/widgets/student_announcement_card.dart';
import 'package:unidesk/shared/widgets/responsive_layout.dart';

class StudentAnnouncementsSection extends StatefulWidget {
  const StudentAnnouncementsSection({super.key, required this.announcements});

  final List<StudentAnnouncement> announcements;

  @override
  State<StudentAnnouncementsSection> createState() =>
      _StudentAnnouncementsSectionState();
}

class _StudentAnnouncementsSectionState
    extends State<StudentAnnouncementsSection>
    with AutomaticKeepAliveClientMixin {
  late final PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _restartAutoplay();
  }

  @override
  void didUpdateWidget(covariant StudentAnnouncementsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.announcements.length != widget.announcements.length) {
      _currentIndex = 0;
      _pageController.jumpToPage(0);
      _restartAutoplay();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final compact = ResponsiveLayout.isCompact(context);

    if (widget.announcements.isEmpty) {
      return const SizedBox.shrink();
    }

    final sectionTitle = Text(
      'Announcements',
      style: TextStyle(
        fontSize: compact ? 20 : 22,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1D2733),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle,
        const SizedBox(height: 6),
        Text(
          'Latest updates from your instructors and courses.',
          style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: compact ? 235 : 255,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.announcements.length,
            padEnds: false,
            onPageChanged: (index) {
              if (!mounted) {
                return;
              }
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final announcement = widget.announcements[index];
              return Padding(
                padding: EdgeInsets.only(right: compact ? 12 : 14),
                child: StudentAnnouncementCard(
                  announcement: announcement,
                  onPressed: () => _handleAnnouncementTap(announcement),
                ),
              );
            },
          ),
        ),
        if (widget.announcements.length > 1) ...[
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.announcements.length, (index) {
              final isActive = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: isActive
                      ? const Color(0xFF12AFC0)
                      : const Color(0xFFD5DCE3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  void _restartAutoplay() {
    _autoPlayTimer?.cancel();
    if (widget.announcements.length < 2) {
      return;
    }
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }
      final nextIndex = (_currentIndex + 1) % widget.announcements.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _handleAnnouncementTap(StudentAnnouncement announcement) async {
    if (announcement.hasLink) {
      final uri = Uri.tryParse(announcement.link!);
      if (uri != null) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          return;
        }
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open the announcement link.')),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        final bodyText = announcement.content.isNotEmpty
            ? announcement.content
            : announcement.previewText;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8E0E7),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    announcement.badgeLabel,
                    style: textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF13AFC0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    announcement.title,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E2630),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (announcement.creatorName.isNotEmpty)
                    Text(
                      'Posted by ${announcement.creatorName}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.blueGrey.shade600,
                      ),
                    ),
                  if (announcement.creatorName.isNotEmpty)
                    const SizedBox(height: 12),
                  Text(
                    bodyText,
                    style: textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: const Color(0xFF4F5F6E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
