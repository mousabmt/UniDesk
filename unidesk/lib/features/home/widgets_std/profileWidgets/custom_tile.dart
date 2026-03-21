import 'package:flutter/material.dart';
import 'package:unidesk/core/constants/colors.dart';
import 'package:unidesk/features/language/langProvider.dart';
 import './custom_field.dart';
class InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
 
  const InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color:  Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style:
                      const TextStyle(fontSize: 13, color: Color.fromARGB(255, 1, 1, 1)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
 
// ─── Bottom sheet ────────────────────────────────────────────────────────────
class _PersonalInfoSheet extends StatefulWidget {
  final Map<String, dynamic> profile;
  final LangProvider lang;
 
  const _PersonalInfoSheet({required this.profile, required this.lang});
 
  @override
  State<_PersonalInfoSheet> createState() => _PersonalInfoSheetState();
}
 
class _PersonalInfoSheetState extends State<_PersonalInfoSheet> {
  late final TextEditingController _addressCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phone1Ctrl;
  late final TextEditingController _phone2Ctrl;
  late final TextEditingController _id1Ctrl;
  late final TextEditingController _phoneId1Ctrl;
  late final TextEditingController _id2Ctrl;
  late final TextEditingController _phoneId2Ctrl;
 
  @override
  void initState() {
    super.initState();
    final ids = (widget.profile['identifiers'] as List?) ?? [];
    _addressCtrl =
        TextEditingController(text: widget.profile['address'] ?? '');
    _emailCtrl =
        TextEditingController(text: widget.profile['email'] ?? '');
    _phone1Ctrl =
        TextEditingController(text: ids.isNotEmpty ? ids[0] : '');
    _phone2Ctrl =
        TextEditingController(text: ids.length > 1 ? ids[1] : '');
    _id1Ctrl =
        TextEditingController(text: ids.isNotEmpty ? ids[0] : '');
    _phoneId1Ctrl =
        TextEditingController(text: ids.isNotEmpty ? ids[0] : '');
    _id2Ctrl =
        TextEditingController(text: ids.length > 1 ? ids[1] : '');
    _phoneId2Ctrl =
        TextEditingController(text: ids.length > 1 ? ids[1] : '');
  }
 
  @override
  void dispose() {
    for (final c in [
      _addressCtrl, _emailCtrl, _phone1Ctrl, _phone2Ctrl,
      _id1Ctrl, _phoneId1Ctrl, _id2Ctrl, _phoneId2Ctrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
 
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
 
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    lang.translate('personal_information'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
 
              // Fields
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    SheetField(
                      label: lang.translate('permanent_address'),
                      controller: _addressCtrl,
                    ),
                    SheetField(
                      label: lang.translate('email'),
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SheetField(
                      label: lang.translate('identifier_1'),
                      controller: _id1Ctrl,
                    ),
                    SheetField(
                      label: lang.translate('identifier_2'),
                      controller: _id1Ctrl,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
 
              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          side:
                              const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          lang.translate('cancel'),
                          style: const TextStyle(
                              color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: hook up to save API
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                  lang.translate('changes_saved')),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF6B2737),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child:
                            Text(lang.translate('save_changes')),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
 