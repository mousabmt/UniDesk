import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/core/constants/constants.dart';
import 'package:unidesk/features/language/langProvider.dart';
import 'package:unidesk/shared/widgets/app_layout.dart';
import 'package:unidesk/shared/widgets/responsive_layout.dart';

class TechnicalSupportPage extends StatefulWidget {
  const TechnicalSupportPage({super.key});

  @override
  State<TechnicalSupportPage> createState() => _TechnicalSupportPageState();
}

class _TechnicalSupportPageState extends State<TechnicalSupportPage> {
  final TextEditingController _searchController = TextEditingController();
  final String _searchQuery = '';
  int? _expandedFaqIndex;

  // ── Data ────────────────────────────────────────────────────────────────────

  static const _categories = [
    _SupportCategory(
      icon: Icons.person_outline_rounded,
      title: 'Account Issues',
      subtitle: 'Login, password problems',
    ),
    _SupportCategory(
      icon: Icons.credit_card_rounded,
      title: 'Payment Help',
      subtitle: 'Fees or transaction issues',
    ),
    _SupportCategory(
      icon: Icons.menu_book_rounded,
      title: 'Course Problems',
      subtitle: 'Registration or materials',
    ),
    _SupportCategory(
      icon: Icons.settings_outlined,
      title: 'Technical Errors',
      subtitle: 'App bugs or loading problems',
    ),
  ];

  static const _faqs = [
    _Faq(
      question: 'How do I reset my password?',
      answer:
          'Go to the login page and tap "Forgot Password". Enter your university email and follow the reset link sent to your inbox.',
    ),
    _Faq(
      question: 'How can I pay university fees?',
      answer:
          'Navigate to the Payments section from the home screen. You can pay via credit card, bank transfer, or university portal.',
    ),
    _Faq(
      question: "Why can't I register courses?",
      answer:
          'Course registration opens during specific periods. Make sure you have no financial holds and check the academic calendar for registration dates.',
    ),
    _Faq(
      question: 'How do I contact technical support?',
      answer:
          'You can reach us via chat, email, or phone call using the Contact Support section on this page. Our team is available 24/7.',
    ),
  ];



  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();

    return AppLayout(
      currentIndex: NavIndexes.home,
      child: Directionality(
        textDirection: lang.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // _buildSearchBar(),
            const SizedBox(height: 20),
            _buildCategoryGrid(),
            const SizedBox(height: 20),
            _buildContactSection(),
            const SizedBox(height: 20),
            _buildFaqSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Search bar ───────────────────────────────────────────────────────────────

  // Widget _buildSearchBar() => Container(
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(14),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withValues(alpha: 0.07),
  //             blurRadius: 10,
  //             offset: const Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       child: TextField(
  //         controller: _searchController,
  //         onChanged: (v) => setState(() => _searchQuery = v),
  //         decoration: InputDecoration(
  //           hintText: 'Search your issue ...',
  //           hintStyle: const TextStyle(
  //             color: Color(0xFF9CA3AF),
  //             fontSize: 14,
  //           ),
  //           prefixIcon: const Icon(Icons.search_rounded,
  //               color: Color(0xFF6B7280), size: 22),
  //           suffixIcon: _searchQuery.isNotEmpty
  //               ? IconButton(
  //                   icon: const Icon(Icons.close_rounded,
  //                       color: Color(0xFF6B7280), size: 20),
  //                   onPressed: () {
  //                     _searchController.clear();
  //                     setState(() => _searchQuery = '');
  //                   },
  //                 )
  //               : const Icon(Icons.search_rounded,
  //                   color: Color(0xFF6B7280), size: 22),
  //           border: InputBorder.none,
  //           contentPadding:
  //               const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  //         ),
  //       ),
  //     );

  // // ── Category grid ────────────────────────────────────────────────────────────

  Widget _buildCategoryGrid() => LayoutBuilder(
        builder: (context, constraints) {
          final compact = ResponsiveLayout.isCompact(context);
          final crossAxisCount = constraints.maxWidth < 420 ? 1 : 2;

          return GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: compact ? 1.9 : 1.5,
            children: _categories.map(_buildCategoryCard).toList(),
          );
        },
      );

  Widget _buildCategoryCard(_SupportCategory cat) => GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF2A9D8F),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(cat.icon, color: Colors.white, size: 20),
              const SizedBox(height: 8),
              Text(
                cat.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                cat.subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );

  // ── Contact section ──────────────────────────────────────────────────────────

  Widget _buildContactSection() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFD9EEEC),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 420;
                if (compact) {
                  return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 20,
                    runSpacing: 16,
                    children: [
                      _buildContactButton(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Start Chat',
                        onTap: () {},
                      ),
                      _buildContactButton(
                        icon: Icons.email_outlined,
                        label: 'Send Email',
                        onTap: () {},
                      ),
                      _buildContactButton(
                        icon: Icons.call_rounded,
                        label: 'Call Us',
                        onTap: () {},
                      ),
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildContactButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Start Chat',
                      onTap: () {},
                    ),
                    _buildContactButton(
                      icon: Icons.email_outlined,
                      label: 'Send Email',
                      onTap: () {},
                    ),
                    _buildContactButton(
                      icon: Icons.call_rounded,
                      label: 'Call Us',
                      onTap: () {},
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                color: Color(0xFF2A9D8F),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      );

  // ── FAQ section ───────────────────────────────────────────────────────────────

  Widget _buildFaqSection() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFD9EEEC),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),

              ...List.generate(_faqs.length, (i) {
                final faq = _faqs[i];
                final isExpanded = _expandedFaqIndex == i;

                return GestureDetector(
                  onTap: () => setState(
                    () => _expandedFaqIndex = isExpanded ? null : i,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                faq.question,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                            AnimatedRotation(
                              turns: isExpanded ? 0.25 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                                color: Color(0xFF2A9D8F),
                              ),
                            ),
                          ],
                        ),
                        if (isExpanded) ...[
                          const SizedBox(height: 8),
                          const Divider(height: 1, color: Color(0xFFE5E7EB)),
                          const SizedBox(height: 8),
                          Text(
                            faq.answer,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      );
}

// ── Data classes ──────────────────────────────────────────────────────────────

class _SupportCategory {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SupportCategory({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _Faq {
  final String question;
  final String answer;
  const _Faq({required this.question, required this.answer});
}
