# Cadence installer: junctions the three skills into $HOME\.claude\skills.
#
# Idempotent: re-run safely to update.
#
# Customize via env vars:
#   CADENCE_DIR = where the Cadence repo lives (default: $HOME\.claude-cadence)
#   SKILLS_DIR  = your Claude skills dir        (default: $HOME\.claude\skills)
#   REPO_URL    = git remote                    (default: https://github.com/mnoori/Cadence.git)
#   BRANCH      = branch to track               (default: main)

$ErrorActionPreference = "Stop"

$CadenceDir = if ($env:CADENCE_DIR) { $env:CADENCE_DIR } else { Join-Path $HOME ".claude-cadence" }
$SkillsDir = if ($env:SKILLS_DIR) { $env:SKILLS_DIR } else { Join-Path $HOME ".claude\skills" }
$RepoUrl = if ($env:REPO_URL) { $env:REPO_URL } else { "https://github.com/mnoori/Cadence.git" }
$Branch = if ($env:BRANCH) { $env:BRANCH } else { "main" }

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ScriptRepoRoot = Resolve-Path (Join-Path $ScriptDir "..")

if (Test-Path (Join-Path $ScriptRepoRoot ".claude-plugin\plugin.json")) {
    $CadenceDir = $ScriptRepoRoot.Path
    Write-Host "Using existing clone at $CadenceDir"
} elseif (Test-Path (Join-Path $CadenceDir ".git")) {
    Write-Host "Updating existing Cadence install at $CadenceDir"
    git -C $CadenceDir pull --ff-only origin $Branch
} else {
    Write-Host "Cloning Cadence to $CadenceDir"
    git clone --branch $Branch --depth 1 $RepoUrl $CadenceDir
}

if (-not (Test-Path $SkillsDir)) {
    New-Item -ItemType Directory -Path $SkillsDir | Out-Null
}

$Linked = @()
$Skipped = @()

Get-ChildItem (Join-Path $CadenceDir "skills") -Directory | ForEach-Object {
    $SkillName = $_.Name
    $Source = $_.FullName
    $Target = Join-Path $SkillsDir $SkillName

    if (Test-Path $Target) {
        $Item = Get-Item $Target -Force
        if ($Item.LinkType -eq "Junction" -or $Item.LinkType -eq "SymbolicLink") {
            Remove-Item $Target -Force
        } else {
            $Skipped += "$SkillName (target exists and is not a junction/symlink; will not overwrite)"
            return
        }
    }

    New-Item -ItemType Junction -Path $Target -Target $Source | Out-Null
    $Linked += $SkillName
}

Write-Host ""
Write-Host "Installed:"
foreach ($Skill in $Linked) {
    Write-Host "  + $Skill -> $SkillsDir\$Skill"
}

if ($Skipped.Count -gt 0) {
    Write-Host ""
    Write-Host "Skipped:"
    foreach ($Skill in $Skipped) {
        Write-Host "  ! $Skill"
    }
}

Write-Host ""
Write-Host "Next:"
Write-Host "  1. Restart Claude Code, or run /reload-plugins if available."
Write-Host "  2. Confirm cadence-pr-review, cadence-research, and cadence-sweep appear."
Write-Host "  3. Test cadence-pr-review on $CadenceDir\skills\cadence-pr-review\evals\sample-pr\"
Write-Host ""
Write-Host "Uninstall:"
Write-Host "  Remove-Item `"$SkillsDir\cadence-pr-review`", `"$SkillsDir\cadence-research`", `"$SkillsDir\cadence-sweep`""
Write-Host "  Remove-Item `"$CadenceDir`" -Recurse -Force   # only if you do not want to keep the source"
