import 'package:flutter/material.dart';
import 'package:kalender/kalender_extensions.dart';
import 'package:kalender/src/models/calendar_events/calendar_event.dart';
import 'package:kalender/src/models/calendar_events/time_region_event.dart';
import 'package:kalender/src/models/components/time_region_tile_components.dart';
import 'package:kalender/src/models/controllers/calendar_controller.dart';
import 'package:kalender/src/models/controllers/events_controller.dart';
import 'package:kalender/src/type_definitions.dart';

/// The base class for all event tiles.
///
/// Event tiles are used to display events in the calendar.
abstract class TimeRegionTile<T extends Object?> extends StatelessWidget {
  final EventsController<T> eventsController;
  final CalendarController<T> controller;
  final TimeRegionEvent<T> event;

  final TimeRegionTileComponents<T> tileComponents;

  /// The dateTimeRange of this tile
  final DateTimeRange dateTimeRange;

  /// Creates a new [TimeRegionTile] widget.
  const TimeRegionTile({
    super.key,
    required this.controller,
    required this.eventsController,
    required this.tileComponents,
    required this.event,
    required this.dateTimeRange,
  });

  DateTimeRange get localDateTimeRange => dateTimeRange.asLocal;

  ValueNotifier<Size> get feedbackWidgetSize =>
      eventsController.feedbackWidgetSize;
  ValueNotifier<CalendarEvent<T>?> get selectedEvent =>
      controller.selectedEvent;

  TimeRegionTileBuilder<T> get tileBuilder => tileComponents.tileBuilder;

  bool get continuesBefore => event.continuesBefore(dateTimeRange.start);
  bool get continuesAfter => event.continuesAfter(dateTimeRange.end);
}
