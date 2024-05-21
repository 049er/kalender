import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:kalender/src/extensions.dart';
import 'package:kalender/src/models/controllers/view_controller.dart';
import 'package:kalender/src/models/providers/calendar_provider.dart';
import 'package:kalender/src/models/providers/month_provider.dart';
import 'package:kalender/src/widgets/drag_targets/multi_day_drag_target.dart';
import 'package:kalender/src/widgets/events_widgets/multi_day_events_widget.dart';
import 'package:kalender/src/widgets/gesture_detectors/multi_day_gesture_detector.dart';

/// This widget is used to display a multi-day body.
class MonthBody<T extends Object?> extends StatelessWidget {
  /// The [EventsController] that will be used by the [MonthBody].
  final EventsController<T>? eventsController;

  /// The [CalendarController] that will be used by the [MonthBody].
  final CalendarController<T>? calendarController;

  /// The [MultiDayBodyConfiguration] that will be used by the [MonthBody].
  final MultiDayHeaderConfiguration? configuration;

  /// The callbacks used by the [MonthBody].
  final CalendarCallbacks<T>? callbacks;

  /// The tile components used by the [MonthBody].
  final TileComponents<T> tileComponents;

  /// Creates a new [MonthBody].
  const MonthBody({
    super.key,
    this.eventsController,
    this.calendarController,
    this.callbacks,
    required this.tileComponents,
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
        'The eventsController needs to be provided when the $MonthBody<$T> is not wrapped in a $CalendarProvider<$T>.',
      );
      assert(
        calendarController != null,
        'The calendarController needs to be provided when the $MonthBody<$T> is not wrapped in a $CalendarProvider<$T>.',
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
      calendarController!.viewController is MonthViewController<T>,
      'The CalendarController\'s $ViewController<$T> needs to be a $MonthViewController<$T>',
    );

    final viewController =
        calendarController!.viewController as MonthViewController<T>;
    final viewConfiguration = viewController.viewConfiguration;
    final bodyConfiguration =
        this.configuration ?? MultiDayHeaderConfiguration();
    final pageNavigation = viewConfiguration.pageNavigationFunctions;
    final pageTriggerConfiguration = bodyConfiguration.pageTriggerConfiguration;
    final tileHeight = bodyConfiguration.tileHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = constraints.maxWidth;
        final pageHeight = constraints.maxHeight;

        // Calculate the width of a single day.
        final dayWidth = pageWidth / DateTime.daysPerWeek;
        final weekHeight = pageHeight / 5;

        return SizedBox(
          width: pageWidth,
          height: pageHeight,
          child: PageView.builder(
            controller: viewController.pageController,
            itemCount: pageNavigation.numberOfPages,
            onPageChanged: (index) {
              final visibleRange = pageNavigation.dateTimeRangeFromIndex(
                index,
              );
              viewController.visibleDateTimeRange.value = visibleRange;
            },
            itemBuilder: (context, index) {
              final visibleRange = pageNavigation.dateTimeRangeFromIndex(
                index,
              );

              final multiDayEvents = List.generate(5, (index) {
                final visibleDateTimeRange = DateTimeRange(
                  start: visibleRange.start.addDays(index * 7),
                  end: visibleRange.start.addDays((index * 7) + 7),
                );

                final multiDayEvents = MultiDayEventWidget<T>(
                  eventsController: eventsController!,
                  visibleDateTimeRange: visibleDateTimeRange,
                  tileComponents: tileComponents,
                  viewController: viewController,
                  dayWidth: dayWidth,
                  allowResizing: bodyConfiguration.allowResizing,
                  showAllEvents: true,
                );

                final multiDayDragTarget = MultiDayDragTarget<T>(
                  eventsController: eventsController,
                  viewController: viewController,
                  tileComponents: tileComponents,
                  pageTriggerSetup: pageTriggerConfiguration,
                  visibleDateTimeRange: visibleDateTimeRange,
                  dayWidth: dayWidth,
                  pageWidth: pageWidth,
                  tileHeight: tileHeight,
                  callbacks: callbacks,
                  allowSingleDayEvents: true,
                );

                final gestureDetector = MultiDayGestureDetector(
                  eventsController: eventsController,
                  callbacks: callbacks,
                  viewController: viewController,
                  visibleDateTimeRange: visibleDateTimeRange,
                  createEventTrigger: bodyConfiguration.createEventTrigger,
                  dayWidth: dayWidth,
                );

                return SizedBox(
                  height: pageHeight / 5,
                  width: pageWidth,
                  child: Stack(
                    children: [
                      Positioned.fill(child: gestureDetector),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: weekHeight,
                          minWidth: weekHeight,
                        ),
                        child: multiDayEvents,
                      ),
                      Positioned.fill(
                        child: multiDayDragTarget,
                      ),
                    ],
                  ),
                );
              });

              return Column(
                children: multiDayEvents,
              );
            },
          ),
        );
      },
    );
  }
}
