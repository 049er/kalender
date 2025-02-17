import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:kalender/src/models/calendar_events/draggable_event.dart';
import 'package:kalender/src/widgets/draggable/new_draggable.dart';

/// This widget generates draggable widgets for each visible day.
/// - These draggable widgets are used to create new events.
///
class DayEventDraggableWidgets<T extends Object?>
    extends NewDraggableWidget<T> {
  final MultiDayBodyConfiguration bodyConfiguration;
  final DateTimeRange visibleDateTimeRange;
  final TimeOfDayRange timeOfDayRange;
  final double dayWidth;
  final double pageHeight;
  final double heightPerMinute;

  const DayEventDraggableWidgets({
    super.key,
    required super.controller,
    required this.bodyConfiguration,
    required this.visibleDateTimeRange,
    required this.timeOfDayRange,
    required this.pageHeight,
    required this.dayWidth,
    required this.heightPerMinute,
    required super.callbacks,
  });

  @override
  Widget build(BuildContext context) {
    var localPosition = Offset.zero;
    final allowCreation = bodyConfiguration.allowEventCreation;
    final createEventTrigger = bodyConfiguration.createEventGesture;
    return Listener(
      onPointerDown: (event) => localPosition = event.localPosition,
      onPointerSignal: (event) => localPosition = event.localPosition,
      onPointerMove: (event) => localPosition = event.localPosition,
      child: Row(
        children: [
          if (allowCreation)
            for (final date in visibleDateTimeRange.days)
              switch (createEventTrigger) {
                CreateEventGesture.tap => Draggable(
                    dragAnchorStrategy: pointerDragAnchorStrategy,
                    onDragStarted: () => createNewEvent(date, localPosition),
                    onDraggableCanceled: onDragFinished,
                    onDragEnd: onDragFinished,
                    data: Create(controllerId: controller.id),
                    feedback: Container(
                        color: Colors.transparent, width: 1, height: 1),
                    child: Container(
                        color: Colors.transparent,
                        width: dayWidth,
                        height: pageHeight),
                  ),
                CreateEventGesture.longPress => LongPressDraggable(
                    delay: const Duration(milliseconds: 200),
                    dragAnchorStrategy: pointerDragAnchorStrategy,
                    onDragStarted: () => createNewEvent(date, localPosition),
                    onDraggableCanceled: onDragFinished,
                    onDragEnd: onDragFinished,
                    data: Create(controllerId: controller.id),
                    feedback: Container(
                        color: Colors.transparent, width: 1, height: 1),
                    child: Container(
                        color: Colors.transparent,
                        width: dayWidth,
                        height: pageHeight),
                  ),
              },
        ],
      ),
    );
  }

  /// Calculate the initial dateTimeRange of a new event.
  ///
  /// [date] is the date the draggable is located at.
  /// [localPosition] is the last known position of the cursor.
  @override
  DateTimeRange calculateDateTimeRange(DateTime date, Offset localPosition) {
    final start = _calculateTimeAndDate(date, localPosition);
    final end = start.add(bodyConfiguration.newEventDuration);
    return DateTimeRange(start: start, end: end);
  }

  /// Calculate a DateTime from the [date] of the draggable and the [localPosition] of the cursor.
  DateTime _calculateTimeAndDate(DateTime date, Offset localPosition) {
    // Calculate the duration from the top of the page to the localPosition.
    final durationFromStart = localPosition.dy ~/ heightPerMinute;
    final snapIntervalMinutes = bodyConfiguration.snapIntervalMinutes;
    final numberOfIntervals = (durationFromStart / snapIntervalMinutes).round();
    final durationFromTop =
        Duration(minutes: snapIntervalMinutes * numberOfIntervals);

    // Calculate the start of the day.
    final startOfDay = timeOfDayRange.start.toDateTime(date);

    // Add the calculated duration to the startOfDay and convert to local.
    return startOfDay.add(durationFromTop).asLocal;
  }
}
