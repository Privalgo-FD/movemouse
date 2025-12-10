# Packaging scripts

This folder contains convenience scripts to build Move Mouse locally and produce a ZIP release that mirrors the CI packaging step.

Files
- `package-release.ps1` — PowerShell script. Usage:

  ```powershell
  # Build 4x only (Release)
  ./package-release.ps1

  # Build 4x and 3x (Release)
  ./package-release.ps1 -Include3x

  # Specify config
  ./package-release.ps1 -Configuration Debug
  ```

- `package-release.bat` — Batch wrapper (calls the PowerShell script).

Trigger CI from your machine

If you want to run the GitHub Actions workflow that builds and creates a draft release, you can use the `gh` CLI:

```bash
# Run the combined workflow and include 3x explicitly
gh workflow run build-windows.yml --ref master -f include_3x=true

# Or run the 4x-only workflow
gh workflow run build-4x-windows.yml --ref master
```

Notes
- The PowerShell script expects `nuget` and `msbuild` on PATH (typically available in Developer Command Prompt).  
- The `gh` commands require you to be authenticated with the GitHub CLI and have permission to run workflows in this repo.
