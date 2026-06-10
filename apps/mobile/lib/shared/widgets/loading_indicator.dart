import 'package:flutter/material.dart';

import '../../app/theme/mbg_theme.dart';

class MbgLoadingIndicator extends StatefulWidget {
  final double size;
  final String? message;

  const MbgLoadingIndicator({super.key, this.size = 48, this.message});

  @override
  State<MbgLoadingIndicator> createState() => _MbgLoadingIndicatorState();
}

class _MbgLoadingIndicatorState extends State<MbgLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RotationTransition(
          turns: _controller,
          child: const Icon(
            Icons.eco_rounded,
            size: 48,
            color: MBGColors.primary,
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.message!,
            style: TextStyle(
              fontSize: 13,
              color: MBGColors.neutral500,
            ),
          ),
        ],
      ],
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: MBGColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1D1B) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(
              color: isDark
                  ? MBGColors.neutral200.withValues(alpha: 0.1)
                  : MBGColors.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (i) => Padding(
                padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final delay = i * 0.2;
                    final value =
                        ((_controller.value - delay) % 1.0).abs();
                    final opacity = value < 0.5
                        ? 0.3 + (value * 1.4)
                        : 1.0 - ((value - 0.5) * 1.4);
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: MBGColors.primary
                            .withValues(alpha: opacity.clamp(0.3, 1.0)),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
