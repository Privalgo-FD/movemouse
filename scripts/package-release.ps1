<#
.SYNOPSIS
  Build Move Mouse (4x and optional 3x) and create a ZIP release.

.PARAMETER Include3x
  If specified, attempt to build the legacy `3x` solution and include its output.

.PARAMETER Configuration
  Build configuration (Debug/Release). Default: Release

USAGE
  .\package-release.ps1 -Include3x -Configuration Release
#>

[CmdletBinding()]
param(
    [switch]$Include3x,
    [string]$Configuration = 'Release'
)

function Ensure-Tool([string]$exe) {
    $p = Get-Command $exe -ErrorAction SilentlyContinue
    if (-not $p) {
        Write-Error "Required tool '$exe' not found on PATH. Install Visual Studio/MSBuild or add the tool to PATH."
        exit 2
    }
}

# Ensure required tools
Ensure-Tool nuget
Ensure-Tool msbuild

$root = Split-Path -Path $PSScriptRoot -Parent
Set-Location $root

Write-Host "Building 4x solution..."
nuget restore "4x\Move Mouse.sln"
msbuild "4x\Move Mouse.sln" /p:Configuration=$Configuration /m

if ($Include3x) {
    Write-Host "Building 3x solution..."
    nuget restore "3x\Move Mouse.sln"
    msbuild "3x\Move Mouse.sln" /p:Configuration=$Configuration /m
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmm'
$zipName = "MoveMouse-release-$timestamp.zip"
$outDir = Join-Path $root 'release-output'
if (Test-Path $outDir) { Remove-Item -Recurse -Force $outDir }
New-Item -ItemType Directory -Path $outDir | Out-Null

function CopyIfExists($src, $destRel) {
    if (Test-Path $src) {
        $dest = Join-Path $outDir $destRel
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
        Copy-Item -Path (Join-Path $src '*') -Destination $dest -Recurse -Force
        return $true
    } else {
        return $false
    }
}

$included = @()
if (CopyIfExists (Join-Path $root '4x\Move Mouse\bin\' $Configuration) '4x') { $included += '4x' }
if ($Include3x) { if (CopyIfExists (Join-Path $root '3x\Move Mouse\bin\' $Configuration) '3x') { $included += '3x' } }

if ($included.Count -eq 0) {
    Write-Error "No build outputs found to package. Check that builds succeeded and output folders exist."
    exit 3
}

Push-Location $outDir
Compress-Archive -Path * -DestinationPath (Join-Path $root $zipName) -Force
Pop-Location

Write-Host "Created ZIP: $zipName"
Write-Host "Path: $(Join-Path $root $zipName)"

exit 0
