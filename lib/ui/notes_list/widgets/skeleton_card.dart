import 'package:flutter/material.dart';

class SkeletonList extends StatefulWidget {
  const SkeletonList({super.key, this.count = 4});

  final int count;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          itemCount: widget.count,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bar(scheme, width: 0.6, height: 15),
                const SizedBox(height: 12),
                _bar(scheme, width: 0.9, height: 11),
                const SizedBox(height: 8),
                _bar(scheme, width: 0.7, height: 11),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bar(ColorScheme scheme,
      {required double width, required double height}) {
    final progress = _controller.value;
    final base = scheme.onSurfaceVariant.withValues(alpha: 0.12);
    final highlight = scheme.onSurfaceVariant.withValues(alpha: 0.04);

    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: width,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: LinearGradient(
            colors: [base, highlight, base],
            begin: Alignment(-1 - 2 * progress, 0),
            end: Alignment(1 - 2 * progress, 0),
          ),
        ),
      ),
    );
  }
}
