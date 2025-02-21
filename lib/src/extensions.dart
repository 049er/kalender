import 'package:flutter/material.dart';

/// An extension on the [DateTimeRange] class that provides helpful methods.
extension DateTimeRangeExtensions on DateTimeRange {
  /// Check if both the [start] and [end] times are in utc.
  bool get isUtc => start.isUtc && end.isUtc;

  /// The time difference in days between the [start] and [end] of this range.
  ///
  /// This calculates the difference in days using UTC time to ensure consistent
  /// results regardless of time zones.
  ///
  /// Example:
  /// ```dart
  /// final range = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 31));
  /// print(range.dayDifference); // Output: 30
  /// ```
  int get dayDifference {
    final startDate = start.asUtc;
    final endDate = end.asUtc;
    final difference = endDate.difference(startDate).inDays;
    return difference;
  }

  /// The difference in months between the [start] and [end] dates of this range.
  ///
  /// This calculates the absolute difference in years, multiplies by 12, and then
  /// adds the difference in months.  It handles cases where the start and end
  /// dates are in different years or have different days of the month.
  ///
  /// Example:
  /// ```dart
  /// final range = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2025, 6, 1));
  /// print(range.monthDifference); // Output: 17
  /// ```
  int get monthDifference {
    var months = ((start.year - end.year).abs() - 1) * 12;
    months += end.month + (12 - start.month);
    return months;
  }

  /// Returns the ISO week number(s) that this [DateTimeRange] spans.
  ///
  /// This method returns a tuple containing one or two week numbers, depending
  /// on whether the range spans a single week or multiple weeks, following the
  /// ISO 8601 standard where Monday is the first day of the week.
  ///
  /// *   If the range spans a single week, the tuple contains the week number
  ///     and `null` as the second value.
  /// *   If the range spans multiple weeks, the tuple contains the week number
  ///     of the first day and the week number of the last day.
  /// *   If the range spans across two years and is less than a week long, then both week numbers are returned.
  ///
  /// Example (single week):
  /// ```dart
  /// final range = DateTimeRange(start: DateTime(2025, 1, 6), end: DateTime(2025, 1, 12));
  /// final (weekNumber, secondWeekNumber) = range.weekNumbers;
  /// print(weekNumber); // Output: 2 (ISO week 2)
  /// print(secondWeekNumber); // Output: null
  /// ```
  ///
  /// Example (multiple weeks):
  /// ```dart
  /// final range = DateTimeRange(start: DateTime(2025, 1, 6), end: DateTime(2025, 1, 13));
  /// final (weekNumber, secondWeekNumber) = range.weekNumbers;
  /// print(weekNumber); // Output: 2 (ISO week 2)
  /// print(secondWeekNumber); // Output: 3 (ISO week 3)
  /// ```
  (int first, int? last) get weekNumbers {
    final days = dates(inclusive: true);
    final isSingleWeek = days.length <= 7;

    if (start.year != end.year && !isSingleWeek) {
      return (start.weekNumber, end.weekNumber);
    }

    if (!isSingleWeek) {
      return (start.weekNumber, end.weekNumber);
    } else {
      return (start.weekNumber, null);
    }
  }

