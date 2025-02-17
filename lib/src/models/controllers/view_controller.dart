import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:kalender/src/models/mixins/calendar_navigation_functions.dart';

/// A controller for calendar views.
///
/// A view controller lets you control a calendar view.
abstract class ViewController<T extends Object?>
    with CalendarNavigationFunctions<T> {
  /// The view configuration that will be used by the controller.
  ViewConfiguration get viewConfiguration;

  /// The [DateTimeRange] that is currently visible.
  ValueNotifier<DateTimeRange> get visibleDateTimeRange;

  /// The [CalendarEvent]s that are currently visible.
  ValueNotifier<Set<CalendarEvent<T>>> get visibleEvents;

  /// Jump to the given [DateTime].
  @override
  void jumpToPage(int page);

  /// Jump to the given [DateTime].
  @override
  void jumpToDate(DateTime date);

  @override
  Future<void> animateToNextPage({
    Duration? duration,
    Curve? curve,
  });

  @override
  Future<void> animateToPreviousPage({
    Duration? duration,
    Curve? curve,
  });

  @override
  Future<void> animateToDate(
    DateTime date, {
    Duration? duration,
    Curve? curve,
  });

  @override
  Future<void> animateToDateTime(
    DateTime date, {
    Duration? pageDuration,
    Curve? pageCurve,
    Duration? scrollDuration,
    Curve? scrollCurve,
  });

  @override
  Future<void> animateToEvent(
    CalendarEvent<T> event, {
    Duration? pageDuration,
    Curve? pageCurve,
    Duration? scrollDuration,
    Curve? scrollCurve,
    bool centerEvent = true,
  });

  @override
  String toString() {
    return runtimeType.toString();
  }
}

class MultiDayViewController<T extends Object?> extends ViewController<T> {
  MultiDayViewController({
    required this.viewConfiguration,
    required this.visibleDateTimeRange,
    required this.visibleEvents,
    DateTime? initialDate,
  }) {
    final pageNavigationFunctions = viewConfiguration.pageNavigationFunctions;
    initialPage =
        pageNavigationFunctions.indexFromDate(initialDate ?? DateTime.now());

    final type = viewConfiguration.type;
    final viewPortFraction = type == MultiDayViewType.freeScroll
        ? 1 / viewConfiguration.numberOfDays
        : 1.0;

    pageController = PageController(
        initialPage: initialPage, viewportFraction: viewPortFraction);
    headerController = PageController(
        initialPage: initialPage, viewportFraction: viewPortFraction);
    numberOfPages = pageNavigationFunctions.numberOfPages;
    heightPerMinute =
        ValueNotifier<double>(viewConfiguration.initialHeightPerMinute);

    final range = pageNavigationFunctions.dateTimeRangeFromIndex(initialPage);

    if (type == MultiDayViewType.freeScroll) {
      visibleDateTimeRange.value = DateTimeRange(
        start: range.start,
        end: range.start.addDays(viewConfiguration.numberOfDays),
      );
    } else {
      visibleDateTimeRange.value =
          pageNavigationFunctions.dateTimeRangeFromIndex(initialPage);
    }

    // Calculate the scroll offset so that the initialTimeOfDay is aligned with the top.
    final initialTimeOfDay =
        viewConfiguration.initialTimeOfDay.toDateTime(DateTime.now());
    final dayStart =
        viewConfiguration.timeOfDayRange.start.toDateTime(DateTime.now());
    final timeDifference = initialTimeOfDay.difference(dayStart);
    final initialScrollOffset =
        timeDifference.inMinutes * (heightPerMinute.value);
    scrollController =
        ScrollController(initialScrollOffset: initialScrollOffset);

    // ---- SHILO ADD THIS: to jump also to the time of the initial date not only tha date ----
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => animateToDateTime(
        initialDate ?? DateTime.now().copyWith(hour: 0),
        scrollDuration: const Duration(microseconds: 1),
        pageDuration: const Duration(microseconds: 1),
      ),
    );
    // ------------------------------------------------------------------------
    visibleEvents.value = {};

