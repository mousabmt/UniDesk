import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/core/constants/constants.dart';
import 'package:unidesk/features/language/langProvider.dart';
import 'package:unidesk/shared/widgets/app_layout.dart';
import 'package:unidesk/features/home/student/providers_std/profile_provider.dart';
import '../../widgets_std/profileWidgets/custom_tile.dart';
import '../../widgets_std/profileWidgets/custom_info.dart';
 
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
 
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
     context.read<ProfileProvider>().loadIfNeeded();
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;
 
    return AppLayout(
      currentIndex: NavIndexes.profile,
      child: Directionality(
        textDirection: lang.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SafeArea(
            child: profileProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : profileProvider.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              lang.translate('failed_to_load_profile'),
                              style: const TextStyle(color: Colors.red),
                            ),
                            TextButton(
                              onPressed: profileProvider.refresh,
                              child: Text(lang.translate('refresh')),
                            ),
                          ],
                        ),
                      )
                    : profile == null
                        ? Center(child: Text(lang.translate('no_profile_data')))
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // ── Header bar ──────────────────────
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        lang.translate('profile'),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.refresh),
                                        onPressed: profileProvider.refresh,
                                        tooltip: lang.translate('refresh'),
                                      ),
                                    ],
                                  ),
                                ),
 
                                // ── Avatar + name + major ────────────
                                Column(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFF2D9BF),
                                        border: Border.all(
                                            color: Colors.white, width: 4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.1),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.person,
                                          size: 52,
                                          color: Color(0xFFB07040)),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      profile['name'] ?? '-',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Al al-Bayt University',
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      profile['major'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.grey),
                                    ),
                                  ],
                                ),
 
                                const SizedBox(height: 24),
 
                                // ── Section title ────────────────────
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    lang.translate('student_information'),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
 
                                const SizedBox(height: 12),
 
                                // ── Info tiles ───────────────────────
                                InfoTile(
                                  icon: Icons.badge_outlined,
                                  label: lang.translate('student_id'),
                                  value: profile['id']?.toString() ?? '-',
                                ),
                                InfoTile(
                                  icon: Icons.email_outlined,
                                  label: lang.translate('email'),
                                  value: profile['email'] ?? '-',
                                ),
                                InfoTile(
                                  icon: Icons.bar_chart_outlined,
                                  label: lang.translate('gpa'),
                                  value: () {
                                    final g = profile['gpa'] ?? profile['cumulativeGpa'];
                                    if (g is num) return g.toStringAsFixed(2);
                                    return g?.toString() ?? '-';
                                  }(),
                                ),
                                InfoTile(
                                    icon: Icons.menu_book_outlined,
                                   label: lang.translate('credits_completed'),
                                   value:
                                       profile['credits']?.toString() ?? '-',
                                 ),
                                 InfoTile(
                                    icon: Icons.access_time_outlined,
                                   label: lang.translate('total_hours'),
                                   value:
                                        (profile['totalHours'] ??
                                                profile['totalCredits'])
                                            ?.toString() ??
                                        '-',
                                 ),
 
                                const SizedBox(height: 18),
 
                                // ── Personal info button ─────────────
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: ElevatedButton(
                                    onPressed: () => showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => PersonalInfoSheet(
                                        profile: profile,
                                        lang: lang,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF6B2737),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      lang.translate('personal_information'),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
 
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
          ),
        ),
      ),
    );
  }
}
 