  /// Generates a list of [DateTime] objects representing the dates within this [DateTimeRange].
  ///
  /// The [inclusive] parameter controls whether the end date is included in the list. (The function will always return at least one date)
  ///
  /// **Important Considerations:**
  ///
  /// * **Time Zone Consistency:** The start and end [DateTime] of the [DateTimeRange]
  ///   must be in the same time zone. An assertion will be thrown if they are not.
  ///   This is crucial for accurate date calculations.
  /// * **Daylight Saving Time (DST):** This function handles DST transitions correctly.
  ///   It uses date components (year, month, day) for incrementing to avoid DST-related
  ///   issues.
  ///
  /// Example:
  ///
  /// ```dart
  /// final startDate = DateTime(2024, 10, 26);
  /// final endDate = DateTime(2024, 10, 29);
  /// final range = DateTimeRange(start: startDate, end: endDate);
  /// final dates = range.dates(inclusive: true);
  /// print(dates); // Output: [2024-10-26, 2024-10-27, 2024-10-28, 2024-10-29]
  /// final dates2 = range.dates(inclusive: false);
  /// print(dates); // Output: [2024-10-26, 2024-10-27, 2024-10-28]
  /// ```
  ///
  List<DateTime> dates({bool inclusive = false}) {
    assert(
      start.isUtc == end.isUtc,
      'This calculation requires the start and end DateTime objects to be in the same timezone. '
      'Start: $start, End: $end',
    );

    // Start with the beginning of the start date.
    final dates = [start.startOfDay];

    // Handle the case where the start and end dates are the same.
    if (start.isSameDay(end)) return dates;

    // Iterate through the dates, incrementing by one day at a time.
    var current = dates.last;
    while (current.isBefore(end) || (inclusive && current.isAtSameMomentAs(end))) {
      // Increment using date components (DST-safe)
      final next = current.copyWith(day: current.day + 1);

      // Add the next date to the list if it's within the range.
      if (next.isBefore(end) || (inclusive && next.isAtSameMomentAs(end))) {
        dates.add(next);
        current = next;
      } else if (inclusive && next.isAtSameMomentAs(end)) {
        dates.add(next);
        current = next;
      } else {
        break;
      }
    }

    return dates;
  }

  /// Returns a [DateTimeRange] representing the portion of this [DateTimeRange]
  /// that falls on the given [date], or `null` if the [date] is not within this range.
  ///
  /// This method calculates the intersection of this [DateTimeRange] with the
  /// specified [date].  It handles cases where the [date] is the same as the
  /// start or end of the range, or if it falls within the range.  If the [date]
  /// is outside the range, it returns `null`.
  ///
  /// Example:
  /// ```dart
  /// final range = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 31));
  /// final date = DateTime(2024, 1, 15);
  /// final rangeOnDate = range.dateTimeRangeOnDate(date);
  /// print(rangeOnDate?.start); // Output: 2024-01-15 00:00:00.000
  /// print(rangeOnDate?.end);   // Output: 2024-01-15 23:59:59.999
  ///
  /// final range2 = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 1));
  /// final date2 = DateTime(2024, 1, 1);
  /// final rangeOnDate2 = range2.dateTimeRangeOnDate(date2);
  /// print(rangeOnDate2?.start); // Output: 2024-01-01 00:00:00.000
  /// print(rangeOnDate2?.end);   // Output: 2024-01-01 23:59:59.999
  ///
  /// final dateOutsideRange = DateTime(2024, 2, 1);
  /// final rangeOnDateOutside = range.dateTimeRangeOnDate(dateOutsideRange);
  /// print(rangeOnDateOutside); // Output: null
  /// ```
  DateTimeRange? dateTimeRangeOnDate(DateTime date) {
    // Check if the given date is outside the range. If so, return null.
    if (!date.isDuring(this)) return null;

    // Check if the start and end dates are the same day. If so, the entire range is on that day.
    if (start.isSameDay(end)) return this;

    // Check if the given date is the same as the start date.
    if (date.isSameDay(start)) return DateTimeRange(start: start, end: start.endOfDay);

    // Check if the given date is the same as the end date.
    if (date.isSameDay(end)) return DateTimeRange(start: end.startOfDay, end: end);

    // If none of the above conditions are met, the date must be within the range
    // but not the start or end date.
    return DateTimeRange(start: date.startOfDay, end: date.endOfDay);
  }

