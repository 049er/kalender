import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:kalender/src/models/calendar_events/draggable_event.dart';
import 'package:kalender/src/platform.dart';
import 'package:kalender/src/widgets/event_tiles/event_tile.dart';

/// This widget renders the tile widget and resize handles in a stack.
///
/// The tile widget is rendered below the resize handles.
class DayEventTile<T extends Object?> extends EventTile<T> {
  const DayEventTile({
    super.key,
    required super.controller,
    required super.eventsController,
    required super.callbacks,
    required super.tileComponents,
    required super.event,
    required super.dateTimeRange,
    required super.allowRescheduling,
    required super.allowResizing,
  });

  @override
  Widget build(BuildContext context) {
    late final topResizeDetector = ValueListenableBuilder(
      valueListenable: selectedEvent,
      builder: (context, value, child) {
        if (!isMobileDevice) {
          if (controller.internalFocus) return const SizedBox();
        } else {
          if (value != event) return const SizedBox();
        }

        return Draggable<Resize<T>>(
          data: resizeEvent(ResizeDirection.top),
          feedback: const SizedBox(),
          dragAnchorStrategy: pointerDragAnchorStrategy,
          onDragStarted: selectEvent,
          child: verticalResizeHandle ?? Container(color: Colors.transparent),
        );
      },
    );

    late final bottomResizeDetector = ValueListenableBuilder(
      valueListenable: selectedEvent,
      builder: (context, value, child) {
        if (!isMobileDevice) {
          if (controller.internalFocus) return const SizedBox();
        } else {
          if (value != event) return const SizedBox();
        }

        return Draggable<Resize<T>>(
          data: resizeEvent(ResizeDirection.bottom),
          feedback: const SizedBox(),
          dragAnchorStrategy: pointerDragAnchorStrategy,
          onDragStarted: selectEvent,
          child: verticalResizeHandle ?? Container(color: Colors.transparent),
        );
      },
    );

    late final feedback = ValueListenableBuilder(
      valueListenable: feedbackWidgetSize,
      builder: (context, value, child) {
        final feedbackTile = feedbackTileBuilder?.call(event, value);
        return feedbackTile ?? const SizedBox();
      },
    );

    final tile = tileBuilder.call(event, localDateTimeRange);
    final tileWhenDragging = tileWhenDraggingBuilder?.call(event);
    final isDragging =
        controller.selectedEventId == event.id && controller.internalFocus;
    late final draggable = isMobileDevice
        ? LongPressDraggable<Reschedule<T>>(
            data: rescheduleEvent,
            feedback: feedback,
            childWhenDragging: tileWhenDragging,
            dragAnchorStrategy: dragAnchorStrategy ?? childDragAnchorStrategy,
            onDragStarted: selectEvent,
            maxSimultaneousDrags: 1,
            child: isDragging && tileWhenDragging != null
                ? tileWhenDragging
                : tile,
          )
        : Draggable<Reschedule<T>>(
            data: rescheduleEvent,
            feedback: feedback,
            childWhenDragging: tileWhenDragging,
            dragAnchorStrategy: dragAnchorStrategy ?? childDragAnchorStrategy,
            onDragStarted: selectEvent,
            child: isDragging && tileWhenDragging != null
                ? tileWhenDragging
                : tile,
          );

    final tileWidget = GestureDetector(
      onTap: onEventTapped != null
          ? () {
              // Find the global position and size of the tile.
              final renderObject = context.findRenderObject()! as RenderBox;
              onEventTapped!.call(event, renderObject);
            }
          : null,
      child: canReschedule ? draggable : tile,
    );

    final resizeHandles = tileComponents.verticalHandlePositioner?.call(
          topResizeDetector,
          bottomResizeDetector,
          showStart,
          showEnd,
        ) ??
        VerticalTileResizeHandlePositioner(
          startResizeDetector: topResizeDetector,
          endResizeDetector: bottomResizeDetector,
          showStart: showStart,
          showEnd: showEnd,
        );

    return Stack(
      fit: StackFit.expand,
      children: [
        tileWidget,
        if (allowResizing) Positioned.fill(child: resizeHandles),
      ],
    );
  }
}
