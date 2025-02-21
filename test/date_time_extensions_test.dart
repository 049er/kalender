import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kalender/src/extensions.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart' show ListEquality;

Future<void> main() async {
  final timezone = Platform.environment['TZ'] ?? 'UTC';

  final testDates = [
    DateTime.now(),
    // America/New_York
    DateTime(2020, 3, 8, 2), // 2020	Sunday, 8 March, 02:00	Sunday, 1 November, 02:00
    DateTime(2020, 11, 1, 2),
    DateTime(2021, 3, 14, 2), // 2021	Sunday, 14 March, 02:00	Sunday, 7 November, 02:00
    DateTime(2021, 11, 7, 2),
    DateTime(2022, 3, 13, 2), // 2022	Sunday, 13 March, 02:00	Sunday, 6 November, 02:00
    DateTime(2022, 11, 6, 2),
    DateTime(2023, 3, 12, 2), // 2023	Sunday, 12 March, 02:00	Sunday, 5 November, 02:00
    DateTime(2023, 11, 5, 2),
    DateTime(2024, 3, 10, 2), // 2024	Sunday, 10 March, 02:00	Sunday, 3 November, 02:00
    DateTime(2024, 11, 3, 2),
    DateTime(2025, 3, 9, 2), // 2025	Sunday, 9 March, 02:00	Sunday, 2 November, 02:00
    DateTime(2025, 11, 2, 2),

    // Europe/London
    DateTime(2020, 3, 29, 1), // 2020	Sunday, 29 March, 01:00	Sunday, 25 October, 02:00
    DateTime(2020, 10, 25, 2),
    DateTime(2021, 3, 28, 1), // 2021	Sunday, 28 March, 01:00	Sunday, 31 October, 02:00
    DateTime(2021, 10, 31, 2),
    DateTime(2022, 3, 27, 1), // 2022	Sunday, 27 March, 01:00	Sunday, 30 October, 02:00
    DateTime(2022, 10, 30, 2),
    DateTime(2023, 3, 26, 1), // 2023	Sunday, 26 March, 01:00	Sunday, 29 October, 02:00
    DateTime(2023, 10, 29, 2),
    DateTime(2024, 3, 31, 1), // 2024	Sunday, 31 March, 01:00	Sunday, 27 October, 02:00
    DateTime(2024, 10, 27, 2),
    DateTime(2025, 3, 30, 1), // 2025	Sunday, 30 March, 01:00	Sunday, 26 October, 02:00
    DateTime(2025, 10, 26, 2),

    // Australia/Sydney
    DateTime(2020, 4, 5, 3), // 2020 Sunday, 5 April, 03:00	Sunday, 4 October, 02:00
    DateTime(2020, 10, 4, 2),
    DateTime(2021, 4, 4, 3), // 2021 Sunday, 4 April, 03:00	Sunday, 3 October, 02:00
    DateTime(2021, 10, 3, 2),
    DateTime(2022, 4, 3, 3), // 2022 Sunday, 3 April, 03:00	Sunday, 2 October, 02:00
    DateTime(2022, 10, 2, 2),
    DateTime(2023, 4, 2, 3), // 2023 Sunday, 2 April, 03:00	Sunday, 1 October, 02:00
    DateTime(2023, 10, 1, 2),
    DateTime(2024, 4, 7, 3), // 2024 Sunday, 7 April, 03:00	Sunday, 6 October, 02:00
    DateTime(2024, 10, 6, 2),
    DateTime(2025, 4, 6, 3), // 2025 Sunday, 6 April, 03:00	Sunday, 5 October, 02:00
    DateTime(2025, 10, 5, 2),
  ];

  group(timezone, () {
    final isUtc = timezone == 'UTC';
    final dates = isUtc ? testDates.map((e) => e.toUtc()) : testDates;
    group('DateTimeExtensions', () => dateTimeTests(dates));
    group('DateTimeRangeExtensions', () => dateTimeRangeTests(dates));
  });
}

