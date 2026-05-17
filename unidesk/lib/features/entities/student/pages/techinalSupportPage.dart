import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/core/constants/constants.dart';
import 'package:unidesk/features/language/langProvider.dart';
import 'package:unidesk/shared/widgets/app_layout.dart';

class TechnicalSupportPage extends StatefulWidget {
  const TechnicalSupportPage({super.key});

  @override
  State<TechnicalSupportPage> createState() => _TechnicalSupportPageState();
}

class _TechnicalSupportPageState extends State<TechnicalSupportPage> {
  int? _expandedFaqIndex;

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

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature is coming soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  final lang = context.read<LangProvider>();
  final bottomPadding = MediaQuery.of(context).padding.bottom;

  return AppLayout(
    currentIndex: NavIndexes.home,
    child: Directionality(
      textDirection: lang.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: RefreshIndicator(
        // ✅ wrap ListView with RefreshIndicator
        color: const Color(0xFF2A9D8F),
        onRefresh: () async {
          // add your refresh logic here when ready
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(), // ✅ required for RefreshIndicator to work even when content doesn't scroll
          padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomPadding),
          children: [
            const Text(
              'Technical Support',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'How can we help you today?',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
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
    ),
  );
}
Widget _buildCategoryGrid() {
  return Column(
    children: [
      Row(
        children: [
          Expanded(child: _buildCategoryCard(_categories[0])),
          const SizedBox(width: 12),
          Expanded(child: _buildCategoryCard(_categories[1])),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(child: _buildCategoryCard(_categories[2])),
          const SizedBox(width: 12),
          Expanded(child: _buildCategoryCard(_categories[3])),
        ],
      ),
    ],
  );
}
  Widget _buildCategoryCard(_SupportCategory cat) => Material(
        color: const Color(0xFF2A9D8F),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          // ✅ ripple feedback
          onTap: _showComingSoon,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  cat.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildContactButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Start Chat',
                onTap: _showComingSoon,
              ),
              _buildContactButton(
                icon: Icons.email_outlined,
                label: 'Send Email',
                onTap: _showComingSoon,
              ),
              _buildContactButton(
                icon: Icons.call_rounded,
                label: 'Call Us',
                onTap: _showComingSoon,
              ),
            ],
          ),
        ],
      ),
    );

Widget _buildContactButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) =>
    SizedBox(
      width: 72, // ✅ constrained — prevents overflow
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: const Color(0xFF2A9D8F),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 54,
                height: 54,
                child: Icon(icon, color: Colors.white, size: 24), // ✅ uses actual icon param
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
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

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: isExpanded
                      ? const Color(0xFFEDF7F6) // ✅ visual expanded feedback
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    // ✅ ripple on FAQ items
                    onTap: () => setState(
                      () => _expandedFaqIndex = isExpanded ? null : i,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  faq.question,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isExpanded
                                        ? const Color(0xFF2A9D8F) // ✅
                                        : const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                              AnimatedRotation(
                                turns: isExpanded ? 0.25 : 0,
                                duration: const Duration(milliseconds: 250),
                                child: const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 20,
                                  color: Color(0xFF2A9D8F),
                                ),
                              ),
                            ],
                          ),
                          // ✅ AnimatedSize for smooth expand/collapse
                          AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            child: isExpanded
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      const Divider(
                                        height: 1,
                                        color: Color(0xFFE5E7EB),
                                      ),
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
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
}

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