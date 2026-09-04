import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../features/ai/jarvis_weather_ai.dart';
import '../../../../core/services/aria_voice.dart';

class AriaPanel extends StatefulWidget {
  const AriaPanel({
    super.key,
    required this.insights,
    required this.briefing,
    required this.voice,
    required this.city,
  });

  final List<AriaInsight> insights;
  final String briefing;
  final AriaVoice voice;
  final String city;

  @override
  State<AriaPanel> createState() => _AriaPanelState();
}

class _AriaPanelState extends State<AriaPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    widget.voice.speaking.addListener(_onSpeakingChanged);
  }

  void _onSpeakingChanged() {
    if (widget.voice.speaking.value) {
      _waveCtrl.repeat(reverse: true);
    } else {
      _waveCtrl.animateTo(0, duration: 300.ms);
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.voice.speaking.removeListener(_onSpeakingChanged);
    _waveCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSpeakTap() async {
    if (widget.voice.speaking.value) {
      await widget.voice.stop();
    } else {
      await widget.voice.speak(widget.briefing);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF12002E), Color(0xFF0A1240)],
        ),
        border: Border.all(
          color: const Color(0xFF9C27B0).withValues(alpha: 0.30),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B1FA2).withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _AriaHeader(city: widget.city, isSpeaking: widget.voice.speaking.value),

          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: const Color(0xFF9C27B0).withValues(alpha: 0.22),
          ),

          // Briefing text
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
            child: Text(
              widget.briefing.isEmpty
                  ? 'ARIA is analysing atmospheric conditions...'
                  : widget.briefing,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 
                    widget.briefing.isEmpty ? 0.38 : 0.88),
                fontSize: 14.5,
                height: 1.65,
                letterSpacing: 0.15,
                fontStyle: widget.briefing.isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ).animate().fadeIn(duration: 500.ms),

          // Quick-scan insight chips
          if (widget.insights.isNotEmpty) _ChipRow(insights: widget.insights),

          // Speak button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: _SpeakButton(
              isSpeaking: widget.voice.speaking.value,
              waveCtrl: _waveCtrl,
              onTap: _onSpeakTap,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _AriaHeader extends StatelessWidget {
  const _AriaHeader({required this.city, required this.isSpeaking});

  final String city;
  final bool isSpeaking;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 14),
      child: Row(
        children: [
          // Pulsing indicator
          _PulseDot(active: isSpeaking),
          const SizedBox(width: 10),
          // Name + subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ARIA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                ),
              ),
              Text(
                isSpeaking ? 'Speaking...' : 'Atmospheric Intelligence · $city',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF66BB6A).withValues(alpha: 0.45),
                width: 1,
              ),
            ),
            child: const Text(
              'ONLINE',
              style: TextStyle(
                color: Color(0xFF66BB6A),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pulsing dot ────────────────────────────────────────────────────────────

class _PulseDot extends StatelessWidget {
  const _PulseDot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color =
        active ? const Color(0xFFE040FB) : const Color(0xFF7E57C2);
    return SizedBox(
      width: 18,
      height: 18,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (active)
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.22),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1.3, 1.3),
                  duration: 800.ms,
                ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ],
      ),
    );
  }
}

// ── Insight chips ──────────────────────────────────────────────────────────

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.insights});
  final List<AriaInsight> insights;

  @override
  Widget build(BuildContext context) {
    // Pick up to 5 most-relevant chips (alerts first, then others)
    final chips = [
      ...insights.where((i) => i.isAlert),
      ...insights.where((i) => !i.isAlert),
    ].take(5).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: chips
            .asMap()
            .entries
            .map((e) => _InsightChip(insight: e.value)
                .animate()
                .fadeIn(delay: (e.key * 60).ms, duration: 400.ms)
                .slideX(begin: 0.12, end: 0))
            .toList(),
      ),
    );
  }
}

class _InsightChip extends StatelessWidget {
  const _InsightChip({required this.insight});
  final AriaInsight insight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: insight.color.withValues(alpha: insight.isAlert ? 0.20 : 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: insight.color.withValues(alpha: insight.isAlert ? 0.55 : 0.28),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(insight.icon, size: 12, color: insight.color),
          const SizedBox(width: 5),
          Text(
            insight.title,
            style: TextStyle(
              color: insight.color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Speak button with waveform ─────────────────────────────────────────────

class _SpeakButton extends StatelessWidget {
  const _SpeakButton({
    required this.isSpeaking,
    required this.waveCtrl,
    required this.onTap,
  });

  final bool isSpeaking;
  final AnimationController waveCtrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: isSpeaking
                ? [const Color(0xFF6A1B9A), const Color(0xFF4527A0)]
                : [
                    const Color(0xFF4A148C).withValues(alpha: 0.6),
                    const Color(0xFF1A237E).withValues(alpha: 0.6),
                  ],
          ),
          border: Border.all(
            color: isSpeaking
                ? const Color(0xFFCE93D8).withValues(alpha: 0.55)
                : const Color(0xFF7986CB).withValues(alpha: 0.30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
              color: isSpeaking
                  ? const Color(0xFFE040FB)
                  : Colors.white.withValues(alpha: 0.7),
              size: 18,
            ),
            const SizedBox(width: 10),
            if (isSpeaking) ...[
              _Waveform(ctrl: waveCtrl),
              const SizedBox(width: 10),
              const Text(
                'ARIA is speaking',
                style: TextStyle(
                  color: Color(0xFFE040FB),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ] else
              Text(
                'Hear ARIA speak',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Animated waveform bars ─────────────────────────────────────────────────

class _Waveform extends StatelessWidget {
  const _Waveform({required this.ctrl});
  final AnimationController ctrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(5, (i) {
          final phase = (i / 5) * math.pi;
          return AnimatedBuilder(
            animation: ctrl,
            builder: (context, _) {
              final h = 4.0 +
                  (math.sin(ctrl.value * math.pi * 2 + phase) + 1) / 2 * 14;
              return Container(
                width: 3,
                height: h,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: const Color(0xFFE040FB),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