    // This listener will sync the headerController with the pageController.
    // Note this only really works if both PageView's have the same horizontal 'size'.
    pageController.addListener(() {
      if (!headerController.hasClients) return;
      headerController.position.correctPixels(pageController.offset);
      headerController.position.notifyListeners();
    });
  }

  @override
  final MultiDayViewConfiguration viewConfiguration;

  /// The initial page of the view.
  late final int initialPage;

  /// The number of pages in the view.
  late final int numberOfPages;

  /// The page controller used by the view.
  late final PageController pageController;

  /// The page controller used by the header. (Linked to [pageController])
  late final PageController headerController;

  /// The scroll controller used by the view.
  late ScrollController scrollController;

  /// The height per minute of the view.
  late ValueNotifier<double> heightPerMinute;

  @override
  final ValueNotifier<DateTimeRange> visibleDateTimeRange;

  @override
  final ValueNotifier<Set<CalendarEvent<T>>> visibleEvents;

  @override
  Future<void> animateToDate(
    DateTime date, {
    Duration? duration,
    Curve? curve,
  }) {
    // Calculate the pageNumber of the date.
    final pageNumber =
        viewConfiguration.pageNavigationFunctions.indexFromDate(date);
    // Animate to that page.
    return pageController.animateToPage(
      pageNumber,
      duration: duration ?? const Duration(milliseconds: 300),
      curve: curve ?? Curves.easeInOut,
    );
  }

  @override
  Future<void> animateToDateTime(
    DateTime date, {
    Duration? pageDuration,
    Curve? pageCurve,
    Duration? scrollDuration,
    Curve? scrollCurve,
  }) async {
    // Animate to the date.
    await animateToDate(date, duration: pageDuration, curve: pageCurve);

    final startOfDay = viewConfiguration.timeOfDayRange.start.toDateTime(date);
    final timeDifference = date.difference(startOfDay);
    final timeOffset = timeDifference.inMinutes * (heightPerMinute.value);

    // Animate to the offset of the time.
    return scrollController.animateTo(
      timeOffset,
      duration: scrollDuration ?? const Duration(milliseconds: 300),
      curve: scrollCurve ?? Curves.easeInOut,
    );
  }

  @override
  Future<void> animateToEvent(
    CalendarEvent<T> event, {
    Duration? pageDuration,
    Curve? pageCurve,
    Duration? scrollDuration,
    Curve? scrollCurve,
    bool centerEvent = true,
  }) async {
    final DateTime date;

    if (centerEvent) {
      final eventCenter =
          event.start.add(Duration(minutes: event.duration.inMinutes ~/ 2));
      final halfViewPortHeight =
          scrollController.position.viewportDimension ~/ 2;
      final duration =
          Duration(minutes: halfViewPortHeight ~/ heightPerMinute.value);
      date = eventCenter.subtract(duration);
    } else {
      date = event.start;
    }

    return animateToDateTime(
      date,
      pageDuration: pageDuration,
      pageCurve: pageCurve,
      scrollDuration: scrollDuration,
      scrollCurve: scrollCurve,
    );
  }

  @override
  Future<void> animateToNextPage({Duration? duration, Curve? curve}) {
    return pageController.nextPage(
      duration: duration ?? const Duration(milliseconds: 300),
      curve: curve ?? Curves.easeInOut,
    );
  }

  @override
  Future<void> animateToPreviousPage({Duration? duration, Curve? curve}) {
    return pageController.previousPage(
      duration: duration ?? const Duration(milliseconds: 300),
      curve: curve ?? Curves.easeInOut,
    );
  }

  @override
  void jumpToDate(DateTime date) {
    final pageNumber =
        viewConfiguration.pageNavigationFunctions.indexFromDate(date);
    jumpToPage(pageNumber);
  }

  @override
  void jumpToPage(int page) => pageController.jumpToPage(page);

  @override
  String toString() {
    return '${runtimeType.toString()} (${viewConfiguration.runtimeType})';
  }
}

class MonthViewController<T extends Object?> extends ViewController<T> {
  MonthViewController({
    required this.viewConfiguration,
    required this.visibleDateTimeRange,
    required this.visibleEvents,
    DateTime? initialDate,
  }) {
    final pageNavigationFunctions = viewConfiguration.pageNavigationFunctions;
    initialPage =
        pageNavigationFunctions.indexFromDate(initialDate ?? DateTime.now());
    pageController = PageController(initialPage: initialPage);
    numberOfPages = pageNavigationFunctions.numberOfPages;
    visibleDateTimeRange.value = pageNavigationFunctions.dateTimeRangeFromIndex(initialPage);
    visibleEvents.value = {};
  }

  @override
  final MonthViewConfiguration viewConfiguration;

  /// The initial page of the view.
  late final int initialPage;

  /// The number of pages in the view.
  late final int numberOfPages;

  /// The page controller used by the view.
  late final PageController pageController;

  @override
  late final ValueNotifier<DateTimeRange> visibleDateTimeRange;

  @override
  late final ValueNotifier<Set<CalendarEvent<T>>> visibleEvents;

  @override
  Future<void> animateToDate(
    DateTime date, {
    Duration? duration,
    Curve? curve,
  }) async {
    // Calculate the pageNumber of the date.
    final pageNumber =
        viewConfiguration.pageNavigationFunctions.indexFromDate(date);

    // Animate to that page.
    await pageController.animateToPage(
      pageNumber,
      duration: duration ?? const Duration(milliseconds: 300),
      curve: curve ?? Curves.easeInOut,
    );
  }

  @override
  Future<void> animateToDateTime(
    DateTime date, {
    Duration? pageDuration,
    Curve? pageCurve,
    Duration? scrollDuration,
    Curve? scrollCurve,
  }) async {
    // Animate to the date.
    await animateToDate(date, duration: pageDuration, curve: pageCurve);
  }

  @override
  Future<void> animateToEvent(
    CalendarEvent<T> event, {
    Duration? pageDuration,
    Curve? pageCurve,
    Duration? scrollDuration,
    Curve? scrollCurve,
    bool centerEvent = true,
  }) {
    return animateToDateTime(
      event.start,
      pageDuration: pageDuration,
      pageCurve: pageCurve,
      scrollDuration: scrollDuration,
      scrollCurve: scrollCurve,
    );
  }

  @override
  Future<void> animateToNextPage({Duration? duration, Curve? curve}) async {
    await pageController.nextPage(
      duration: duration ?? const Duration(milliseconds: 300),
      curve: curve ?? Curves.easeInOut,
    );
  }

  @override
  Future<void> animateToPreviousPage({Duration? duration, Curve? curve}) async {
    await pageController.previousPage(
      duration: duration ?? const Duration(milliseconds: 300),
      curve: curve ?? Curves.easeInOut,
    );
  }

  @override
  void jumpToDate(DateTime date) {
    final pageNumber = viewConfiguration.pageNavigationFunctions.indexFromDate(
      date,
    );
    jumpToPage(pageNumber);
  }

  @override
  void jumpToPage(int page) => pageController.jumpToPage(page);

  @override
  String toString() {
    return '${runtimeType.toString()} (${viewConfiguration.runtimeType})';
  }
}
