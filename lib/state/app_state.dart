import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/models.dart';

/// The nine screens in the design's screen map.
enum BFScreen { queue, checkin, grid, staff, detail, job, next, me, owner }

/// Single source of truth for the whole prototype.
///
/// Everything the three roles see is derived from one customer status plus
/// "is this braider clocked in", exactly as the design specifies. There is no
/// separate availability state to drift out of sync.
class AppState extends ChangeNotifier {
  /// [ticking] drives the periodic re-render. Widget tests pass false and
  /// pump their own frames — a live periodic timer trips the test binding's
  /// "no pending timers" invariant.
  AppState({bool ticking = true}) {
    _seed();
    // The design re-renders every 20s so elapsed timers and wait estimates
    // stay honest without touching any data.
    if (ticking) {
      _ticker = Timer.periodic(
        const Duration(seconds: 20),
        (_) => notifyListeners(),
      );
    }
  }

  // ── allocation behaviour ───────────────────────────────────────────────
  // These were editor-exposed props on the design canvas (`autoAssign`,
  // `pullNext`, `showWaitEstimate`), all defaulting to true. They are kept as
  // runtime flags so the behaviour matches the design out of the box.
  bool autoAssign = true;
  bool pullNext = true;
  bool showWaitEstimate = true;

  // ── session ────────────────────────────────────────────────────────────
  Role? role;

  /// Display name of whoever is signed in, for the welcome splash.
  String? userName;

  /// True from sign-in until the welcome splash finishes playing.
  bool showSplash = false;
  BFScreen screen = BFScreen.queue;
  final List<BFScreen> _stack = [];
  int meId = 1;

  int? detailId;
  int? assignId;
  String? toast;
  bool showAdd = false;

  Timer? _ticker;
  Timer? _toastTimer;

  // ── check-in form ──────────────────────────────────────────────────────
  String formName = '';
  String formPhone = '';
  String formStyle = 'Knotless box braids';

  // ── new-braider form ───────────────────────────────────────────────────
  String nbName = '';
  String nbSkill = '';

  // ── data ───────────────────────────────────────────────────────────────
  late List<Braider> braiders;
  late List<Customer> customers;
  int seq = 15;

  /// Row ids come from a counter, not the clock. The design's JS used
  /// `Date.now()`, which collides when two walk-ins are checked in inside the
  /// same millisecond and lands them both in the same chair.
  int _nextCustomerId = 109;

  void _seed() {
    final t = DateTime.now();
    DateTime ago(double minutes) =>
        t.subtract(Duration(milliseconds: (minutes * 60000).round()));

    braiders = [
      Braider(
        id: 1,
        name: 'Amina Sesay',
        skills: 'Knotless · Cornrows',
        on: true,
        clockedInAt: ago(6.5 * 60),
        idleSince: ago(4 * 60),
      ),
      Braider(
        id: 2,
        name: 'Fatou Bah',
        skills: 'Twists · Feed-in',
        on: true,
        clockedInAt: ago(6 * 60),
        idleSince: ago(2 * 60),
      ),
      Braider(
        id: 3,
        name: 'Zainab Kamara',
        skills: 'Micro · Fulani',
        on: true,
        clockedInAt: ago(5 * 60),
        idleSince: ago(38),
      ),
      Braider(
        id: 4,
        name: 'Mariama Jalloh',
        skills: 'Cornrows · Kids',
        on: true,
        clockedInAt: ago(7 * 60),
        idleSince: ago(5 * 60),
      ),
      Braider(
        id: 5,
        name: 'Isatu Conteh',
        skills: 'Knotless · Twists',
        on: true,
        clockedInAt: ago(3 * 60),
        idleSince: ago(12),
      ),
      Braider(
        id: 6,
        name: 'Hawa Turay',
        skills: 'Feed-in · Retouch',
        on: false,
        clockedInAt: null,
        idleSince: t,
      ),
    ];

    customers = [
      Customer(
        id: 101,
        no: '008',
        name: 'Kadiatu Koroma',
        phone: '076 214 880',
        style: 'Cornrows',
        status: CustomerStatus.completed,
        braiderId: 4,
        checkedInAt: ago(7 * 60),
        startedAt: ago(6.8 * 60),
        completedAt: ago(4.9 * 60),
      ),
      Customer(
        id: 102,
        no: '009',
        name: 'Salamatu Jah',
        phone: '077 901 233',
        style: 'Retouch',
        status: CustomerStatus.completed,
        braiderId: 2,
        checkedInAt: ago(6 * 60),
        startedAt: ago(5.8 * 60),
        completedAt: ago(4.7 * 60),
      ),
      Customer(
        id: 103,
        no: '010',
        name: 'Rugiatu Sesay',
        phone: '088 445 100',
        style: 'Twists',
        status: CustomerStatus.completed,
        braiderId: 5,
        checkedInAt: ago(5 * 60),
        startedAt: ago(4.6 * 60),
        completedAt: ago(1.4 * 60),
      ),
      Customer(
        id: 104,
        no: '011',
        name: 'Josephine Cole',
        phone: '076 552 019',
        style: 'Knotless box braids',
        status: CustomerStatus.inProgress,
        braiderId: 1,
        checkedInAt: ago(4.4 * 60),
        startedAt: ago(4 * 60),
        completedAt: null,
      ),
      Customer(
        id: 105,
        no: '012',
        name: 'Adama Bangura',
        phone: '078 330 774',
        style: 'Fulani braids',
        status: CustomerStatus.inProgress,
        braiderId: 2,
        checkedInAt: ago(2.3 * 60),
        startedAt: ago(2 * 60),
        completedAt: null,
      ),
      Customer(
        id: 106,
        no: '013',
        name: 'Marie Kargbo',
        phone: '077 118 620',
        style: 'Micro braids',
        status: CustomerStatus.inProgress,
        braiderId: 4,
        checkedInAt: ago(5.2 * 60),
        startedAt: ago(5 * 60),
        completedAt: null,
      ),
      Customer(
        id: 107,
        no: '014',
        name: 'Fatmata Turay',
        phone: '076 700 415',
        style: 'Feed-in braids',
        status: CustomerStatus.waiting,
        braiderId: null,
        checkedInAt: ago(26),
        startedAt: null,
        completedAt: null,
      ),
      Customer(
        id: 108,
        no: '015',
        name: 'Isha Mansaray',
        phone: '077 620 331',
        style: 'Cornrows',
        status: CustomerStatus.waiting,
        braiderId: null,
        checkedInAt: ago(9),
        startedAt: null,
        completedAt: null,
      ),
    ];
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _toastTimer?.cancel();
    super.dispose();
  }

