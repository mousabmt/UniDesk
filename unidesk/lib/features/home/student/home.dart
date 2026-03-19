import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    if (auth.userId == null || !auth.isValidToken) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AuthProvider>().logout();
        if (context.mounted) {
          context.go('/login');
        }
      });

    }

   return AppLayout(
  currentIndex: NavIndexes.home,
  child: SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
FutureBuilder<Map<String, dynamic>>(
future: _profileFuture,
builder: (context, snapshot) {
  if(snapshot.connectionState==ConnectionState.waiting){
    return CircularProgressIndicator();

  }
  if(snapshot.hasError){
    return Text("Error loading data, please try again later.");
  }
  final profile = snapshot.data!;
        // 1. Welcome text

  return  Text(
 ' ${lang.translate('welcome_back')} ${profile['name']}!',
          style: const TextStyle(
            fontSize:17,
            fontWeight: FontWeight.bold,
          ),
        );
},

),
     
      SizedBox(
child:  // 3. Quick actions row (3 buttons)
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
      ),
       
SizedBox(
  child:        // 4. Stats row from profile loaded in Home
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
),
 
      SizedBox(
        child:   // 5. Advertisements section
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
        
      ),
  
      ],
    ),
  ),
);
  }
}
