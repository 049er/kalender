import 'package:flutter/material.dart';
import 'package:kalender/src/models/calendar_events/base_event.dart';

/// A class representing an event with additional data and modifiable behavior.
class CalendarEvent<T extends Object?> extends BaseEvent<T> {
  /// Whether this [CalendarEvent] can be modified.
  bool canModify;

  CalendarEvent({
    required DateTimeRange dateTimeRange,
    T? data,
    this.canModify = true,
  }) : super(dateTimeRange: dateTimeRange, data: data);

  /// Copy the [CalendarEvent] with the new values.
  @override
  CalendarEvent<T> copyWith({
    DateTimeRange? dateTimeRange,
    T? data,
    bool? canModify,
  }) {
    return CalendarEvent<T>(
      dateTimeRange: dateTimeRange ?? this.dateTimeRange,
      canModify: canModify ?? this.canModify,
      data: data ?? this.data,
    );
  }

  @override
  String toString() {
    return 'id: $id, data: $data, start: $start, end: $end, canModify: $canModify';
  }
}
