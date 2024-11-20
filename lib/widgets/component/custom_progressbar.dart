
import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final Widget Function(int current, int total, int percent)? topWidget;

  const CustomProgressBar({
    super.key,
    required this.current,
    required this.total,
    this.topWidget,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = current / total;
    final percentage = (progress * 100).toInt();

    return Column(
      children: [
        topWidget != null
            ? topWidget!(current, total, percentage) :
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$current/$total',
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}