  // ── time helpers ───────────────────────────────────────────────────────

  /// Whole minutes since [ts], never negative.
  int minsSince(DateTime ts) {
    final ms = DateTime.now().difference(ts).inMilliseconds;
    return ms <= 0 ? 0 : (ms / 60000).round();
  }

  /// `95` → `1h 35m`, `40` → `40m`.
  String fmt(int m) =>
      m >= 60 ? '${m ~/ 60}h ${(m % 60).toString().padLeft(2, '0')}m' : '${m}m';

  /// Wall-clock like `2:05 PM`.
  String clock(DateTime ts) {
    final h24 = ts.hour;
    final h = h24 % 12 == 0 ? 12 : h24 % 12;
    final m = ts.minute.toString().padLeft(2, '0');
    return '$h:$m ${h24 < 12 ? 'AM' : 'PM'}';
  }

  // ── derived collections ────────────────────────────────────────────────

  List<Customer> get waiting =>
      customers.where((c) => c.status == CustomerStatus.waiting).toList()
        ..sort((a, b) => a.checkedInAt.compareTo(b.checkedInAt));

  List<Customer> get active =>
      customers.where((c) => c.status == CustomerStatus.inProgress).toList()
        ..sort((a, b) => a.startedAt!.compareTo(b.startedAt!));

  List<Customer> get done =>
      customers.where((c) => c.status == CustomerStatus.completed).toList()
        ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

  /// The in-progress customer occupying [braiderId]'s chair, if any.
  Customer? busyWith(int braiderId, [List<Customer>? source]) {
    for (final c in source ?? customers) {
      if (c.status == CustomerStatus.inProgress && c.braiderId == braiderId) {
        return c;
      }
    }
    return null;
  }

  /// Derived availability — never stored.
  bool isFree(Braider b, [List<Customer>? source]) =>
      b.on && busyWith(b.id, source) == null;

  /// Free braiders, longest-idle first. `[0]` is the auto-allocation pick.
  List<Braider> freeBraiders([List<Customer>? source]) =>
      braiders.where((b) => isFree(b, source)).toList()
        ..sort((a, b) => a.idleSince.compareTo(b.idleSince));

  Braider braiderById(int id) =>
      braiders.firstWhere((b) => b.id == id, orElse: () => braiders.first);

  String braiderName(int? id) {
    if (id == null) return '—';
    final match = braiders.where((b) => b.id == id);
    return match.isEmpty ? '—' : match.first.name;
  }

