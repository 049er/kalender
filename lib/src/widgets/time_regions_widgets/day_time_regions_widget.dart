import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:kalender/src/widgets/time_region_tile/day_time_range_tile.dart';

/// This widget is renders all the time region event tiles that are visible on the provided dateTimeRange.
///
/// It fetches the events that need to be rendered from the [EventsController],
/// the [EventsController] is also listened to in-case events are added or updated.
///
/// This widget also takes responsibility for updating the [CalendarController.visibleTimeRegionEvents].
///
/// To render the event tiles it uses [CustomMultiChildLayout],
/// along with a [overlapLayoutStrategy].
///
/// * Note: When a time region event is being modified by the user it renders that event in a separate [CustomMultiChildLayout],
///         This is somewhat expensive computationally as it lays out all the events again to determine the position
///         of the event being modified. See todo for a possible solution.
class DayTimeRegionsWidget<T extends Object?> extends StatefulWidget {
  final EventsController<T> eventsController;
  final CalendarController<T> controller;
  final CalendarCallbacks<T>? callbacks;

  final TimeRegionTileComponents<T> tileComponents;
  final MultiDayBodyConfiguration configuration;
  final DateTimeRange visibleDateTimeRange;
  final TimeOfDayRange timeOfDayRange;
  final double dayWidth;
  final double heightPerMinute;

  /// Creates a [DayTimeRegionsWidget].
  const DayTimeRegionsWidget({
    super.key,
    required this.eventsController,
    required this.controller,
    required this.callbacks,
    required this.tileComponents,
    required this.configuration,
    required this.dayWidth,
    required this.heightPerMinute,
    required this.visibleDateTimeRange,
    required this.timeOfDayRange,
  });

  @override
  State<DayTimeRegionsWidget<T>> createState() =>
      _DayTimeRegionsWidgetState<T>();
}

class _DayTimeRegionsWidgetState<T extends Object?>
    extends State<DayTimeRegionsWidget<T>> {
  /// The visible time range events value notifier.
  ValueNotifier<Set<TimeRegionEvent>> get visibleEvents =>
      widget.controller.visibleTimeRegionEvents;

  /// A map containing all the days and Events that will be displayed.
  late Map<DateTime, Iterable<TimeRegionEvent<T>>> eventsMap;

  @override
  void initState() {
    super.initState();
    _populateEventsMap();
    widget.eventsController.addListener(_updateEventsMap);
  }

  @override
  void dispose() {
    widget.eventsController.removeListener(_updateEventsMap);
    super.dispose();
  }

  /// Update the [eventsMap].
  void _updateEventsMap() => setState(_populateEventsMap);

  /// Populate the [eventsMap].
  void _populateEventsMap() {
    final visibleDates = widget.visibleDateTimeRange.days;
    final showMultiDayEvents = widget.configuration.showMultiDayEvents;

    // Clear the visible events.
    final allEvents = <TimeRegionEvent<T>>{};

    final entries = visibleDates.map((date) {
      final events = widget.eventsController.timeRegionEventsFromDateTimeRange(
        date.dayRange,
        includeDayEvents: true,
        includeMultiDayEvents: showMultiDayEvents,
      );

      allEvents.addAll(events);

      final sortedEvents = OverlapLayoutDelegate(
        events: [],
        date: date,
        timeOfDayRange: TimeOfDayRange.allDay(),
        heightPerMinute: 0,
      ).sortEvents(events) as List<TimeRegionEvent<T>>;
      return MapEntry(date, sortedEvents);
    });

    // Add the events to the visible events.
    visibleEvents.value = allEvents;

    eventsMap = Map.fromEntries(entries);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: eventsMap.entries.map((entry) {
        final date = entry.key;
        final visibleEvents = entry.value.toList();

        final timeRegions = CustomMultiChildLayout(
          delegate: OverlapLayoutDelegate(
            events: visibleEvents,
            heightPerMinute: widget.heightPerMinute,
            date: date,
            timeOfDayRange: widget.timeOfDayRange,
          ),
          children: visibleEvents.indexed
              .map(
                (item) => LayoutId(
                  id: item.$1,
                  child: DayTimeReangeTile(
                    event: item.$2,
                    eventsController: widget.eventsController,
                    controller: widget.controller,
                    tileComponents: widget.tileComponents,
                    dateTimeRange: date.dayRange,
                  ),
                ),
              )
              .toList(),
        );

        return Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(child: timeRegions),
            ],
          ),
        );
      }).toList(),
    );
  }
}