void dateTimeRangeTests(Iterable<DateTime> testDates) {
  group('isUtc', () {
    final start = DateTime.now();
    final end = start.copyWith(hour: start.hour + 1);
    test('start and end in local', () {
      expect(DateTimeRange(start: start, end: end).isUtc, isFalse);
    });
    test('start in utc and end in local', () {
      expect(DateTimeRange(start: start.toUtc(), end: end).isUtc, isFalse);
    });
    test('start in local and end in utc', () {
      expect(DateTimeRange(start: start, end: end.toUtc()).isUtc, isFalse);
    });
    test('start and end in utc', () {
      expect(DateTimeRange(start: start.toUtc(), end: end.toUtc()).isUtc, isTrue);
    });
  });

  group('dayDifference', () {
    // TODO: some more testing needed.

    for (final date in testDates) {
      final start = date.copyWith(day: date.day - 1);
      final end = date.copyWith(day: date.day + 1);
      test('dayDifference: from $start until $end', () {
        final range = DateTimeRange(start: start, end: end);
        expect(range.dayDifference, 2);
      });
    }
  });

  group('monthDifference', () {
    test('Same month', () {
      final range = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 31));
      expect(range.monthDifference, 0);
    });
    test('One month difference', () {
      final range = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 2, 1));
      expect(range.monthDifference, 1);
    });

    test('Several months difference', () {
      final range = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 5, 1));
      expect(range.monthDifference, 4);
    });

    test('Across years', () {
      final range = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2025, 1, 1));
      expect(range.monthDifference, 12);
    });

    test('Across years with different months', () {
      final range = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2025, 6, 1));
      expect(range.monthDifference, 17);
    });

    test('Leap year', () {
      final range = DateTimeRange(start: DateTime(2024, 2, 29), end: DateTime(2024, 3, 1)); // Leap year
      expect(range.monthDifference, 1);
    });

    test('Different days of the month', () {
      final range = DateTimeRange(start: DateTime(2024, 1, 15), end: DateTime(2024, 2, 20));
      expect(range.monthDifference, 1);
    });

    test('Same date across years', () {
      final range = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2026, 1, 1));
      expect(range.monthDifference, 24);
    });
  });

  group('weekNumbers', () {
    test('Single week', () {
      final range = DateTimeRange(start: DateTime(2025, 1, 6), end: DateTime(2025, 1, 12));
      final (weekNumber, secondWeekNumber) = range.weekNumbers;
      expect(weekNumber, 2);
      expect(secondWeekNumber, null);
    });

    test('Single week - crosses year boundary', () {
      final range = DateTimeRange(start: DateTime(2024, 12, 30), end: DateTime(2025, 1, 5));
      final (weekNumber, secondWeekNumber) = range.weekNumbers;
      expect(weekNumber, 1);
      expect(secondWeekNumber, null);
    });

    test('Single week - tue to wed', () {
      final range = DateTimeRange(start: DateTime(2025, 1, 7), end: DateTime(2025, 1, 12));
      final (weekNumber, secondWeekNumber) = range.weekNumbers;
      expect(weekNumber, 2);
      expect(secondWeekNumber, null);
    });

    test('Multiple weeks', () {
      final range = DateTimeRange(start: DateTime(2025, 1, 6), end: DateTime(2025, 1, 14));
      final (weekNumber, secondWeekNumber) = range.weekNumbers;
      expect(weekNumber, 2);
      expect(secondWeekNumber, 3);
    });

    test('Multiple weeks - ends on monday', () {
      final range = DateTimeRange(start: DateTime(2025, 1, 6), end: DateTime(2025, 1, 13));
      final (weekNumber, secondWeekNumber) = range.weekNumbers;
      expect(weekNumber, 2);
      expect(secondWeekNumber, 3);
    });

    test('Multiple weeks - spans across years', () {
      final range = DateTimeRange(start: DateTime(2024, 12, 23), end: DateTime(2025, 12, 22));
      final (weekNumber, secondWeekNumber) = range.weekNumbers;
      expect(weekNumber, 52);
      expect(secondWeekNumber, 52);
    });
  });

  group('dates()', () {
    for (final date in testDates) {
      test('Same start and end date (inclusive)', () {
        final range = DateTimeRange(start: date, end: date);
        final dates = range.dates(inclusive: true);
        expect(dates, [date.startOfDay]);
      });

      test('Same start and end date (exclusive)', () {
        final range = DateTimeRange(start: date, end: date);
        final dates = range.dates(inclusive: false);
        expect(dates, [date.startOfDay]);
      });

      test('Start date before end date', () {
        final startDate = date.startOfDay;
        final endDate = startDate.copyWith(day: startDate.day + 3);
        final range = DateTimeRange(start: startDate, end: endDate);
        final expectedDates = [
          startDate,
          startDate.copyWith(day: startDate.day + 1),
          startDate.copyWith(day: startDate.day + 2),
          startDate.copyWith(day: startDate.day + 3),
        ];
        final dates = range.dates(inclusive: true);
        expect(const ListEquality<DateTime>().equals(dates, expectedDates), isTrue);
      });

      test('Start date before end date (exclusive)', () {
        final startDate = date.startOfDay;
        final endDate = startDate.copyWith(day: startDate.day + 3);
        final range = DateTimeRange(start: startDate, end: endDate);
        final expectedDates = [
          startDate,
          startDate.copyWith(day: startDate.day + 1),
          startDate.copyWith(day: startDate.day + 2),
        ];
        final dates = range.dates(inclusive: false);
        expect(const ListEquality<DateTime>().equals(dates, expectedDates), isTrue);
      });
    }
  });

  group('dateTimeRangeOnDate()', () {
    test('Date outside range', () {
      final range = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 31));
      final date = DateTime(2024, 2, 1);
      expect(range.dateTimeRangeOnDate(date), isNull);
    });

    test('Start and end on same day', () {
      final range = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 1));
      final date = DateTime(2024, 1, 1);
      expect(range.dateTimeRangeOnDate(date), range); // Should return the same range
    });

    test('Date is start date', () {
      final range = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 31));
      final date = DateTime(2024, 1, 1);
      final expectedRange = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 2));
      expect(range.dateTimeRangeOnDate(date), expectedRange);
    });

    test('Date is end date', () {
      final range = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 31));
      final date = DateTime(2024, 1, 31);
      final expectedRange = DateTimeRange(start: DateTime(2024, 1, 31, 0, 0, 0, 0), end: DateTime(2024, 1, 31));
      expect(range.dateTimeRangeOnDate(date), expectedRange);
    });

    test('Date is within range', () {
      final range = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 31));
      final date = DateTime(2024, 1, 15);
      final expectedRange = DateTimeRange(start: DateTime(2024, 1, 15), end: DateTime(2024, 1, 16));
      expect(range.dateTimeRangeOnDate(date), expectedRange);
    });

    test('Date is within range, different times', () {
      final range = DateTimeRange(start: DateTime(2024, 1, 1, 10), end: DateTime(2024, 1, 31, 15));
      final date = DateTime(2024, 1, 15, 5);
      final expectedRange = DateTimeRange(start: DateTime(2024, 1, 15), end: DateTime(2024, 1, 16));
      expect(range.dateTimeRangeOnDate(date), expectedRange);
    });
  });

  group('overlaps()', () {
    test('No overlap - before', () {
      final range1 = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 10));
      final range2 = DateTimeRange(start: DateTime(2024, 1, 11), end: DateTime(2024, 1, 20));
      expect(range1.overlaps(range2), isFalse);
      expect(range2.overlaps(range1), isFalse);
    });

    test('No overlap - before (touching)', () {
      final range1 = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 10));
      final range2 = DateTimeRange(start: DateTime(2024, 1, 10), end: DateTime(2024, 1, 20));
      expect(range1.overlaps(range2), isFalse);
      expect(range2.overlaps(range1), isFalse);
      expect(range1.overlaps(range2, touching: true), isTrue);
      expect(range2.overlaps(range1, touching: true), isTrue);
    });

    test('No overlap - after', () {
      final range1 = DateTimeRange(start: DateTime(2024, 1, 11), end: DateTime(2024, 1, 20));
      final range2 = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 10));
      expect(range1.overlaps(range2), isFalse);
      expect(range2.overlaps(range1), isFalse);
    });

    test('No overlap - after (touching)', () {
      final range1 = DateTimeRange(start: DateTime(2024, 1, 10), end: DateTime(2024, 1, 20));
      final range2 = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 10));
      expect(range1.overlaps(range2), isFalse);
      expect(range2.overlaps(range1), isFalse);
      expect(range1.overlaps(range2, touching: true), isTrue);
      expect(range2.overlaps(range1, touching: true), isTrue);
    });

    test('Overlap', () {
      final range1 = DateTimeRange(start: DateTime(2024, 1, 5), end: DateTime(2024, 1, 15));
      final range2 = DateTimeRange(start: DateTime(2024, 1, 10), end: DateTime(2024, 1, 20));
      expect(range1.overlaps(range2), isTrue);
      expect(range2.overlaps(range1), isTrue);
    });

    test('Overlap - range1 contains range2', () {
      final range1 = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 31));
      final range2 = DateTimeRange(start: DateTime(2024, 1, 5), end: DateTime(2024, 1, 10));
      expect(range1.overlaps(range2), isTrue);
      expect(range2.overlaps(range1), isTrue);
    });

    test('Overlap - range2 contains range1', () {
      final range1 = DateTimeRange(start: DateTime(2024, 1, 5), end: DateTime(2024, 1, 10));
      final range2 = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 31));
      expect(range1.overlaps(range2), isTrue);
      expect(range2.overlaps(range1), isTrue);
    });

    test('Overlap - same end different start', () {
      final range1 = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 10));
      final range2 = DateTimeRange(start: DateTime(2024, 1, 2), end: DateTime(2024, 1, 10));
      expect(range1.overlaps(range2), isTrue);
      expect(range2.overlaps(range1), isTrue);
    });

    test('Overlap - range2 contains range1', () {
      final range1 = DateTimeRange(start: DateTime(2024, 1, 5), end: DateTime(2024, 1, 10));
      final range2 = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 31));
      expect(range1.overlaps(range2), isTrue);
      expect(range2.overlaps(range1), isTrue);
    });

    test('Same range', () {
      final range1 = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 10));
      final range2 = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 10));
      expect(range1.overlaps(range2), isTrue); // A range always overlaps itself
    });

    test('One range is zero duration', () {
      final range1 = DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 10));
      final range2 = DateTimeRange(start: DateTime(2024, 1, 5), end: DateTime(2024, 1, 5));
      expect(range1.overlaps(range2), isTrue);
      expect(range2.overlaps(range1), isTrue);
    });
  });
}

