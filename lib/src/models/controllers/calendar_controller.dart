import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:kalender/src/models/mixins/calendar_navigation_functions.dart';
import 'package:kalender/src/models/mixins/new_event.dart';

/// The [CalendarController] is used to controller a single [CalendarView].
/// It provides some useful functions for navigating the [CalendarView].
///
/// The [CalendarView] attaches itself to the [CalendarController] by calling [attach].
/// And detaches itself by calling [detach].
///
class CalendarController<T extends Object?> extends ChangeNotifier
    with CalendarNavigationFunctions<T>, NewEvent<T> {
  CalendarController({DateTime? initialDate})
      : initialDate = initialDate ?? DateTime.now(),
        id = DateTime.now().millisecondsSinceEpoch;

  /// This controllers id.
  final int id;

  late final DateTime initialDate;

  /// This is a reference to the [ViewController] that is currently attached to this [CalendarController].
  ViewController<T>? _viewController;
  ViewController<T>? get viewController => _viewController;
  bool get isAttached => _viewController != null;

  /// The [DateTimeRange] that is currently visible.
  late final visibleDateTimeRange =
      ValueNotifier<DateTimeRange>(initialDate.dayRange);

  /// The [CalendarEvent]s that are currently visible.
  final visibleEvents = ValueNotifier<Set<CalendarEvent<T>>>({});

  /// The [TimeRegionEvent]s that are currently visible.
  final visibleTimeRegionEvents = ValueNotifier<Set<TimeRegionEvent<T>>>({});

  /// The event currently being focused on.
  final selectedEvent = ValueNotifier<CalendarEvent<T>?>(null);
  int? _selectedEventId;
  int? get selectedEventId => _selectedEventId;

  /// This is used to determine if focus on the event is coming from within the package or from outside.
  bool _internalFocus = false;
  bool get internalFocus => _internalFocus;

  /// Place focus on an event.
  ///
  /// [event] the event to focus on.
  /// [internal] leave false if not called from within the package.
  void selectEvent(CalendarEvent<T> event, {bool internal = false}) {
    selectedEvent.value = event;
    _selectedEventId = event.id;
    _internalFocus = internal;
  }

  void updateEvent(CalendarEvent<T> event, {bool internal = false}) {
    selectedEvent.value = event;
    _internalFocus = internal;
  }

  /// Deselect the event.
  void deselectEvent() {
    selectedEvent.value = null;
    _internalFocus = false;
    _selectedEventId = null;
  }

  bool isAttachedTo(ViewController viewController) {
    return viewController == _viewController;
  }

  /// Attach the [ViewController] to this [CalendarController].
  void attach(ViewController<T> viewController) {
    if (isAttached) detach();

    _viewController = viewController;
    notifyListeners();
  }

  /// Detach the [ViewController] from this [CalendarController].
  void detach() {
    _viewController = null;
  }

  /// Jump to the given [DateTime].
  @override
  void jumpToPage(int page) {
    viewController?.jumpToPage(page);
  }

  /// Jump to the given [DateTime].
  @override
  void jumpToDate(DateTime date) {
    viewController?.jumpToDate(date);
  }

  @override
  Future<void> animateToNextPage({
    Duration? duration,
    Curve? curve,
  }) async {
    await viewController?.animateToNextPage(
      duration: duration,
      curve: curve,
    );
  }

  @override
  Future<void> animateToPreviousPage({
    Duration? duration,
    Curve? curve,
  }) async {
    return viewController?.animateToPreviousPage(
      duration: duration,
      curve: curve,
    );
  }

  @override
  Future<void> animateToDate(
    DateTime date, {
    Duration? duration,
    Curve? curve,
  }) async {
    return viewController?.animateToDate(
      date,
      duration: duration,
      curve: curve,
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
    return viewController?.animateToDateTime(
      date,
      pageDuration: pageDuration,
      pageCurve: pageCurve,
      scrollDuration: scrollDuration,
      scrollCurve: scrollCurve,
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
    return viewController?.animateToEvent(
      event,
      centerEvent: centerEvent,
    );
  }

  @override
  String toString() {
    return runtimeType.toString();
  }
}
