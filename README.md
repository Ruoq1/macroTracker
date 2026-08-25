# MacroTracker

Ultra-minimal offline iOS macro tracker. See the project brief for the full V1 spec and philosophy.

## Deferred ideas

### HealthKit-derived TDEE (not implemented)

Optional toggle for Watch/Health users to auto-compute TDEE as `basalEnergyBurned + activeEnergyBurned`
(today's HealthKit samples) instead of the manual TDEE field in Daily Goals.

Feasible, not started. Deferred because it breaks the app's "fully offline, zero permissions" baseline
even as an opt-in, default-off toggle:

- The app currently never shows a system permission dialog. Adding HealthKit means an entitlement +
  `NSHealthShareUsageDescription` are baked into every build regardless of whether a given user enables it.
- The App ID needs the HealthKit capability enabled on developer.apple.com, and the `MacroTracker AppStore`
  provisioning profile would need to be regenerated to include it.
- TDEE would become a live, activity-driven number instead of a fixed daily figure — the "goal" mental
  model would need to account for it changing through the day (e.g. jumping after a workout syncs).
- HealthKit reads are local (no network), so "offline" itself stays true; it's the "zero permissions / zero
  system integration" property that would be lost.
- Can't be meaningfully tested in Simulator — needs a real device (ideally with a paired Watch) with actual
  Health data.

If revisited: keep manual TDEE entry as the default, gate the HealthKit path behind an explicit opt-in
toggle in Settings, and query `HKQuantityType(.basalEnergyBurned)` + `.activeEnergyBurned` summed over today.
