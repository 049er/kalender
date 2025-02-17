import 'package:flutter/material.dart';
import 'package:kalender/src/extensions.dart';
import 'package:kalender/src/models/calendar_callbacks.dart';
import 'package:kalender/src/models/components/tile_components.dart';
import 'package:kalender/src/models/components/time_region_tile_components.dart';
import 'package:kalender/src/models/controllers/calendar_controller.dart';
import 'package:kalender/src/models/controllers/events_controller.dart';
import 'package:kalender/src/models/controllers/view_controller.dart';
import 'package:kalender/src/models/providers/calendar_provider.dart';
import 'package:kalender/src/models/view_configurations/multi_day_view_configuration.dart';
import 'package:kalender/src/widgets/components/day_separator.dart';
import 'package:kalender/src/widgets/components/hour_lines.dart';
import 'package:kalender/src/widgets/components/time_indicator.dart';
import 'package:kalender/src/widgets/components/time_line.dart';
import 'package:kalender/src/widgets/drag_targets/day_drag_target.dart';
import 'package:kalender/src/widgets/draggable/day_draggable.dart';
import 'package:kalender/src/widgets/events_widgets/day_events_widget.dart';
import 'package:kalender/src/widgets/internal_components/page_clipper.dart';
import 'package:kalender/src/widgets/internal_components/timeline_sizer.dart';
import 'package:kalender/src/widgets/time_regions_widgets/day_time_regions_widget.dart';

/// This widget is used to display a multi-day body.
///
/// The multi-day body has two big parts to it:
/// 1. The content:
///   - Static content such as [HourLines] and [TimeLine].
///   - Dynamic content such as the [PageView] which displays:
///     [DaySeparator], [DayEventDraggableWidgets], [DayEventsWidget] and the [TimeIndicator]
///
/// 2. The [DayDragTarget]
///    This is the drag target for all events that are being modified and how the calendar deals with rescheduling and resizing of events.
class MultiDayBody<T extends Object?> extends StatelessWidget {
  /// The [EventsController] that will be used by the [MultiDayBody].
  final EventsController<T>? eventsController;

  /// The [CalendarController] that will be used by the [MultiDayBody].
  final CalendarController<T>? calendarController;

  /// The [MultiDayBodyConfiguration] that will be used by the [MultiDayBody].
  final MultiDayBodyConfiguration? configuration;

  /// The callbacks used by the [MultiDayBody].
  final CalendarCallbacks<T>? callbacks;

  /// The tile components used by the [MultiDayBody].
  final TileComponents<T> tileComponents;

  /// The tile components for time regions used by the [MultiDayBody].
  final TimeRegionTileComponents<T>? timeRegionTileComponents;

  /// The [ValueNotifier] containing the [heightPerMinute] value.
  final ValueNotifier<double>? heightPerMinute;

  /// Creates a new [MultiDayBody].
  ///
  /// This widget is used to display events in a day/week view format.
  ///
  /// This widget is intended to be the body of a [CalendarView].
  const MultiDayBody({
    super.key,
    this.eventsController,
    this.calendarController,
    this.callbacks,
    required this.tileComponents,
    required this.timeRegionTileComponents,
    this.heightPerMinute,
    this.configuration,
  });

