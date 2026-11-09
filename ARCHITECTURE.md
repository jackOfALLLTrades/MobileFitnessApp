# App architecture

## Core concepts

- **Exercise** is a lift in the exercise library. It contains its name, muscle group, and whether it is built in.
- **Routine** is a reusable workout blueprint.
- **RoutineExercise** places an Exercise in a Routine, with an order and planned set count. A lift can appear in different routines with different plans.
- **WorkoutSession** records one actual workout. Active and completed workouts use this same model.
- **WorkoutExercise** records an exercise within a workout, with its own name, order, and logged sets.
- **WorkoutSet** records weight, reps, order, and completion for one set.

## Data flow

A user selects a Routine to start a WorkoutSession. Each RoutineExercise becomes a WorkoutExercise, and its planned set count determines the initial WorkoutSets. The workout stores the exercise name as a snapshot rather than linking to the library Exercise. Editing the routine does not rewrite an existing workout.

Logging updates WorkoutSets in the session. Finishing sets the session's end date and completion flag; discarding deletes it. Minimizing changes presentation, not completion. On launch, the session manager can restore the latest unfinished session.

## Finding files

All paths below are relative to `MobileFitnessApp/MobileFitnessApp`.

| Folder | Responsibility |
| --- | --- |
| `App` | App entry point, model registration, tabs, and workout presentation |
| `Features/Dashboard` | Home dashboard content |
| `Features/Exercises` | Library model, seeded catalog, browsing, selection, and custom exercise creation |
| `Features/Routines` | Blueprint models, list, and editor |
| `Features/Workouts` | Workout records, active workout UI, editing state, and history lookup |
| `Shared/Views` | Components used across features, including reordering and set-column layout |

## Current ownership

- Views own layout, navigation, sheets, and confirmation dialogs. SwiftData queries in views provide live collections.
- ActiveWorkoutView obtains the environment's model context and creates content with a persistent ActiveWorkoutViewModel. The view model owns weight/reps drafts, input parsing, workout mutations, and saving. It currently exposes SwiftUI bindings, so it intentionally depends on SwiftUI.
- WorkoutSessionManager coordinates lifecycle actions and owns the app-wide active-session reference and minimized state. It delegates persistence to WorkoutSessionService and updates app state only after saving succeeds. Its state is read-only to callers.
- WorkoutSessionService creates sessions from routine snapshots, finishes and discards sessions, and fetches the latest unfinished session. It owns these database operations without depending on views or presentation state. ActiveWorkoutViewModel continues to own in-session logging and edits.
- PreviousPerformanceLookup reads supplied history and formats previous values. It does not fetch or save data. It uses the latest earlier completed workout containing a matching exercise name; a missing set in that workout displays a dash.
- RoutineEditorViewModel owns the routine name, selected exercises, planned set rows, validation, and saving. RoutineEditorView owns presentation and dismisses only after a successful save. RoutineListView asks WorkoutSessionManager to start workouts from routines.
- HomeView and ActiveWorkoutView use the same manager/service discard path. Views retain confirmation dialogs and dismiss only after successful lifecycle operations.

- ExerciseSelectionViewModel owns uncommitted picker selection, search/sort preferences, and duplicate replacement checks. ExerciseSelectionView owns committing selection, navigation, and library deletion. ExerciseBrowser shares filtering between the library and picker and groups picker results.
- MinimizedWorkoutBanner owns banner layout; HomeView supplies reopen/discard actions. WorkoutDurationFormatter supplies the same elapsed-time text to the banner and workout header.

## Naming conventions

- Domain models use nouns: Exercise, Routine, WorkoutSession, WorkoutExercise, WorkoutSet.
- Use **routine** for a blueprint and **workout/session** for an actual attempt.
- Screens and visual components end in `View` or use a clear visual role such as `Row`, `Section`, or `Layout`.
- Editors that support both creation and updates use `Editor`, not `Create`.
- View models own screen editing state and actions. Small helpers describe their specific job, such as PreviousPerformanceLookup.
- Use the existing Swift comment header, with imports/code starting on line 8 (see AGENTS.md).
- Match a file's name to its primary type. Keep feature-specific components with their feature; move components to Shared only when multiple features use them.
- Extract code when it establishes a clear responsibility or removes duplication. File length alone is not a reason to add another layer.

## Alpha storage change

This cleanup renames the SwiftData entity SessionExercise to WorkoutExercise and the WorkoutSet relationship sessionExercise to workoutExercise. No migration from the previous alpha schema is provided. Existing development installs may need their local app data reset (for example, by deleting and reinstalling the simulator app). This deletes local routines and workouts; the built-in exercise catalog is seeded again by the existing catalog flow.

## Verification

Use Xcode to build and run the iOS app. Check routine creation/editing, starting a workout with the planned set counts, set input and completion, exercise replacement/reordering/deletion, minimize/reopen, finish/discard, and unfinished-workout restoration after relaunch. Swift syntax checks alone do not verify types, SwiftData schema loading, or runtime behavior.
