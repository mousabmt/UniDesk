import 'package:flutter/material.dart';
import 'package:unidesk/features/language/langProvider.dart';
import '../profileWidgets/custom_field.dart'; 
class PersonalInfoSheet extends StatefulWidget {
  final Map<String, dynamic> profile;
  final LangProvider lang;

  const PersonalInfoSheet({
    super.key,
    required this.profile,
    required this.lang,
  });

  @override
  State<PersonalInfoSheet> createState() => _PersonalInfoSheetState();
}

class _PersonalInfoSheetState extends State<PersonalInfoSheet> {
  late final TextEditingController _addressCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phone1Ctrl;
  late final TextEditingController _phone2Ctrl;

  @override
  void initState() {
    super.initState();
    final ids = (widget.profile['identifiers'] as List?) ?? [];
    _addressCtrl = TextEditingController(text: widget.profile['address'] ?? '');
    _emailCtrl = TextEditingController(text: widget.profile['personal_email'] ?? '');
    _phone1Ctrl = TextEditingController(text: ids.isNotEmpty ? ids[0] : '');
    _phone2Ctrl = TextEditingController(text: ids.length > 1 ? ids[1] : '');
  }

  @override
  void dispose() {
    for (final c in [_addressCtrl, _emailCtrl, _phone1Ctrl, _phone2Ctrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveInfo() {
    widget.profile['personal_email'] = _emailCtrl.text;
    widget.profile['identifier_1'] = _phone1Ctrl.text;
    widget.profile['identifier_2'] = _phone2Ctrl.text;
    widget.profile['address'] = _addressCtrl.text;
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Directionality(
          textDirection: lang.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    horizontal: 20,
                    vertical: 8,
                  ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      SheetField(
                        label: lang.translate('permanent_address'),
                        controller: _addressCtrl,
                      ),
                      SheetField(
                        label: lang.translate('personal_email'),
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SheetField(
                        label: lang.translate('identifier_1'),
                        controller: _phone1Ctrl,
                        keyboardType: TextInputType.phone,
                      ),
                      SheetField(
                        label: lang.translate('identifier_2'),
                        controller: _phone2Ctrl,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            lang.translate('cancel'),
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _saveInfo();
                            // TODO: hook up to save API
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(lang.translate('changes_saved')),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B2737),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Text(lang.translate('save_changes')),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