  @override
  Widget build(BuildContext context) {
    var eventsController = this.eventsController;
    var calendarController = this.calendarController;
    var callbacks = this.callbacks;

    final provider = CalendarProvider.maybeOf<T>(context);
    if (provider == null) {
      assert(
        eventsController != null,
        'The eventsController needs to be provided when the $MultiDayBody<$T> is not wrapped in a $CalendarProvider<$T>.',
      );
      assert(
        calendarController != null,
        'The calendarController needs to be provided when the $MultiDayBody<$T> is not wrapped in a $CalendarProvider<$T>.',
      );
    } else {
      eventsController ??= provider.eventsController;
      calendarController ??= provider.calendarController;
      callbacks ??= provider.callbacks;
    }

    assert(
      calendarController!.isAttached,
      'The CalendarController needs to be attached to a $ViewController<$T>.',
    );

    assert(
      calendarController!.viewController is MultiDayViewController<T>,
      'The CalendarController\'s $ViewController<$T> needs to be a $MultiDayViewController<$T>',
    );

    final viewController =
        calendarController!.viewController as MultiDayViewController<T>;
    final viewConfiguration = viewController.viewConfiguration;
    final timeOfDayRange = viewConfiguration.timeOfDayRange;
    final numberOfDays = viewConfiguration.numberOfDays;
    final pageNavigation = viewConfiguration.pageNavigationFunctions;
    final selectedEvent = calendarController.selectedEvent;
    final bodyConfiguration = this.configuration ?? MultiDayBodyConfiguration();

    final calendarComponents = provider?.components;
    final styles = calendarComponents?.multiDayComponentStyles?.bodyStyles;
    final components = calendarComponents?.multiDayComponents?.bodyComponents;

    // Override the height per minute if it is provided.
    if (heightPerMinute != null) {
      viewController.heightPerMinute = heightPerMinute!;
    }

    return ValueListenableBuilder(
      valueListenable: viewController.heightPerMinute,
      builder: (context, heightPerMinute, child) {
        // Calculate the height of the page.
        final dayDuration = timeOfDayRange.duration;
        final pageHeight = heightPerMinute * dayDuration.inMinutes;

        final hourLinesStyle = styles?.hourLinesStyle;
        final hourLines = components?.hourLines?.call(
              heightPerMinute,
              timeOfDayRange,
              hourLinesStyle,
            ) ??
            HourLines(
              timeOfDayRange: timeOfDayRange,
              heightPerMinute: heightPerMinute,
              style: hourLinesStyle,
            );

        final timelineStyle = styles?.timelineStyle;
        final timeline = components?.timeline?.call(
              heightPerMinute,
              timeOfDayRange,
              timelineStyle,
            ) ??
            TimeLine(
              timeOfDayRange: timeOfDayRange,
              heightPerMinute: heightPerMinute,
              style: timelineStyle,
              eventBeingDragged: selectedEvent,
              visibleDateTimeRange: viewController.visibleDateTimeRange,
            );

        final timeIndicatorStyle = styles?.timeIndicatorStyle;
        late final timeIndicator = components?.timeIndicator?.call(
              timeOfDayRange,
              heightPerMinute,
              0,
              timeIndicatorStyle,
            ) ??
            TimeIndicator(
              timeOfDayRange: timeOfDayRange,
              heightPerMinute: heightPerMinute,
              timelineWidth: 0,
              style: timeIndicatorStyle,
            );

        final content = LayoutBuilder(
          builder: (context, constraints) {
            final dayWidth =
                constraints.maxWidth / viewConfiguration.numberOfDays;

            final pageView = PageClipWidget(
              left: -16,
              child: PageView.builder(
                padEnds: false,
                key: ValueKey(viewConfiguration.hashCode),
                controller: viewController.pageController,
                itemCount: viewController.numberOfPages,
                physics: configuration?.pageScrollPhysics,
                clipBehavior: Clip.none,
                onPageChanged: (index) {
                  final visibleRange =
                      pageNavigation.dateTimeRangeFromIndex(index);

                  if (viewConfiguration.type == MultiDayViewType.freeScroll) {
                    final range = DateTimeRange(
                      start: visibleRange.start,
                      end: visibleRange.start.addDays(numberOfDays),
                    );
                    viewController.visibleDateTimeRange.value = range.asLocal;
                  } else {
                    viewController.visibleDateTimeRange.value =
                        visibleRange.asLocal;
                  }

                  callbacks?.onPageChanged
                      ?.call(viewController.visibleDateTimeRange.value);
                },
                itemBuilder: (context, index) {
                  final visibleRange = pageNavigation.dateTimeRangeFromIndex(
                    index,
                  );

                  final visibleDates = visibleRange.days;
                  final timeIndicatorDateIndex = visibleDates.indexWhere(
                    (date) => date.isToday,
                  );

                  final daySeparatorStyle = styles?.daySeparatorStyle;
                  final daySeparator =
                      components?.daySeparator?.call(daySeparatorStyle) ??
                          DaySeparator(style: daySeparatorStyle);
                  final daySeparators = List.generate(
                    numberOfDays + 1,
                    (index) {
                      final left = dayWidth * index;
                      return Positioned(
                        top: 0,
                        bottom: 0,
                        left: left,
                        child: daySeparator,
                      );
                    },
                  );

                  Widget timeRegions = const SizedBox();
                  if (timeRegionTileComponents != null) {
                    timeRegions = DayTimeRegionsWidget<T>(
                      eventsController: eventsController!,
                      controller: calendarController!,
                      callbacks: callbacks,
                      tileComponents: timeRegionTileComponents!,
                      configuration: bodyConfiguration,
                      dayWidth: dayWidth,
                      heightPerMinute: heightPerMinute,
                      visibleDateTimeRange: visibleRange,
                      timeOfDayRange: timeOfDayRange,
                    );
                  }

                  final events = DayEventsWidget<T>(
                    eventsController: eventsController!,
                    controller: calendarController!,
                    callbacks: callbacks,
                    tileComponents: tileComponents,
                    configuration: bodyConfiguration,
                    dayWidth: dayWidth,
                    heightPerMinute: heightPerMinute,
                    visibleDateTimeRange: visibleRange,
                    timeOfDayRange: timeOfDayRange,
                  );

                  final draggable = DayEventDraggableWidgets<T>(
                    controller: calendarController,
                    callbacks: callbacks,
                    bodyConfiguration: bodyConfiguration,
                    visibleDateTimeRange: visibleRange,
                    timeOfDayRange: timeOfDayRange,
                    dayWidth: dayWidth,
                    pageHeight: pageHeight,
                    heightPerMinute: heightPerMinute,
                  );

                  late final left = dayWidth * timeIndicatorDateIndex;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(child: timeRegions),
                      ...daySeparators,
                      Positioned.fill(child: hourLines),
                      Positioned.fill(child: draggable),
                      Positioned.fill(child: events),
                      if (timeIndicatorDateIndex != -1)
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: left,
                          width: dayWidth,
                          child: timeIndicator,
                        ),
                    ],
                  );
                },
              ),
            );

            return pageView;
          },
        );

