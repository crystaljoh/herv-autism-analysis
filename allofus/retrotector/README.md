# RetroTector setup in All of Us VM

This folder documents my initial attempt to install and run RetroTector
inside an All of Us Researcher Workbench Jupyter environment.

## Scope
This repository content is limited to:
- general environment setup steps
- filesystem setup
- download/unzip steps for code
- configuration edits
- command-line launch attempts

This repository does NOT include:
- participant data
- exported AoU files
- cohort outputs
- IDs, tokens, credentials, or secrets

## Current status
- RetroTector source and distribution were unpacked in the VM
- `Configuration.txt` was edited so `WorkingDirectory` points to the local VM path
- `Workplace/NewDNA` was created
- A Java launch attempt reached the application but failed with a headless/X11 error,
  which suggests the GUI entry point is not usable in the AoU environment
- Next step is to identify the exact non-GUI engine command used for:
  - SweepDNA
  - SweepScripts
