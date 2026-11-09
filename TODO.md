# Bodies feature backlog

Suggested order from smallest change to largest. Completed items are checked off.

- [x] **Restore the Profile tab label and keep workout history.** In `HomeView`, replace the stacked History and Profile tab modifiers with one Profile tab. Keep the existing history and workout detail screens accessible there.
- [x] **Expand the built-in exercise catalog.** Add movements such as Push-Up, Chin-Up, Dip, and Reverse Crunch. Pull-Up and Hanging Leg Raise already exist. Verify that reseeding adds missing exercises without creating duplicates.
- [x] **Add exercise notes to workouts.** Add or swipe to remove individual exercise notes. Show the latest saved note as a hint and display written notes in workout history.
- [x] **Allow deleting a completed workout.** Add a swipe action with full swipe disabled and a confirmation naming the workout. Cancel should preserve it. Confirm should delete that session and its logged sets, and refresh history and any derived calendar or progress views.
- [x] **Show recent history on Profile.** Display the five most recent completed workouts and link to the full history when there are more.
- [x] **Create a Settings screen under Profile.** Open Settings from the gear button and persist preferences across launches.
  - [x] **History preview count:** Let users choose three, four, or five recent workouts. Default to five and apply the selection to the Profile preview.
  - [x] **Weight units:** Offer pounds (lb) and kilograms (kg). Treat existing weights as pounds and store weights in one consistent unit. Convert at entry and display boundaries, including previous performance and history. Apply the preference to progress charts when they are added.
  - [ ] **Appearance:** Start with System, Light, and Dark, then add Eggshell and optionally a fourth palette. Present theme choices in a popup with a preview of each palette. Check text and control contrast across tabs, lists, sheets, and the calendar.
- [ ] **Put a workout calendar on Home.** Adapt Ryan's month grid, navigation, and day selection from `origin/Ryans-Branch` (`44a5510`). Bring over the calendar component independently of his older navigation. Place it in Dashboard, use completed sessions only, and update the preview for `WorkoutExercise`. Verify that completing or deleting a workout updates the marked day.
- [ ] **Offer to update the routine when finishing a workout.** Track the source routine and compare the final exercise lineup with the starting lineup. If an exercise was added, removed, or replaced, offer **Update Routine** or **Finish Without Updating**. Set-only edits, order-only changes, and exercise changes undone before finishing should leave the prompt hidden. If the source routine no longer exists, finish normally.
- [ ] **Support reps-only bodyweight exercises.** Give exercises an explicit logging mode and carry it into workout records when starting a routine, adding an exercise, or replacing one. Hide weight entry for movements such as Push-Up, Pull-Up, and Hanging Leg Raise, and show reps-only results in history and previous performance. Preserve weighted variants, existing saved weights, and timed exercises such as Plank.

## Settings ideas for later

- **Rest timer:** Default duration and whether checking off a set starts the timer automatically.
- **Calendar week start:** Follow the device default or let users choose Sunday or Monday.
- **Export workout history:** Download a CSV with workouts, sets, units, and notes.
