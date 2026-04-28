# RetroTector setup steps (AoU Jupyter)

This is a narrative version of the steps I followed inside an
All of Us Researcher Workbench Jupyter environment. It is intentionally
high level and does not include any participant-specific paths or IDs.

---

## 1. Create a working directory

- Created a clean directory under my home directory in the VM
  (e.g., `~/RetroTector-main`) to hold everything related to this setup.

Purpose: keep RetroTector code and config in one place instead of
scattering files around the VM.

---

## 2. Download RetroTector archives

Inside `~/RetroTector-main` I downloaded:

- a RetroTector GitHub/archive zip (source)
- the `ReTe1.0.1.zip` distribution archive

In practice, this was done with `wget` calls, but in this repo I’m only
recording the fact that both archives were downloaded, not the exact
signed URLs used inside All of Us.

---

## 3. Unzip the archives

Still in `~/RetroTector-main`:

- unzipped the RetroTector GitHub archive
- unzipped `ReTe1.0.1.zip`

After this, the directory contained (among other things):

- a `ReTe1.0.1/` folder
- `ReTe1.0.1/Database/`
- `ReTe1.0.1/Workplace/`

---

## 4. Inspect directory layout

Quick sanity check to make sure key subdirectories were present:

- `ReTe1.0.1/Database`
- `ReTe1.0.1/Workplace`

No changes here, just confirming that the unpacked structure looked
reasonable.

---

## 5. Edit Configuration.txt

- Opened `ReTe1.0.1/Database/Configuration.txt`.
- Ensured there was a `WorkingDirectory = ...` line.
- Set `WorkingDirectory` to the absolute path of the `Workplace`
  directory inside the VM, something like:

  `WorkingDirectory = /home/<user>/RetroTector-main/ReTe1.0.1/Workplace`

All other parameters were left at their default values.

---

## 6. Create Workplace/NewDNA

- Made sure the directory `ReTe1.0.1/Workplace/NewDNA` existed.
- This is where new FASTA files would go for engine runs (e.g., chrY).

---

## 7. Test Java launch

From inside `ReTe1.0.1` I ran a test Java command to verify that:

- Java was available in the VM.
- The RetroTector classes could be found on the classpath.

The test call used the RetroTector main class and immediately triggered
a `java.awt.HeadlessException` complaining about `No X11 DISPLAY`
because the environment is headless.

This is actually useful information: it confirms that the GUI entry
point is not usable inside All of Us and that we should be invoking the
**command‑line / engine** entry points instead.

---

## 8. Open question (engine usage)

To match what Duncan described in his 4/13/2026 notes for chrY, the next
piece of information needed is:

- the exact non‑GUI RetroTector engine command(s) used in the All of Us
  VM for:
  - `SweepDNA`
  - `SweepScripts`
- the directory the commands are run from

Once we have that, I can:

- drop a small test FASTA (e.g., chrY reference) into
  `Workplace/NewDNA`, and
- try to reproduce the chrY runs he describes, then document the runtime
  and putein file counts here as well.
