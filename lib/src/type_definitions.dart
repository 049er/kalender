import 'package:flutter/material.dart';
import 'package:kalender/src/models/calendar_events/calendar_event.dart';
import 'package:kalender/src/models/calendar_events/time_region_event.dart';
import 'package:kalender/src/models/time_of_day_range.dart';
import 'package:kalender/src/widgets/components/day_header.dart';
import 'package:kalender/src/widgets/components/day_separator.dart';
import 'package:kalender/src/widgets/components/hour_lines.dart';
import 'package:kalender/src/widgets/components/month_day_header.dart';
import 'package:kalender/src/widgets/components/month_grid.dart';
import 'package:kalender/src/widgets/components/resize_handle_positioner.dart';
import 'package:kalender/src/widgets/components/time_indicator.dart';
import 'package:kalender/src/widgets/components/time_line.dart';
import 'package:kalender/src/widgets/components/week_day_header.dart';
import 'package:kalender/src/widgets/components/week_number.dart';

/// Widget builders ///

/// The default builder for the event tiles.
///
/// [event] is the event that the tile will be built for.
///
/// [tileRange] is the [DateTimeRange] of the view the tile will be displayed in.
/// * (This can be compared to the [CalendarEvent.dateTimeRange] to determine on which day it falls.)
typedef TileBuilder<T extends Object?> = Widget Function(
  CalendarEvent<T> event,
  DateTimeRange tileRange,
);

/// The default builder for the time region event tiles.
///
/// [event] is the event that the tile will be built for.
///
/// [tileRange] is the [DateTimeRange] of the view the tile will be displayed in.
/// * (This can be compared to the [CalendarEvent.dateTimeRange] to determine on which day it falls.)
typedef TimeRegionTileBuilder<T extends Object?> = Widget Function(
  TimeRegionEvent<T> event,
  DateTimeRange tileRange,
);

/// The builder for the event tile when dragging.
///
/// [event] is the event that the tile will be built for.
typedef TileWhenDraggingBuilder<T extends Object?> = Widget Function(
  CalendarEvent<T> event,
);

/// The builder for the feedback tile. (When dragging)
///
/// [event] is the event that the tile will be built for.
/// [dropTargetWidgetSize] is the size of the drop target widget.
typedef FeedbackTileBuilder<T extends Object?> = Widget Function(
  CalendarEvent<T> event,
  Size dropTargetWidgetSize,
);

/// The builder for the drop target event tile.
///
/// [event] is the event that the tile will be built for.
typedef TileDropTargetBuilder<T extends Object?> = Widget Function(
  CalendarEvent<T> event,
);

/// The builder that positions the ResizeHandles.
///
/// [startResizeHandle] the top/left resize handle.
/// [endResizeHandle] the bottom/right resize handle.
/// [showStart] should the start resize detector be show.
/// [showEnd] should the end resize detector be show.
typedef ResizeHandlePositioner = ResizeHandlePositionerWidget Function(
  Widget startResizeHandle,
  Widget endResizeHandle,
  bool showStart,
  bool showEnd,
);

/// The hour lines builder.
///
/// The [heightPerMinute] is the height of each minute.
/// The [timeOfDayRange] is the range of time that the hour lines will be displayed for.
/// The [style] is used to style the hour lines.
typedef HourLinesBuilder = Widget Function(
  double heightPerMinute,
  TimeOfDayRange timeOfDayRange,
  HourLinesStyle? style,
);

/// The time line builder.
///
/// The [heightPerMinute] is the height of each minute.
/// The [timeOfDayRange] is the range of time that the time line will be displayed for.
/// The [style] is used to style the time line.
typedef TimeLineBuilder = Widget Function(
  double heightPerMinute,
  TimeOfDayRange timeOfDayRange,
  TimelineStyle? style,
);

/// The day separator builder.
///
/// The [style] is used to style the day separator.
typedef DaySeparatorBuilder = Widget Function(
  DaySeparatorStyle? style,
);

/// The time indicator builder.
///
/// The [timeOfDayRange] is the range of time that the time indicator will be displayed for.
/// The [heightPerMinute] is the height of each minute.
/// The [timelineWidth] is the width of the timeline.
/// The [style] is used to style the time indicator.
typedef TimeIndicatorBuilder = Widget Function(
  TimeOfDayRange timeOfDayRange,
  double heightPerMinute,
  double timelineWidth,
  TimeIndicatorStyle? style,
);

/// The day header builder.
///
/// The [date] is the date that the header will be displayed for.
/// The [style] is used to style the day header.
typedef DayHeaderBuilder = Widget Function(
  DateTime date,
  DayHeaderStyle? style,
);

/// The week number builder.
///
/// The [visibleDateTimeRange] is the range of dates that the week number will be displayed for.
/// The [style] is used to style the week number.
typedef WeekNumberBuilder = Widget Function(
  DateTimeRange visibleDateTimeRange,
  WeekNumberStyle? style,
);

/// The week day header builder.
///
/// The [date] is the date that the header will be displayed for.
/// The [style] is used to style the week day header.
typedef WeekDayHeaderBuilder = Widget Function(
  DateTime date,
  WeekDayHeaderStyle? style,
);

/// The month grid builder.
///
/// The [style] is used to style the month grid.
typedef MonthGridBuilder = Widget Function(
  MonthGridStyle? style,
);

/// The month day header builder.
typedef MonthDayHeaderBuilder = Widget Function(
  DateTime date,
  MonthDayHeaderStyle? style,
);

/// The trigger widget builder, should be constrained in width.
///
/// The [pageWidth] is the width of the page.
typedef HorizontalTriggerWidgetBuilder = Widget Function(
  double pageWidth,
);

/// The trigger widget builder, should be constrained in height.
///
/// The [viewPortHeight] is the height of the page.
typedef VerticalTriggerWidgetBuilder = Widget Function(
  double viewPortHeight,
);

/// Calculates the VisibleDateRange from the [index].
///
/// [index] is the page index.
typedef DateTimeRangeFromIndex = DateTimeRange Function(int index);

/// Calculates the page index of the [date].
typedef IndexFromDate = int Function(DateTime date);

/// The number of pages for the [DateTimeRange] of the calendar.
typedef NumberOfPages = int Function();
