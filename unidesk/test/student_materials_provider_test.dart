import 'package:flutter_test/flutter_test.dart';
import 'package:unidesk/features/entities/student/materials/data/student_materials_repository.dart';
import 'package:unidesk/features/entities/student/materials/models/student_material_course_option.dart';
import 'package:unidesk/features/entities/student/materials/models/student_course_material.dart';
import 'package:unidesk/features/entities/student/materials/providers/student_materials_provider.dart';

void main() {
  group('StudentMaterialsProvider', () {
    test(
      'loads materials for the first available course on first load',
      () async {
        final repository = _FakeStudentMaterialsRepository(
          materialsByCourse: {
            '1': [
              const StudentCourseMaterial(
                id: 'm1',
                courseId: '1',
                name: 'Intro.pdf',
                fileType: 'application/pdf',
                extensionLabel: 'PDF',
                sizeLabel: '52 KB',
                uploadedAtLabel: 'May 17, 2026',
                uploadedBy: 'Ahmed Hassan',
                downloadUrl: 'https://example.com/1',
              ),
            ],
          },
        );
        final provider = StudentMaterialsProvider(repository);

        await provider.loadIfNeeded(
          courseOptions: const [
            StudentMaterialCourseOption(
              selectionValue: '1',
              materialsCourseId: '1',
              displayLabel: 'CS101 - Algorithms',
            ),
            StudentMaterialCourseOption(
              selectionValue: '2',
              materialsCourseId: '2',
              displayLabel: 'CS102 - Databases',
            ),
          ],
        );

        expect(provider.selectedCourseSelectionValue, '1');
        expect(provider.materials, hasLength(1));
        expect(provider.materials.first.name, 'Intro.pdf');
        expect(provider.error, isNull);
        expect(repository.requestedCourseIds, ['1']);
      },
    );

    test('reloads materials when the selected course changes', () async {
      final repository = _FakeStudentMaterialsRepository(
        materialsByCourse: {
          '1': [
            const StudentCourseMaterial(
              id: 'm1',
              courseId: '1',
              name: 'Week1.pdf',
              fileType: 'application/pdf',
              extensionLabel: 'PDF',
              sizeLabel: '10 KB',
              uploadedAtLabel: 'May 17, 2026',
              uploadedBy: 'Ahmed Hassan',
              downloadUrl: 'https://example.com/1',
            ),
          ],
          '2': [
            const StudentCourseMaterial(
              id: 'm2',
              courseId: '2',
              name: 'Week2.pdf',
              fileType: 'application/pdf',
              extensionLabel: 'PDF',
              sizeLabel: '11 KB',
              uploadedAtLabel: 'May 18, 2026',
              uploadedBy: 'Ahmed Hassan',
              downloadUrl: 'https://example.com/2',
            ),
          ],
        },
      );
      final provider = StudentMaterialsProvider(repository);
      const courseOptions = [
        StudentMaterialCourseOption(
          selectionValue: '1',
          materialsCourseId: '1',
          displayLabel: 'CS101 - Algorithms',
        ),
        StudentMaterialCourseOption(
          selectionValue: '2',
          materialsCourseId: '2',
          displayLabel: 'CS102 - Databases',
        ),
      ];

      await provider.loadIfNeeded(courseOptions: courseOptions);
      await provider.selectCourse(
        selectionValue: '2',
        courseOptions: courseOptions,
      );

      expect(provider.selectedCourseSelectionValue, '2');
      expect(provider.materials, hasLength(1));
      expect(provider.materials.first.courseId, '2');
      expect(repository.requestedCourseIds, ['1', '2']);
    });

    test('exposes errors and refreshes the current course', () async {
      final repository = _FakeStudentMaterialsRepository(
        materialsByCourse: {
          '1': [
            const StudentCourseMaterial(
              id: 'm1',
              courseId: '1',
              name: 'Recovered.pdf',
              fileType: 'application/pdf',
              extensionLabel: 'PDF',
              sizeLabel: '12 KB',
              uploadedAtLabel: 'May 19, 2026',
              uploadedBy: 'Ahmed Hassan',
              downloadUrl: 'https://example.com/recovered',
            ),
          ],
        },
        failingCourseIds: {'1'},
      );
      final provider = StudentMaterialsProvider(repository);
      const courseOptions = [
        StudentMaterialCourseOption(
          selectionValue: '1',
          materialsCourseId: '1',
          displayLabel: 'CS101 - Algorithms',
        ),
      ];

      await provider.loadIfNeeded(courseOptions: courseOptions);

      expect(provider.error, contains('Failed to load materials'));
      expect(provider.materials, isEmpty);

      repository.failingCourseIds.clear();
      await provider.refresh(courseOptions: courseOptions);

      expect(provider.error, isNull);
      expect(provider.materials, hasLength(1));
      expect(repository.requestedCourseIds, ['1', '1']);
    });

    test(
      'preserves stable grouped selection when duplicate raw courses collapse to one option',
      () async {
        final repository = _FakeStudentMaterialsRepository(
          materialsByCourse: {
            '5002185': [
              const StudentCourseMaterial(
                id: 'm5',
                courseId: '5002185',
                name: 'Week5.pdf',
                fileType: 'application/pdf',
                extensionLabel: 'PDF',
                sizeLabel: '13 KB',
                uploadedAtLabel: 'May 20, 2026',
                uploadedBy: 'Ahmed Hassan',
                downloadUrl: 'https://example.com/5',
              ),
            ],
          },
        );
        final provider = StudentMaterialsProvider(repository);
        const courseOptions = [
          StudentMaterialCourseOption(
            selectionValue: '5002185',
            materialsCourseId: '5002185',
            displayLabel: 'CS201 - Algorithms',
          ),
        ];

        await provider.loadIfNeeded(courseOptions: courseOptions);
        await provider.refresh(courseOptions: courseOptions);

        expect(provider.selectedCourseSelectionValue, '5002185');
        expect(provider.materials, hasLength(1));
        expect(repository.requestedCourseIds, ['5002185', '5002185']);
      },
    );
  });
}

class _FakeStudentMaterialsRepository implements StudentMaterialsRepository {
  _FakeStudentMaterialsRepository({
    required this.materialsByCourse,
    Set<String>? failingCourseIds,
  }) : failingCourseIds = failingCourseIds ?? <String>{};

  final Map<String, List<StudentCourseMaterial>> materialsByCourse;
  final Set<String> failingCourseIds;
  final List<String> requestedCourseIds = [];

  @override
  Future<List<StudentCourseMaterial>> getMaterialsByCourse(
    String courseId,
  ) async {
    requestedCourseIds.add(courseId);
    if (failingCourseIds.contains(courseId)) {
      throw Exception('Failed to load materials for course $courseId');
    }
    return materialsByCourse[courseId] ?? const [];
  }
}
