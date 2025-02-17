## 0.5.1

### What's new

- Allow to customize specific areas in the calendar using the TimeRegionEvent that get rendered below the
  regular events level and allow to create events above it

## 0.5.0

### Breaking changes:

Version 0.5.0 has quite a few Breaking changes, there is no easy way to migrate to this version. Here are a few important things that have changed.

- The [CalendarView](https://github.com/werner-scholtz/kalender/blob/main/lib/src/calendar_view.dart) now takes a `header` [CalendarHeader](https://github.com/werner-scholtz/kalender/blob/main/lib/src/calendar_header.dart) and `body` [CalendarBody](https://github.com/werner-scholtz/kalender/blob/main/lib/src/calendar_body.dart) widgets. You can wrap these widgets in other widgets to style them as seen [here](https://github.com/werner-scholtz/kalender/blob/9a053c9daac51985bbbb336393d5013ef3977bd0/example/lib/main.dart#L112)

- Event tiles now make use of the [Draggable](https://api.flutter.dev/flutter/widgets/Draggable-class.html) widget provided by flutter.
  Take a look at the [TileComponents](https://github.com/werner-scholtz/kalender/blob/main/lib/src/models/components/tile_components.dart) for more details on how tiles work now. This opens some interesting possibilities for displaying multiple calendars.

- The [CalendarCallbacks](https://github.com/werner-scholtz/kalender/blob/main/lib/src/models/calendar_callbacks.dart) (previously `CalendarEventHandlers`) have been changed so more information is given when an interaction occurs.

- The schedule view has been removed, but will be reimplemented in the future.

### What's new

- Auto scroll/paging (https://github.com/werner-scholtz/kalender/issues/75 && https://github.com/werner-scholtz/kalender/issues/64)
- Calender can now accept Draggable's (https://github.com/werner-scholtz/kalender/issues/48)
- More information for the TileBuilder (https://github.com/werner-scholtz/kalender/issues/83)

## pre-0.5.0

- https://github.com/werner-scholtz/kalender/blob/main-0.4.2/CHANGELOG.md