  /// Checks if this [DateTimeRange] overlaps with another [DateTimeRange].
  ///
  /// Two [DateTimeRange] objects overlap if they share any common time interval.
  /// This method checks if the start of one range is before the end of the other,
  /// AND the end of the first range is after the start of the second.  This
  /// determines a true overlap, where the ranges have some period in common.
  ///
  /// By default, ranges that only "touch" at their start or end times are *not*
  /// considered to overlap. This behavior can be changed by setting the
  /// `touching` parameter to `true`.
  ///
  /// Example (non-touching overlap):
  /// ```dart
  /// final range1 = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 10));
  /// final range2 = DateTimeRange(start: DateTime(2024, 1, 5), end: DateTime(2024, 1, 15));
  /// print(range1.overlaps(range2)); // Output: true
  ///
  /// final range3 = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 5));
  /// final range4 = DateTimeRange(start: DateTime(2024, 1, 5), end: DateTime(2024, 1, 10));
  /// print(range3.overlaps(range4)); // Output: false (only touching)
  /// ```
  ///
  /// Example (touching overlap):
  /// ```dart
  /// final range3 = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 5));
  /// final range4 = DateTimeRange(start: DateTime(2024, 1, 5), end: DateTime(2024, 1, 10));
  /// print(range3.overlaps(range4, touching: true)); // Output: true (touching considered overlap)
  /// ```
  bool overlaps(DateTimeRange other, {bool touching = false}) {
    // Check if the ranges overlap.
    final overlap = start.isBefore(other.end) && end.isAfter(other.start);
    if (!touching) return overlap;

    // Check if the start or end times are touching.
    final startTouching = other.start.isAtSameMomentAs(end);
    final endTouching = other.end.isAtSameMomentAs(start);
    return startTouching || endTouching;
  }

  /// TODO: REMOVE THIS COMPLETLY
  /// A list of [DateTime]s that the [DateTimeRange] spans.
  ///
  /// Includes the [start] date.
  /// Includes the [end] date only if it is not the start of the day. (after 00:00:00)
  List<DateTime> get days {
    final start = this.start.asUtc;
    final end = this.end.asUtc;

    if (start.isSameDay(end)) return [this.start.startOfDay];

    final dateTimeRange = DateTimeRange(
      start: start.startOfDay,
      end: end.startOfDay == end ? end.startOfDay : end.endOfDay,
    );

    final numberOfDays = dateTimeRange.dayDifference;
    final dates = <DateTime>[];
    for (var i = 0; i < numberOfDays; i++) {
      dates.add(this.start.startOfDay.add(Duration(days: i)));
    }
    return dates;
  }

  /// Returns a [DateTimeRange] with the [DateTime]s as UTC values without converting them.
  DateTimeRange get asUtc => DateTimeRange(start: start.asUtc, end: end.asUtc);

  /// Returns a [DateTimeRange] with the [DateTime]s as local values without converting them.
  DateTimeRange get asLocal => DateTimeRange(start: start.asLocal, end: end.asLocal);
}

extension DateTimeExtensions on DateTime {
  /// Check if the [DateTime] is today in the current time zone.
  ///
  /// This method compares the year, month, and day of this [DateTime] object
  /// with the current date in the system's local time zone.  It returns `true`
  /// if they are the same, and `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime.now();
  /// print(date.isToday); // Output: true (if called today)
  ///
  /// final otherDate = DateTime(2024, 1, 1);
  /// print(otherDate.isToday); // Output: false (if not called on Jan 1, 2024)
  /// ```
  bool get isToday {
    final now = DateTime.now();
    final comparison = isUtc ? now.toUtc() : now; // Use local time for comparison.
    return year == comparison.year && month == comparison.month && day == comparison.day;
  }

