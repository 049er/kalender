import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalender/src/extensions.dart';

void main() {
  group(
    'DateTimeExtension Tests',
    () {
      testStartOfDay();
      testEndOfDay();
      testDayRange();
      testAddDays();
      testSubtractDays();
      testStartOfWeekWithOffset();
      testEndOfWeekWithOffset();
      testWeekRangeWithOffset();
    },
    skip: true,
  );

  group(
    'DateTimeRangeExtension Tests',
    () {
      testDayDifference();
      testMonthDifference();
      testRescheduleDateTime();
      testDatesSpanned();
    },
    skip: true,
  );
}

void testStartOfDay() {
  test('startOfDay', () {
    final date = DateTime(2024, 1, 1, 5);
    final startOfDay = date.startOfDay;
    expect(startOfDay, DateTime(2024, 1, 1));
  });
}

void testEndOfDay() {
  test('endOfDay', () {
    final date = DateTime(2024, 1, 1, 5);
    final startOfDay = date.endOfDay;
    expect(startOfDay, DateTime(2024, 1, 2));
  });
}

void testDayRange() {
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
}

void testAddDays() {
  test('addDays', () {
    final date = DateTime(2024, 1, 1);
    final added = date.addDays(10);
    expect(
      added,
      DateTime(2024, 1, 11),
    );
  });
}

void testSubtractDays() {
  test('subtractDays', () {
    final date = DateTime(2024, 1, 1);
    final added = date.subtractDays(10);
    expect(
      added,
      DateTime(2023, 12, 22),
    );
  });
}

void testStartOfWeekWithOffset() {
  test('startOfWeekWithOffset', () {
    final date = DateTime(2024, 1, 1);
    for (var i = 1; i <= 7; i++) {
      final startOfWeek = date.startOfWeekWithOffset(i);
      expect(startOfWeek.weekday, i);
    }
  });
}

void testEndOfWeekWithOffset() {
  test('endOfWeekWithOffset', () {
    final date = DateTime(2024, 1, 1);
    for (var i = 1; i <= 7; i++) {
      final startOfWeek = date.endOfWeekWithOffset(i);
      expect(startOfWeek.weekday, i);
    }
  });
}

void testWeekRangeWithOffset() {
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
}

void testDayDifference() {
  group('DayDifference Tests', () {
    final start = DateTime(2024, 1, 1);

    for (var day = 0; day < 365; day++) {
      for (var numberOfDays = 1; numberOfDays <= 2; numberOfDays++) {
        test('dayDifference', () {
          final today = start.add(Duration(days: day));
          final tomorrow = today.add(Duration(days: numberOfDays));
          final range = DateTimeRange(start: today, end: tomorrow);
          final difference = range.dayDifference;
          expect(difference, numberOfDays);
        });
      }
    }

    final edgeCases = {
      DateTimeRange(
        start: start,
        end: start,
      ): 0,
      DateTimeRange(
        start: start,
        end: start.add(const Duration(hours: 5)),
      ): 0,
      DateTimeRange(
        start: start,
        end: start.add(const Duration(days: 1)),
      ): 1,
      DateTimeRange(
        start: start,
        end: start.add(const Duration(days: 1, hours: 5)),
      ): 1,
    };

    for (final edgeCase in edgeCases.entries) {
      test('dayDifference', () {
        expect(edgeCase.key.dayDifference, edgeCase.value);
      });
    }
  });
}

void testMonthDifference() {
  group('MonthDifference Tests', () {
    final start = DateTime(2024, 1, 1);

    for (var i = 1; i < 13; i++) {
      test('monthDifference', () {
        final end = DateTime(start.year, start.month + i);
        final range = DateTimeRange(start: start, end: end);
        final difference = range.monthDifference;

        expect(difference, i);
      });
    }
  });
}

void testRescheduleDateTime() {
  // group('RescheduleDateTime Tests', () {
  //   final start = DateTime(2024, 1, 1);
  //   for (var i = -7; i <= 7; i++) {
  //     test('rescheduleDateTime', () {
  //       final end = DateTime(start.year, start.month, start.day + 1);
  //       final range = DateTimeRange(start: start, end: end);
  //       final duration = Duration(days: i);
  //       final rescheduledRange = range.rescheduleDateTime(duration);
  //       expect(rescheduledRange.start, start.add(duration));
  //       expect(rescheduledRange.end, end.add(duration));
  //     });
  //   }
  // });
}

void testDatesSpanned() {
  group('DatesSpanned Tests', () {
    final start = DateTime(2024, 1, 1);

    final rangesToTest = {
      DateTimeRange(
        start: start,
        end: start,
      ): 1,
      DateTimeRange(
        start: start,
        end: start.add(const Duration(days: 1)),
      ): 1,
      DateTimeRange(
        start: start,
        end: start.add(const Duration(days: 2)),
      ): 2,
      DateTimeRange(
        start: start,
        end: start.add(const Duration(days: 3)),
      ): 3,
      DateTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 1, 1, 2),
      ): 1,
      DateTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 1, 1, 12),
      ): 1,
      DateTimeRange(
        start: DateTime(2024, 1, 1, 12),
        end: DateTime(2024, 1, 1, 12),
      ): 1,
      DateTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 1, 2),
      ): 1,
      DateTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 1, 2, 6),
      ): 2,
      DateTimeRange(
        start: DateTime(2024, 1, 1, 7),
        end: DateTime(2024, 1, 2, 6),
      ): 2,
      DateTimeRange(
        start: DateTime(2024, 1, 1, 23),
        end: DateTime(2024, 1, 2, 1),
      ): 2,
      DateTimeRange(
        start: DateTime(2024, 1, 1, 23),
        end: DateTime(2024, 1, 3, 1),
      ): 3,
    };

    for (final entry in rangesToTest.entries) {
      final range = entry.key;

      test('datesSpanned', () {
        final dates = range.days;
        expect(
          dates.length,
          entry.value,
        );
      });
    }
  });
}
