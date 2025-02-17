import 'package:flutter/material.dart';
import 'package:kalender/src/extensions.dart';

/// A class representing a object that can be displayed by the calendar.
///
/// A calendar event requires a [DateTimeRange] this is used by the [CalendarView] to render the event.
///
/// Any calculations done with the [_dateTimeRange] should be done in utc time and then converted back to local time.
class BaseEvent<T extends Object?> {
  /// Additional data for the [BaseEvent].
  T? data;

  /// The [DateTimeRange] of the [BaseEvent].
  final DateTimeRange _dateTimeRange;
  DateTimeRange get dateTimeRange => _dateTimeRange;

  /// The [DateTimeRange] of the [BaseEvent] in the [DateTime.utc] format.
  DateTimeRange get _dateTimeRangeAsUtc => _dateTimeRange.asUtc;

  /// The id of the [BaseEvent].
  /// Do not set this value manually as this is set by the [EventsController].
  int _id = -1;
  int get id => _id;
  set id(int value) {
    if (_id != -1) return;
    _id = value;
  }

  BaseEvent({
    required DateTimeRange dateTimeRange,
    this.data,
  }) : _dateTimeRange = dateTimeRange;

  /// The start [DateTime] of the [BaseEvent].
  DateTime get start => dateTimeRange.start.asLocal;

  /// The start [DateTime.utc] of the [BaseEvent].
  DateTime get _startAsUTC => start.asUtc;

  /// The end [DateTime] of the [BaseEvent].
  DateTime get end => dateTimeRange.end.asLocal;

  /// The end [DateTime.utc] of the [BaseEvent].
  DateTime get _endAsUTC => end.asUtc;

  /// Whether the [BaseEvent] is a multi day event.
  bool get isMultiDayEvent => dateTimeRange.dayDifference >= 1;

  /// The [DateTime]s that the [BaseEvent] spans.
  List<DateTime> get datesSpanned => dateTimeRange.days;

  /// The [DateTime]s that the [BaseEvent] spans as UTC [DateTime]s.
  List<DateTime> get datesSpannedAsUtc => _dateTimeRangeAsUtc.days;

  /// The total duration of the [BaseEvent].
  Duration get duration => dateTimeRange.duration;

  /// Whether the [BaseEvent] is during the given [DateTimeRange].
  ///
  /// This expects the [DateTimeRange]'s start and end dates to be constructed in the [DateTime.utc] format.
  bool occursDuringDateTimeRange(DateTimeRange dateTimeRange) {
    assert(dateTimeRange.isUtc);
    return _dateTimeRangeAsUtc.occursDuring(dateTimeRange);
  }

  /// Whether the [BaseEvent] continues before the given [DateTime].
  ///
  /// This expects the [DateTime] to be constructed with [DateTime.utc].
  bool continuesBefore(DateTime date) {
    assert(date.isUtc, 'The $date should be in utc time.');
    return _startAsUTC.isBefore(date.startOfDay);
  }

  /// Whether the [BaseEvent] continues after the given [DateTime].
  ///
  /// This expects the [DateTime] to be constructed with [DateTime.utc].
  bool continuesAfter(DateTime date) {
    assert(date.isUtc, 'The $date should be in utc time.');
    return _endAsUTC.isAfter(date.endOfDay);
  }

  /// The [DateTimeRange] of the [BaseEvent] on a specific date.
  ///
  /// This expects the [DateTime] to be constructed with [DateTime.utc].
  DateTimeRange dateTimeRangeOnDate(DateTime date) {
    assert(date.isUtc, 'The $date should be in utc time.');
    return _dateTimeRangeAsUtc.dateTimeRangeOnDate(date);
  }

  /// Copy the [BaseEvent] with the new values.
  BaseEvent<T> copyWith({
    DateTimeRange? dateTimeRange,
    T? data,
  }) {
    return BaseEvent<T>(
      dateTimeRange: dateTimeRange ?? this.dateTimeRange,
      data: data ?? this.data,
    );
  }

  @override
  String toString() {
    return 'id: $id, start: $start, end: $end';
  }
}
