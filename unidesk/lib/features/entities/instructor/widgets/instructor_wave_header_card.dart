import 'package:flutter/material.dart';

import 'instructor_surface_card.dart';

class InstructorWaveHeaderCard extends StatelessWidget {
  final Widget content;
  final bool compact;
  final double compactBreakpoint;
  final double minHeightCompact;
  final double minHeightRegular;
  final double waveWidthCompact;
  final double waveWidthRegular;
  final Widget? leadingCompact;
  final Widget? leadingRegular;
  final EdgeInsetsGeometry contentPadding;

  const InstructorWaveHeaderCard({
    super.key,
    required this.content,
    required this.compact,
    this.compactBreakpoint = 360,
    this.minHeightCompact = 180,
    this.minHeightRegular = 150,
    this.waveWidthCompact = 110,
    this.waveWidthRegular = 160,
    this.leadingCompact,
    this.leadingRegular,
    this.contentPadding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return InstructorSurfaceCard(
      radius: 20,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: compact ? minHeightCompact : minHeightRegular,
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: SizedBox(
                  width: compact ? waveWidthCompact : waveWidthRegular,
                  child: CustomPaint(painter: const InstructorWavePainter()),
                ),
              ),
              Padding(
                padding: contentPadding,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final useCompactLayout =
                        compact || constraints.maxWidth < compactBreakpoint;

                    if (useCompactLayout) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ?leadingCompact,
                          if (leadingCompact != null) const SizedBox(height: 12),
                          content,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        ?leadingRegular,
                        if (leadingRegular != null) const SizedBox(width: 12),
                        Expanded(child: content),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InstructorWavePainter extends CustomPainter {
  const InstructorWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xffDDF3F2)
      ..style = PaintingStyle.fill;
    final path1 = Path();
    path1.moveTo(size.width * 0.6, 0);
    path1.cubicTo(size.width * 0.3, size.height * 0.1, size.width * 0.1,
        size.height * 0.4, size.width * 0.3, size.height * 0.7);
    path1.cubicTo(size.width * 0.5, size.height * 0.9, size.width * 0.2,
        size.height, 0, size.height);
    path1.lineTo(size.width, size.height);
    path1.lineTo(size.width, 0);
    path1.close();
    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..color = const Color(0xffB8E8E6)
      ..style = PaintingStyle.fill;
    final path2 = Path();
    path2.moveTo(size.width * 0.9, 0);
    path2.cubicTo(size.width * 0.7, size.height * 0.2, size.width * 0.5,
        size.height * 0.5, size.width * 0.7, size.height * 0.8);
    path2.cubicTo(size.width * 0.8, size.height * 0.9, size.width * 0.6,
        size.height, size.width * 0.5, size.height);
    path2.lineTo(size.width, size.height);
    path2.lineTo(size.width, 0);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
