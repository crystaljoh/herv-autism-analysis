# RetroTector setup in All of Us Jupyter VM

This folder documents my initial attempt to install and run RetroTector
inside an All of Us Researcher Workbench Jupyter environment.

The goal is to make it easy for other people on the team to see exactly
how the environment was set up, what worked, and where I got stuck,
without exporting any All of Us data or private configuration.

## What is included here

This folder only contains:

- high-level setup steps
- environment and filesystem preparation
- generic download / unzip commands
- configuration edits (e.g., WorkingDirectory)
- a test Java launch that hits the expected headless/X11 error

No All of Us participant data, workspace IDs, or secrets are stored here.

## Current status (2026‑04‑27)

- RetroTector source and the ReTe1.0.1 distribution were unpacked inside
  an All of Us Jupyter VM.
- `Database/Configuration.txt` was edited so that `WorkingDirectory`
  points to the VM’s local `ReTe1.0.1/Workplace` directory.
- `Workplace/NewDNA` exists on the VM.
- A test Java call can see the RetroTector classes but fails with a
  `java.awt.HeadlessException` (no X11 DISPLAY), which is consistent
  with trying to start the GUI entry point from a headless console
  environment.

So at this point, the install is mostly in place, but the GUI main class
is not usable in the All of Us environment. The next step is to confirm
and document the **non‑GUI engine commands** used for:

- `SweepDNA`
- `SweepScripts`

once we have the exact `java ...` invocation for the All of Us VM.
