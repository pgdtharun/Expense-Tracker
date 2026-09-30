# Expense Tracker

A simple, clean expense tracker built with Flutter and Firebase, submitted as the practical task for the CyphLab Flutter Developer Internship.

## Features implemented

**Core requirements**
- Add, edit, and delete expenses
- Category selection (8 fixed categories with icons/colors)
- All data stored in Cloud Firestore
- Total expenses for the selected month, with prev/next month navigation
- Full expense history list for the selected month
- Filter by category (chips) and by date (month navigation)
- Text search across title and note
- Form validation (required title, numeric amount > 0, character limits)
- Explicit loading, empty, and error states — with a retry action on error

**Additional features**
- Category breakdown pie chart for the selected month
- Light/dark mode toggle
- Monthly + per-category summary (shown together on the home screen)
- Firebase Anonymous Authentication, so each install's data is scoped to its own `uid` in Firestore rather than shared globally
- Swipe-to-delete with a confirmation dialog, alongside delete-from-edit-screen
- `firestore.rules` included, restricting reads/writes to the owning `uid`

## Tech stack

| Layer | Choice |
|---|---|
| Framework | Flutter (Dart) |
| State management | `provider` (`ChangeNotifier`) |
| Backend | Cloud Firestore |
| Auth | Firebase Anonymous Auth |
| Charts | `fl_chart` |
| Formatting | `intl` |

## Project structure

```
lib/
  main.dart                    # App entry point, theming, auth gate
  firebase_options.dart        # ⚠️ placeholder — see setup below
  constants/
    categories.dart            # ExpenseCategory enum: labels, icons, colors
    app_colors.dart
  models/
    expense.dart                # Expense model + Firestore (de)serialization
  services/
    auth_service.dart          # Anonymous sign-in
    expense_service.dart       # Firestore CRUD, isolated from UI/state
  providers/
    expense_provider.dart      # Loading/filtering/summary state (ChangeNotifier)
    theme_provider.dart        # Light/dark mode
  utils/
    formatters.dart            # Currency/date formatting
    validators.dart            # Form validation rules
  screens/
    home_screen.dart
    add_edit_expense_screen.dart
  widgets/
    summary_card.dart
    filter_bar.dart
    expense_chart.dart
    expense_list_item.dart
    state_widgets.dart         # LoadingView / EmptyView / ErrorView
firestore.rules
```

The layering (model → service → provider → screen/widget) keeps Firestore
entirely out of the widget tree: screens only ever talk to `ExpenseProvider`,
which is the only thing that knows `ExpenseService` exists.

## Setup instructions

### 1. Prerequisites
- Flutter SDK (stable channel) installed and on your `PATH`
- A Firebase project (free Spark plan is enough)
- The FlutterFire CLI: `dart pub global activate flutterfire_cli`

### 2. Clone and generate platform folders
This repo contains the Dart source (`lib/`), Firebase config, and project
metadata (`pubspec.yaml` etc.) — but not the generated platform folders
(`android/`, `ios/`) that `flutter create` normally produces, since those
are large, boilerplate, and machine-generated. Generate them once, then
drop this repo's files in:

```bash
git clone <this-repo-url> expense_tracker_repo
flutter create --project-name expense_tracker --org com.yourname expense_tracker
cd expense_tracker
# Copy the repo's lib/, pubspec.yaml, analysis_options.yaml, README.md,
# firebase.json, firestore.rules, firestore.indexes.json, and .gitignore
# over the freshly-scaffolded project, overwriting the generated versions.
cp -r ../expense_tracker_repo/lib .
cp ../expense_tracker_repo/pubspec.yaml ../expense_tracker_repo/analysis_options.yaml \
   ../expense_tracker_repo/README.md ../expense_tracker_repo/firebase.json \
   ../expense_tracker_repo/firestore.rules ../expense_tracker_repo/firestore.indexes.json \
   ../expense_tracker_repo/.gitignore .
flutter pub get
```

### 3. Connect your own Firebase project
This repo ships with a **placeholder** `lib/firebase_options.dart` (fake keys,
clearly marked) so the project structure is complete and reviewable, but it
will not connect to a real backend as-is. To connect it:

```bash
firebase login          # if you haven't already
flutterfire configure   # select/create your Firebase project when prompted
```

This regenerates `lib/firebase_options.dart` with your project's real
config and adds `google-services.json` / `GoogleService-Info.plist` as
needed. (These files are **not secret** — Firebase client config values are
meant to be public; the actual protection is `firestore.rules`, below.)

In the Firebase console, enable:
- **Authentication → Sign-in method → Anonymous**
- **Firestore Database** (start in production mode)

Then deploy the included security rules and composite index (the app's main
query filters by `userId` and orders by `date`, which Firestore needs a
composite index for):
```bash
firebase init firestore   # if not already set up
firebase deploy --only firestore:rules,firestore:indexes
```
If you skip this, the app will show the error state on first run with a
"requires an index" message — Firestore's error includes a direct link to
auto-create it, as a fallback.

### 4. Run
```bash
flutter analyze   # static analysis — please run this before reviewing
flutter run
```

### 5. Build a release APK
```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

## Design notes / trade-offs

- **Anonymous auth instead of a login screen** — keeps the app self-contained
  for review (no account to create) while still giving every install a
  stable `uid` to scope Firestore data by. Swapping in email/password auth
  later would only mean changing `AuthService`; nothing else depends on
  *how* the `uid` was obtained.
- **One Firestore stream, filtered client-side** — `ExpenseService` streams
  all of a user's expenses once; `ExpenseProvider` derives the selected
  month, category filter, search, monthly total, and chart data from that
  single in-memory list. For an app this size that's simpler and more
  responsive than re-querying Firestore on every filter change, at the cost
  of not scaling to a very large history — a reasonable trade-off here.
- **Month navigation as the "date filter"** — rather than a separate date
  range picker, prev/next month controls double as both the date filter and
  the period the monthly total refers to, which matches how the task is
  worded ("total for the selected/current month") without adding a second,
  overlapping date control.

## Troubleshooting

- **"Requires an index" error on first run** — see the Firestore index note
  in step 3 above; deploy `firestore.indexes.json` or click the link in the
  error message.
- **Package version conflicts on `flutter pub get`** — the pinned versions
  in `pubspec.yaml` were reasonable at time of writing but Firebase
  packages move fast. If you see a resolution error, run
  `flutter pub upgrade --major-versions` to move to whatever's current.
- **Anonymous sign-in fails** — double check Authentication → Sign-in
  method → Anonymous is enabled in the Firebase console for your project.

## AI tools used

I used **Claude** (Anthropic) throughout this task:
- Planning the architecture (layering, state management choice, file
  structure) before writing any code.
- Writing the initial implementation of each file.
- I do not have prior hands-on Flutter/Dart experience (my background is
  native Android/Kotlin plus web full-stack work) — Claude helped me get
  productive in Dart syntax and Flutter/Firebase APIs quickly, but I
  reviewed, read, and understood every file rather than submitting
  generated code unread. I can walk through and explain any part of this
  codebase, and would want feedback on anything that doesn't reflect that.

Claude's own environment didn't have the Flutter SDK available (no network
access to Flutter's engine artifacts there), so the code was written and
reviewed line-by-line without being run in that environment. I ran
`flutter analyze`, `flutter pub get`, and the app itself on my own machine
before recording the demo and submitting this — see the screen recording
for the working app.
