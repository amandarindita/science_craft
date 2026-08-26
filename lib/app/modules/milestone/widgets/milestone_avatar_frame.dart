import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Bingkai avatar milestone yang dirender langsung oleh Flutter.
///
/// Tidak membutuhkan asset tambahan. Backend tetap hanya menyimpan reward_key
/// frame yang sedang digunakan, misalnya `frame_atom` atau `frame_molecule`.
class MilestoneAvatarFrame extends StatelessWidget {
  const MilestoneAvatarFrame({
    super.key,
    required this.child,
    required this.size,
    this.frameId,
    this.muted = false,
    this.showShadow = true,
  });

  final Widget child;
  final double size;
  final String? frameId;
  final bool muted;
  final bool showShadow;

  bool get _hasFrame => frameId != null && frameId!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final double innerSize = _hasFrame ? size * 0.73 : size * 0.86;

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: showShadow
              ? const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x220F172A),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: <Widget>[
            if (_hasFrame)
              Positioned.fill(
                child: CustomPaint(
                  painter: _MilestoneFramePainter(
                    frameId: frameId!,
                    muted: muted,
                  ),
                ),
              ),
            Container(
              width: innerSize,
              height: innerSize,
              padding: EdgeInsets.all(size * 0.035),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: muted
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xCCFFFFFF),
                  width: 2,
                ),
              ),
              child: ClipOval(child: child),
            ),
          ],
        ),
      ),
    );
  }
}

class MilestoneFramePlaceholder extends StatelessWidget {
  const MilestoneFramePlaceholder({
    super.key,
    required this.frameId,
    required this.size,
    this.locked = false,
  });

  final String frameId;
  final double size;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return MilestoneAvatarFrame(
      frameId: frameId,
      size: size,
      muted: locked,
      showShadow: false,
      child: Container(
        color: const Color(0xFFF8FAFC),
        alignment: Alignment.center,
        child: Icon(
          locked ? Icons.lock_rounded : Icons.person_rounded,
          size: size * 0.36,
          color: locked
              ? const Color(0xFF94A3B8)
              : const Color(0xFF64748B),
        ),
      ),
    );
  }
}

class _MilestoneFramePainter extends CustomPainter {
  const _MilestoneFramePainter({
    required this.frameId,
    required this.muted,
  });

  final String frameId;
  final bool muted;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width, size.height) / 2;

    if (frameId == 'frame_molecule') {
      _paintMolecule(canvas, center, radius);
      return;
    }

    _paintAtom(canvas, center, radius);
  }

  void _paintAtom(Canvas canvas, Offset center, double radius) {
    final Rect shaderRect = Rect.fromCircle(center: center, radius: radius);
    final List<Color> colors = muted
        ? const <Color>[Color(0xFFCBD5E1), Color(0xFF94A3B8)]
        : const <Color>[Color(0xFF2563EB), Color(0xFF7C3AED), Color(0xFF38BDF8)];

    final Paint ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(radius * 0.065, 2.2)
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(colors: colors).createShader(shaderRect);

    final double orbitWidth = radius * 1.58;
    final double orbitHeight = radius * 0.67;
    final Rect orbitRect = Rect.fromCenter(
      center: center,
      width: orbitWidth,
      height: orbitHeight,
    );

    for (final double angle in <double>[0, math.pi / 3, -math.pi / 3]) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.translate(-center.dx, -center.dy);
      canvas.drawOval(orbitRect, ringPaint);
      canvas.restore();
    }

    final Paint nucleusPaint = Paint()
      ..color = muted ? const Color(0xFF94A3B8) : const Color(0xFF7C3AED);
    canvas.drawCircle(center, radius * 0.09, nucleusPaint);

    final Paint electronPaint = Paint()
      ..color = muted ? const Color(0xFFCBD5E1) : Colors.white
      ..style = PaintingStyle.fill;
    final Paint electronBorder = Paint()
      ..color = muted ? const Color(0xFF94A3B8) : const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(radius * 0.035, 1.3);

    for (final double angle in <double>[-0.45, 1.75, 3.55]) {
      final Offset point = Offset(
        center.dx + math.cos(angle) * radius * 0.82,
        center.dy + math.sin(angle) * radius * 0.82,
      );
      canvas.drawCircle(point, radius * 0.075, electronPaint);
      canvas.drawCircle(point, radius * 0.075, electronBorder);
    }
  }

  void _paintMolecule(Canvas canvas, Offset center, double radius) {
    final Rect shaderRect = Rect.fromCircle(center: center, radius: radius);
    final List<Color> colors = muted
        ? const <Color>[Color(0xFFCBD5E1), Color(0xFF94A3B8)]
        : const <Color>[Color(0xFF0891B2), Color(0xFF14B8A6), Color(0xFF2563EB)];

    final Paint outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(radius * 0.085, 2.5)
      ..shader = SweepGradient(colors: colors).createShader(shaderRect);

    canvas.drawCircle(center, radius * 0.82, outerPaint);

    final List<double> angles = <double>[
      -math.pi / 2,
      -math.pi / 6,
      math.pi / 3,
      math.pi,
      math.pi * 2 / 3,
    ];

    final List<Offset> nodes = angles
        .map(
          (double angle) => Offset(
            center.dx + math.cos(angle) * radius * 0.82,
            center.dy + math.sin(angle) * radius * 0.82,
          ),
        )
        .toList(growable: false);

    final Paint linkPaint = Paint()
      ..color = muted ? const Color(0xFFCBD5E1) : const Color(0xFF67E8F9)
      ..strokeWidth = math.max(radius * 0.045, 1.5)
      ..strokeCap = StrokeCap.round;

    for (int index = 0; index < nodes.length; index++) {
      final Offset current = nodes[index];
      final Offset next = nodes[(index + 2) % nodes.length];
      canvas.drawLine(current, next, linkPaint);
    }

    final Paint nodePaint = Paint()
      ..color = muted ? const Color(0xFFE2E8F0) : Colors.white;
    final Paint nodeBorder = Paint()
      ..color = muted ? const Color(0xFF94A3B8) : const Color(0xFF0891B2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(radius * 0.04, 1.3);

    for (final Offset node in nodes) {
      canvas.drawCircle(node, radius * 0.105, nodePaint);
      canvas.drawCircle(node, radius * 0.105, nodeBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _MilestoneFramePainter oldDelegate) {
    return oldDelegate.frameId != frameId || oldDelegate.muted != muted;
  }
}