        final dragTarget = LayoutBuilder(
          builder: (context, constraints) {
            final pageHeight = constraints.maxHeight;
            final pageWidth = constraints.maxWidth;
            final dayWidth =
                constraints.maxWidth / viewConfiguration.numberOfDays;

            return SizedBox(
              height: pageHeight,
              child: DayDragTarget<T>(
                eventsController: eventsController!,
                calendarController: calendarController!,
                viewController: viewController,
                scrollController: viewController.scrollController,
                callbacks: callbacks,
                tileComponents: tileComponents,
                bodyConfiguration: bodyConfiguration,
                timeOfDayRange: timeOfDayRange,
                pageWidth: pageWidth,
                dayWidth: dayWidth,
                viewPortHeight: pageHeight,
                heightPerMinute: heightPerMinute,
                leftPageTrigger: components?.leftTriggerBuilder,
                rightPageTrigger: components?.rightTriggerBuilder,
                topScrollTrigger: components?.topTriggerBuilder,
                bottomScrollTrigger: components?.bottomTriggerBuilder,
              ),
            );
          },
        );

        return Stack(
          children: [
            Scrollbar(
              controller: viewController.scrollController,
              child: SingleChildScrollView(
                controller: viewController.scrollController,
                physics: configuration?.scrollPhysics,
                child: SizedBox(
                  height: pageHeight,
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          SizedBox(height: pageHeight, child: timeline),
                          Expanded(child: content),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Row(
                children: [
                  TimelineSizer<T>(child: const SizedBox()),
                  Expanded(child: dragTarget),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
