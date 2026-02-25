# Habit Aligner (Behavioral Operating System)

Habit Aligner is an offline-first Flutter app for planning intentional work sessions, tracking behavioral drift, and generating actionable coaching insights.

## Core Capabilities

- **Session lifecycle management**: start, pause, resume, complete, or abandon sessions.
- **Adaptive daily planning**: auto-generated plan blocks based on your historical performance.
- **Behavioral analytics**: focus score, streaks, interruptions, drift insights, and weekly reporting.
- **Local-first persistence**: Isar-backed storage with migration and invariant repair.
- **Operational exports**: JSON and CSV exports, plus local backup snapshots.

## Architecture Snapshot

- `lib/features/logs/`: domain models, repository layer, use cases, and presentation state/controllers.
- `lib/features/intelligence/`: adaptive planning, coaching engine, weekly reporting, and gamification.
- `lib/core/`: design system, logging, and shared widgets.

## Getting Started

### Prerequisites

- Flutter `3.35.4+`
- Dart `3.9.2+`

### Install & Run

```bash
flutter pub get
flutter run
```

## Quality Checks

Run static analysis and tests:

```bash
flutter analyze
flutter test
flutter test --coverage
```

## Current Stability Enhancements

- App-level ownership of `LogController` to prevent controller recreation across rebuilds.
- Safer screen lifecycle with optional controller disposal.
- In-app integrity check trigger to verify repository-level data consistency.
- Export/backup action feedback via snackbars for better user confidence.

## Project Status

This repository includes unit/domain/widget tests and an integration smoke test scaffold. For stronger confidence, expand `integration_test/` with full user-journey coverage (boot, lifecycle actions, planning, and export flows).
