import 'package:flutter/material.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_course_details.dart';

class CourseStudentListItem extends StatelessWidget {
  const CourseStudentListItem({
    super.key,
    required this.student,
  });

  final InstructorCourseStudent student;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: const Color(0xffe0f7f6),
        child: Text(
          _initialsFor(student.name),
          style: const TextStyle(
            color: Color(0xff0bb4b1),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        student.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(student.email),
    );
  }

  static String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