  Braider get me =>
      braiders.firstWhere((b) => b.id == meId, orElse: () => braiders.first);

  Customer? get meCurrent => busyWith(me.id);

  Customer? get detail {
    if (detailId == null) return null;
    final match = customers.where((c) => c.id == detailId);
    return match.isEmpty ? null : match.first;
  }

  Customer? get assignTarget {
    if (assignId == null) return null;
    final match = customers.where((c) => c.id == assignId);
    return match.isEmpty ? null : match.first;
  }

  /// Remaining minutes on each busy chair, soonest-free first.
  List<int> get remainingOnChairs {
    final r =
        active
            .map(
              (c) => (c.durationMinutes - minsSince(c.startedAt!))
                  .clamp(5, 1 << 30)
                  .toInt(),
            )
            .toList()
          ..sort();
    return r;
  }

  /// Wait estimate for the customer at queue position [i].
  String chairEstimate(int i) {
    final free = freeBraiders();
    if (free.length > i) return 'now';
    final rem = remainingOnChairs;
    final k = i - free.length;
    return k < rem.length ? '~${fmt(rem[k])}' : '~${fmt(240)}';
  }

  // ── navigation ─────────────────────────────────────────────────────────

  bool get canBack => _stack.isNotEmpty;

  void go(BFScreen s) {
    screen = s;
    _stack.clear();
    detailId = null;
    notifyListeners();
  }

  void push(BFScreen s, {int? detail}) {
    _stack.add(screen);
    screen = s;
    if (detail != null) detailId = detail;
    notifyListeners();
  }

  void back() {
    if (_stack.isEmpty) return;
    screen = _stack.removeLast();
    detailId = null;
    notifyListeners();
  }

  void signIn(Role r, BFScreen s, {int? asBraider, String? name}) {
    role = r;
    userName = name;
    showSplash = true;
    screen = s;
    _stack.clear();
    if (asBraider != null) meId = asBraider;
    notifyListeners();
  }

  // ── accounts ───────────────────────────────────────────────────────────
  final List<Account> accounts = [
    const Account(
      name: 'Sandra Musa',
      email: 'sandra@braidflow.app',
      password: 'owner1234',
      role: Role.owner,
    ),
    const Account(
      name: 'Grace Kanu',
      email: 'grace@braidflow.app',
      password: 'desk1234',
      role: Role.supervisor,
    ),
    const Account(
      name: 'Amina Sesay',
      email: 'amina@braidflow.app',
      password: 'chair1234',
      role: Role.braider,
      braiderId: 1,
    ),
  ];

  Account? _accountFor(String email) {
    final e = email.trim().toLowerCase();
    for (final a in accounts) {
      if (a.email == e) return a;
    }
    return null;
  }

  void _enter(Account a) {
    switch (a.role) {
      case Role.owner:
        signIn(Role.owner, BFScreen.owner, name: a.name);
      case Role.supervisor:
        signIn(Role.supervisor, BFScreen.queue, name: a.name);
      case Role.braider:
        signIn(
          Role.braider,
          BFScreen.job,
          asBraider: a.braiderId,
          name: a.name,
        );
    }
  }

  /// Returns an error message, or null on success. The message is the same
  /// for an unknown email and a wrong password so it can't be used to probe
  /// which emails have accounts.
  String? signInWithEmail(String email, String password) {
    final a = _accountFor(email);
    if (a == null || a.password != password) {
      return 'Email or password is incorrect.';
    }
    _enter(a);
    return null;
  }

  /// Creates a desk or owner account and signs it in. Returns an error
  /// message, or null on success.
  String? signUp({
    required String name,
    required String email,
    required String password,
    required Role role,
  }) {
    if (_accountFor(email) != null) {
      return 'An account with this email already exists.';
    }
    final a = Account(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      password: password,
      role: role,
    );
    accounts.add(a);
    _enter(a);
    return null;
  }

  void finishSplash() {
    if (!showSplash) return;
    showSplash = false;
    notifyListeners();
  }

  void logout() {
    role = null;
    userName = null;
    showSplash = false;
    screen = BFScreen.queue;
    _stack.clear();
    detailId = null;
    assignId = null;
    notifyListeners();
  }

  // ── toast ──────────────────────────────────────────────────────────────

  void say(String msg) {
    _toastTimer?.cancel();
    toast = msg;
    notifyListeners();
    _toastTimer = Timer(const Duration(milliseconds: 3600), () {
      toast = null;
      notifyListeners();
    });
  }

  // ── the state machine ──────────────────────────────────────────────────

