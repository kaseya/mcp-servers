# Installs the Datto RMM connector and skills for Claude Code. Run via install-claude-code.cmd.
$ErrorActionPreference = 'Stop'

function Fail($msg) { Write-Host "`nERROR: $msg" -ForegroundColor Red; exit 1 }

# Accepts the versioned release name (datto-rmm-1.2.3.mcpb) or the plain one.
# Several matches in one folder (e.g. an old and a new release) is an error, not a guess.
function Find-Release($versioned, $plain) {
  foreach ($d in @($PSScriptRoot, (Get-Location).Path)) {
    $m = @(Get-ChildItem -Path (Join-Path $d $versioned), (Join-Path $d $plain) -ErrorAction SilentlyContinue)
    if ($m.Count -gt 1) { Fail "Found more than one $versioned in $d. Keep only the release you want to install." }
    if ($m.Count -eq 1) { return $m[0].FullName }
  }
}
$mcpb = Find-Release 'datto-rmm-[0-9]*.mcpb' 'datto-rmm.mcpb'
$zip = Find-Release 'Datto-RMM-plugin-[0-9]*.zip' 'Datto-RMM-plugin.zip'
if (-not $mcpb) { Fail 'datto-rmm-<version>.mcpb not found. Put it in the same folder as this script.' }
if (-not $zip) { Fail 'Datto-RMM-plugin-<version>.zip not found. Put it in the same folder as this script.' }

if (-not (Get-Command node -ErrorAction SilentlyContinue)) { Fail 'Node.js is not installed. Install Node.js 22 or newer from https://nodejs.org, then run this again.' }
if ([int](((node -v) -replace '^v', '').Split('.')[0]) -lt 22) { Fail "Node.js $(node -v) is too old. Install Node.js 22 or newer." }
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) { Fail 'Claude Code (the "claude" command) is not installed or not on PATH.' }

Write-Host '[1/3] Installing connector...'
$dir = Join-Path $HOME '.drmm-mcpb-client'
$tmp = Join-Path $env:TEMP 'datto-rmm-connector.zip'
Copy-Item $mcpb $tmp -Force
Expand-Archive $tmp $dir -Force
Remove-Item $tmp
$bundle = Join-Path $dir 'dist\bundle.cjs'
if (-not (Test-Path $bundle)) { Fail "Connector files missing after extract ($bundle). Is datto-rmm.mcpb the right file?" }

Write-Host '[2/3] Enter your Datto RMM platform number, API key and API secret when asked.'
node $bundle setup
if ($LASTEXITCODE -ne 0) { Fail 'Credential setup failed. Run this script again.' }

$ErrorActionPreference = 'Continue'
claude mcp remove datto-rmm --scope user *> $null
$ErrorActionPreference = 'Stop'
claude mcp add --transport stdio --scope user datto-rmm -- node $bundle
if ($LASTEXITCODE -ne 0) { Fail 'Could not register the connector with Claude Code.' }

Write-Host '[3/3] Installing skills...'
$skills = Join-Path $HOME '.claude\skills\datto-rmm'
if (Test-Path $skills) { Remove-Item $skills -Recurse -Force }
Expand-Archive $zip $skills -Force

Write-Host "`nDone. Start 'claude' and ask: List my Datto RMM sites." -ForegroundColor Green
