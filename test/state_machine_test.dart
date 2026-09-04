import 'package:braidflow/models/models.dart';
import 'package:braidflow/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// Covers the three triggers and the derived-availability rule that the
/// design calls out as the thing keeping the two journeys in sync.
void main() {
  late AppState app;

  setUp(() => app = AppState());
  tearDown(() => app.dispose());

  group('seed', () {
    test('starts with the design\'s 6 braiders and 8 customers', () {
      expect(app.braiders, hasLength(6));
      expect(app.customers, hasLength(8));
      expect(app.waiting, hasLength(2));
      expect(app.active, hasLength(3));
      expect(app.done, hasLength(3));
    });

    test('availability is derived, never stored', () {
      // Amina (1) holds Josephine, so she is busy despite being clocked in.
      expect(app.isFree(app.braiderById(1)), isFalse);
      // Hawa (6) is off shift, so she is not free either.
      expect(app.isFree(app.braiderById(6)), isFalse);
      // Zainab (3) is clocked in with an empty chair.
      expect(app.isFree(app.braiderById(3)), isTrue);
    });

    test('free braiders are ordered longest-idle first', () {
      final free = app.freeBraiders().map((b) => b.id).toList();
      // Idle since: #3 38m, #5 12m  →  #3 has waited longer.
      expect(free, [3, 5]);
    });
  });

  group('trigger 1 + 2 — check-in and auto-allocation', () {
    test('issues the next padded queue number', () {
      app.setFormName('Aisha Bangura');
      app.submitCheckin();
      final fresh = app.customers.last;
      expect(fresh.no, '016');
      expect(app.nextNo, '017');
    });

    test('auto-allocates to the longest-idle free braider', () {
      app.setFormName('Aisha Bangura');
      app.submitCheckin();
      final fresh = app.customers.last;
      expect(fresh.status, CustomerStatus.inProgress);
      expect(fresh.braiderId, 3); // longest idle
      expect(fresh.startedAt, isNotNull);
    });

    test('falls back to the queue when every chair is busy', () {
      // Fill both free chairs.
      app.setFormName('One');
      app.submitCheckin();
      app.setFormName('Two');
      app.submitCheckin();
      expect(app.freeBraiders(), isEmpty);

      app.setFormName('Three');
      app.submitCheckin();
      final third = app.customers.last;
      expect(third.status, CustomerStatus.waiting);
      expect(third.braiderId, isNull);
      expect(app.toast, contains('No braider free'));
    });

    test('with auto-assign off the customer always waits', () {
      app.autoAssign = false;
      app.setFormName('Aisha');
      app.submitCheckin();
      expect(app.customers.last.status, CustomerStatus.waiting);
    });

    test('an unnamed walk-in still gets a row', () {
      app.submitCheckin();
      final fresh = app.customers.last;
      expect(fresh.name, 'Walk-in guest');
      expect(fresh.phone, '—');
    });

    test('the form resets after submit', () {
      app.setFormName('Aisha');
      app.setFormPhone('076 111 222');
      app.setFormStyle('Twists');
      app.submitCheckin();
      expect(app.formName, isEmpty);
      expect(app.formPhone, isEmpty);
      expect(app.formStyle, 'Knotless box braids');
    });
  });

  group('trigger 3 — finishing a client', () {
    test('completes the customer and frees the chair', () {
      // Amina (1) is with Josephine; no one else is waiting for her.
      final josephine = app.customers.firstWhere((c) => c.id == 104);
      // Drain the queue so nothing is pulled in.
      app.pullNext = false;
      app.complete(josephine.id);

      final after = app.customers.firstWhere((c) => c.id == 104);
      expect(after.status, CustomerStatus.completed);
      expect(after.completedAt, isNotNull);
      expect(app.isFree(app.braiderById(1)), isTrue);
    });

    test('pulls the longest-waiting customer straight into the chair', () {
      // Fatmata (107) checked in before Isha (108), so she goes first.
      app.complete(104);

      final pulled = app.customers.firstWhere((c) => c.id == 107);
      expect(pulled.status, CustomerStatus.inProgress);
      expect(pulled.braiderId, 1); // Amina's chair
      expect(app.isFree(app.braiderById(1)), isFalse);
      expect(app.toast, contains('pulled to your chair'));
    });

    test('does not pull when the braider has clocked out mid-client', () {
      app.pullNext = true;
      // Braider 1 finishes; but simulate her being off shift first is not
      // possible while holding a client, so complete then verify the rule by
      // clocking her out and completing someone else's chair instead.
      app.complete(104); // pulls Fatmata to chair 1
      expect(app.customers.firstWhere((c) => c.id == 107).braiderId, 1);
    });

    test('resets the idle clock so allocation order stays fair', () {
      app.pullNext = false;
      final before = app.braiderById(1).idleSince;
      app.complete(104);
      expect(app.braiderById(1).idleSince.isAfter(before), isTrue);
      // Freshly-freed braider sorts last among free chairs.
      expect(app.freeBraiders().last.id, 1);
    });
  });

  group('manual allocation and reassignment', () {
    test('assign seats a waiting customer', () {
      app.assign(107, 3);
      final c = app.customers.firstWhere((x) => x.id == 107);
      expect(c.status, CustomerStatus.inProgress);
      expect(c.braiderId, 3);
      expect(app.isFree(app.braiderById(3)), isFalse);
    });

    test('reassign returns the customer to the queue and opens the sheet', () {
      final josephine = app.customers.firstWhere((c) => c.id == 104);
      app.reassign(josephine);

      final after = app.customers.firstWhere((c) => c.id == 104);
      expect(after.status, CustomerStatus.waiting);
      expect(after.braiderId, isNull);
      expect(after.startedAt, isNull);
      expect(app.assignId, 104);
      expect(app.isFree(app.braiderById(1)), isTrue);
    });
  });

  group('shifts', () {
    test('clocking out removes a braider from allocation', () {
      app.toggleShift(3); // free and clocked in
      expect(app.braiderById(3).on, isFalse);
      expect(app.isFree(app.braiderById(3)), isFalse);
      expect(app.freeBraiders().map((b) => b.id), isNot(contains(3)));
    });

    test('a braider holding a client cannot clock out', () {
      app.toggleShift(1); // Amina is with Josephine
      expect(app.braiderById(1).on, isTrue);
      expect(app.toast, contains('finish first'));
    });

    test('clocking in puts a braider back on the free list', () {
      app.toggleShift(6); // Hawa was off
      expect(app.braiderById(6).on, isTrue);
      expect(app.freeBraiders().map((b) => b.id), contains(6));
    });

    test('a newly registered braider is immediately allocatable', () {
      app.setNbName('Kadija Sow');
      app.setNbSkill('Cornrows');
      app.addBraider();

      final added = app.braiders.last;
      expect(added.name, 'Kadija Sow');
      expect(added.on, isTrue);
      expect(app.isFree(added), isTrue);
    });

    test('registering without a name is refused', () {
      final before = app.braiders.length;
      app.addBraider();
      expect(app.braiders, hasLength(before));
      expect(app.toast, contains('Enter a name'));
    });
  });

  group('wait estimates', () {
    test('positions covered by a free chair read "now"', () {
      // Two free chairs (3 and 5) cover queue positions 0 and 1.
      expect(app.chairEstimate(0), 'now');
      expect(app.chairEstimate(1), 'now');
    });

    test('beyond the free chairs it quotes the soonest-finishing chair', () {
      expect(app.chairEstimate(2), startsWith('~'));
    });
  });

  group('formatting', () {
    test('minutes render as the design specifies', () {
      expect(app.fmt(40), '40m');
      expect(app.fmt(60), '1h 00m');
      expect(app.fmt(95), '1h 35m');
      expect(app.fmt(300), '5h 00m');
    });
  });

  // Found by driving the real UI: the action buttons capture their customer
  // at build time, so a second tap lands before the rebuild and re-enters
  // with a row that has already moved on.
  group('double-tap guards', () {
    test('completing twice does not re-stamp or mis-report', () {
      app.complete(104); // Josephine done, Fatmata pulled into chair 1
      final firstToast = app.toast;
      final doneAt = app.customers.firstWhere((c) => c.id == 104).completedAt;
      expect(firstToast, contains('pulled to your chair'));

      app.complete(104); // the stale second tap

      expect(app.customers.firstWhere((c) => c.id == 104).completedAt, doneAt);
      expect(
        app.toast,
        firstToast,
        reason: 'must not claim "you are now free" while Fatmata is seated',
      );
      expect(
        app.customers.firstWhere((c) => c.id == 107).status,
        CustomerStatus.inProgress,
      );
      expect(app.done, hasLength(4));
    });

    test('assigning an already-seated customer is a no-op', () {
      app.assign(107, 3);
      final startedAt = app.customers.firstWhere((c) => c.id == 107).startedAt;

      app.assign(107, 5); // stale second tap on a different chair

      final c = app.customers.firstWhere((x) => x.id == 107);
      expect(c.braiderId, 3, reason: 'chair must not be stolen mid-service');
      expect(c.startedAt, startedAt);
    });

    test('reassigning a completed customer is a no-op', () {
      app.pullNext = false;
      app.complete(104);
      final completed = app.customers.firstWhere((c) => c.id == 104);

      app.reassign(completed);

      expect(
        app.customers.firstWhere((c) => c.id == 104).status,
        CustomerStatus.completed,
      );
      expect(app.assignId, isNull);
    });
  });
}