  /// WAITING → IN PROGRESS. Seats [customerId] in [braiderId]'s chair.
  void assign(int customerId, int braiderId) {
    final match = customers.where((x) => x.id == customerId);
    if (match.isEmpty) return;
    final c = match.first;
    // Only a waiting customer can be seated. Guards a double-tap on
    // "Take <name>", which would otherwise reset startedAt on a chair
    // that is already running.
    if (c.status != CustomerStatus.waiting) return;

    final now = DateTime.now();
    final b = braiderById(braiderId);

    customers = customers
        .map(
          (x) => x.id == customerId
              ? x.copyWith(
                  status: CustomerStatus.inProgress,
                  braiderId: braiderId,
                  startedAt: now,
                )
              : x,
        )
        .toList();
    assignId = null;
    say('${c.name} → ${b.firstName}. Chair is now busy.');
  }

  /// Longest-idle free braider, or null when every chair is busy.
  int? _autoPick(List<Customer> projected) {
    final free = freeBraiders(projected);
    return free.isEmpty ? null : free.first.id;
  }

  /// Trigger 1 — supervisor checks in a walk-in, queue number issued.
  /// Trigger 2 — auto-allocation, when enabled.
  void submitCheckin() {
    final name = formName.trim().isEmpty ? 'Walk-in guest' : formName.trim();
    final no = (seq + 1).toString().padLeft(3, '0');
    final now = DateTime.now();
    final id = _nextCustomerId++;

    final fresh = Customer(
      id: id,
      no: no,
      name: name,
      phone: formPhone.trim().isEmpty ? '—' : formPhone.trim(),
      style: formStyle,
      status: CustomerStatus.waiting,
      braiderId: null,
      checkedInAt: now,
      startedAt: null,
      completedAt: null,
    );

    final projected = [...customers, fresh];
    final pick = autoAssign ? _autoPick(projected) : null;

    seq += 1;
    customers = projected
        .map(
          (c) => c.id == id && pick != null
              ? c.copyWith(
                  status: CustomerStatus.inProgress,
                  braiderId: pick,
                  startedAt: now,
                )
              : c,
        )
        .toList();

    formName = '';
    formPhone = '';
    formStyle = 'Knotless box braids';
    screen = BFScreen.queue;
    _stack.clear();

    if (pick != null) {
      say('Queue $no · $name auto-allocated to ${braiderById(pick).firstName}');
    } else {
      say('Queue $no · $name added. No braider free — waiting.');
    }
  }

  /// Trigger 3 — IN PROGRESS → COMPLETED. The braider flips to free, and when
  /// [pullNext] is on the longest-waiting customer is pulled straight to her
  /// chair, so the queue and availability move together.
  void complete(int customerId) {
    final match = customers.where((x) => x.id == customerId);
    if (match.isEmpty) return;
    final c = match.first;
    // Guard a double-tap on "Finish client". The button captures the
    // customer at build time, so a second tap before the rebuild would
    // re-enter with the already-completed row — re-stamping completedAt and
    // announcing "you are now free" while the pulled-in customer sits in
    // the chair.
    if (c.status != CustomerStatus.inProgress) return;

    final now = DateTime.now();

    var updated = customers
        .map(
          (x) => x.id == customerId
              ? x.copyWith(status: CustomerStatus.completed, completedAt: now)
              : x,
        )
        .toList();

    braiders = braiders
        .map((b) => b.id == c.braiderId ? b.copyWith(idleSince: now) : b)
        .toList();

    Customer? next;
    if (pullNext && c.braiderId != null) {
      final stillWaiting =
          updated.where((x) => x.status == CustomerStatus.waiting).toList()
            ..sort((a, b) => a.checkedInAt.compareTo(b.checkedInAt));
      final br = braiders.where((b) => b.id == c.braiderId);
      if (stillWaiting.isNotEmpty && br.isNotEmpty && br.first.on) {
        next = stillWaiting.first;
      }
    }

    if (next != null) {
      updated = updated
          .map(
            (x) => x.id == next!.id
                ? x.copyWith(
                    status: CustomerStatus.inProgress,
                    braiderId: c.braiderId,
                    startedAt: now,
                  )
                : x,
          )
          .toList();
    }

    customers = updated;
    detailId = null;
    if (role == Role.braider) {
      screen = BFScreen.job;
    } else if (screen == BFScreen.detail) {
      // The customer being inspected has just left the queue, so the detail
      // screen has nothing to render. Fall back to wherever we came from
      // instead of stranding the supervisor on a blank screen.
      screen = _stack.isNotEmpty ? _stack.last : BFScreen.queue;
    }
    _stack.clear();

    say(
      next != null
          ? '${c.name} completed. ${next.name} (queue ${next.no}) pulled to your chair.'
          : '${c.name} completed. You are now free.',
    );
  }