void dateTimeTests(Iterable<DateTime> testDates) {
  group('isToday', () {
    test('Is today', () {
      final now = DateTime.now();
      expect(now.isToday, isTrue);
    });

    test('Is not today', () {
      final pastDate = DateTime(2023, 1, 1);
      expect(pastDate.isToday, isFalse);
    });

    test('Is today - UTC', () {
      final now = DateTime.now().toUtc();
      expect(now.isToday, isTrue);
    });

    test('Is not today - UTC', () {
      final pastDate = DateTime(2023, 1, 1).toUtc();
      expect(pastDate.isToday, isFalse);
    });
  });

  group('startOfDay', () {
    test('Start of day - local time', () {
      final date = DateTime(2024, 1, 15, 10, 30);
      final start = date.startOfDay;
      expect(start.year, 2024);
      expect(start.month, 1);
      expect(start.day, 15);
      expect(start.hour, 0);
      expect(start.minute, 0);
      expect(start.second, 0);
      expect(start.millisecond, 0);
      expect(start.microsecond, 0);
      expect(start.isUtc, date.isUtc);
      expect(start.timeZoneOffset, date.timeZoneOffset);
    });

    test('Start of day - UTC', () {
      final date = DateTime.utc(2024, 1, 15, 10, 30);
      final start = date.startOfDay;
      expect(start.year, 2024);
      expect(start.month, 1);
      expect(start.day, 15);
      expect(start.hour, 0);
      expect(start.minute, 0);
      expect(start.second, 0);
      expect(start.millisecond, 0);
      expect(start.microsecond, 0);
      expect(start.isUtc, isTrue);
      expect(start.timeZoneOffset, Duration.zero);
    });

    for (final date in testDates) {
      test('Start of day - $date', () {
        final start = date.startOfDay;
        expect(start.year, date.year);
        expect(start.month, date.month);
        expect(start.day, date.day);
        expect(start.hour, 0);
        expect(start.minute, 0);
        expect(start.second, 0);
        expect(start.millisecond, 0);
        expect(start.microsecond, 0);
        expect(start.isUtc, date.isUtc);
        expect(start.timeZoneOffset, date.timeZoneOffset);
      });
    }
  });

  group('endOfDay', () {
    test('Start of day - local time', () {
      final date = DateTime(2024, 1, 15, 10, 30);
      final start = date.startOfDay;
      expect(start.year, 2024);
      expect(start.month, 1);
      expect(start.day, 15);
      expect(start.hour, 0);
      expect(start.minute, 0);
      expect(start.second, 0);
      expect(start.millisecond, 0);
      expect(start.microsecond, 0);
      expect(start.isUtc, date.isUtc);
      expect(start.timeZoneOffset, date.timeZoneOffset);
    });

    test('End of day - UTC', () {
      final date = DateTime.utc(2024, 1, 15, 10, 30);
      final start = date.startOfDay;
      expect(start.year, 2024);
      expect(start.month, 1);
      expect(start.day, 15);
      expect(start.hour, 0);
      expect(start.minute, 0);
      expect(start.second, 0);
      expect(start.millisecond, 0);
      expect(start.microsecond, 0);
      expect(start.isUtc, isTrue);
      expect(start.timeZoneOffset, Duration.zero);
    });
  });

  group('dayRange', () {
    test('Day range - local time', () {
      final date = DateTime(2024, 1, 15, 10, 30);
      final range = date.dayRange;
      expect(range.start.year, 2024);
      expect(range.start.month, 1);
      expect(range.start.day, 15);
      expect(range.start.hour, 0);
      expect(range.start.minute, 0);
      expect(range.start.second, 0);
      expect(range.start.millisecond, 0);
      expect(range.start.microsecond, 0);
      expect(range.start.isUtc, date.isUtc);
      expect(range.start.timeZoneOffset, date.timeZoneOffset);

      expect(range.end.year, 2024);
      expect(range.end.month, 1);
      expect(range.end.day, 16); // Next day
      expect(range.end.hour, 0);
      expect(range.end.minute, 0);
      expect(range.end.second, 0);
      expect(range.end.millisecond, 0);
      expect(range.end.microsecond, 0);
      expect(range.end.isUtc, date.isUtc);
      expect(range.end.timeZoneOffset, date.timeZoneOffset);
    });

    test('Day range - UTC', () {
      final date = DateTime(2024, 1, 15, 10, 30).toUtc();
      final range = date.dayRange;
      expect(range.start.year, 2024);
      expect(range.start.month, 1);
      expect(range.start.day, 15);
      expect(range.start.hour, 0);
      expect(range.start.minute, 0);
      expect(range.start.second, 0);
      expect(range.start.millisecond, 0);
      expect(range.start.microsecond, 0);
      expect(range.start.isUtc, isTrue);
      expect(range.start.timeZoneOffset, Duration.zero);

      expect(range.end.year, 2024);
      expect(range.end.month, 1);
      expect(range.end.day, 16); // Next day
      expect(range.end.hour, 0);
      expect(range.end.minute, 0);
      expect(range.end.second, 0);
      expect(range.end.millisecond, 0);
      expect(range.end.microsecond, 0);
      expect(range.end.isUtc, isTrue);
      expect(range.end.timeZoneOffset, Duration.zero);
    });
  });

  group('monthRange', () {});

  test('startOfDay', () {
    final date = DateTime(2024, 1, 1, 5);
    final startOfDay = date.startOfDay;
    expect(startOfDay, DateTime(2024, 1, 1));
  });

  test('endOfDay', () {
    final date = DateTime(2024, 1, 1, 5);
    final startOfDay = date.endOfDay;
    expect(startOfDay, DateTime(2024, 1, 2));
  });

  test('dayRange', () {
    final date = DateTime(2024, 1, 1);
    final dayRange = date.dayRange;
    expect(
      dayRange,
      DateTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 1, 2),
      ),
    );
  });

  test('addDays', () {
    final date = DateTime(2024, 1, 1);
    final added = date.addDays(10);
    expect(
      added,
      DateTime(2024, 1, 11),
    );
  });

  test('subtractDays', () {
    final date = DateTime(2024, 1, 1);
    final added = date.subtractDays(10);
    expect(
      added,
      DateTime(2023, 12, 22),
    );
  });

  test('startOfWeekWithOffset', () {
    final date = DateTime(2024, 1, 1);
    for (var i = 1; i <= 7; i++) {
      final startOfWeek = date.startOfWeekWithOffset(i);
      expect(startOfWeek.weekday, i);
    }
  });

  test('endOfWeekWithOffset', () {
    final date = DateTime(2024, 1, 1);
    for (var i = 1; i <= 7; i++) {
      final startOfWeek = date.endOfWeekWithOffset(i);
      expect(startOfWeek.weekday, i);
    }
  });

  test('weekRangeWithOffset', () {
    final date = DateTime(2024, 1, 1);
    for (var i = 1; i <= 7; i++) {
      final week = date.weekRangeWithOffset(i);
      expect(week.dayDifference, 7);

      final dateIsAfterStart = (date.isAfter(week.start) || date.isAtSameMomentAs(week.start));

      final dateIsBeforeEnd = (date.isAfter(week.start) || date.isAtSameMomentAs(week.start));

      final dateIsDuringWeek = dateIsAfterStart && dateIsBeforeEnd;

      expect(dateIsDuringWeek, true);
    }
  });

  /// TODO: add more tests.
}
