param(
  [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"

$publicRoots = @(
  "README.md",
  "docs",
  "media"
)

$blockedPatterns = @(
  "\bSlay\b",
  "\bSpire\b",
  "Pokemon",
  "Pokémon",
  "Hearthstone",
  "Dota",
  "Super Auto",
  "\bSAP\b",
  "\bSTS\b",
  "Balatro",
  "Vampire",
  "Monster Rancher",
  "Backpack",
  "Bazaar",
  "JoJo",
  "Pokecenter",
  "Elite Four",
  "Master Ball",
  "Great Ball",
  "Ultra Ball",
  "X-Attack",
  "X-Defense",
  "Life Orb",
  "Focus Band",
  "Mega Button",
  "Fly, Surf",
  "public boundary",
  "safe to publish",
  "sanitized",
  "as an AI",
  "prompt history",
  "raw log",
  "real username",
  "API secret",
  "Discord",
  "C:\\"
)

$mojibakePatterns = @("â", "Ã", "�")

$failures = New-Object System.Collections.Generic.List[string]

function Add-Failure([string]$Message) {
  $script:failures.Add($Message) | Out-Null
}

function Get-PublicFiles {
  foreach ($entry in $publicRoots) {
    $path = Join-Path $Root $entry
    if (-not (Test-Path -LiteralPath $path)) { continue }
    $item = Get-Item -LiteralPath $path
    if ($item.PSIsContainer) {
      Get-ChildItem -LiteralPath $path -Recurse -File |
        Where-Object { $_.Extension -in @(".md", ".html", ".txt", ".yml", ".yaml", ".json") }
    } else {
      $item
    }
  }
}

$files = @(Get-PublicFiles)

foreach ($file in $files) {
  $relative = Resolve-Path -LiteralPath $file.FullName -Relative
  $text = Get-Content -Raw -LiteralPath $file.FullName

  foreach ($pattern in $blockedPatterns) {
    if ($text -match $pattern) {
      Add-Failure "$relative contains blocked public-doc pattern: $pattern"
    }
  }

  foreach ($pattern in $mojibakePatterns) {
    if ($text.Contains($pattern)) {
      Add-Failure "$relative contains likely mojibake character: $pattern"
    }
  }

  if ($file.Extension -eq ".md") {
    $linkMatches = [regex]::Matches($text, '\[[^\]]+\]\(([^)]+)\)')
    foreach ($match in $linkMatches) {
      $target = $match.Groups[1].Value
      if ($target -match '^(https?://|mailto:|#)') { continue }
      $targetPath = ($target -split '#')[0]
      if ([string]::IsNullOrWhiteSpace($targetPath)) { continue }
      $resolved = Join-Path $file.DirectoryName $targetPath
      if (-not (Test-Path -LiteralPath $resolved)) {
        Add-Failure "$relative has broken local link: $target"
      }
    }
  }
}

if ($failures.Count -gt 0) {
  Write-Host "Public docs check failed:" -ForegroundColor Red
  foreach ($failure in $failures) {
    Write-Host " - $failure" -ForegroundColor Red
  }
  exit 1
}

Write-Host "Public docs check passed." -ForegroundColor Green
