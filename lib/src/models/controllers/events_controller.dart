import 'package:flutter/material.dart';
import 'package:kalender/src/models/calendar_events/calendar_event.dart';
import 'package:kalender/src/models/controllers/date_map.dart';
import 'package:kalender/src/models/controllers/time_region_controller.dart';

/// A controller for [CalendarEvent]s.
///
/// This is used to store and manage the [CalendarEvent]s.
class EventsController<T extends Object?>
    with ChangeNotifier, TimeRegionController<T> {
  ValueNotifier<Size> feedbackWidgetSize = ValueNotifier(Size.zero);

  /// The list of [CalendarEvent]s.
  final Map<int, CalendarEvent<T>> _events = {};
  Iterable<CalendarEvent<T>> get events => _events.values;

  /// A Map of dates and event ids.
  final DateMap _dateMap = DateMap();

  /// The ids for the [CalendarEvent]s
  int _lastId = 0;
  int get _nextId {
    _lastId++;
    return _lastId;
  }

  /// Adds an [CalendarEvent] to the [EventsController].
  ///
  /// Returns the id assigned to the event.
  int addEvent(CalendarEvent<T> event) {
    final id = _assignIdAndAdd(event);
    notifyListeners();
    return id;
  }

  /// Adds a list of [CalendarEvent]s to the [EventsController].
  ///
  /// Returns the id's assigned to the events in order.
  List<int> addEvents(List<CalendarEvent<T>> events) {
    final ids = events.map(_assignIdAndAdd).toList();
    notifyListeners();
    return ids;
  }

  /// Removes an [CalendarEvent] from the list of [CalendarEvent]s.
  void removeEvent(CalendarEvent<T> event) {
    assert(
        event.id != -1, 'The id of the event must be set before removing it.');
    _events.remove(event.id);
    _dateMap.removeEvent(event);
    notifyListeners();
  }

  /// Remove an [CalendarEvent] with its id.
  void removeById(int id) {
    assert(id != -1, 'Must be a valid id.');
    _dateMap.removeEvent(_events[id]!);
    _events.remove(id);
    notifyListeners();
  }

  /// Removes a list of [CalendarEvent]s from the list of [CalendarEvent]s.
  ///
  /// The events will be removed where [test] returns true.
  void removeWhere(bool Function(int key, CalendarEvent<T> element) test) {
    _events.removeWhere(
      (key, event) {
        final remove = test(key, event);
        if (remove) _dateMap.removeEvent(event);
        return remove;
      },
    );
    notifyListeners();
  }

  /// Removes all [CalendarEvent]s from [_events].
  void clearEvents() {
    _events.clear();
    _dateMap.clear();
    notifyListeners();
  }

  /// Updates an [CalendarEvent].
  ///
  /// The [event] is the event that needs to be changed.
  /// The [updatedEvent] is the event that will replace the [event].
  void updateEvent({
    required CalendarEvent<T> event,
    required CalendarEvent<T> updatedEvent,
  }) {
    updatedEvent.id = event.id;
    _events[event.id] = updatedEvent;
    _dateMap.updateEvent(event, updatedEvent);
    notifyListeners();
  }

  /// Retrieve a [CalendarEvent] by it's id if it exists.
  CalendarEvent<T>? byId(int id) => _events[id];

  /// Assigns an id to the [event] and adds it to the [_events] Map.
  int _assignIdAndAdd(CalendarEvent<T> event) {
    assert(event.id == -1, 'The id of the event must not be set manually.');

    event.id = _nextId;
    _dateMap.addEvent(event);

    // Add the event to the Map.
    _events[event.id] = event;

    return event.id;
  }

  /// Finds the [CalendarEvent]s that occur during the [dateTimeRange].
  Iterable<CalendarEvent<T>> eventsFromDateTimeRange(
    DateTimeRange dateTimeRange, {
    bool includeMultiDayEvents = true,
    bool includeDayEvents = true,
  }) {
    final eventIds = _dateMap.eventIdsFromDateTimeRange(dateTimeRange);
    final events = eventIds.map((id) => _events[id]).nonNulls;

    if (includeMultiDayEvents && includeDayEvents) {
      return events
          .where((event) => event.occursDuringDateTimeRange(dateTimeRange));
    } else if (includeMultiDayEvents) {
      return _multiDayEventsFromDateTimeRange(events, dateTimeRange);
    } else if (includeDayEvents) {
      return _dayEventsFromDateTimeRange(events, dateTimeRange);
    } else {
      return [];
    }
  }

  /// Finds the [CalendarEvent]s longer than 1 day that occur during the [dateTimeRange].
  Iterable<CalendarEvent<T>> _multiDayEventsFromDateTimeRange(
    Iterable<CalendarEvent<T>> events,
    DateTimeRange dateTimeRange,
  ) {
    return events.where((event) {
      // If the event is not a multi day event, return false.
      if (!event.isMultiDayEvent) return false;
      return event.occursDuringDateTimeRange(dateTimeRange);
    });
  }

  /// Finds the [CalendarEvent]s that are shorter than 1 day that occur during the [dateTimeRange].
  Iterable<CalendarEvent<T>> _dayEventsFromDateTimeRange(
    Iterable<CalendarEvent<T>> events,
    DateTimeRange dateTimeRange,
  ) {
    return events.where((event) {
      // If the event is a multi day event, return false.
      if (event.isMultiDayEvent) return false;
      return event.occursDuringDateTimeRange(dateTimeRange);
    });
  }
}
