"""
RetroTector setup commands (AoU Jupyter VM)

This script mirrors the main steps I followed in a Jupyter notebook
to prepare RetroTector inside an All of Us VM. It is intentionally
sanitized: no participant data, no workspace IDs, no secrets.

NOTE: The actual download URLs used inside All of Us are not included
here on purpose. Replace the placeholder values with appropriate
public/source URLs if/when we decide to document them.
"""

from pathlib import Path
import os
import re
import subprocess
import textwrap

# -------------------------------------------------------------------
# STEP 1: Create and enter a working directory
# -------------------------------------------------------------------

BASE = Path.home() / "RetroTector-main"
BASE.mkdir(exist_ok=True)
print(f"[info] Working directory: {BASE}")

os.chdir(BASE)

# -------------------------------------------------------------------
# STEP 2: Download RetroTector archives (placeholders here)
# -------------------------------------------------------------------

download_commands = [
    # NOTE:
    # In the real AoU notebook, these were concrete wget commands to
    # fetch:
    #   - a RetroTector GitHub/archive zip
    #   - ReTe1.0.1.zip
    #
    # For this repo, we only record the structure, not the actual URLs.
    #
    # Example (commented out by default):
    # 'wget -O RetroTector-github.zip "<GITHUB_ARCHIVE_URL>"',
    # 'wget -O ReTe1.0.1.zip "<RETROTECTOR_ZIP_URL>"',
]

for cmd in download_commands:
    print(f"[info] Running: {cmd}")
    subprocess.run(cmd, shell=True, check=False)

# -------------------------------------------------------------------
# STEP 3: Unzip archives (assumes the zip files are present)
# -------------------------------------------------------------------

unzip_commands = [
    "unzip -o RetroTector-github.zip",
    "unzip -o ReTe1.0.1.zip",
]

for cmd in unzip_commands:
    print(f"[info] Running: {cmd}")
    subprocess.run(cmd, shell=True, check=False)

# -------------------------------------------------------------------
# STEP 4: Inspect directory contents
# -------------------------------------------------------------------

print("\n[info] Top-level contents in BASE:")
for item in sorted(BASE.iterdir()):
    print(" -", item.name)

# -------------------------------------------------------------------
# STEP 5: Edit Database/Configuration.txt (WorkingDirectory)
# -------------------------------------------------------------------

config_path = BASE / "ReTe1.0.1" / "Database" / "Configuration.txt"
workplace_path = BASE / "ReTe1.0.1" / "Workplace"

if config_path.exists():
    txt = config_path.read_text()

    # Replace existing WorkingDirectory line if it exists
    txt_new = re.sub(
        r"(?m)^WorkingDirectory\s*=.*$",
        f"WorkingDirectory = {workplace_path}",
        txt,
    )

    # If there was no WorkingDirectory line at all, append one
    if txt_new == txt and "WorkingDirectory" not in txt:
        txt_new = txt + f"\nWorkingDirectory = {workplace_path}\n"

    config_path.write_text(txt_new)
    print(f"\n[info] Updated config: {config_path}")
    print(f"[info] Set WorkingDirectory = {workplace_path}")
else:
    print(f"\n[warn] Configuration file not found: {config_path}")

# -------------------------------------------------------------------
# STEP 6: Ensure Workplace/NewDNA exists
# -------------------------------------------------------------------

newdna = workplace_path / "NewDNA"
newdna.mkdir(parents=True, exist_ok=True)
print(f"\n[info] Ensured directory exists: {newdna}")

# -------------------------------------------------------------------
# STEP 7: Test Java launch (GUI entry point, expected to fail headless)
# -------------------------------------------------------------------

java_cmd = textwrap.dedent(
    f"""
    cd "{BASE / 'ReTe1.0.1'}" && \
    java -cp . retrotector/RetroTector Quit
    """
).strip()

print("\n[info] Running Java test command:")
print(java_cmd)

result = subprocess.run(
    java_cmd,
    shell=True,
    text=True,
    capture_output=True,
)

print("\n[info] Return code:", result.returncode)
print("\n[info] STDOUT (truncated):\n", result.stdout[:2000])
print("\n[info] STDERR (truncated):\n", result.stderr[:2000])

print(
    """
[summary]
- This Java launch confirms that the VM can see the RetroTector classes,
  but the GUI entry point fails with a HeadlessException (no X11 DISPLAY).
- In this environment we should be using the non-GUI engine entry points
  (e.g., for SweepDNA / SweepScripts) instead of the GUI main class.
"""
)
