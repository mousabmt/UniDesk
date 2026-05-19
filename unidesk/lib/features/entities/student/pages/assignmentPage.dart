import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/entities/student/assignments/models/student_assignment.dart';
import 'package:unidesk/features/entities/student/assignments/providers/student_assignments_provider.dart';
import 'package:unidesk/features/entities/student/widgets/student_refresh_status.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../features/language/langProvider.dart';

class AssignmentPage extends StatefulWidget {
  const AssignmentPage({super.key});

  @override
  State<AssignmentPage> createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  late StudentAssignmentsProvider _provider;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider = Provider.of<StudentAssignmentsProvider>(
        context,
        listen: false,
      );
      _provider.loadAssignments();
    });
  }

  Future<void> _refreshAssignments(StudentAssignmentsProvider provider) async {
    setState(() {
      _isRefreshing = true;
    });
    try {
      await provider.loadAssignments();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    return Directionality(
      textDirection: lang.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xfff9fbfc),
        appBar: AppBar(
          title: Text(
            lang.translate('assignments'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          elevation: 0,
        ),
        body: Consumer<StudentAssignmentsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingAssignments) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.assignmentsError != null) {
              return _buildErrorWidget(
                provider.assignmentsError!,
                onRetry: () => provider.loadAssignments(),
              );
            }

            if (provider.assignments.isEmpty) {
              return const Center(child: Text('No assignments available'));
            }

            return RefreshIndicator(
              onRefresh: () => _refreshAssignments(provider),
              child: ListView.builder(
                itemCount: provider.assignments.length + 1,
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return StudentRefreshStatus(
                      isRefreshing: _isRefreshing,
                      message: 'Refreshing assignments...',
                      padding: EdgeInsets.zero,
                    );
                  }

                  final assignment = provider.assignments[index - 1];
                  return AssignmentCard(
                    assignment: assignment,
                    onTap: () => _showAssignmentDetail(assignment),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _showAssignmentDetail(StudentAssignment assignment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AssignmentDetailSheet(assignment: assignment),
    );
  }

  Widget _buildErrorWidget(String error, {VoidCallback? onRetry}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading assignments',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}

class AssignmentCard extends StatelessWidget {
  final StudentAssignment assignment;
  final VoidCallback onTap;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusLabel = assignment.statusLabel;
    final double score =
        double.tryParse(assignment.submission?.scoreLabel ?? '0') ?? 0.0;

    final double ratio = assignment.maxScore > 0
        ? score / assignment.maxScore
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          assignment.course.courseName,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Due: ${assignment.dueDateLabel}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.score, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Max Score: ${assignment.maxScore}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  if (assignment.isSubmitted &&
                      assignment.submission != null) ...[
                    const SizedBox(width: 16),
                    if (assignment.isGraded)
                      Text(
                        'Score: ${assignment.submission!.scoreLabel}/${assignment.maxScore}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ratio >= 0.9
                              ? Colors.green[700]
                              : ratio >= 0.75
                              ? Colors.orange[700]
                              : Colors.red[700],
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Text(
                        'Pending Grade',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange[700],
                        ),
                      ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (assignment.isGraded) return Colors.green;
    if (assignment.isSubmitted) return Colors.blue;
    if (assignment.isOverdue) return Colors.red;
    return Colors.orange;
  }
}

class AssignmentDetailSheet extends StatefulWidget {
  final StudentAssignment assignment;

  const AssignmentDetailSheet({super.key, required this.assignment});

  @override
  State<AssignmentDetailSheet> createState() => _AssignmentDetailSheetState();
}

class _AssignmentDetailSheetState extends State<AssignmentDetailSheet> {
  late StudentAssignmentsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<StudentAssignmentsProvider>(context, listen: false);

    // Defer loading to avoid build-phase setState warning
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_provider.selectedAssignment?.id != widget.assignment.id) {
        _provider.loadAssignmentDetail(widget.assignment.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentAssignmentsProvider>(
      builder: (context, provider, _) {
        final assignment = provider.selectedAssignment ?? widget.assignment;

        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignment.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            assignment.course.courseName,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  assignment.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                // Details Grid
                Row(
                  children: [
                    Expanded(
                      child: _DetailCard(
                        title: 'Due Date',
                        value: assignment.dueDateLabel,
                        icon: Icons.calendar_today,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DetailCard(
                        title: 'Max Score',
                        value: assignment.maxScore.toString(),
                        icon: Icons.score,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DetailCard(
                        title: 'Section',
                        value: 'Section ${assignment.section.sectionNumber}',
                        icon: Icons.class_,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DetailCard(
                        title: 'Status',
                        value: assignment.statusLabel,
                        icon: Icons.info_outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // File Section
                if (assignment.file != null) ...[
                  Text(
                    'Assignment File',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _FileCard(file: assignment.file!),
                  const SizedBox(height: 16),
                ],

                // Submission Section
                if (assignment.isSubmitted && assignment.submission != null)
                  _SubmissionCard(
                    submission: assignment.submission!,
                    maxScore: assignment.maxScore,
                  )
                else
                  _SubmitAssignmentForm(assignmentId: assignment.id),

                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _DetailCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FileCard extends StatelessWidget {
  final dynamic file;

  const _FileCard({required this.file});

  @override
  Widget build(BuildContext context) {
    final fileName = file.fileName ?? 'Download';
    final fileSize = file.fileSize ?? 0;
    final fileUrl = file.fileUrl ?? '';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.attachment, color: Colors.blue),
        title: Text(fileName),
        subtitle: Text('${(fileSize / 1024).toStringAsFixed(2)} KB'),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () => _downloadFile(context, fileUrl),
        ),
      ),
    );
  }

  Future<void> _downloadFile(BuildContext context, String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open file')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

class _SubmissionCard extends StatelessWidget {
  final dynamic submission;
  final int maxScore;

  const _SubmissionCard({required this.submission, required this.maxScore});

  @override
  Widget build(BuildContext context) {
    final score = submission.score;
    final double ratio = score != null && maxScore > 0 ? score / maxScore : 0.0;
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: submission.isGraded ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  submission.isGraded ? 'Graded' : 'Submitted',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: submission.isGraded ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Submitted At: ${submission.submittedAtLabel}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (submission.isGraded) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue[50]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${submission.scoreLabel}/$maxScore',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: ratio >= 0.9
                                ? Colors.green[700]
                                : ratio >= 0.75
                                ? Colors.orange[700]
                                : Colors.red[700],
                          ),
                    ),
                  ],
                ),
              ),
              if (submission.feedback != null &&
                  submission.feedback.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Feedback',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        submission.feedback,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _SubmitAssignmentForm extends StatefulWidget {
  final String assignmentId;

  const _SubmitAssignmentForm({required this.assignmentId});

  @override
  State<_SubmitAssignmentForm> createState() => _SubmitAssignmentFormState();
}

class _SubmitAssignmentFormState extends State<_SubmitAssignmentForm> {
  PlatformFile? _selectedFile;

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentAssignmentsProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Submit Assignment',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (provider.submitError != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        provider.submitError!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            if (provider.submitSuccess != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        provider.submitSuccess!,
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_selectedFile == null)
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Select File to Submit',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to choose a file (Max 10MB)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green[300]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.green[50],
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'File Selected',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          Text(
                            _selectedFile!.name,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() => _selectedFile = null);
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedFile == null || provider.isSubmitting
                    ? null
                    : _submitAssignment,
                icon: provider.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  provider.isSubmitting ? 'Submitting...' : 'Submit Assignment',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        // Check file size (10MB = 10485760 bytes)
        if (file.size > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File size must be less than 10MB')),
            );
          }
          return;
        }
        setState(() => _selectedFile = file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error selecting file: $e')));
      }
    }
  }

  Future<void> _submitAssignment() async {
    if (_selectedFile == null) return;

    final provider = Provider.of<StudentAssignmentsProvider>(
      context,
      listen: false,
    );
    final fileBytes = _selectedFile!.bytes;
    final localPath = kIsWeb ? null : _selectedFile!.path;

    if ((localPath == null || localPath.isEmpty) && fileBytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to read the selected file. Please choose it again.',
            ),
          ),
        );
      }
      return;
    }

    // Clear previous messages before submitting
    provider.clearSubmitMessage();

    final success = await provider.submitAssignment(
      assignmentId: widget.assignmentId,
      fileName: _selectedFile!.name,
      localPath: localPath,
      fileBytes: fileBytes,
    );

    if (success && mounted) {
      // Wait for success message to be visible, then close
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          provider.clearSubmitMessage();
          Navigator.pop(context);
        }
      });
    }
  }
}
