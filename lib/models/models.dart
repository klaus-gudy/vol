/// Domain model for Braidflow.
///
/// Mirrors the four tables in the design's data-model panel:
/// `salon_staff`, `customers`, `shifts`, `services`.
///
/// Deliberately absent: any "availability" field. A braider's status is
/// derived from (clocked in?) + (holds an in-progress customer?), which is
/// what keeps the supervisor and braider views in sync.
library;

enum Role { owner, supervisor, braider }

enum CustomerStatus { waiting, inProgress, completed }

/// A login. The prototype has no backend, so accounts live in memory and the
/// password is compared as plain text — fine for a demo, never for production.
class Account {
  const Account({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.braiderId,
  });

  final String name;
  final String email;
  final String password;
  final Role role;

  /// Set for braiders: which chair's job screen they land on.
  final int? braiderId;
}

/// `services` — name → average minutes. Drives wait estimates and the
/// progress bars, since long styles make a fixed slot length meaningless.
const Map<String, int> kServiceDurations = {
  'Knotless box braids': 300,
  'Cornrows': 120,
  'Feed-in braids': 150,
  'Fulani braids': 210,
  'Twists': 180,
  'Micro braids': 420,
  'Retouch': 60,
};

List<String> get kStyles => kServiceDurations.keys.toList();

int durationFor(String style) => kServiceDurations[style] ?? 180;

/// `salon_staff` + today's row from `shifts`, flattened.
class Braider {
  Braider({
    required this.id,
    required this.name,
    required this.skills,
    required this.on,
    required this.clockedInAt,
    required this.idleSince,
  });

  final int id;
  final String name;
  final String skills;

  /// Clocked in for today's shift. Clocking out removes her from allocation.
  final bool on;

  /// `shifts.clock_in` for today, null when off shift.
  final DateTime? clockedInAt;

  /// When she last became free — the sort key for longest-idle allocation.
  final DateTime idleSince;

  Braider copyWith({
    String? name,
    String? skills,
    bool? on,
    DateTime? clockedInAt,
    bool clearClockedInAt = false,
    DateTime? idleSince,
  }) {
    return Braider(
      id: id,
      name: name ?? this.name,
      skills: skills ?? this.skills,
      on: on ?? this.on,
      clockedInAt: clearClockedInAt ? null : (clockedInAt ?? this.clockedInAt),
      idleSince: idleSince ?? this.idleSince,
    );
  }

  String get firstName => name.split(' ').first;

  String get initials => name
      .split(' ')
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0])
      .join();
}

/// `customers` — one row per walk-in, carrying the whole state machine.
class Customer {
  Customer({
    required this.id,
    required this.no,
    required this.name,
    required this.phone,
    required this.style,
    required this.status,
    required this.braiderId,
    required this.checkedInAt,
    required this.startedAt,
    required this.completedAt,
  });

  final int id;

  /// `queue_no`, zero-padded to three digits.
  final String no;
  final String name;
  final String phone;
  final String style;
  final CustomerStatus status;
  final int? braiderId;
  final DateTime checkedInAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  Customer copyWith({
    CustomerStatus? status,
    int? braiderId,
    bool clearBraider = false,
    DateTime? startedAt,
    bool clearStartedAt = false,
    DateTime? completedAt,
  }) {
    return Customer(
      id: id,
      no: no,
      name: name,
      phone: phone,
      style: style,
      status: status ?? this.status,
      braiderId: clearBraider ? null : (braiderId ?? this.braiderId),
      checkedInAt: checkedInAt,
      startedAt: clearStartedAt ? null : (startedAt ?? this.startedAt),
      completedAt: completedAt ?? this.completedAt,
    );
  }

  int get durationMinutes => durationFor(style);
}
