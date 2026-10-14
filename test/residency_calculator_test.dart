import 'package:flutter_test/flutter_test.dart';

import 'package:hkhub_app/modules/residency/data/residency_calculator.dart';
import 'package:hkhub_app/modules/residency/data/residency_models.dart';

void main() {
  group('calendar arithmetic', () {
    test('addMonths clamps to the target month length', () {
      expect(addMonths(DateTime(2026, 8, 31), 1), DateTime(2026, 9, 30));
      expect(addMonths(DateTime(2026, 1, 15), 13), DateTime(2027, 2, 15));
      expect(addMonths(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 28));
    });

    test('addYears handles leap days', () {
      expect(addYears(DateTime(2024, 2, 29), 1), DateTime(2025, 2, 28));
      expect(addYears(DateTime(2026, 3, 15), 7), DateTime(2033, 3, 15));
    });

    test('calendarElapsed reports whole calendar units', () {
      final elapsed = calendarElapsed(DateTime(2026, 3, 15), DateTime(2029, 6, 20));
      expect(elapsed.years, 3);
      expect(elapsed.months, 3);
      expect(elapsed.days, 5);
    });

    test('hongKongToday applies the UTC+8 offset', () {
      expect(hongKongToday(DateTime.utc(2026, 1, 1, 20, 0)), DateTime(2026, 1, 2));
      expect(hongKongToday(DateTime.utc(2026, 1, 1, 3, 0)), DateTime(2026, 1, 1));
    });
  });

  group('progress', () {
    test('starts at zero on the start date', () {
      final progress = computeResidencyProgress(
        startDate: DateTime(2026, 1, 1),
        today: DateTime(2026, 1, 1),
      );
      expect(progress.elapsedDays, 0);
      expect(progress.elapsedYears, 0);
      expect(progress.elapsedMonths, 0);
      expect(progress.fraction, 0);
      expect(progress.reached, isFalse);
      expect(progress.remainingDays,
          DateTime(2033, 1, 1).difference(DateTime(2026, 1, 1)).inDays);
    });

    test('counts whole days and remaining days without overlap', () {
      final progress = computeResidencyProgress(
        startDate: DateTime(2026, 1, 1),
        today: DateTime(2026, 1, 11),
      );
      expect(progress.elapsedDays, 10);
      expect(progress.remainingDays,
          DateTime(2033, 1, 1).difference(DateTime(2026, 1, 11)).inDays);
      expect(progress.elapsedDays + progress.remainingDays,
          DateTime(2033, 1, 1).difference(DateTime(2026, 1, 1)).inDays);
    });

    test('reaches full progress at exactly seven years', () {
      final progress = computeResidencyProgress(
        startDate: DateTime(2026, 1, 1),
        today: DateTime(2033, 1, 1),
      );
      expect(progress.reached, isTrue);
      expect(progress.remainingDays, 0);
      expect(progress.fraction, 1);
      expect(progress.elapsedYears, 7);
    });

    test('stays clamped after seven years', () {
      final progress = computeResidencyProgress(
        startDate: DateTime(2026, 1, 1),
        today: DateTime(2035, 5, 5),
      );
      expect(progress.reached, isTrue);
      expect(progress.fraction, 1);
      expect(progress.remainingDays, 0);
    });
  });

  group('milestones', () {
    final nodes = buildMilestones(DateTime(2026, 1, 1));

    test('has 77 month nodes and 7 year nodes', () {
      expect(nodes.length, 84);
      expect(nodes.where((node) => node.kind == MilestoneKind.year).length, 7);
      expect(nodes.where((node) => node.kind == MilestoneKind.month).length, 77);
    });

    test('has no duplicate dates', () {
      final dates = nodes.map((node) => node.date).toSet();
      expect(dates.length, nodes.length);
    });

    test('twelve-month boundaries are year nodes', () {
      final firstYear = nodes.firstWhere((node) => node.kind == MilestoneKind.year);
      expect(firstYear.index, 1);
      expect(firstYear.date, DateTime(2027, 1, 1));
      expect(nodes.any((node) => node.kind == MilestoneKind.month && node.index == 12), isFalse);
    });

    test('window keeps achieved nodes and the single next node', () {
      final window = buildMilestoneWindow(nodes, DateTime(2026, 3, 15));
      expect(window.achievedCount, 2);
      expect(window.next?.date, DateTime(2026, 4, 1));
      expect(window.next?.kind, MilestoneKind.month);
      expect(window.isComplete, isFalse);
    });

    test('window prefers the year node on the boundary date', () {
      final window = buildMilestoneWindow(nodes, DateTime(2027, 1, 1));
      expect(window.achievedCount, 12);
      expect(window.achieved.last.kind, MilestoneKind.year);
      expect(window.achieved.last.index, 1);
      expect(window.next?.date, DateTime(2027, 2, 1));
    });

    test('window is complete after the final year node', () {
      final window = buildMilestoneWindow(nodes, DateTime(2033, 1, 1));
      expect(window.achievedCount, 84);
      expect(window.next, isNull);
      expect(window.isComplete, isTrue);
    });

    test('recent returns newest-first, capped', () {
      final window = buildMilestoneWindow(nodes, DateTime(2028, 1, 1));
      final recent = window.recent(3);
      expect(recent.length, 3);
      expect(recent.first.date.isAfter(recent.last.date), isTrue);
    });
  });

  group('renewal status', () {
    RenewalLevel level(int days) => renewalStatus(
      expiryDate: DateTime(2026, 1, 1).add(Duration(days: days)),
      today: DateTime(2026, 1, 1),
    ).level;

    test('escalates at 90/60/30 days', () {
      expect(level(91), RenewalLevel.none);
      expect(level(90), RenewalLevel.upcoming);
      expect(level(61), RenewalLevel.upcoming);
      expect(level(60), RenewalLevel.soon);
      expect(level(31), RenewalLevel.soon);
      expect(level(30), RenewalLevel.urgent);
      expect(level(0), RenewalLevel.urgent);
    });

    test('reports negative days once expired', () {
      final status = renewalStatus(
        expiryDate: DateTime(2026, 1, 1),
        today: DateTime(2026, 1, 5),
      );
      expect(status.daysRemaining, -4);
      expect(status.level, RenewalLevel.urgent);
    });
  });

  group('profile sanitisation', () {
    test('drops malformed dates and unknown visa keys', () {
      final profile = ResidencyProfile.fromJson({
        'start_date': '2026-02-30',
        'visa_type': 'not-a-scheme',
        'visa_expiry': '2026-2-3',
        'seen_milestones': 999,
        'departures': [
          {'start': '2026-01-01', 'end': '2025-12-31'},
          {'start': 'bad', 'end': null},
          {'start': '2026-03-01', 'end': null},
        ],
      });
      expect(profile.startDate, isNull);
      expect(profile.visaType, isNull);
      expect(profile.visaExpiryDate, isNull);
      expect(profile.seenMilestoneCount, 0);
      expect(profile.departures.length, 1);
      expect(profile.departures.single.startDate, '2026-03-01');
    });

    test('accepts a well-formed profile', () {
      final profile = ResidencyProfile.fromJson({
        'start_date': '2026-01-01',
        'visa_type': 'ttps',
        'visa_expiry': '2027-01-01',
        'seen_milestones': 2,
        'departures': [
          {'start': '2026-05-01', 'end': '2026-05-20'},
        ],
      });
      expect(profile.isConfigured, isTrue);
      expect(profile.visaType, 'ttps');
      expect(profile.seenMilestoneCount, 2);
      expect(profile.departures.length, 1);
    });

    test('cleanIsoDate rejects loose formats', () {
      expect(cleanIsoDate('2026-01-01'), '2026-01-01');
      expect(cleanIsoDate('2026-1-1'), isNull);
      expect(cleanIsoDate('2026/01/01'), isNull);
      expect(cleanIsoDate(20260101), isNull);
    });
  });

  group('departures', () {
    test('counts an ongoing mark up to today', () {
      const mark = DepartureMark(startDate: '2026-01-01');
      expect(departureDurationDays(mark, DateTime(2026, 1, 31)), 30);
    });

    test('uses the end date when present', () {
      const mark = DepartureMark(startDate: '2026-01-01', endDate: '2026-01-11');
      expect(departureDurationDays(mark, DateTime(2026, 6, 1)), 10);
    });

    test('flags only long departures for the advisory', () {
      const short = DepartureMark(startDate: '2026-01-01', endDate: '2026-02-01');
      const long = DepartureMark(startDate: '2026-01-01', endDate: '2026-09-01');
      expect(hasLongDeparture([short], DateTime(2026, 3, 1)), isFalse);
      expect(hasLongDeparture([long], DateTime(2026, 12, 1)), isTrue);
      expect(hasLongDeparture([short, long], DateTime(2026, 12, 1)), isTrue);
      expect(hasLongDeparture(const [], DateTime(2026, 12, 1)), isFalse);
    });
  });
}
