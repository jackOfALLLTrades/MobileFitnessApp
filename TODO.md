# Bodies feature backlog

Suggested order from smallest change to largest. Completed items are checked off.

- [x] **Restore the Profile tab label and keep workout history.** In `HomeView`, replace the stacked History and Profile tab modifiers with one Profile tab. Keep the existing history and workout detail screens accessible there.
- [x] **Expand the built-in exercise catalog.** Add movements such as Push-Up, Chin-Up, Dip, and Reverse Crunch. Pull-Up and Hanging Leg Raise already exist. Verify that reseeding adds missing exercises without creating duplicates.
- [ ] **Add workout notes.** Add a notes field to the active workout and save it on the session so it survives relaunch. Show nonempty notes in workout history detail, including for workouts with no completed sets. Verify that older sessions still load without notes.
- [ ] **Allow deleting a completed workout.** Add a swipe action with full swipe disabled and a confirmation naming the workout. Cancel should preserve it. Confirm should delete that session and its logged sets, and refresh history and any derived calendar or progress views.
- [ ] **Put a workout calendar on Home.** Adapt Ryan's month grid, navigation, and day selection from `origin/Ryans-Branch` (`44a5510`). Bring over the calendar component independently of his older navigation. Place it in Dashboard, use completed sessions only, and update the preview for `WorkoutExercise`. Verify that completing or deleting a workout updates the marked day.
- [ ] **Support reps-only bodyweight exercises.** Give exercises an explicit logging mode and carry it into workout records when starting a routine, adding an exercise, or replacing one. Hide weight entry for movements such as Push-Up, Pull-Up, and Hanging Leg Raise, and show reps-only results in history and previous performance. Preserve weighted variants, existing saved weights, and timed exercises such as Plank.
- [ ] **Add themes in Profile Settings.** Start with Light and Dark, then add Eggshell and optionally a fourth palette. Persist the selection. Apply custom colors consistently across tabs, lists, workout sheets, and the calendar, checking text and control contrast.
