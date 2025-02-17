import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:kalender/src/models/controllers/date_map.dart';

/// A controller for [TimeRegionEvent]s.
///
/// This is used to store and manage the [TimeRegionEvent]s.
mixin TimeRegionController<T extends Object?> on ChangeNotifier {
  /// The list of [TimeRegionEvent]s.
  final Map<int, TimeRegionEvent<T>> _timeRegionsEvents = {};
  Iterable<TimeRegionEvent<T>> get timeRegionsEvents =>
      _timeRegionsEvents.values;

  /// A Map of dates and event ids.
  final DateMap _timeRegionsDateMap = DateMap();

  /// The ids for the [TimeRegionEvent]s
  int _timeRegionLastId = 0;
  int get __timeRegionNextId {
    _timeRegionLastId++;
    return _timeRegionLastId;
  }

  /// Adds an [TimeRegionEvent] to the [EventsController].
  void addTimeRegionEvent(TimeRegionEvent<T> event) {
    _assignTimeRegionIdAndAdd(event);
    notifyListeners();
  }

  /// Adds a list of [TimeRegionEvent]s to the [EventsController].
  void addTimeRegionEvents(List<TimeRegionEvent<T>> events) {
    for (final event in events) {
      _assignTimeRegionIdAndAdd(event);
    }
    notifyListeners();
  }

  /// Removes an [TimeRegionEvent] from the list of [TimeRegionEvent]s.
  void removeTimeRegionEvent(TimeRegionEvent<T> event) {
    assert(
        event.id != -1, 'The id of the event must be set before removing it.');
    _timeRegionsEvents.remove(event.id);
    _timeRegionsDateMap.removeEvent(event);
    notifyListeners();
  }

  /// Removes a list of [TimeRegionEvent]s from the list of [TimeRegionEvent]s.
  ///
  /// The events will be removed where [test] returns true.
  void removeTimeRegionWhere(
    bool Function(int key, TimeRegionEvent<T> element) test,
  ) {
    _timeRegionsEvents.removeWhere(
      (key, event) {
        final remove = test(key, event);
        if (remove) _timeRegionsDateMap.removeEvent(event);
        return remove;
      },
    );
    notifyListeners();
  }

  /// Removes all [TimeRegionEvent]s from [_timeRegionsEvents].
  void clearTimeRegionEvents() {
    _timeRegionsEvents.clear();
    _timeRegionsDateMap.clear();
    notifyListeners();
  }

  /// Updates an [TimeRegionEvent].
  ///
  /// The [event] is the event that needs to be changed.
  /// The [updatedEvent] is the event that will replace the [event].
  void updateTimeRegionEvent({
    required TimeRegionEvent<T> event,
    required TimeRegionEvent<T> updatedEvent,
  }) {
    updatedEvent.id = event.id;
    _timeRegionsEvents[event.id] = updatedEvent;
    _timeRegionsDateMap.updateEvent(event, updatedEvent);
    notifyListeners();
  }

  /// Assigns an id to the [event] and adds it to the [_timeRegionsEvents] Map.
  void _assignTimeRegionIdAndAdd(TimeRegionEvent<T> event) {
    assert(event.id == -1, 'The id of the event must not be set manually.');

    event.id = __timeRegionNextId;
    _timeRegionsDateMap.addEvent(event);

    // Add the event to the Map.
    _timeRegionsEvents[event.id] = event;
  }

  /// Finds the [TimeRegionEvent]s that occur during the [dateTimeRange].
  Iterable<TimeRegionEvent<T>> timeRegionEventsFromDateTimeRange(
    DateTimeRange dateTimeRange, {
    bool includeMultiDayEvents = true,
    bool includeDayEvents = true,
  }) {
    final eventIds =
        _timeRegionsDateMap.eventIdsFromDateTimeRange(dateTimeRange);
    final events = eventIds.map((id) => _timeRegionsEvents[id]).nonNulls;

    if (includeMultiDayEvents && includeDayEvents) {
      return events
          .where((event) => event.occursDuringDateTimeRange(dateTimeRange));
    } else if (includeMultiDayEvents) {
      return _timeRegionMultiDayEventsFromDateTimeRange(events, dateTimeRange);
    } else if (includeDayEvents) {
      return _timeRegionDayEventsFromDateTimeRange(events, dateTimeRange);
    } else {
      return [];
    }
  }

  /// Finds the [TimeRegionEvent]s longer than 1 day that occur during the [dateTimeRange].
  Iterable<TimeRegionEvent<T>> _timeRegionMultiDayEventsFromDateTimeRange(
    Iterable<TimeRegionEvent<T>> events,
    DateTimeRange dateTimeRange,
  ) {
    return events.where((event) {
      // If the event is not a multi day event, return false.
      if (!event.isMultiDayEvent) return false;
      return event.occursDuringDateTimeRange(dateTimeRange);
    });
  }

  /// Finds the [TimeRegionEvent]s that are shorter than 1 day that occur during the [dateTimeRange].
  Iterable<TimeRegionEvent<T>> _timeRegionDayEventsFromDateTimeRange(
    Iterable<TimeRegionEvent<T>> events,
    DateTimeRange dateTimeRange,
  ) {
    return events.where((event) {
      // If the event is a multi day event, return false.
      if (event.isMultiDayEvent) return false;
      return event.occursDuringDateTimeRange(dateTimeRange);
    });
  }
}
