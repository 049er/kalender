import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:kalender/src/enumerations.dart';
import 'package:kalender/src/models/mixins/snap_points.dart';
import 'package:kalender/src/models/resize_event.dart';
import 'package:kalender/src/platform.dart';

/// A [StatelessWidget] that displays a single [CalendarEvent] in the [MultiDayBody].
class DayEventTile<T extends Object?> extends StatefulWidget {
  final EventsController<T> eventsController;
  final CalendarController<T> controller;

  final CalendarEvent<T> event;
  final CalendarCallbacks<T>? callbacks;

  final TileComponents<T> tileComponents;

  final MultiDayBodyConfiguration bodyConfiguration;
  final DateTimeRange visibleDateTimeRange;
  final TimeOfDayRange timeOfDayRange;
  final double dayWidth;
  final double heightPerMinute;

  final bool continuesBefore;
  final bool continuesAfter;

  const DayEventTile({
    super.key,
    required this.event,
    required this.eventsController,
    required this.controller,
    required this.callbacks,
    required this.tileComponents,
    required this.bodyConfiguration,
    required this.visibleDateTimeRange,
    required this.timeOfDayRange,
    required this.dayWidth,
    required this.heightPerMinute,
    required this.continuesBefore,
    required this.continuesAfter,
  });

  @override
  State<DayEventTile<T>> createState() => _DayEventTileState<T>();
}

class _DayEventTileState<T extends Object?> extends State<DayEventTile<T>> with SnapPoints {
  EventsController<T> get eventsController => widget.eventsController;
  CalendarController<T> get controller => widget.controller;
  ViewController<T> get viewController => controller.viewController!;

  CalendarEvent<T> get event => widget.event;
  MultiDayBodyConfiguration get bodyConfiguration => widget.bodyConfiguration;
  CalendarCallbacks<T>? get callbacks => widget.callbacks;
  TileComponents<T> get tileComponents => widget.tileComponents;
  DragAnchorStrategy? get dragAnchorStrategy => tileComponents.dragAnchorStrategy;
  ValueNotifier<Size> get feedbackWidgetSize => eventsController.feedbackWidgetSize;
  TimeOfDayRange get timeOfDayRange => widget.timeOfDayRange;
  double get dayWidth => widget.dayWidth;
  double get heightPerMinute => widget.heightPerMinute;

  ValueNotifier<CalendarEvent<T>?> get selectedEvent => controller.selectedEvent;

  @override
  Widget build(BuildContext context) {
    final onTap = callbacks?.onEventTapped;
    late final tileComponent = tileComponents.tileBuilder.call(widget.event);
    late final dragComponent = tileComponents.tileWhenDraggingBuilder?.call(widget.event);

    return LayoutBuilder(
      builder: (context, constraints) {
        final showResizeWidgets = bodyConfiguration.allowResizing && event.canModify;

        late final resizeHeight = min(constraints.maxHeight * 0.25, 12.0);

        late final showTop =
            showResizeWidgets && constraints.maxHeight > 24 && !widget.continuesBefore;
        late final topResizeEvent = ResizeEvent(event, ResizeDirection.top);
        late final topResizeDetector = Draggable<ResizeEvent<T>>(
          data: topResizeEvent,
          feedback: const SizedBox(),
          dragAnchorStrategy: pointerDragAnchorStrategy,
          child: tileComponents.verticalResizeHandle ?? const SizedBox(),
          onDragStarted: () => controller.selectEvent(event, internal: true),
        );

        late final showBottom = showResizeWidgets && !widget.continuesAfter;
        late final bottomResizeEvent = ResizeEvent(event, ResizeDirection.bottom);
        late final bottomResizeDetector = Draggable<ResizeEvent<T>>(
          data: bottomResizeEvent,
          feedback: const SizedBox(),
          dragAnchorStrategy: pointerDragAnchorStrategy,
          child: tileComponents.verticalResizeHandle ?? const SizedBox(),
          onDragStarted: () => controller.selectEvent(event, internal: true),
        );

        late final feedback = ValueListenableBuilder(
          valueListenable: feedbackWidgetSize,
          builder: (context, value, child) {
            final feedbackTile = tileComponents.feedbackTileBuilder?.call(
              widget.event,
              value,
            );
            return feedbackTile ?? const SizedBox();
          },
        );

        final isDragging = controller.selectedEventId == event.id && controller.internalFocus;
        late final draggableTile = isMobileDevice
            ? LongPressDraggable(
                data: widget.event,
                feedback: feedback,
                childWhenDragging: dragComponent,
                dragAnchorStrategy: dragAnchorStrategy ?? childDragAnchorStrategy,
                child: isDragging && dragComponent != null ? dragComponent : tileComponent,
              )
            : Draggable<CalendarEvent<T>>(
                data: widget.event,
                feedback: feedback,
                childWhenDragging: dragComponent,
                dragAnchorStrategy: dragAnchorStrategy ?? childDragAnchorStrategy,
                child: isDragging && dragComponent != null ? dragComponent : tileComponent,
              );

        final tileWidget = GestureDetector(
          onTap: onTap != null
              ? () {
                  // Find the global position and size of the tile.
                  final renderObject = context.findRenderObject()! as RenderBox;
                  onTap.call(widget.event, renderObject);
                }
              : null,
          child: bodyConfiguration.allowRescheduling ? draggableTile : tileComponent,
        );

        return Stack(
          children: [
            Positioned.fill(child: tileWidget),
            // Desktop
            if (showTop)
              if (!isMobileDevice)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: resizeHeight,
                  child: ValueListenableBuilder(
                    valueListenable: selectedEvent,
                    builder: (context, value, child) {
                      if (value == null) return topResizeDetector;
                      if (!controller.internalFocus) return topResizeDetector;
                      return const SizedBox();
                    },
                  ),
                )
              else
                Positioned(
                  top: 0,
                  right: 0,
                  width: resizeHeight,
                  height: resizeHeight,
                  child: ValueListenableBuilder(
                    valueListenable: selectedEvent,
                    builder: (context, value, child) {
                      if (value == event) return topResizeDetector;
                      return const SizedBox();
                    },
                  ),
                ),
            if (showBottom)
              if (!isMobileDevice)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: resizeHeight,
                  child: ValueListenableBuilder(
                    valueListenable: selectedEvent,
                    builder: (context, value, child) {
                      if (value == null) return bottomResizeDetector;
                      if (!controller.internalFocus) return bottomResizeDetector;
                      return const SizedBox();
                    },
                  ),
                )
              else
                Positioned(
                  bottom: 0,
                  left: 0,
                  width: resizeHeight,
                  height: resizeHeight,
                  child: ValueListenableBuilder(
                    valueListenable: selectedEvent,
                    builder: (context, value, child) {
                      if (value == event) return bottomResizeDetector;
                      return const SizedBox();
                    },
                  ),
                ),
          ],
        );
      },
    );
  }
}
