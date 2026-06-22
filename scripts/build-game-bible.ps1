param(
  [string]$SourceRoot = (Join-Path $env:USERPROFILE "Documents\Gojomons"),
  [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"

$outDir = Join-Path $Root "docs\game-bible"
$dataDir = Join-Path $outDir "data"

function Read-SourceText([string]$RelativePath) {
  $path = Join-Path $SourceRoot $RelativePath
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing source file: $RelativePath. Pass -SourceRoot if the game repo lives elsewhere."
  }
  return [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
}

function Read-SourceJson([string]$RelativePath) {
  return (Read-SourceText $RelativePath) | ConvertFrom-Json
}

function Assert-CanonCount([string]$Name, [object]$Expected, [object]$Actual) {
  $expectedInt = [int]$Expected
  $actualInt = [int]$Actual
  if ($expectedInt -ne $actualInt) {
    throw "Canon count mismatch for ${Name}: manifest has $expectedInt, generated public snapshot has $actualInt."
  }
}

function Clean-Text([object]$Value) {
  if ($null -eq $Value) { return "" }
  $text = [string]$Value
  $text = $text.Replace([string][char]0x2019, "'").Replace([string][char]0x2018, "'")
  $text = $text.Replace([string][char]0x201C, '"').Replace([string][char]0x201D, '"')
  $text = $text.Replace([string][char]0x2014, " - ").Replace([string][char]0x2013, " - ")
  $text = $text.Replace([string][char]0x2026, "...")
  $text = $text.Replace([string][char]0x2192, " -> ")
  $text = [regex]::Replace($text, '[^\u0009\u000A\u000D\u0020-\u007E]', '')
  $text = $text -replace '\s+', ' '
  return $text.Trim()
}

function New-Slug([string]$Text) {
  $slug = (Clean-Text $Text).ToLowerInvariant() -replace '[^a-z0-9]+', '-'
  return $slug.Trim('-')
}

function Escape-MdCell([object]$Value) {
  $text = Clean-Text $Value
  if ([string]::IsNullOrWhiteSpace($text)) { return "-" }
  return ($text -replace '\|', '\|')
}

function Join-Values([object[]]$Values) {
  $items = @($Values) | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) } | ForEach-Object { Clean-Text $_ }
  if ($items.Count -eq 0) { return "-" }
  return ($items -join ", ")
}

function Find-MatchingBrace([string]$Text, [int]$OpenIndex) {
  $depth = 0
  $inString = $false
  $escape = $false
  $inComment = $false

  for ($i = $OpenIndex; $i -lt $Text.Length; $i++) {
    $ch = $Text[$i]

    if ($inComment) {
      if ($ch -eq "`n") { $inComment = $false }
      continue
    }

    if ($inString) {
      if ($escape) {
        $escape = $false
        continue
      }
      if ($ch -eq "\") {
        $escape = $true
        continue
      }
      if ($ch -eq '"') { $inString = $false }
      continue
    }

    if ($ch -eq "#") {
      $inComment = $true
      continue
    }
    if ($ch -eq '"') {
      $inString = $true
      continue
    }
    if ($ch -eq "{") {
      $depth += 1
      continue
    }
    if ($ch -eq "}") {
      $depth -= 1
      if ($depth -eq 0) { return $i }
    }
  }

  throw "Could not find matching brace."
}

function Get-DictEntries([string]$Text, [string[]]$MarkerPatterns) {
  $marker = $null
  $matchedPattern = ""
  foreach ($pattern in $MarkerPatterns) {
    $candidate = [regex]::Match($Text, $pattern)
    if ($candidate.Success) {
      $marker = $candidate
      $matchedPattern = $pattern
      break
    }
  }
  if ($null -eq $marker) { throw "Could not find dictionary marker: $($MarkerPatterns -join ' | ')" }

  $open = $Text.IndexOf("{", $marker.Index)
  if ($open -lt 0) { throw "Could not find dictionary opening brace: $matchedPattern" }
  $close = Find-MatchingBrace $Text $open
  $body = $Text.Substring($open + 1, $close - $open - 1)

  $entries = New-Object System.Collections.Generic.List[object]
  $inComment = $false

  for ($i = 0; $i -lt $body.Length; $i++) {
    $ch = $body[$i]
    if ($inComment) {
      if ($ch -eq "`n") { $inComment = $false }
      continue
    }
    if ($ch -eq "#") {
      $inComment = $true
      continue
    }
    if ($ch -ne '"') { continue }

    $j = $i + 1
    $escape = $false
    while ($j -lt $body.Length) {
      $cj = $body[$j]
      if ($escape) {
        $escape = $false
      } elseif ($cj -eq "\") {
        $escape = $true
      } elseif ($cj -eq '"') {
        break
      }
      $j += 1
    }
    if ($j -ge $body.Length) { break }

    $key = $body.Substring($i + 1, $j - $i - 1)
    $k = $j + 1
    while ($k -lt $body.Length -and [char]::IsWhiteSpace($body[$k])) { $k += 1 }
    if ($k -ge $body.Length -or $body[$k] -ne ":") { continue }
    $k += 1
    while ($k -lt $body.Length -and [char]::IsWhiteSpace($body[$k])) { $k += 1 }
    if ($k -ge $body.Length -or $body[$k] -ne "{") { continue }

    $entryClose = Find-MatchingBrace $body $k
    $block = $body.Substring($k, $entryClose - $k + 1)
    $entries.Add([pscustomobject]@{ Id = $key; Block = $block }) | Out-Null
    $i = $entryClose
  }

  return $entries
}

