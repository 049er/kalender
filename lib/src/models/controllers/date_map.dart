import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';

/// A class for searching the events by date more efficient.
class DateMap {
  /// Map of the [DateTime] and event ids.
  final Map<DateTime, Set<int>> _dateMap = {};

  /// Clear the [_dateMap].
  void clear() => _dateMap.clear();

  /// Add an [event] to the map.
  void addEvent(BaseEvent event) {
    final id = event.id;
    final dates = event.datesSpannedAsUtc;
    for (final date in dates) {
      _dateMap.update(
        date,
        (value) => value..add(id),
        ifAbsent: () => {id},
      );
    }
  }

  /// Remove an [event] from the map.
  void removeEvent(BaseEvent event) {
    final id = event.id;
    final dates = event.datesSpannedAsUtc;
    for (final date in dates) {
      _dateMap.update(
        date,
        (value) => value..remove(id),
      );
    }
  }

  /// Update an [event] in the map with the [updatedEvent].
  void updateEvent(BaseEvent event, BaseEvent updatedEvent) {
    removeEvent(event);
    addEvent(updatedEvent);
  }

  /// Retrieve a [Set] of event id's from the map.
  Set<int> eventIdsFromDateTimeRange(DateTimeRange dateTimeRange) {
    final days = dateTimeRange.asUtc.days;
    final eventIds = <int>{};
    for (final day in days) {
      eventIds.addAll(_dateMap[day] ?? {});
    }
    return eventIds;
  }
}