  /// Gets the start of the date.
  ///
  /// This returns a new [DateTime] object representing the start of the day
  /// (midnight) in the same time zone as the original [DateTime].
  ///
  /// Example (local):
  /// ```dart
  /// final date = DateTime(2024, 1, 15, 10, 30); // January 15, 2024, 10:30 AM
  /// final start = date.startOfDay;
  /// print(start); // Output: 2024-01-15 00:00:00.000
  /// ```
  ///
  /// Example (utc):
  /// ```dart
  /// final date = DateTime.utc(2024, 1, 15, 10, 30); // January 15, 2024, 10:30 AM
  /// final start = date.startOfDay;
  /// print(start); // Output: 2024-01-15 00:00:00.000Z
  /// ```
  DateTime get startOfDay {
    return copyWith(year: year, month: month, day: day, hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  }

  /// Gets the end of the date. (aka the start of the next day).
  ///
  /// This returns a new [DateTime] object representing the end of the date
  /// (midnight of the next day), in the same time zone as the original [DateTime].
  ///
  /// Example (local):
  /// ```dart
  /// final date = DateTime(2024, 1, 15, 10, 30); // January 15, 2024, 10:30 AM
  /// final end = date.endOfDay;
  /// print(end); // Output: 2024-01-16 00:00:00.000
  /// ```
  ///
  /// Example (utc):
  /// ```dart
  /// final date = DateTime.utc(2024, 1, 15, 10, 30); // January 15, 2024, 10:30 AM
  /// final end = date.endOfDay;
  /// print(end); // Output: 2024-01-16 00:00:00.000Z
  /// ```
  DateTime get endOfDay => startOfDay.copyWith(day: day + 1);

  /// Gets the [DateTimeRange] representing the entire day in which this
  /// [DateTime] falls.
  ///
  /// The returned [DateTimeRange] starts at the beginning of the day (midnight)
  /// and ends at the beginning of the next day, both in the same
  /// time zone as this [DateTime].
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 1, 15, 10, 30); // January 15, 2024, 10:30 AM
  /// final range = date.dayRange;
  /// print(range.start); // Output: 2024-01-15 00:00:00.000
  /// print(range.end);   // Output: 2024-01-16 00:00:00.000
  /// ```
  DateTimeRange get dayRange => DateTimeRange(start: startOfDay, end: endOfDay);

