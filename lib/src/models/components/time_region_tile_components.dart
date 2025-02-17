import 'package:kalender/src/type_definitions.dart';
import 'package:kalender/src/widgets/multi_day/multi_day_body.dart';

/// The components used by the [MultiDayBody] to render the time region event tiles.
///
/// - [tileBuilder]
class TimeRegionTileComponents<T extends Object?> {
  /// The default builder for stationary time range event tiles.
  final TimeRegionTileBuilder<T> tileBuilder;

  const TimeRegionTileComponents({
    required this.tileBuilder,
  });
}
