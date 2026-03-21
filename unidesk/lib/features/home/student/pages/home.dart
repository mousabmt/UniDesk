import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/core/constants/constants.dart';
import 'package:unidesk/core/services/mockApi.dart';
import 'package:unidesk/features/home/widgets_std/homeWidgets/actions_row.dart';
import 'package:unidesk/features/home/widgets_std/homeWidgets/stats_row.dart';
import 'package:unidesk/features/home/widgets_std/homeWidgets/ads.dart';
import 'package:unidesk/shared/widgets/app_layout.dart';
import '../../../language/langProvider.dart';
import '../providers_std/profile_provider.dart';
import 'package:unidesk/features/home/student/providers_std/course_provider.dart';
import 'package:unidesk/features/home/student/providers_std/annouc_provider.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Auth guard — safe place to redirect


      // Trigger all cached loads
          Future.microtask(() =>{
      context.read<ProfileProvider>().loadIfNeeded(),
      context.read<CoursesProvider>().loadIfNeeded(),
      context.read<AnnoucProvider>().loadIfNeeded(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    final profile = context.watch<ProfileProvider>();
    final courses = context.watch<CoursesProvider>();
    final ads = context.watch<AnnoucProvider>();

    return AppLayout(
      currentIndex: NavIndexes.home,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome text
            if (profile.isLoading)
              const CircularProgressIndicator()
            else if (profile.error != null)
              const Text('Error loading data, please try again later.')
            else
              Text(
                '${lang.translate('welcome_back')} ${profile.profile!['name']}!',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),

            const SizedBox(height: 20),

            // Quick actions
            if (courses.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (courses.courses != null)
              QuickActionsRow(courses: courses.courses!),

            const SizedBox(height: 20),

            // Stats
            if (profile.profile != null)
              StatsRow(profile: profile.profile!),

            const SizedBox(height: 20),

            // Ads
            if (ads.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (ads.ads != null)
              AdvertisementsSection(ads: ads.ads!),
          ],
        ),
      ),
    );
  }
}