function Get-StringField([string]$Block, [string]$Name) {
  $pattern = '"' + [regex]::Escape($Name) + '"\s*:\s*"(?<value>(?:\\.|[^"])*)"'
  $m = [regex]::Match($Block, $pattern)
  if ($m.Success) { return Clean-Text $m.Groups["value"].Value }
  return ""
}

function Get-NumberField([string]$Block, [string]$Name) {
  $pattern = '"' + [regex]::Escape($Name) + '"\s*:\s*(?<value>-?\d+(?:\.\d+)?)'
  $m = [regex]::Match($Block, $pattern)
  if ($m.Success) {
    return [double]::Parse($m.Groups["value"].Value, [System.Globalization.CultureInfo]::InvariantCulture)
  }
  return $null
}

function Get-BoolField([string]$Block, [string]$Name) {
  $pattern = '"' + [regex]::Escape($Name) + '"\s*:\s*(?<value>true|false)'
  $m = [regex]::Match($Block, $pattern)
  if ($m.Success) { return $m.Groups["value"].Value -eq "true" }
  return $false
}

function Get-ArrayField([string]$Block, [string]$Name) {
  $pattern = '"' + [regex]::Escape($Name) + '"\s*:\s*\[(?<body>.*?)\]'
  $m = [regex]::Match($Block, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
  if (-not $m.Success) { return @() }
  return @([regex]::Matches($m.Groups["body"].Value, '"([^"]+)"') | ForEach-Object { Clean-Text $_.Groups[1].Value })
}

function Get-Learnset([string]$Block) {
  $pattern = '"learnset"\s*:\s*\[(?<body>.*?)\]'
  $m = [regex]::Match($Block, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
  if (-not $m.Success) { return @() }

  $items = New-Object System.Collections.Generic.List[object]
  foreach ($match in [regex]::Matches($m.Groups["body"].Value, '\{\s*"level"\s*:\s*(\d+)\s*,\s*"move"\s*:\s*"([^"]+)"\s*\}')) {
    $items.Add([pscustomobject]@{
      level = [int]$match.Groups[1].Value
      move = Clean-Text $match.Groups[2].Value
    }) | Out-Null
  }
  return $items
}

function Format-Accuracy([Nullable[double]]$Accuracy) {
  if ($null -eq $Accuracy) { return "-" }
  return ("{0}%" -f [int][math]::Round($Accuracy * 100))
}

function Public-ItemName([string]$Id, [string]$Name, [string]$Block) {
  if ((Get-StringField $Block "kind") -eq "ball") {
    $tier = Get-NumberField $Block "ball_tier"
    if (Get-BoolField $Block "guaranteed") { return "Perfect Capture Orb" }
    if ($tier -eq 1) { return "Standard Capture Orb" }
    if ($tier -eq 2) { return "Reliable Capture Orb" }
    if ($tier -eq 3) { return "Prime Capture Orb" }
    return "Capture Orb"
  }
  if ($Name.StartsWith("TM ")) { return "Training Manual: " + $Name.Substring(3) }
  if ($Block -match '(?s)"kind"\s*:\s*"stat_boost_temp".*?"stat"\s*:\s*"attack"') { return "Attack Amp" }
  if ($Block -match '(?s)"kind"\s*:\s*"stat_boost_temp".*?"stat"\s*:\s*"defense"') { return "Defense Amp" }
  if ($Block -match '(?s)"kind"\s*:\s*"damage_boost_all".*?"recoil_pct"\s*:') { return "Vitality Core" }
  if ($Block -match '"kind"\s*:\s*"survive_ko_chance"' -and -not (Get-BoolField $Block "once")) { return "Last Stand Band" }
  return Clean-Text $Name
}

function Public-ItemDescription([string]$Description) {
  $text = Clean-Text $Description
  $text = $text -replace '(?i)\bcapture ball\b', 'capture orb'
  $text = $text -replace '(?i)\bball\b', 'orb'
  $text = $text -replace '(?i)\bTM\b', 'training manual'
  return $text
}

function Get-MoveFlags([string]$Block) {
  $flags = New-Object System.Collections.Generic.List[string]
  if (Get-BoolField $Block "multi_target") { $flags.Add("AoE") | Out-Null }
  if ($null -ne (Get-NumberField $Block "hits_min")) { $flags.Add("multi-hit") | Out-Null }
  if ($null -ne (Get-NumberField $Block "drain")) { $flags.Add("drain") | Out-Null }
  $status = Get-StringField $Block "onhit_status"
  if ($status -ne "") { $flags.Add("status: $status") | Out-Null }
  if ($null -ne (Get-NumberField $Block "self_heal_pct")) { $flags.Add("heal") | Out-Null }
  if ($null -ne (Get-NumberField $Block "shield_pct")) { $flags.Add("shield") | Out-Null }
  if ($null -ne (Get-NumberField $Block "crit_rate_bonus")) { $flags.Add("crit") | Out-Null }
  if ($Block -match '"user_buff"\s*:') { $flags.Add("setup") | Out-Null }
  if ($Block -match '"target_debuff"\s*:') { $flags.Add("debuff") | Out-Null }
  if ($flags.Count -eq 0) { return @("damage") }
  return @($flags)
}

function Get-ItemCategory([string]$Id, [string]$Block) {
  $kind = Get-StringField $Block "kind"
  $slot = Get-StringField $Block "slot"
  if ($kind -eq "ball") { return "Capture" }
  if ($kind -eq "tm") { return "Training" }
  if ($slot -eq "master") { return "Master gear" }
  if (Get-BoolField $Block "type_change") { return "Type-change" }
  if ($Id -match '_charm$') { return "Element charm" }
  if ($Id -match '^prism_graft_') { return "Type graft" }
  if (Get-BoolField $Block "consumable") { return "Consumable" }
  return "Held item"
}

function Get-RelationList([string]$Block, [string]$Field, [int]$Sign) {
  $pattern = '"' + [regex]::Escape($Field) + '"\s*:\s*\{(?<body>.*?)\}'
  $m = [regex]::Match($Block, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
  if (-not $m.Success) { return @() }
  $out = @()
  foreach ($match in [regex]::Matches($m.Groups["body"].Value, '"([^"]+)"\s*:\s*([+-]?\d+)')) {
    if ([int]$match.Groups[2].Value -eq $Sign) {
      $out += Clean-Text $match.Groups[1].Value
    }
  }
  return $out
}

function Write-TextFile([string]$Path, [string[]]$Lines) {
  $content = (($Lines | ForEach-Object { Clean-Text $_ }) -join "`n") + "`n"
  [System.IO.File]::WriteAllText($Path, $content, [System.Text.UTF8Encoding]::new($false))
}

New-Item -ItemType Directory -Force -Path $outDir, $dataDir | Out-Null

$aspectsText = Read-SourceText "SYSTEMS\gojomons\AspectsDB.gd"
$movesText = Read-SourceText "SYSTEMS\moves\MovesDB.gd"
$itemsText = Read-SourceText "SYSTEMS\items\item_db.gd"
$relicsText = Read-SourceText "SYSTEMS\relics\relics_db.gd"
$typeChartText = Read-SourceText "SYSTEMS\gojomons\rules\type_chart.gd"
$gameManifest = Read-SourceJson "DOCUMENTATION\data\game_manifest.json"
$projectFacts = Read-SourceJson "DOCUMENTATION\data\project_facts.json"
$docsCanon = Read-SourceJson "DOCUMENTATION\data\docs_canon_manifest.json"

$typeOrder = @("Fire", "Water", "Life", "Machine", "Storm", "Mystic", "Light", "Dark", "Alien")
$typeIdentity = @{
  "Fire" = @{ Verbs = "Burn / Persist"; Service = "Forge, rebirth spark"; Bias = "damage, risk, pressure" }
  "Water" = @{ Verbs = "Cleanse / Flow"; Service = "Heal, cleanse, stabilize"; Bias = "sustain, flexible recovery" }
  "Life" = @{ Verbs = "Regrow / Revive"; Service = "Grow, nurture, regenerate"; Bias = "HP, drain, comeback value" }
  "Machine" = @{ Verbs = "Construct / Upgrade"; Service = "Upgrade, repair, retrofit"; Bias = "defense, augments, prep scaling" }
  "Storm" = @{ Verbs = "Overcharge / Chain"; Service = "Charge, accelerate, tune tempo"; Bias = "speed, multi-hit, volatility" }
  "Mystic" = @{ Verbs = "Foresee / Echo"; Service = "Attune, echo, prophecy"; Bias = "special power, repeat effects" }
  "Light" = @{ Verbs = "Protect / Reflect"; Service = "Bless, reveal, purify"; Bias = "shields, accuracy, prevention" }
  "Dark" = @{ Verbs = "Corrupt / Obscure"; Service = "Curse, bargain, drain"; Bias = "drain, crit, pressure over time" }
  "Alien" = @{ Verbs = "Mutate / Assimilate"; Service = "Mutate, distort, reroll"; Bias = "adaptation, type shifts, weird tempo" }
}

$realSpriteIds = @()
$realSpriteMatch = [regex]::Match($aspectsText, 'const\s+REAL_SPRITE_MONS:.*?\[(?<body>.*?)\]', [System.Text.RegularExpressions.RegexOptions]::Singleline)
if ($realSpriteMatch.Success) {
  $realSpriteIds = @([regex]::Matches($realSpriteMatch.Groups["body"].Value, '"([^"]+)"') | ForEach-Object { $_.Groups[1].Value })
}

$moveEntries = Get-DictEntries $movesText @('const\s+_MOVES:\s*Dictionary\s*=')
$moves = @()
foreach ($entry in $moveEntries) {
  $block = $entry.Block
  $name = Get-StringField $block "name"
  if ($name -eq "") { $name = $entry.Id }
  $moves += [pscustomobject]@{
    source_key = $entry.Id
    slug = New-Slug $name
    name = $name
    elements = @(Get-ArrayField $block "elements")
    style_tags = @(Get-ArrayField $block "style_tags")
    category = Get-StringField $block "category"
    power = Get-NumberField $block "power"
    accuracy = Get-NumberField $block "accuracy"
    flags = @(Get-MoveFlags $block)
    vfx_status = if ((Get-StringField $block "fx_override_scene") -ne "") { "Custom VFX" } else { "Fallback VFX" }
  }
}
$moveNameById = @{}
foreach ($move in $moves) { $moveNameById[$move.source_key] = $move.name }

$aspectEntries = Get-DictEntries $aspectsText @(
  'var\s+aspects\s*:=',
  'var\s+aspects\s*:\s*Variant\s*='
)
$mons = @()
foreach ($entry in $aspectEntries) {
  $block = $entry.Block
  $name = Get-StringField $block "display_name"
  if ($name -eq "") { $name = $entry.Id }
  $types = @(Get-ArrayField $block "types")
  $subtypes = @(Get-ArrayField $block "subtypes")
  $tags = @(Get-ArrayField $block "tags")
  $stats = @{
    hp = [int](Get-NumberField $block "base_hp")
    attack = [int](Get-NumberField $block "base_attack")
    defense = [int](Get-NumberField $block "base_defense")
    sp_attack = [int](Get-NumberField $block "base_sp_attack")
    sp_defense = [int](Get-NumberField $block "base_sp_defense")
    speed = [int](Get-NumberField $block "base_speed")
  }
  $bst = $stats.hp + $stats.attack + $stats.defense + $stats.sp_attack + $stats.sp_defense + $stats.speed
  $scene = Get-StringField $block "scene_path"
  $production = if ($realSpriteIds -contains $entry.Id) { "Sprite-backed" } elseif ($scene -match '_placeholder') { "Prototype marker" } else { "Scene under review" }

  $mons += [pscustomobject]@{
    source_key = $entry.Id
    slug = New-Slug $name
    name = $name
    types = $types
    subtypes = $subtypes
    style = Get-StringField $block "style"
    description = Clean-Text (Get-StringField $block "desc")
    stats = $stats
    bst = $bst
    default_moves = @(Get-ArrayField $block "default_moves")
    learnset = @(Get-Learnset $block)
    tags = $tags
    production_status = $production
    raw_block = $block
  }
}
$monNameById = @{}
foreach ($mon in $mons) { $monNameById[$mon.source_key] = $mon.name }

function Format-Evolution([string]$Block) {
  if ($Block -match '"evolve_conditions"\s*:\s*\{\s*\}') { return "-" }
  if ($Block -match '"branches"\s*:') {
    $branches = @()
    foreach ($match in [regex]::Matches($Block, '"into"\s*:\s*"([^"]+)".*?"condition"\s*:\s*"([^"]+)"', [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
      $targetId = $match.Groups[1].Value
      $target = if ($monNameById.ContainsKey($targetId)) { $monNameById[$targetId] } else { $targetId }
      $branches += "$target ($($match.Groups[2].Value))"
    }
    if ($branches.Count -gt 0) { return "Branches to " + ($branches -join "; ") }
    return "Branch data present"
  }
  $simple = [regex]::Match($Block, '"evolve_conditions"\s*:\s*\{.*?"into"\s*:\s*"([^"]+)".*?"level"\s*:\s*(\d+)', [System.Text.RegularExpressions.RegexOptions]::Singleline)
  if ($simple.Success) {
    $targetId = $simple.Groups[1].Value
    $target = if ($monNameById.ContainsKey($targetId)) { $monNameById[$targetId] } else { $targetId }
    return "Evolves to $target at level $($simple.Groups[2].Value)"
  }
  return "Evolution data present"
}

foreach ($mon in $mons) {
  $mon | Add-Member -NotePropertyName evolution -NotePropertyValue (Format-Evolution $mon.raw_block)
  $mon.PSObject.Properties.Remove("raw_block")
}

$itemEntries = Get-DictEntries $itemsText @('const\s+ITEMS:\s*Dictionary\s*=')
$items = @()
foreach ($entry in $itemEntries) {
  $block = $entry.Block
  $rawName = Get-StringField $block "name"
  if ($rawName -eq "") { $rawName = $entry.Id }
  $items += [pscustomobject]@{
    source_key = $entry.Id
    slug = New-Slug (Public-ItemName $entry.Id $rawName $block)
    name = Public-ItemName $entry.Id $rawName $block
    category = Get-ItemCategory $entry.Id $block
    price = Get-NumberField $block "price"
    rarity = Get-StringField $block "rarity"
    description = Public-ItemDescription (Get-StringField $block "description")
  }
}

$relicEntries = Get-DictEntries $relicsText @('const\s+RELICS:\s*Dictionary\s*=')
$relics = @()
foreach ($entry in $relicEntries) {
  $block = $entry.Block
  $name = Get-StringField $block "name"
  if ($name -eq "") { $name = $entry.Id }
  $relics += [pscustomobject]@{
    source_key = $entry.Id
    slug = New-Slug $name
    name = $name
    rarity = Get-StringField $block "rarity"
    role = Get-StringField $block "role"
    master_signature = Get-StringField $block "master_signature"
    description = Clean-Text (Get-StringField $block "description")
  }
}

$chartEntries = Get-DictEntries $typeChartText @('static\s+var\s+CHART:\s*Dictionary\s*=')
$chart = @{}
foreach ($entry in $chartEntries) {
  $chart[$entry.Id] = [pscustomobject]@{
    strong_into = @(Get-RelationList $entry.Block "offense" 1)
    struggles_into = @(Get-RelationList $entry.Block "offense" -1)
    resists = @(Get-RelationList $entry.Block "defense" -1)
    weak_to = @(Get-RelationList $entry.Block "defense" 1)
  }
}

$generatedDate = Get-Date -Format "yyyy-MM-dd"
$snapshotCounts = [pscustomobject]@{
  gojomons = $mons.Count
  moves = $moves.Count
  items = $items.Count
  relics = $relics.Count
  types = $typeOrder.Count
}

Assert-CanonCount "species" $gameManifest.counts.species $snapshotCounts.gojomons
Assert-CanonCount "moves" $gameManifest.counts.moves $snapshotCounts.moves
Assert-CanonCount "items" $gameManifest.counts.items $snapshotCounts.items
Assert-CanonCount "relics" $gameManifest.counts.relics $snapshotCounts.relics
Assert-CanonCount "types" $gameManifest.counts.types $snapshotCounts.types
Assert-CanonCount "project_facts.species" $projectFacts.content_counts.species $snapshotCounts.gojomons
Assert-CanonCount "project_facts.moves" $projectFacts.content_counts.moves $snapshotCounts.moves
Assert-CanonCount "project_facts.items" $projectFacts.content_counts.items $snapshotCounts.items
Assert-CanonCount "project_facts.relics" $projectFacts.content_counts.relics $snapshotCounts.relics
Assert-CanonCount "project_facts.types" $projectFacts.content_counts.types $snapshotCounts.types

$canonSnapshot = [pscustomobject]@{
  source_project = "Gojomons source game repo"
  validation = "Public extraction matched source canon counts at build time."
  source_files = [pscustomobject]@{
    docs_canon = "DOCUMENTATION/DOCS_CANON.md"
    docs_canon_manifest = "DOCUMENTATION/data/docs_canon_manifest.json"
    game_manifest = "DOCUMENTATION/data/game_manifest.json"
    project_facts = "DOCUMENTATION/data/project_facts.json"
  }
  docs_canon_updated = $docsCanon.updated
  content_counts = $gameManifest.counts
  repository_metrics = $projectFacts.repository_metrics
}

$snapshot = [pscustomobject]@{
  generated_on = $generatedDate
  canon = $canonSnapshot
  counts = $snapshotCounts
  gojomons = @($mons | Sort-Object name | Select-Object slug, name, types, subtypes, style, bst, production_status, evolution, tags, description)
  moves = @($moves | Sort-Object name | Select-Object slug, name, elements, category, power, accuracy, flags, vfx_status)
  items = @($items | Sort-Object name | Select-Object slug, name, category, price, rarity, description)
  relics = @($relics | Sort-Object name | Select-Object slug, name, rarity, role, master_signature, description)
}
$snapshotPath = Join-Path $dataDir "public-game-bible.json"
$snapshotJson = ($snapshot | ConvertTo-Json -Depth 8) + "`n"
[System.IO.File]::WriteAllText($snapshotPath, $snapshotJson, [System.Text.UTF8Encoding]::new($false))

$htmlPath = Join-Path $outDir "living-game-bible.html"
if (Test-Path -LiteralPath $htmlPath) {
  $html = [System.IO.File]::ReadAllText($htmlPath, [System.Text.Encoding]::UTF8)
  $html = [regex]::Replace(
    $html,
    '(?s)<script id="bibleDataFallback" type="application/json">.*?</script>',
    '<script id="bibleDataFallback" type="application/json">' + $snapshotJson.TrimEnd() + '</script>'
  )
  $html = [regex]::Replace($html, '<div class="home-metric"><b>\d+</b><span>species</span></div>', '<div class="home-metric"><b>' + $mons.Count + '</b><span>species</span></div>')
  $html = [regex]::Replace($html, '<div class="home-metric"><b>\d+</b><span>moves</span></div>', '<div class="home-metric"><b>' + $moves.Count + '</b><span>moves</span></div>')
  $html = [regex]::Replace($html, '<div class="home-metric"><b>\d+</b><span>items</span></div>', '<div class="home-metric"><b>' + $items.Count + '</b><span>items</span></div>')
  $html = [regex]::Replace($html, '<div class="home-metric"><b>\d+</b><span>relics</span></div>', '<div class="home-metric"><b>' + $relics.Count + '</b><span>relics</span></div>')
  $html = [regex]::Replace($html, '<div class="home-metric"><b>\d+</b><span>types plus Base</span></div>', '<div class="home-metric"><b>' + $typeOrder.Count + '</b><span>types plus Base</span></div>')
  $html = [regex]::Replace($html, '<div class="home-metric"><b>\d+</b><span>master specs</span></div>', '<div class="home-metric"><b>' + [int]$gameManifest.counts.master_specs + '</b><span>master specs</span></div>')
  $snapshotLine = "$($mons.Count) species, $($moves.Count) moves, $($items.Count) items, $($relics.Count) relics, $($typeOrder.Count) types plus Base, $([int]$gameManifest.counts.masters) masters, $([int]$gameManifest.counts.master_specs) specs."
  $html = [regex]::Replace($html, '\d+ species, \d+ moves, \d+ items, \d+ relics, \d+ types plus Base, \d+ masters(?: plus void)?, \d+ specs\.', $snapshotLine)
  [System.IO.File]::WriteAllText($htmlPath, $html, [System.Text.UTF8Encoding]::new($false))
}

$typeCounts = @{}
foreach ($type in $typeOrder) { $typeCounts[$type] = 0 }
foreach ($mon in $mons) {
  foreach ($type in $mon.types) {
    if (-not $typeCounts.ContainsKey($type)) { $typeCounts[$type] = 0 }
    $typeCounts[$type] += 1
  }
}

$styleCounts = $mons | Group-Object style | Sort-Object Name
$productionCounts = $mons | Group-Object production_status | Sort-Object Name
$legendaryMons = @($mons | Where-Object { $_.tags -contains "legendary" } | Sort-Object name)

$readme = New-Object System.Collections.Generic.List[string]
$readme.Add("# Living Game Bible") | Out-Null
$readme.Add("") | Out-Null
$readme.Add("Generated from the current game data on $generatedDate. This is the one-stop public reference for the project spine, roster, types, moves, items, relics, and opponent structure. Counts are checked against the source game repo canon before this snapshot is written.") | Out-Null
$readme.Add("") | Out-Null
$readme.Add("## Interactive Bible") | Out-Null
$readme.Add("") | Out-Null
$readme.Add("- [Living Game Bible](living-game-bible.html): searchable HTML view for the current game shape, pipeline, roster/capture policy, type ledger, bestiary, masters, economy, catalog, bosses, balance, and roadmap.") | Out-Null
$readme.Add("") | Out-Null
$readme.Add("## Sections") | Out-Null
$readme.Add("- [Bestiary](bestiary.md): every current Gojomon, including type, style, stats, evolution notes, and production status.") | Out-Null
$readme.Add("- [Types](types.md): the nine-element model, type chart, service seeds, and roster balance.") | Out-Null
$readme.Add("- [Moves](moves.md): move catalog with element, category, power, accuracy, flags, and VFX status.") | Out-Null
$readme.Add("- [Items and relics](items-and-relics.md): current power objects and reward-building material.") | Out-Null
$readme.Add("- [Opponents](opponents.md): gyms, elites, legendary fights, wild waves, and what still needs wiring.") | Out-Null
$readme.Add("- [Public data snapshot](data/public-game-bible.json): generated data for future pages tooling.") | Out-Null
$readme.Add("") | Out-Null
$readme.Add("## Current Scale") | Out-Null
$readme.Add("| Area | Count |") | Out-Null
$readme.Add("|---|---:|") | Out-Null
$readme.Add("| Gojomons | $($mons.Count) |") | Out-Null
$readme.Add("| Moves | $($moves.Count) |") | Out-Null
$readme.Add("| Items | $($items.Count) |") | Out-Null
$readme.Add("| Relics | $($relics.Count) |") | Out-Null
$readme.Add("| Types | $($typeOrder.Count) |") | Out-Null
$readme.Add("") | Out-Null
$readme.Add("## Canon Sources") | Out-Null
$readme.Add('- `DOCUMENTATION/DOCS_CANON.md`: source ownership map.') | Out-Null
$readme.Add('- `DOCUMENTATION/data/game_manifest.json`: live content counts from the game repo.') | Out-Null
$readme.Add('- `DOCUMENTATION/data/project_facts.json`: repository metrics for showcase and portfolio pages.') | Out-Null
$readme.Add('- `data/public-game-bible.json`: this showcase snapshot, including the canon block used by future tooling.') | Out-Null
$readme.Add("") | Out-Null
$readme.Add("## Production Status Words") | Out-Null
$readme.Add("| Label | Meaning |") | Out-Null
$readme.Add("|---|---|") | Out-Null
$readme.Add("| Sprite-backed | Uses a dedicated creature scene currently listed as art-backed in the game data. |") | Out-Null
$readme.Add("| Prototype marker | Data-ready creature using the shared type-color marker until final art is made. |") | Out-Null
$readme.Add("| Custom VFX | Move has an authored or shared VFX scene assigned. |") | Out-Null
$readme.Add("| Fallback VFX | Move currently relies on the generic element-colored fallback. |") | Out-Null
$readme.Add("") | Out-Null
$readme.Add("## Maintenance") | Out-Null
$readme.Add("Regenerate after changing roster, moves, items, relics, or type-chart data. Prefer the source game repo runner because it refreshes the canon first:") | Out-Null
$readme.Add("") | Out-Null
$readme.Add('```powershell') | Out-Null
$readme.Add('# Run from the private/source Gojomons repo:') | Out-Null
$readme.Add('powershell -NoProfile -ExecutionPolicy Bypass -File DOCUMENTATION/tools/refresh_docs_canon.ps1') | Out-Null
$readme.Add("") | Out-Null
$readme.Add("# Showcase-only fallback:") | Out-Null
$readme.Add("powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build-game-bible.ps1") | Out-Null
$readme.Add("powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-public-docs.ps1") | Out-Null
$readme.Add('```') | Out-Null
Write-TextFile (Join-Path $outDir "README.md") $readme

$bestiary = New-Object System.Collections.Generic.List[string]
$bestiary.Add("# Gojomon Bestiary") | Out-Null
$bestiary.Add("") | Out-Null
$bestiary.Add("Generated on $generatedDate from the current roster database. The table gives the fast scan; the entries below it give the usable creature notes.") | Out-Null
$bestiary.Add("") | Out-Null
$bestiary.Add("## Roster Balance") | Out-Null
$bestiary.Add("| Type | Count |") | Out-Null
$bestiary.Add("|---|---:|") | Out-Null
foreach ($type in $typeOrder) { $bestiary.Add("| $type | $($typeCounts[$type]) |") | Out-Null }
$bestiary.Add("") | Out-Null
$bestiary.Add("| Style | Count |") | Out-Null
$bestiary.Add("|---|---:|") | Out-Null
foreach ($group in $styleCounts) { $bestiary.Add("| $($group.Name) | $($group.Count) |") | Out-Null }
$bestiary.Add("") | Out-Null
$bestiary.Add("| Production status | Count |") | Out-Null
$bestiary.Add("|---|---:|") | Out-Null
foreach ($group in $productionCounts) { $bestiary.Add("| $($group.Name) | $($group.Count) |") | Out-Null }
$bestiary.Add("") | Out-Null
$bestiary.Add("## Roster Table") | Out-Null
$bestiary.Add("| Gojomon | Type(s) | Style | BST | Production | Evolution |") | Out-Null
$bestiary.Add("|---|---|---|---:|---|---|") | Out-Null
foreach ($mon in ($mons | Sort-Object name)) {
  $bestiary.Add("| $(Escape-MdCell $mon.name) | $(Escape-MdCell (Join-Values $mon.types)) | $(Escape-MdCell $mon.style) | $($mon.bst) | $(Escape-MdCell $mon.production_status) | $(Escape-MdCell $mon.evolution) |") | Out-Null
}
$bestiary.Add("") | Out-Null
$bestiary.Add("## Bestiary Entries") | Out-Null
foreach ($mon in ($mons | Sort-Object name)) {
  $defaultMoves = @($mon.default_moves | ForEach-Object { if ($moveNameById.ContainsKey($_)) { $moveNameById[$_] } else { $_ } })
  $learnset = @($mon.learnset | ForEach-Object {
    $moveName = if ($moveNameById.ContainsKey($_.move)) { $moveNameById[$_.move] } else { $_.move }
    "L$($_.level) $moveName"
  })
  $statsLine = "HP $($mon.stats.hp), Atk $($mon.stats.attack), Def $($mon.stats.defense), SpA $($mon.stats.sp_attack), SpD $($mon.stats.sp_defense), Spd $($mon.stats.speed)"
  $bestiary.Add("") | Out-Null
  $bestiary.Add("### $($mon.name)") | Out-Null
  $bestiary.Add("- Types: $(Join-Values $mon.types). Subtypes: $(Join-Values $mon.subtypes).") | Out-Null
  $bestiary.Add("- Style: $($mon.style). BST: $($mon.bst). Status: $($mon.production_status).") | Out-Null
  $bestiary.Add("- Stats: $statsLine.") | Out-Null
  $bestiary.Add("- Default moves: $(Join-Values $defaultMoves).") | Out-Null
  $bestiary.Add("- Learnset: $(Join-Values $learnset).") | Out-Null
  $bestiary.Add("- Evolution: $($mon.evolution).") | Out-Null
  if (-not [string]::IsNullOrWhiteSpace($mon.description)) {
    $bestiary.Add("- Note: $($mon.description)") | Out-Null
  }
}
Write-TextFile (Join-Path $outDir "bestiary.md") $bestiary

$typesDoc = New-Object System.Collections.Generic.List[string]
$typesDoc.Add("# Type Breakdown") | Out-Null
$typesDoc.Add("") | Out-Null
$typesDoc.Add("The game uses nine elements plus neutral Base moves. Type math is additive: each advantage adds 0.5, each disadvantage subtracts 0.5, and the final multiplier clamps at zero.") | Out-Null
$typesDoc.Add("") | Out-Null
$typesDoc.Add("| Type | Roster | Verbs | Strong into | Struggles into | Resists | Weak to | Service seed |") | Out-Null
$typesDoc.Add("|---|---:|---|---|---|---|---|---|") | Out-Null
foreach ($type in $typeOrder) {
  $c = $chart[$type]
  $id = $typeIdentity[$type]
  $typesDoc.Add("| $type | $($typeCounts[$type]) | $(Escape-MdCell $id.Verbs) | $(Escape-MdCell (Join-Values $c.strong_into)) | $(Escape-MdCell (Join-Values $c.struggles_into)) | $(Escape-MdCell (Join-Values $c.resists)) | $(Escape-MdCell (Join-Values $c.weak_to)) | $(Escape-MdCell $id.Service) |") | Out-Null
}
$typesDoc.Add("") | Out-Null
$typesDoc.Add("## Type Notes") | Out-Null
foreach ($type in $typeOrder) {
  $id = $typeIdentity[$type]
  $names = @($mons | Where-Object { $_.types -contains $type } | Sort-Object name | ForEach-Object { $_.name })
  $typesDoc.Add("") | Out-Null
  $typesDoc.Add("### $type") | Out-Null
  $typesDoc.Add("- Current roster: $(Join-Values $names).") | Out-Null
  $typesDoc.Add("- Mechanical lean: $($id.Bias).") | Out-Null
  $typesDoc.Add("- Service seed: $($id.Service).") | Out-Null
}
Write-TextFile (Join-Path $outDir "types.md") $typesDoc

$movesDoc = New-Object System.Collections.Generic.List[string]
$movesDoc.Add("# Move Catalog") | Out-Null
$movesDoc.Add("") | Out-Null
$movesDoc.Add("Generated on $generatedDate from the move database. The catalog tracks combat role and production status without exposing local project paths.") | Out-Null
$movesDoc.Add("") | Out-Null
$movesDoc.Add("| Move | Element(s) | Category | Power | Accuracy | Flags | Style tags | VFX |") | Out-Null
$movesDoc.Add("|---|---|---|---:|---:|---|---|---|") | Out-Null
foreach ($move in ($moves | Sort-Object name)) {
  $power = if ($null -eq $move.power) { "-" } else { [string][int]$move.power }
  $movesDoc.Add("| $(Escape-MdCell $move.name) | $(Escape-MdCell (Join-Values $move.elements)) | $(Escape-MdCell $move.category) | $power | $(Escape-MdCell (Format-Accuracy $move.accuracy)) | $(Escape-MdCell (Join-Values $move.flags)) | $(Escape-MdCell (Join-Values $move.style_tags)) | $(Escape-MdCell $move.vfx_status) |") | Out-Null
}
Write-TextFile (Join-Path $outDir "moves.md") $movesDoc

$itemsDoc = New-Object System.Collections.Generic.List[string]
$itemsDoc.Add("# Items And Relics") | Out-Null
$itemsDoc.Add("") | Out-Null
$itemsDoc.Add("Generated on $generatedDate from the item and relic databases. Public names here favor original language for capture and training objects even when older source keys still need a naming pass.") | Out-Null
$itemsDoc.Add("") | Out-Null
$itemsDoc.Add("## Items") | Out-Null
$itemsDoc.Add("| Item | Category | Price | Rarity | Description |") | Out-Null
$itemsDoc.Add("|---|---|---:|---|---|") | Out-Null
foreach ($item in ($items | Sort-Object category, name)) {
  $price = if ($null -eq $item.price) { "-" } else { [string][int]$item.price }
  $itemsDoc.Add("| $(Escape-MdCell $item.name) | $(Escape-MdCell $item.category) | $price | $(Escape-MdCell $item.rarity) | $(Escape-MdCell $item.description) |") | Out-Null
}
$itemsDoc.Add("") | Out-Null
$itemsDoc.Add("## Relics") | Out-Null
$itemsDoc.Add("| Relic | Rarity | Role | Signature | Description |") | Out-Null
$itemsDoc.Add("|---|---|---|---|---|") | Out-Null
foreach ($relic in ($relics | Sort-Object rarity, role, name)) {
  $itemsDoc.Add("| $(Escape-MdCell $relic.name) | $(Escape-MdCell $relic.rarity) | $(Escape-MdCell $relic.role) | $(Escape-MdCell $relic.master_signature) | $(Escape-MdCell $relic.description) |") | Out-Null
}
$itemsDoc.Add("") | Out-Null
$itemsDoc.Add("## Follow-Up Calls") | Out-Null
$itemsDoc.Add("- Rename older capture and teaching source keys to the public language when it is convenient, then regenerate this page.") | Out-Null
$itemsDoc.Add("- Decide which items are shop goods, boss rewards, route rewards, and rare event finds.") | Out-Null
$itemsDoc.Add("- Keep relics run-defining and items tactical; avoid letting both lists collapse into passive stat boosts.") | Out-Null
Write-TextFile (Join-Path $outDir "items-and-relics.md") $itemsDoc

$opponentsDoc = New-Object System.Collections.Generic.List[string]
$opponentsDoc.Add("# Opponents And Bosses") | Out-Null
$opponentsDoc.Add("") | Out-Null
$opponentsDoc.Add("The opponent model is built from the same creature database as the player roster. The current source has scalable builders for type gyms, mixed elites, single-mon mega fights, legendary showcases, and larger wild-wave rosters.") | Out-Null
$opponentsDoc.Add("") | Out-Null
$opponentsDoc.Add("## Current Opponent Builders") | Out-Null
$opponentsDoc.Add("| Builder | Purpose | Current shape |") | Out-Null
$opponentsDoc.Add("|---|---|---|") | Out-Null
$opponentsDoc.Add("| Type gym | Type-themed town or milestone fight | Tiered level band and team size; pulls from matching roster types and arms an ace with an AoE move. |") | Out-Null
$opponentsDoc.Add("| Elite | Mid-route spike or filler boss | Mixed non-legendary team slightly above player level. |") | Out-Null
$opponentsDoc.Add("| Mega | One large mid-game wall | Single non-legendary mon with level, HP, and offense boosts. |") | Out-Null
$opponentsDoc.Add("| Legendary | Showcase boss | One high-level legendary matching the requested type when available. |") | Out-Null
$opponentsDoc.Add("| Wild wave | Horde-style pressure | Larger mixed team until true wave refill exists. |") | Out-Null
$opponentsDoc.Add("") | Out-Null
$opponentsDoc.Add("## Legendary Roster") | Out-Null
$opponentsDoc.Add("| Legendary | Type(s) | Style | BST | Note |") | Out-Null
$opponentsDoc.Add("|---|---|---|---:|---|") | Out-Null
foreach ($mon in $legendaryMons) {
  $opponentsDoc.Add("| $(Escape-MdCell $mon.name) | $(Escape-MdCell (Join-Values $mon.types)) | $(Escape-MdCell $mon.style) | $($mon.bst) | $(Escape-MdCell $mon.description) |") | Out-Null
}
$opponentsDoc.Add("") | Out-Null
$opponentsDoc.Add("## Implementation Calls") | Out-Null
$opponentsDoc.Add("- Wire type gyms into the town/gym buildings as the main typed milestone fights.") | Out-Null
$opponentsDoc.Add("- Place legendary fights into finale or last-room route contexts instead of treating every boss as an elite variant.") | Out-Null
$opponentsDoc.Add("- Add true wave refill behavior when the battle loop is ready; the current larger-team wave is a useful stand-in.") | Out-Null
$opponentsDoc.Add("- Give major bosses one visible gimmick beyond stat scaling so the player can read what the fight is asking.") | Out-Null
Write-TextFile (Join-Path $outDir "opponents.md") $opponentsDoc

Write-Host "Game bible generated in $outDir"
