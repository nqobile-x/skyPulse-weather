import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Full-bleed animated weather scene rendered via CustomPainter.
/// Uses a single AnimationController and RepaintBoundary for GPU efficiency.
class WeatherScene extends StatefulWidget {
  const WeatherScene({
    super.key,
    required this.weatherCode,
    required this.isDay,
  });

  final int weatherCode;
  final bool isDay;

  @override
  State<WeatherScene> createState() => _WeatherSceneState();
}

class _WeatherSceneState extends State<WeatherScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (ctx, _) => CustomPaint(
          painter: _ScenePainter(
            t: _ctrl.value,
            code: widget.weatherCode,
            isDay: widget.isDay,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

// ── Particle data (allocated once, never during paint) ─────────────────────

class _P {
  const _P(this.x, this.y, this.s);
  final double x, y, s;
}

class _ScenePainter extends CustomPainter {
  _ScenePainter({required this.t, required this.code, required this.isDay});

  final double t;
  final int code;
  final bool isDay;

  static final _rng = math.Random(42);

  static final List<_P> _rain = List.generate(
    38, (_) => _P(_rng.nextDouble(), _rng.nextDouble(), 0.5 + _rng.nextDouble() * 0.7),
  );
  static final List<_P> _snow = List.generate(
    42, (_) => _P(_rng.nextDouble(), _rng.nextDouble(), 0.3 + _rng.nextDouble() * 0.5),
  );
  static final List<_P> _stars = List.generate(
    58, (_) => _P(_rng.nextDouble(), _rng.nextDouble() * 0.88, _rng.nextDouble()),
  );

  @override
  void paint(Canvas canvas, Size sz) {
    if (code >= 95) {
      _storm(canvas, sz);
    } else if ((code >= 71 && code <= 77) || code == 85 || code == 86) {
      _snowScene(canvas, sz);
    } else if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) {
      _rainScene(canvas, sz);
    } else if (code == 45 || code == 48) {
      _fogScene(canvas, sz);
    } else if (code >= 2) {
      _cloudyScene(canvas, sz);
    } else {
      isDay ? _sunnyScene(canvas, sz) : _nightScene(canvas, sz);
    }
  }

  // ── Sunny ──────────────────────────────────────────────────────────────────

  void _sunnyScene(Canvas canvas, Size sz) {
    final cx = sz.width * 0.5;
    final cy = sz.height * 0.42;

    // Outer glow
    _blob(canvas, cx, cy, 95,
        const Color(0xFFFFD54F).withValues(alpha: 0.07 + math.sin(t * math.pi * 2) * 0.03), 55);
    _blob(canvas, cx, cy, 68,
        const Color(0xFFFFE082).withValues(alpha: 0.13), 22);

    // Rotating rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.45)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 12; i++) {
      final a = i / 12 * math.pi * 2 + t * math.pi * 0.5;
      final r0 = 48.0;
      final r1 = 63.0 + math.sin(t * math.pi * 6 + i) * 4.5;
      canvas.drawLine(
        Offset(cx + math.cos(a) * r0, cy + math.sin(a) * r0),
        Offset(cx + math.cos(a) * r1, cy + math.sin(a) * r1),
        rayPaint,
      );
    }

    // Sun body
    _blob(canvas, cx, cy, 42, const Color(0xFFFFD54F), null);
    // Highlight
    _blob(canvas, cx - 9, cy - 9, 13, const Color(0xFFFFF9C4).withValues(alpha: 0.55), null);

    // Drifting clouds
    final d = math.sin(t * math.pi * 2 * 0.18) * 14;
    _cloud(canvas, sz.width * 0.16 + d, sz.height * 0.22, 0.65,
        Colors.white.withValues(alpha: 0.30));
    _cloud(canvas, sz.width * 0.76 - d * 0.6, sz.height * 0.32, 0.5,
        Colors.white.withValues(alpha: 0.22));
  }

  // ── Night ──────────────────────────────────────────────────────────────────

  void _nightScene(Canvas canvas, Size sz) {
    // Twinkling stars
    for (int i = 0; i < _stars.length; i++) {
      final s = _stars[i];
      final twinkle = (math.sin(t * math.pi * 2 * (1.2 + s.s) + i * 1.4) + 1) / 2;
      _blob(canvas, s.x * sz.width, s.y * sz.height, 0.8 + twinkle * 0.9,
          Colors.white.withValues(alpha: 0.28 + twinkle * 0.65), null);
    }

    // Moon
    final mx = sz.width * 0.72;
    final my = sz.height * 0.30;
    _blob(canvas, mx, my, 35, const Color(0xFFF5E6A3), null);
    // Crescent shadow (overlaps moon with bg-ish color)
    _blob(canvas, mx + 11, my - 7, 29, const Color(0xFF050A1A), null);
    // Moon glow
    _blob(canvas, mx, my, 46, const Color(0xFFF5E6A3).withValues(alpha: 0.07), 22);
  }

  // ── Cloudy ─────────────────────────────────────────────────────────────────

  void _cloudyScene(Canvas canvas, Size sz) {
    final d = math.sin(t * math.pi * 2 * 0.14) * 16;
    _cloud(canvas, sz.width * 0.5 + d, sz.height * 0.36, 1.2,
        Colors.white.withValues(alpha: 0.28));
    _cloud(canvas, sz.width * 0.22 - d * 0.55, sz.height * 0.26, 0.9,
        Colors.white.withValues(alpha: 0.22));
    _cloud(canvas, sz.width * 0.80 + d * 0.35, sz.height * 0.48, 0.75,
        Colors.white.withValues(alpha: 0.18));
    if (code <= 2) {
      // Partly cloudy — sun peeking
      _blob(canvas, sz.width * 0.66, sz.height * 0.36, 28,
          const Color(0xFFFFD54F).withValues(alpha: 0.55), null);
      _blob(canvas, sz.width * 0.66, sz.height * 0.36, 38,
          const Color(0xFFFFD54F).withValues(alpha: 0.07), 18);
    }
  }

  // ── Rain ───────────────────────────────────────────────────────────────────

  void _rainScene(Canvas canvas, Size sz) {
    final d = math.sin(t * math.pi * 2 * 0.08) * 9;
    _cloud(canvas, sz.width * 0.32 + d, sz.height * 0.19, 0.95,
        const Color(0xFF455A64).withValues(alpha: 0.7));
    _cloud(canvas, sz.width * 0.72 - d, sz.height * 0.14, 0.85,
        const Color(0xFF37474F).withValues(alpha: 0.65));

    final rPaint = Paint()
      ..color = const Color(0xFF82B1FF).withValues(alpha: 0.52)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (final p in _rain) {
      final y = ((p.y + t * p.s * 1.25) % 1.0) * sz.height;
      final x = p.x * sz.width + math.sin(t * math.pi * 2 + p.x * 8) * 2.5;
      canvas.drawLine(Offset(x, y), Offset(x - 3, y + 14), rPaint);
    }
  }

  // ── Snow ───────────────────────────────────────────────────────────────────

  void _snowScene(Canvas canvas, Size sz) {
    _cloud(canvas, sz.width * 0.4, sz.height * 0.17, 1.1,
        Colors.blueGrey.shade200.withValues(alpha: 0.42));
    _cloud(canvas, sz.width * 0.76, sz.height * 0.11, 0.78,
        Colors.blueGrey.shade200.withValues(alpha: 0.32));

    final sPaint = Paint()..color = Colors.white.withValues(alpha: 0.72);
    for (final p in _snow) {
      final y = ((p.y + t * p.s * 0.52) % 1.0) * sz.height;
      final x = p.x * sz.width + math.sin(t * math.pi * 2 * 0.5 + p.y * 7) * 9;
      canvas.drawCircle(Offset(x, y), 2.6, sPaint);
    }
  }

  // ── Fog ────────────────────────────────────────────────────────────────────

  void _fogScene(Canvas canvas, Size sz) {
    final fogPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    for (int i = 0; i < 5; i++) {
      final y = sz.height * (0.08 + i * 0.19) +
          math.sin(t * math.pi * 2 + i * 1.3) * 11;
      fogPaint.color = Colors.white.withValues(alpha: 0.055 + i * 0.008);
      canvas.drawRect(Rect.fromLTWH(0, y, sz.width, 35), fogPaint);
    }
  }

  // ── Storm ──────────────────────────────────────────────────────────────────

  void _storm(Canvas canvas, Size sz) {
    final d = math.sin(t * math.pi * 2 * 0.07) * 6;
    _cloud(canvas, sz.width * 0.35 + d, sz.height * 0.13, 1.35,
        const Color(0xFF37474F).withValues(alpha: 0.90));
    _cloud(canvas, sz.width * 0.72 - d, sz.height * 0.08, 1.1,
        const Color(0xFF263238).withValues(alpha: 0.95));

    // Heavy diagonal rain
    final rPaint = Paint()
      ..color = const Color(0xFF64B5F6).withValues(alpha: 0.48)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    for (final p in _rain) {
      final y = ((p.y + t * p.s * 1.9) % 1.0) * sz.height;
      final x = p.x * sz.width - 5;
      canvas.drawLine(Offset(x, y), Offset(x - 6, y + 18), rPaint);
    }

    // Lightning bolt — fires when t > 0.86
    final flash = (t > 0.86) ? ((t - 0.86) / 0.14).clamp(0.0, 1.0) : 0.0;
    if (flash > 0) {
      final lx = sz.width * 0.48;
      final lPaint = Paint()
        ..color = Colors.white.withValues(alpha: flash * 0.92)
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(lx, sz.height * 0.16)
        ..lineTo(lx - 15, sz.height * 0.38)
        ..lineTo(lx, sz.height * 0.38)
        ..lineTo(lx - 22, sz.height * 0.64);
      canvas.drawPath(path, lPaint);
      // Screen flash
      canvas.drawRect(
        Rect.fromLTWH(0, 0, sz.width, sz.height),
        Paint()..color = Colors.white.withValues(alpha: flash * 0.055),
      );
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _blob(Canvas canvas, double x, double y, double r, Color color, double? blur) {
    final p = Paint()..color = color;
    if (blur != null) p.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    canvas.drawCircle(Offset(x, y), r, p);
  }

  void _cloud(Canvas canvas, double cx, double cy, double scale, Color color) {
    final p = Paint()..color = color;
    final s = scale;
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: 74 * s, height: 38 * s), p);
    canvas.drawCircle(Offset(cx - 21 * s, cy - 8 * s), 21 * s, p);
    canvas.drawCircle(Offset(cx + 19 * s, cy - 6 * s), 18 * s, p);
    canvas.drawCircle(Offset(cx, cy - 15 * s), 25 * s, p);
  }

  @override
  bool shouldRepaint(_ScenePainter o) =>
      o.t != t || o.code != code || o.isDay != isDay;
}
