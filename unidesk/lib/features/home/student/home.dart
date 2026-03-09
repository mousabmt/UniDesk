import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/core/constants/constants.dart';
import 'package:unidesk/core/services/mockApi.dart';
import 'package:unidesk/features/home/widgets_std/actions_row.dart';
import 'package:unidesk/features/home/widgets_std/stats_row.dart';
import 'package:unidesk/features/home/widgets_std/ads.dart';
import 'package:unidesk/shared/widgets/app_layout.dart';
import '../../auth/authProvider.dart';
import '../../language/langProvider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<Map<String, dynamic>> _profileFuture;
  late final Future<List<Map<String, dynamic>>> _coursesFuture;
  late final Future<List<Map<String, dynamic>>> _adsFuture;
  @override
  void initState() {
    super.initState();
    _profileFuture = MockApi.getProfile();
    _coursesFuture = MockApi.getCourses();
    _adsFuture = MockApi.getAds();
  }


  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LangProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    if(auth.userId == null || !auth.isValidToken){
WidgetsBinding.instance.addPostFrameCallback((_) {
context.read<AuthProvider>().logout();
Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
});

    }

   return AppLayout(
  currentIndex: NavIndexes.home,
  child: SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Welcome text
      Text(
 ' ${lang.translate('welcome_back')} ${auth.userId }!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        // 2. Search bar
        SearchBar(),

        // 3. Quick actions row (3 buttons)
         FutureBuilder<List<Map<String, dynamic>>>(
          future: _coursesFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(AppSizes.paddingHorizontal),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return QuickActionsRow(courses: snapshot.data!);
          },
        ),

        // 4. Stats row from profile loaded in Home
        FutureBuilder<Map<String, dynamic>>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(AppSizes.paddingHorizontal),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return StatsRow(profile: snapshot.data!);
          },
        ),

        // 5. Advertisements section
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _adsFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(AppSizes.paddingHorizontal),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return AdvertisementsSection(ads: snapshot.data!);
          },
        ),
  
      ],
    ),
  ),
);
  }
}
