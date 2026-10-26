<#
.SYNOPSIS
    Keeps the IT Glue API key encrypted for the current Windows user, where the IT Glue Claude Desktop
    extension's relay reads it.

.DESCRIPTION
    The key rests in a DPAPI-encrypted file under %LOCALAPPDATA%, readable only by the Windows user who wrote
    it, on the machine that wrote it. Claude Desktop's settings hold no key, so the key is not in the
    environment or the arguments of the extension's process, which Claude Desktop displays.

    The relay (`dist/relay.cjs`) reads the same file, `<Region>.clixml`, with `Import-Clixml`. Claude Code's
    `headersHelper` runs the `headers` verb, which prints the request headers as one JSON object on stdout.
    `headers` never prompts and never touches the network. No other verb writes a key to stdout, and no verb
    writes one to stderr.

    Written for Windows PowerShell 5.1, which every supported Windows version ships.

.EXAMPLE
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\itglue-auth.ps1 configure -Region NA

.EXAMPLE
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\itglue-auth.ps1 status -Region NA

.EXAMPLE
    powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File .\itglue-auth.ps1 headers -Region NA
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateSet('configure', 'headers', 'status', 'clear')]
    [string] $Verb,

    [ValidateSet('NA', 'EU', 'AU')]
    [string] $Region = 'NA',

    # `configure` only: read the key as one line on stdin instead of prompting, for scripted enrolment. The
    # key never appears as an argument, which every same-user process can read from the process list.
    [switch] $FromStdin
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

# A process started from PowerShell 7 passes on a PSModulePath that lists PowerShell 7's module folders
# first. Windows PowerShell 5.1 then finds PowerShell 7's copy of Microsoft.PowerShell.Security, fails to load
# it, and every SecureString cmdlet is missing. This process uses Windows PowerShell's own folders alone.
if ($PSVersionTable.PSEdition -eq 'Desktop') {
    $env:PSModulePath = @(
        (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'WindowsPowerShell\Modules'),
        (Join-Path $env:ProgramFiles 'WindowsPowerShell\Modules'),
        (Join-Path $PSHOME 'Modules')
    ) -join ';'
}

# The version of the stored record's shape. A record of another version is refused rather than guessed at.
$RECORD_VERSION = 1

# The MCP protocol revision the IT Glue MCP server is asked to speak.
$MCP_PROTOCOL_VERSION = '2026-07-28'

# The shape of an IT Glue API key: `ITG.`, an identifier, a dot, and a secret. The relay applies the same check.
$API_KEY_SHAPE = '^ITG\.[^.\s]+\.[^.\s]+$'

$storeDirectory = Join-Path $env:LOCALAPPDATA 'Kaseya\ItGlueMcp'
$recordPath = Join-Path $storeDirectory "$($Region.ToLowerInvariant()).clixml"

function Write-Failure([string] $message) {
    [Console]::Error.WriteLine("itglue-auth: $message")
}

function Get-PlainText([securestring] $secureValue) {
    (New-Object System.Management.Automation.PSCredential('unused', $secureValue)).GetNetworkCredential().Password
}

function Assert-StoreUsable {
    # DPAPI needs the user's key, which some logon types (an SSH session among them) may not load. A round
    # trip of a throwaway value proves the key is there before anything real is written.
    try {
        $probe = ConvertTo-SecureString -String 'itglue-auth-probe' -AsPlainText -Force
        $roundTripped = ConvertTo-SecureString (ConvertFrom-SecureString $probe)
        if ((Get-PlainText $roundTripped) -ne 'itglue-auth-probe') { throw 'mismatch' }
    }
    catch {
        Write-Failure "Windows could not encrypt a value for this user in this session ($($_.Exception.GetType().Name)). Run this from an interactive or Remote Desktop session."
        exit 3
    }
}

function Read-Record {
    if (-not (Test-Path -LiteralPath $recordPath)) { return $null }
    try {
        $record = Import-Clixml -LiteralPath $recordPath
    }
    catch {
        # A record another user wrote, or one copied from another machine, fails to decrypt here.
        Write-Failure "The key for $Region could not be decrypted by this Windows user. Run: itglue-auth configure -Region $Region"
        exit 4
    }
    if ($record.Version -ne $RECORD_VERSION) {
        Write-Failure "The key for $Region was stored by an incompatible version. Run: itglue-auth configure -Region $Region"
        exit 4
    }
    return $record
}

function Invoke-Configure {
    Assert-StoreUsable

    if ($FromStdin) {
        $apiKey = [Console]::In.ReadLine()
        if ($null -eq $apiKey) { Write-Failure '-FromStdin expects one line: the API key.'; exit 2 }
    }
    else {
        $apiKey = Get-PlainText (Read-Host "IT Glue API key for $Region" -AsSecureString)
    }
    $apiKey = $apiKey.Trim()

    if ($apiKey -notmatch $API_KEY_SHAPE) {
        # The value is not quoted: it may still be a credential.
        Write-Failure 'That does not look like an IT Glue API key, which starts with ITG. Nothing was stored.'
        exit 2
    }

    if (-not (Test-Path -LiteralPath $storeDirectory)) {
        [void] (New-Item -ItemType Directory -Path $storeDirectory)
    }
    # Export-Clixml encrypts each SecureString with DPAPI for the current user.
    [pscustomobject]@{
        Version = $RECORD_VERSION
        Region  = $Region
        ApiKey  = ConvertTo-SecureString -String $apiKey -AsPlainText -Force
    } | Export-Clixml -LiteralPath $recordPath -Force

    Write-Host "API key stored for $Region, encrypted for this Windows user. Turn the extension off and on in Claude Desktop."
}

function Write-StdoutUtf8([string] $text) {
    # Windows PowerShell 5.1 encodes piped output in the console code page. Writing bytes to the raw stream
    # sends UTF-8 with no byte-order mark, whatever the code page.
    $bytes = (New-Object System.Text.UTF8Encoding($false)).GetBytes($text)
    $stdout = [Console]::OpenStandardOutput()
    $stdout.Write($bytes, 0, $bytes.Length)
    $stdout.Flush()
}

function Invoke-Headers {
    $record = Read-Record
    if ($null -eq $record) {
        Write-Failure "No IT Glue API key for $Region. Run: itglue-auth configure -Region $Region"
        exit 1
    }
    Write-StdoutUtf8 (ConvertTo-Json -Compress -InputObject ([ordered]@{
            'x-api-key'            = Get-PlainText $record.ApiKey
            'MCP-Protocol-Version' = $MCP_PROTOCOL_VERSION
        }))
}

function Invoke-Status {
    $record = Read-Record
    if ($null -eq $record) {
        Write-Host "${Region}: no key stored."
        exit 1
    }
    Write-Host "Region:  $Region"
    Write-Host "Storage: DPAPI-encrypted file for this Windows user ($recordPath)"
    Write-Host "Key:     $(if ((Get-PlainText $record.ApiKey).Length -gt 0) { 'stored' } else { 'missing' })"
}

function Invoke-Clear {
    if (-not (Test-Path -LiteralPath $recordPath)) {
        Write-Host "${Region}: nothing to clear."
        return
    }
    Remove-Item -LiteralPath $recordPath -Force
    Write-Host "${Region}: key removed."
}

switch ($Verb) {
    'configure' { Invoke-Configure }
    'headers' { Invoke-Headers }
    'status' { Invoke-Status }
    'clear' { Invoke-Clear }
}
