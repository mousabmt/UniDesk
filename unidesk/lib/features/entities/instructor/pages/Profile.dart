import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/core/services/student_api.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import 'package:unidesk/features/entities/instructor/providers/instructor_profile_provider.dart';
import 'package:unidesk/features/language/langProvider.dart';
import '../../widgets_std/profileWidgets/custom_info.dart';
import '../../widgets_std/profileWidgets/custom_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final InstructorProfileProvider _profileProvider;

  @override
  void initState() {
    super.initState();
    _profileProvider = InstructorProfileProvider(
      fetchProfile: _fetchProfileData,
      saveProfile: _saveProfileData,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileProvider.loadIfNeeded();
    });
  }

  @override
  void dispose() {
    _profileProvider.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchProfileData() async {
    final auth = context.read<AuthProvider>();
    final response = await StudentApi.getInstructorProfile(token: auth.token);
    final instructor = response['instructor'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(
            response['instructor'] as Map<String, dynamic>,
          )
        : <String, dynamic>{};
    final currentSemester = response['current_semester'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(
            response['current_semester'] as Map<String, dynamic>,
          )
        : <String, dynamic>{};

    return {
      ...response,
      ...instructor,
      'id': (instructor['id'] ?? auth.userId ?? '-').toString(),
      'name': instructor['name']?.toString() ?? '-',
      'department': instructor['department']?.toString() ?? '-',
      'email': instructor['email']?.toString() ?? '-',
      'phone': instructor['phone']?.toString() ?? '-',
      'office': instructor['office']?.toString() ?? '-',
      'faculty': currentSemester['name']?.toString() ?? '-',
      'specialization': instructor['specialization']?.toString() ?? '-',
      'address': instructor['address']?.toString() ?? '-',
      'personal_email':
          instructor['personal_email']?.toString() ??
          instructor['email']?.toString() ??
          '',
      'identifiers': List<String>.from(
        (instructor['identifiers'] as List?) ??
            [
              if ((instructor['phone']?.toString() ?? '').isNotEmpty)
                instructor['phone'].toString(),
            ],
      ),
    };
  }

  Future<void> _saveProfileData(Map<String, dynamic> profile) async {
    // TODO: replace this with a dedicated instructor profile update API call.
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<InstructorProfileProvider>.value(
      value: _profileProvider,
      child: Consumer2<LangProvider, InstructorProfileProvider>(
        builder: (context, lang, profileProvider, _) {
          return Directionality(
            textDirection: lang.isArabic
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: SafeArea(
                child: RefreshIndicator(
                  onRefresh: profileProvider.refresh,
                  child: _buildBody(context, lang, profileProvider),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    LangProvider lang,
    InstructorProfileProvider profileProvider,
  ) {
    if (profileProvider.isLoading) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (profileProvider.error != null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 120),
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                lang.translate('failed_to_load_profile'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
              const SizedBox(height: 8),
              Text(
                profileProvider.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: profileProvider.refresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B2737),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(lang.translate('retry')),
              ),
            ],
          ),
        ),
      );
    }

    final profile = profileProvider.profile;
    if (profile == null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(child: Text(lang.translate('no_profile_data'))),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              lang.translate('profile'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: profileProvider.isRefreshing
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      key: const ValueKey('refresh-indicator'),
                      children: [
                        Row(
                          children: const [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Refreshing profile...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF2D9BF),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  size: 52,
                  color: Color(0xFFB07040),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                profile['name']?.toString() ?? '-',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Al al-Bayt University',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                profile['department']?.toString() ?? '',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Instructor Information',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InfoTile(
                icon: Icons.badge_outlined,
                label: 'Instructor ID',
                value: profile['id']?.toString() ?? '-',
              ),
              InfoTile(
                icon: Icons.email_outlined,
                label: lang.translate('email'),
                value: profile['email'] ?? '-',
              ),
              InfoTile(
                icon: Icons.apartment_outlined,
                label: 'Department',
                value: profile['department'] ?? '-',
              ),
              InfoTile(
                icon: Icons.location_on_outlined,
                label: 'Office',
                value: profile['office'] ?? '-',
              ),
              InfoTile(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: profile['phone'] ?? '-',
              ),
              if (profileProvider.isSaving)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    borderRadius: BorderRadius.all(Radius.circular(99)),
                  ),
                ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: profileProvider.isSaving
                      ? null
                      : () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => PersonalInfoSheet(
                            profile: Map<String, dynamic>.from(profile),
                            lang: lang,
                            onSave: (updates) =>
                                profileProvider.savePersonalInfo(updates),
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B2737),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    lang.translate('personal_information'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }
}
