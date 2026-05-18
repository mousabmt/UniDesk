import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unidesk/features/entities/student/announcements/models/student_announcement.dart';

class StudentAnnouncementCard extends StatelessWidget {
  const StudentAnnouncementCard({
    super.key,
    required this.announcement,
    required this.onPressed,
  });

  final StudentAnnouncement announcement;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = _paletteFor(announcement);
    final createdAt = announcement.createdAt;
    final dateLabel = createdAt == null
        ? ''
        : DateFormat('MMM d, y').format(createdAt.toLocal());

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onPressed,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.baseColor.withValues(alpha: 0.98), Colors.white],
                stops: const [0.0, 0.78],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor,
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
              border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Badge(
                      label: announcement.badgeLabel,
                      backgroundColor: theme.badgeColor,
                    ),
                    const Spacer(),
                    if (dateLabel.isNotEmpty)
                      Text(
                        dateLabel,
                        style: TextStyle(
                          color: theme.secondaryTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.iconBackgroundColor,
                      ),
                      child: Icon(theme.icon, color: theme.iconColor, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            announcement.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              height: 1.15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E2630),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            announcement.previewText,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: theme.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    if (announcement.creatorName.isNotEmpty)
                      Expanded(
                        child: Text(
                          'By ${announcement.creatorName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.secondaryTextColor,
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                    const SizedBox(width: 12),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [
                            theme.actionStartColor,
                            theme.actionEndColor,
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              announcement.hasLink ? 'Open Link' : 'Read More',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _AnnouncementTheme _paletteFor(StudentAnnouncement announcement) {
    final normalizedType = announcement.type.toLowerCase().trim();
    final normalizedTitle = announcement.title.toLowerCase().trim();
    final normalized = '$normalizedType $normalizedTitle';

    if (normalized.contains('cancel') || normalized.contains('warning')) {
      return const _AnnouncementTheme(
        icon: Icons.warning_amber_rounded,
        baseColor: Color(0xFFFFF7E8),
        badgeColor: Color(0xFFF5A524),
        iconColor: Color(0xFFEB8B00),
        iconBackgroundColor: Color(0xFFFFEDC7),
        actionStartColor: Color(0xFFF5A524),
        actionEndColor: Color(0xFFEB8B00),
        secondaryTextColor: Color(0xFF6B6253),
        shadowColor: Color(0x14F5A524),
      );
    }
    if (normalized.contains('exam')) {
      return const _AnnouncementTheme(
        icon: Icons.campaign_rounded,
        baseColor: Color(0xFFFFF1F1),
        badgeColor: Color(0xFFE86A6A),
        iconColor: Color(0xFFD94C4C),
        iconBackgroundColor: Color(0xFFFFE1E1),
        actionStartColor: Color(0xFFE86A6A),
        actionEndColor: Color(0xFFD94C4C),
        secondaryTextColor: Color(0xFF7B5B5B),
        shadowColor: Color(0x14E86A6A),
      );
    }
    if (normalized.contains('event')) {
      return const _AnnouncementTheme(
        icon: Icons.event_note_rounded,
        baseColor: Color(0xFFF6F1FF),
        badgeColor: Color(0xFF8E6CEF),
        iconColor: Color(0xFF8E6CEF),
        iconBackgroundColor: Color(0xFFEAE1FF),
        actionStartColor: Color(0xFF8E6CEF),
        actionEndColor: Color(0xFF7552DD),
        secondaryTextColor: Color(0xFF635A83),
        shadowColor: Color(0x148E6CEF),
      );
    }
    if (normalized.contains('register')) {
      return const _AnnouncementTheme(
        icon: Icons.how_to_reg_rounded,
        baseColor: Color(0xFFF0FBFA),
        badgeColor: Color(0xFF11B9BE),
        iconColor: Color(0xFF0F9DA2),
        iconBackgroundColor: Color(0xFFDDF7F6),
        actionStartColor: Color(0xFF14B8C4),
        actionEndColor: Color(0xFF1097D2),
        secondaryTextColor: Color(0xFF4A6B73),
        shadowColor: Color(0x1414B8C4),
      );
    }
    if (normalized.contains('assignment')) {
      return const _AnnouncementTheme(
        icon: Icons.description_outlined,
        baseColor: Color(0xFFF2F5FF),
        badgeColor: Color(0xFF5B7BE3),
        iconColor: Color(0xFF4166DA),
        iconBackgroundColor: Color(0xFFE2E9FF),
        actionStartColor: Color(0xFF5B7BE3),
        actionEndColor: Color(0xFF4166DA),
        secondaryTextColor: Color(0xFF5B6785),
        shadowColor: Color(0x145B7BE3),
      );
    }
    if (normalized.contains('project') || normalized.contains('guideline')) {
      return const _AnnouncementTheme(
        icon: Icons.info_outline_rounded,
        baseColor: Color(0xFFF1FBFB),
        badgeColor: Color(0xFF27A7B2),
        iconColor: Color(0xFF1B96A2),
        iconBackgroundColor: Color(0xFFDDF4F5),
        actionStartColor: Color(0xFF27A7B2),
        actionEndColor: Color(0xFF1B96A2),
        secondaryTextColor: Color(0xFF577275),
        shadowColor: Color(0x1427A7B2),
      );
    }
    return const _AnnouncementTheme(
      icon: Icons.campaign_rounded,
      baseColor: Color(0xFFF5F8FC),
      badgeColor: Color(0xFF3FA3AD),
      iconColor: Color(0xFF278E98),
      iconBackgroundColor: Color(0xFFE4F1F3),
      actionStartColor: Color(0xFF13B5C8),
      actionEndColor: Color(0xFF0CA4B8),
      secondaryTextColor: Color(0xFF5F7280),
      shadowColor: Color(0x143FA3AD),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.backgroundColor});

  final String label;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AnnouncementTheme {
  const _AnnouncementTheme({
    required this.icon,
    required this.baseColor,
    required this.badgeColor,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.actionStartColor,
    required this.actionEndColor,
    required this.secondaryTextColor,
    required this.shadowColor,
  });

  final IconData icon;
  final Color baseColor;
  final Color badgeColor;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color actionStartColor;
  final Color actionEndColor;
  final Color secondaryTextColor;
  final Color shadowColor;
}
