# Demo checklist

Notes for anyone giving a live demo of Fortress, written after a pass at
hardening the app for exactly this. A few of the risks below are
operational, not fixable in code — platform permission prompts and physical
device pairing don't have a code-level fix, so they're staged instead.

## Before you're in the room

- [ ] **Run the full demo script on a real device, not just Simulator**, within
  24–48 hours of the demo. This app has at least one real-device-only bug
  found this way already (a blank share sheet that never showed up in
  Simulator) — Simulator confidence and real-device confidence are not the
  same thing here.
- [ ] **Pre-grant Calendar access.** Open the app, build any lineup with a
  date set, tap "Add to Calendar" once, and allow access. Doing this live
  means a system permission dialog interrupts your flow at the exact moment
  you're trying to show off the feature.
- [ ] **Confirm Live Activities are enabled**: Settings → Fortress → Live
  Activities → on. The app now tells you if this is off instead of the
  button silently doing nothing (see below), but it's still better to walk
  in with it already on.
- [ ] **Don't demo the Apple Watch complication live** unless you've already
  paired the Watch, installed the app, and added the complication to a face
  ahead of time. Getting a watchOS simulator working from scratch took
  downloading a 4GB platform image and working around an Xcode SDK-selection
  bug — that's not a live-demo risk worth taking. Show a screenshot or a
  pre-recorded clip instead if you want to mention it.
- [ ] **Set Club Settings to the club you're pitching to, if you know it in
  advance** (gear icon on the main screen → pick their team from the
  division list). Seeing their own crest and fixtures rather than Barnes'
  is a much stronger opener than explaining it afterward.

## What's been hardened

- **Live Activity failures now surface an alert** instead of failing
  silently — if Live Activities are off, the app says so and tells you where
  to turn them on, rather than the "Start Live Activity" button appearing to
  do nothing.
- **The fixture picker now says outright that its data is a snapshot**, not
  a live feed, with a note that any match can be hand-edited if it's
  postponed — so nobody discovers this the hard way mid-pitch.
- **Any division team can become "my team"** via the new Club Settings
  screen — `MyTeam` is no longer hardcoded to Barnes M3 in the data layer.
  See the caveat below on what this does and doesn't solve.

## Honest answers to the two hardest questions

**"Can we use this for our club?"** — Yes, for a club already in the
division catalogue: Club Settings picks their team, crest, and home venue.
For a club *outside* that catalogue, or for custom branding (a different app
name, uploaded crest, non-catalogue kit), the honest answer is "not yet
without a rebuild" — the widget and Watch complication also won't pick up a
Club Settings change without an App Group entitlement, the same class of
one-time manual setup already required for iCloud sync. Don't oversell this
past what it does today.

**"Can the whole team see and edit the same lineup live?"** — No. Sharing
today is one-way: export a graphic, send it to WhatsApp. iCloud sync keeps
your *own* devices on the same lineup, not a shared team workspace. The
honest path to real collaboration is CloudKit sharing (`CKShare` +
`UICloudSharingController`) so an owner can invite specific people to a
lineup with live updates — deliberately not built yet, because it needs a
second Apple ID and device to validate the accept-invitation flow, which
isn't available in this environment. Flag it as roadmap, not "coming next
sprint."