  /// Sends an in-progress customer back to the queue and opens the sheet.
  void reassign(Customer c) {
    if (c.status != CustomerStatus.inProgress) return;
    customers = customers
        .map(
          (x) => x.id == c.id
              ? x.copyWith(
                  status: CustomerStatus.waiting,
                  clearBraider: true,
                  clearStartedAt: true,
                )
              : x,
        )
        .toList();
    assignId = c.id;
    screen = BFScreen.queue;
    _stack.clear();
    detailId = null;
    say('${c.name} returned to the queue — pick a new braider.');
  }

  // ── shifts ─────────────────────────────────────────────────────────────

  /// Clocking out removes a braider from allocation immediately — but only
  /// once her chair is empty.
  void toggleShift(int braiderId) {
    final b = braiderById(braiderId);
    final current = busyWith(braiderId);
    if (b.on && current != null) {
      say('${b.firstName} still has a client — finish first.');
      return;
    }
    final now = DateTime.now();
    braiders = braiders
        .map(
          (x) => x.id == braiderId
              ? x.copyWith(
                  on: !x.on,
                  clockedInAt: !x.on ? now : null,
                  clearClockedInAt: x.on,
                  idleSince: now,
                )
              : x,
        )
        .toList();
    say(
      b.on
          ? '${b.firstName} clocked out — removed from allocation.'
          : '${b.firstName} clocked in — available.',
    );
  }

  /// Same rule, phrased for the braider looking at her own shift card.
  void toggleMyShift() {
    final current = meCurrent;
    if (me.on && current != null) {
      say('Finish your client before clocking out.');
      return;
    }
    final wasOn = me.on;
    final now = DateTime.now();
    braiders = braiders
        .map(
          (x) => x.id == meId
              ? x.copyWith(
                  on: !x.on,
                  clockedInAt: !x.on ? now : null,
                  clearClockedInAt: x.on,
                  idleSince: now,
                )
              : x,
        )
        .toList();
    say(
      wasOn
          ? 'Clocked out — the desk can no longer allocate to you.'
          : 'Clocked in — you are on the free list.',
    );
  }

  void addBraider() {
    final n = nbName.trim();
    if (n.isEmpty) {
      say('Enter a name first.');
      return;
    }
    final id = braiders.map((b) => b.id).reduce((a, b) => a > b ? a : b) + 1;
    final now = DateTime.now();
    braiders = [
      ...braiders,
      Braider(
        id: id,
        name: n,
        skills: nbSkill.trim().isEmpty ? 'General braiding' : nbSkill.trim(),
        on: true,
        clockedInAt: now,
        idleSince: now,
      ),
    ];
    nbName = '';
    nbSkill = '';
    showAdd = false;
    say('${n.split(' ').first} registered and clocked in — now available.');
  }

  // ── sheet + form plumbing ──────────────────────────────────────────────

  void openAssign(int customerId) {
    assignId = customerId;
    notifyListeners();
  }

  void closeAssign() {
    assignId = null;
    notifyListeners();
  }

  void toggleAdd() {
    showAdd = !showAdd;
    notifyListeners();
  }

  void setFormName(String v) {
    formName = v;
    notifyListeners();
  }

  void setFormPhone(String v) {
    formPhone = v;
    notifyListeners();
  }

  void setFormStyle(String v) {
    formStyle = v;
    notifyListeners();
  }

  void setNbName(String v) {
    nbName = v;
    notifyListeners();
  }

  void setNbSkill(String v) {
    nbSkill = v;
    notifyListeners();
  }

  /// Copy for the amber banner under the check-in form.
  String get allocPreview {
    final free = freeBraiders();
    final onCount = braiders.where((b) => b.on).length;
    final on = onCount < 1 ? 1 : onCount;
    if (!autoAssign) {
      return 'Auto-allocation is off — this customer will sit in the '
          'waiting list until you allocate them.';
    }
    if (free.isNotEmpty) {
      return 'Auto-allocation will seat this customer with ${free.first.name} '
          '(free ${fmt(minsSince(free.first.idleSince))}) — you can override.';
    }
    final rem = remainingOnChairs;
    return 'All $on chairs are busy. This customer joins the queue at position '
        '${waiting.length + 1}, chair in ${rem.isNotEmpty ? fmt(rem.first) : '~2h'}.';
  }

  String get nextNo => (seq + 1).toString().padLeft(3, '0');
}
