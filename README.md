# Braidflow

Salon operations for a braiding studio. One queue, three views: the front desk
checks a walk-in in under ten seconds, the braider only ever sees her own chair,
and the owner sees the day.

A Flutter port of the `Braidflow.dc.html` design canvas, kept in
[`design_source/`](design_source/) as the reference spec.

## The one state machine

```
WAITING  ──▶  IN PROGRESS  ──▶  COMPLETED
```

| Trigger | What happens |
| --- | --- |
| 1 | Supervisor checks in a walk-in → queue number issued |
| 2 | Auto-allocation to the longest-idle free braider (supervisor can override) |
| 3 | Braider taps **Finish client** → she flips to free and the next waiting customer is pulled to her chair |

**Braider availability is never entered by hand.** It is derived from "does this
braider hold an in-progress customer, and is she clocked in". That is what keeps
the supervisor's and the braider's views in sync — there is no separate
availability record to drift.

## Screens

| Role | Tabs |
| --- | --- |
| Supervisor · front desk | Queue · Check in · Chairs · Staff |
| Braider | My chair · Up next · Me |
| Owner | Today · Chairs · Staff |

Plus a customer timeline reachable from the queue, and an allocation sheet that
flags the braider auto-allocation would have picked.

## Running it

```bash
flutter run -d chrome
```

Android and iOS targets are scaffolded. iOS needs a full Xcode install (the
project was developed against Command Line Tools only, so the web target is the
verified one).

## Tests

```bash
flutter test
```

- `test/state_machine_test.dart` — the three triggers, derived availability,
  allocation order, shift rules, wait estimates.
- `test/widget_test.dart` — renders every screen in every role, and re-renders
  them at 1.3× and 1.6× accessibility text sizes, on a small phone, and with an
  on-screen keyboard raised. This suite exists because a `borderRadius` on a
  non-uniform `Border` throws only at paint time — invisible to the analyser,
  and invisible in a release web build where assertions are stripped.

## Theme

The palette follows the DSE investor portal (investor.dse.co.tz), read off its
computed styles rather than eyeballed:

| Role | Value | Source |
| --- | --- | --- |
| Ground gradient | `#0A1628` → `#0F1E32` | `--background-start-rgb` / `--background-end-rgb` |
| Raised surface | `#132035` | DSE card colour |
| Text | `#E2E8F0` | portal body colour |
| Accent gradient | `#10B981` → `#2DD4BF` → `#09A0DB` | portal CTA |
| Glass | `rgba(255,255,255,.15)` + `blur(40px)` | portal nav pill |

Both projects already used **Manrope**, so only colour and surface treatment
changed; Instrument Serif is retained for display type.

**On the glass:** a real `BackdropFilter` costs a full offscreen render pass, so
it is reserved for floating chrome — the tab bar, the allocation sheet — where
there is genuinely something moving behind it. Cards use a translucent fill and
a light hairline instead. Over a flat gradient ground the two are visually
near-identical, and a blur layer per row in a six-item list is not.

Token *names* were kept from the original warm-sand theme: `ink` is the colour
you write with, so on a dark ground it is light, and the ~70 `inkA()` muted-text
call sites stayed correct without edits.

## Layout notes

- **Data is in-memory and seeded.** There is no persistence layer; a reload
  restores the seed. The design is a v1 structure, not a backend contract.
- **Allocation behaviour** (`autoAssign`, `pullNext`, `showWaitEstimate`) exists
  as fields on `AppState`, defaulting to the design's values. They were canvas
  editor knobs rather than app UI, so they are not surfaced on a screen.
- **Fonts are bundled** (`assets/fonts/`) rather than fetched at runtime, so the
  typography is identical offline and on every platform.
- **`PhoneFrame`** pins the app to the design's 402×874 artboard on wide
  viewports and lets it fill the screen on a phone.

## Out of scope for v1

Per the design's own notes: SMS "you're next" notifications, deposit capture at
check-in, skill-matched allocation, the weekly owner report, and multi-branch.
