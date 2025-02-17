import 'package:flutter/material.dart';
import 'package:kalender/src/widgets/time_region_tile/time_region_tile.dart';

/// This widget renders the tile widget and resize handles in a stack.
///
/// The tile widget is rendered below the resize handles.
class DayTimeReangeTile<T extends Object?> extends TimeRegionTile<T> {
  const DayTimeReangeTile({
    super.key,
    required super.controller,
    required super.eventsController,
    required super.tileComponents,
    required super.event,
    required super.dateTimeRange,
  });

  @override
  Widget build(BuildContext context) {
    final tile = tileBuilder.call(event, localDateTimeRange);

    return tile;
  }
}
