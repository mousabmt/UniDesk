import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AddAssignmentPage extends StatefulWidget {
  const AddAssignmentPage({super.key});

  @override
  State<AddAssignmentPage> createState() => _AddAssignmentPageState();
}

class _AddAssignmentPageState extends State<AddAssignmentPage> {
  static const Color kTeal = Color(0xFF2E9C9C);

  final _titleController = TextEditingController(text: 'Assignment 4');
  final _descController = TextEditingController(
      text: 'Please solve all the questions in the attached file.');
  final _pointsController = TextEditingController(text: '100');
  final _instructionsController = TextEditingController();

  String _selectedCourse = 'CS301 - Data Structures';
  DateTime _dueDate = DateTime(2024, 5, 25);

  Map<String, String>? _uploadedFile = {
    'name': 'assignment_4.pdf',
    'size': '2.4 MB',
  };

  final List<String> _courses = [
    'CS301 - Data Structures',
    'CS302 - Algorithms',
    'CS401 - Operating Systems',
    'CS402 - Networks',
  ];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: kTeal),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _pointsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF0F0),
      // ✅ شيلنا _buildHeader و_buildBottomNav
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Select Course'),
              const SizedBox(height: 8),
              _buildDropdown(),
              const SizedBox(height: 20),

              _label('Title'),
              const SizedBox(height: 8),
              _buildTextField(_titleController, 'Assignment title'),
              const SizedBox(height: 20),

              _label('Description'),
              const SizedBox(height: 8),
              _buildTextField(_descController, 'Enter description...', maxLines: 4),
              const SizedBox(height: 20),

              _label('Due Date'),
              const SizedBox(height: 8),
              _buildDateField(),
              const SizedBox(height: 20),

              _label('Attach File (Optional)'),
              const SizedBox(height: 8),
              _buildUploadButton(),
              if (_uploadedFile != null) ...[
                const SizedBox(height: 10),
                _buildFileChip(),
              ],
              const SizedBox(height: 20),

              _label('Total Points'),
              const SizedBox(height: 8),
              _buildTextField(_pointsController, '100',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 20),

              _label('Instructions (Optional)'),
              const SizedBox(height: 8),
              _buildTextField(
                _instructionsController,
                'Add any additional instructions for students...',
                maxLines: 4,
              ),
              const SizedBox(height: 28),

              _buildPublishButton(context), // ✅ أضفنا context
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        ),
      );

  InputDecoration _inputDec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kTeal, width: 1.5),
        ),
      );

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
        decoration: _inputDec(hint),
      );

  Widget _buildDropdown() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedCourse,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down,
                color: Color(0xFF444444)),
            style:
                const TextStyle(fontSize: 14, color: Color(0xFF222222)),
            items: _courses
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCourse = v!),
          ),
        ),
      );

  Widget _buildDateField() => GestureDetector(
        onTap: _pickDate,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('MMMM dd, yyyy').format(_dueDate),
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF222222)),
                ),
              ),
              const Icon(Icons.calendar_today_outlined,
                  size: 20, color: Color(0xFF555555)),
            ],
          ),
        ),
      );

  Widget _buildUploadButton() => GestureDetector(
        onTap: () {
          setState(() {
            _uploadedFile = {'name': 'assignment_4.pdf', 'size': '2.4 MB'};
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, width: 1.2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.attach_file, color: kTeal, size: 20),
              SizedBox(width: 8),
              Text('Upload File',
                  style: TextStyle(
                      color: kTeal,
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
            ],
          ),
        ),
      );

  Widget _buildFileChip() => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: const Text('PDF',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_uploadedFile!['name']!,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(_uploadedFile!['size']!,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _uploadedFile = null),
              child: const Icon(Icons.close,
                  size: 20, color: Color(0xFF555555)),
            ),
          ],
        ),
      );

  Widget _buildPublishButton(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            // ✅ بعد النشر ارجع للـ assignments
            context.go('/instructor/assignments-list');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kTeal,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text(
            'Publish Assignment',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3),
          ),
        ),
      );
}