  /// Gets the start of the month.
  ///
  /// This returns a new [DateTime] object representing the first day of the
  /// month (midnight) in the same time zone as the original [DateTime].
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 1, 15, 10, 30); // January 15, 2024, 10:30 AM
  /// final start = date.startOfMonth;
  /// print(start); // Output: 2024-01-01 00:00:00.000
  /// ```
  DateTime get startOfMonth => (isUtc ? DateTime.new : DateTime.utc)(year, month);

  /// Gets the end of the month. (aka start of the next month)
  ///
  /// This returns a new [DateTime] object representing the last day of the
  /// month, (midnight of the start of the next month) in the same time zone
  /// as the original [DateTime].
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 1, 15, 10, 30); // January 15, 2024, 10:30 AM
  /// final start = date.startOfMonth;
  /// print(start); // Output: 2024-01-01 00:00:00.000
  /// ```
  DateTime get endOfMonth => (isUtc ? DateTime.new : DateTime.utc)(year, month + 1);

  /// Gets the month range in which the [DateTime] is in.
  DateTimeRange get monthRange {
    return DateTimeRange(
      start: startOfMonth,
      end: endOfMonth,
    );
  }

  /// Checks if the [DateTime] is within the [DateTimeRange].
  bool isWithin(DateTimeRange dateTimeRange) {
    return isAfter(dateTimeRange.start) && isBefore(dateTimeRange.end);
  }

  bool isDuring(DateTimeRange dateTimeRange) {
    return (isAtSameMomentAs(dateTimeRange.start) || isAfter(dateTimeRange.start)) &&
        (isAtSameMomentAs(dateTimeRange.end) || isBefore(dateTimeRange.end));
  }

  /// Checks if the [DateTime] is the same day as the calling object.
  bool isSameDay(DateTime date) {
    return year == date.year && month == date.month && day == date.day;
  }

  /// Returns a [DateTime] as a UTC value without converting it.
  DateTime get asUtc {
    return DateTime.utc(year, month, day, hour, minute, second, millisecond, microsecond);
  }

  /// Returns a [DateTime] as a local value without converting it.
  DateTime get asLocal {
    return DateTime(year, month, day, hour, minute, second, millisecond, microsecond);
  }

  /// Gets the year range in which the [DateTime] is in.
  DateTimeRange get yearRange {
    return DateTimeRange(
      start: DateTime(year, 1, 1),
      end: DateTime(year + 1, 1, 1),
    );
  }

  /// Add specific amount of [days] (ignoring DST)
  DateTime addDays(int days) {
    return copyWith(
      year: year,
      month: month,
      day: day + days,
      hour: hour,
      minute: minute,
      second: second,
      millisecond: millisecond,
      microsecond: microsecond,
    );
  }

  /// Subtract specific amount of [days] (ignoring DST)
  DateTime subtractDays(int days) {
    return addDays(-days);
  }

  /// Get the start of the week with an offset.
  DateTime startOfWeekWithOffset(int firstDayOfWeek) {
    assert(
      firstDayOfWeek >= 1 && firstDayOfWeek <= 7,
      'firstDayOfWeek must be between 1 and 7',
    );

    final difference = weekday - firstDayOfWeek;

    if (difference < 0) {
      return subtractDays(7 + difference).startOfDay;
    } else {
      return subtractDays(difference).startOfDay;
    }
  }

  /// Gets the end of the week with an offset.
  DateTime endOfWeekWithOffset(int firstDayOfWeek) {
    return startOfWeekWithOffset(firstDayOfWeek).addDays(7).startOfDay;
  }

  /// Find a [DateTimeRange] spanning 7 days that contains this date.
  ///
  /// Starting on the [firstDayOfWeek]
  DateTimeRange weekRangeWithOffset(int firstDayOfWeek) {
    var startOfWeek = subtractDays(weekday - firstDayOfWeek).startOfDay;
    if (startOfWeek.isAfter(this)) {
      startOfWeek = startOfWeek.subtractDays(7);
    }

    return DateTimeRange(
      start: startOfWeek,
      end: startOfWeek.addDays(7),
    );
  }

  /// Returns a [DateTimeRange] with the [DateTime] as the start that spans the given number of days.
  DateTimeRange multiDayDateTimeRange(int numberOfDays) {
    return DateTimeRange(
      start: startOfDay,
      end: endOfDay.addDays(numberOfDays - 1),
    );
  }

  /// Calculates week number from a date as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
  int get weekNumber {
    // Add 3 to always compare with January 4th, which is always in week 1
    // Add 7 to index weeks starting with 1 instead of 0
    final woy = ((ordinalDate - weekday + 10) ~/ 7);

    // If the week number equals zero, it means that the given date belongs to the preceding (week-based) year.
    if (woy == 0) {
      // The 28th of December is always in the last week of the year
      return DateTime(year - 1, 12, 28).weekNumber;
    }

    // If the week number equals 53, one must check that the date is not actually in week 1 of the following year
    if (woy == 53 &&
        DateTime(year, 1, 1).weekday != DateTime.thursday &&
        DateTime(year, 12, 31).weekday != DateTime.thursday) {
      return 1;
    }

    return woy;
  }

  /// The ordinal date, the number of days since December 31st the previous year.
  ///
  /// January 1st has the ordinal date 1
  ///
  /// December 31st has the ordinal date 365, or 366 in leap years
  int get ordinalDate {
    const offsets = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
    return offsets[month - 1] + day + (isLeapYear && month > 2 ? 1 : 0);
  }

  /// True if this date is on a leap year.
  bool get isLeapYear {
    return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
  }

  String get dayNameEnglish => switch (weekday) {
        1 => 'Monday',
        2 => 'Tuesday',
        3 => 'Wednesday',
        4 => 'Thursday',
        5 => 'Friday',
        6 => 'Saturday',
        7 => 'Sunday',
        _ => throw Exception('Invalid weekday'),
      };

  String get monthNameEnglish => switch (month) {
        1 => 'January',
        2 => 'February',
        3 => 'March',
        4 => 'April',
        5 => 'May',
        6 => 'June',
        7 => 'July',
        8 => 'August',
        9 => 'September',
        10 => 'October',
        11 => 'November',
        12 => 'December',
        _ => throw Exception('Invalid month'),
      };
}

extension TimeOfDayExtension on TimeOfDay {
  DateTime toDateTime(DateTime dateTime) => dateTime.copyWith(
        year: dateTime.year,
        month: dateTime.month,
        day: dateTime.day,
        hour: hour,
        minute: minute,
      );
}
