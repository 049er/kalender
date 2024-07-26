import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:kalender/src/enumerations.dart';
import 'package:kalender/src/platform.dart';

/// A [GestureDetector] that listens for gestures on a
class MultiDayGestureDetector<T extends Object?> extends StatefulWidget {
  final EventsController<T> eventsController;
  final CalendarController<T> controller;
  final CalendarCallbacks<T>? callbacks;
  final DateTimeRange visibleDateTimeRange;
  final CreateEventTrigger createEventTrigger;
  final double dayWidth;

  const MultiDayGestureDetector({
    super.key,
    required this.eventsController,
    required this.controller,
    required this.callbacks,
    required this.visibleDateTimeRange,
    required this.createEventTrigger,
    required this.dayWidth,
  });

  @override
  State<MultiDayGestureDetector<T>> createState() => _MultiDayGestureDetectorState<T>();
}

class _MultiDayGestureDetectorState<T extends Object?> extends State<MultiDayGestureDetector<T>> {
  EventsController<T> get eventsController => widget.eventsController;
  CalendarController<T> get controller => widget.controller;
  ViewController<T> get viewController => controller.viewController!;
  CreateEventTrigger get createEventTrigger => widget.createEventTrigger;
  CalendarCallbacks<T>? get callbacks => widget.callbacks;

  double get dayWidth => widget.dayWidth;
  ValueNotifier<CalendarEvent<T>?> get selectedEvent => controller.selectedEvent;
  DateTime? start;

  void onDown(Offset localPosition) {
    final dateTimeRange = _calculateDateTimeRange(localPosition);

    if (dateTimeRange == null) return;
    start = dateTimeRange.start;

    if (isMobileDevice && selectedEvent.value != null) {
      selectedEvent.value = null;
    } else {
      var newEvent = CalendarEvent<T>(dateTimeRange: dateTimeRange);
      newEvent = callbacks?.onEventCreate?.call(newEvent) ?? newEvent;
      controller.selectEvent(newEvent, internal: true);
    }
  }

  void onUpdate(Offset localPosition) {
    if (start == null) return;

    var currentDate = _calculateTimeAndDate(localPosition);
    if (currentDate == null) return;

    if (currentDate == start) {
      currentDate = currentDate.endOfDay;
    }

    // Create a dateTimeRange from the start and currentDateTime.
    final dateTimeRange = currentDate.isBefore(start!)
        ? DateTimeRange(start: currentDate, end: start!.endOfDay)
        : DateTimeRange(start: start!, end: currentDate);

    final selectedEvent = this.selectedEvent.value;
    if (selectedEvent == null) return;
    final updatedEvent = selectedEvent.copyWith(dateTimeRange: dateTimeRange);
    controller.selectEvent(updatedEvent, internal: true);
  }

  void onEnd() {
    start = null;
    final newEvent = selectedEvent.value;
    if (newEvent == null) return;
    controller.deselectEvent();
    callbacks?.onEventCreated?.call(newEvent);
  }

  void onCanceled() {
    start = null;
    controller.deselectEvent();
  }

  DateTimeRange? _calculateDateTimeRange(Offset position) {
    final start = _calculateTimeAndDate(position);
    if (start == null) return null;
    return DateTimeRange(start: start, end: start.endOfDay);
  }

  DateTime? _calculateTimeAndDate(Offset position) {
    // Calculate the date of the position.
    final visibleDates = widget.visibleDateTimeRange.datesSpanned;
    final cursorDate = (position.dx / dayWidth);
    final cursorDateIndex = cursorDate.floor();
    if (cursorDateIndex < 0) return null;
    final date = visibleDates.elementAtOrNull(cursorDateIndex);
    if (date == null) return null;
    return date;
  }

  @override
  Widget build(BuildContext context) {
    final tap = createEventTrigger == CreateEventTrigger.tap;
    final long = createEventTrigger == CreateEventTrigger.longPress;

    return MouseRegion(
      child: GestureDetector(
        // Tap
        onTapDown: tap ? (details) => onDown(details.localPosition) : null,
        onTapUp: tap ? (_) => onEnd() : null,
        onTapCancel: tap ? onCanceled : null,

        // Long Press
        onLongPressDown: long ? (details) => onDown(details.localPosition) : null,
        onLongPressMoveUpdate: long ? (details) => onUpdate(details.localPosition) : null,
        onLongPressEnd: long ? (_) => onEnd() : null,
        onLongPressCancel: long ? onCanceled : null,

        // Pan
        onPanStart: isMobileDevice
            ? null
            : tap
                ? (details) => onDown(details.localPosition)
                : null,
        onPanUpdate: isMobileDevice
            ? null
            : tap
                ? (details) => onUpdate(details.localPosition)
                : null,
        onPanEnd: isMobileDevice
            ? null
            : tap
                ? (_) => onEnd()
                : null,
      ),
    );
  }
}
