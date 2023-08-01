import 'package:flutter/material.dart';
import 'package:kalender/src/components/general/time_indicator.dart';
import 'package:kalender/src/components/gesture_detectors/day_gesture_detector.dart';
import 'package:kalender/src/components/tile_stacks/chaning_tile_stack.dart';
import 'package:kalender/src/components/tile_stacks/positioned_tile_stack.dart';
import 'package:kalender/src/constants.dart';
import 'package:kalender/src/extentions.dart';
import 'package:kalender/src/models/calendar/calendar_components.dart';
import 'package:kalender/src/models/calendar/calendar_controller.dart';
import 'package:kalender/src/models/tile_layout_controllers/tile_layout_controller.dart';
import 'package:kalender/src/models/view_configurations/multi_day_configurations/multi_day_view_configuration.dart';
import 'package:kalender/src/providers/calendar_scope.dart';

class MultiDayContent<T extends Object?> extends StatelessWidget {
  const MultiDayContent({
    super.key,
    required this.viewConfiguration,
    required this.pageWidth,
    required this.dayWidth,
  });

  final MultiDayViewConfiguration viewConfiguration;
  final double pageWidth;
  final double dayWidth;

  @override
  Widget build(BuildContext context) {
    CalendarScope<T> scope = CalendarScope.of(context);
    CalendarComponents<T> components = scope.components;
    CalendarViewState state = scope.state;

    return ValueListenableBuilder<double>(
      valueListenable: state.heightPerMinute!,
      builder: (BuildContext context, double heightPerMinute, Widget? child) {
        double hourHeight = heightPerMinute * minutesAnHour;
        double pageHeight = hourHeight * hoursADay;

        double verticalStep = heightPerMinute * viewConfiguration.verticalDurationStep.inMinutes;

        return Expanded(
          child: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                components.timelineBuilder(
                  viewConfiguration.timelineWidth,
                  pageHeight,
                  hourHeight,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: pageHeight,
                    width: pageWidth,
                    child: PageView.builder(
                      key: Key(viewConfiguration.name),
                      controller: state.pageController,
                      itemCount: state.numberOfPages,
                      onPageChanged: (int index) {
                        scope.state.visibleDateTimeRange.value =
                            viewConfiguration.calculateVisibleDateRangeForIndex(
                          index: index,
                          calendarStart: scope.state.adjustedDateTimeRange.start,
                        );
                      },
                      itemBuilder: (BuildContext context, int index) {
                        DateTimeRange pageVisibleDateRange =
                            viewConfiguration.calculateVisibleDateRangeForIndex(
                          index: index,
                          calendarStart: scope.state.adjustedDateTimeRange.start,
                          firstDayOfWeek: viewConfiguration.firstDayOfWeek,
                        );

                        TileLayoutController<T> tileLayoutController = TileLayoutController<T>(
                          visibleDateRange: pageVisibleDateRange,
                          heightPerMinute: heightPerMinute,
                          dayWidth: dayWidth,
                          verticalDurationStep: const Duration(minutes: 15),
                        );

                        return Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: pageWidth,
                                height: pageHeight,
                                child: components.hourlineBuilder(
                                  pageWidth,
                                  hourHeight,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: pageWidth,
                                height: pageHeight,
                                child: components.daySepratorBuilder(
                                  pageHeight,
                                  dayWidth,
                                  pageVisibleDateRange.dayDifference,
                                ),
                              ),
                            ),
                            DayGestureDetector<T>(
                              height: pageHeight,
                              dayWidth: dayWidth,
                              heightPerMinute: heightPerMinute,
                              visibleDateRange: pageVisibleDateRange,
                              minuteSlotSize: viewConfiguration.minuteSlotSize,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: pageWidth,
                                height: pageHeight,
                                child: PositionedTileStack<T>(
                                  pageVisibleDateRange: pageVisibleDateRange,
                                  tileLayoutController: tileLayoutController,
                                  dayWidth: dayWidth,
                                  verticalStep: verticalStep,
                                  verticalDurationStep: viewConfiguration.verticalDurationStep,
                                  horizontalStep: dayWidth,
                                  horizontalDurationStep: viewConfiguration.horizontalDurationStep,
                                  eventSnapping: viewConfiguration.eventSnapping,
                                  timeIndicatorSnapping: viewConfiguration.timeIndicatorSnapping,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: pageWidth,
                                height: pageHeight,
                                child: ChangingTileStack<T>(
                                  tileLayoutController: tileLayoutController,
                                ),
                              ),
                            ),
                            Visibility(
                              visible: DateTime.now().isWithin(pageVisibleDateRange),
                              child: TimeIndicator(
                                width: dayWidth,
                                height: pageHeight,
                                visibleDateRange: pageVisibleDateRange,
                                heightPerMinute: heightPerMinute,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
