import 'package:flutter/material.dart';
import 'package:kalender/src/models/time_of_day_range.dart';

/// The style of the [HourLines] widget.
class HourLinesStyle {
  /// The [Color] of the hour lines.
  final Color? color;

  /// The thickness of the hour lines.
  final double? thickness;

  /// The indent of the hour lines.
  final double? indent;

  /// The end indent of the hour lines.
  final double? endIndent;

  const HourLinesStyle({
    this.color,
    this.thickness,
    this.indent,
    this.endIndent,
  });
}

/// A widget that displays lines for each hour based on the [timeOfDayRange] and [heightPerMinute].
class HourLines extends StatelessWidget {
  /// The [TimeOfDayRange] that will be used to display the hour lines.
  final TimeOfDayRange timeOfDayRange;

  /// The height per minute.
  final double heightPerMinute;

  /// The style of the hour lines.
  final HourLinesStyle? style;

  /// Creates a new [HourLines] widget.
  const HourLines({
    super.key,
    required this.timeOfDayRange,
    required this.heightPerMinute,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final thickness = style?.thickness ?? 1;
    final color =
        style?.color ?? Theme.of(context).colorScheme.surfaceContainerHighest;
    // final indent = style?.indent ?? 40;
    // final endIndent = style?.endIndent ?? 0;

    final hours = timeOfDayRange.hourRanges;
    var previousXPosition = 0.0;
    final positionedLines = hours.map(
      (e) {
        final rangeHeight = heightPerMinute * e.duration.inMinutes;
        final position = rangeHeight + previousXPosition;
        previousXPosition = position;

        return Positioned(
          top: position,
          left: 0,
          right: 0,
          child: Container(
            // ---- No need for that, now to hours line in inside each page ----
            // margin: EdgeInsetsDirectional.only(start: indent, end: endIndent),
            height: thickness,
            color: color,
          ),
        );
      },
    );

    return Stack(
      children: positionedLines.toList(),
    );
  }
}
