<#
.SYNOPSIS
    Keeps Autotask API credentials encrypted for the current Windows user and prints them as MCP request
    headers for Claude Code's `headersHelper` and Codex CLI's `http_headers_helper`.

.DESCRIPTION
    The credentials rest in a DPAPI-encrypted file under %LOCALAPPDATA%, readable only by the Windows user
    who wrote it, on the machine that wrote it. No MCP client configuration holds a credential: it holds the
    `headers` command, which prints the three headers on stdout when the client connects.

    `headers` is the one verb a client runs. It never prompts, never touches the network, and writes one JSON
    object to stdout or nothing at all. No verb writes a credential value to stdout except `headers`, and no
    verb writes one to stderr.

    Written for Windows PowerShell 5.1, which every supported Windows version ships, so nothing is installed
    before enrolment.

.EXAMPLE
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\autotask-auth.ps1 configure -Endpoint https://mcp3.autotask.net/mcp

.EXAMPLE
    powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File .\autotask-auth.ps1 headers -Profile default
#>
[CmdletBinding()]
param(
    # `headers` when omitted, because Claude Desktop runs a managed-configuration helper by its path alone,
    # with no arguments.
    [Parameter(Position = 0)]
    [ValidateSet('configure', 'headers', 'status', 'clear')]
    [string] $Verb = 'headers',

    # `-Profile` on the command line. The variable is not named `$Profile`, which is PowerShell's automatic
    # variable for the profile script path.
    [Alias('Profile')]
    [ValidatePattern('^[A-Za-z0-9_-]{1,64}$')]
    [string] $ProfileName = 'default',

    [string] $Endpoint,

    # `status` only: repeat the enrolment check against the server. Costs one Autotask authentication attempt.
    [switch] $Verify,

    # `configure` only: read the username, secret, and integration code as three lines on stdin instead of
    # prompting, for scripted enrolment. The values never appear as arguments, which every same-user process
    # can read from the process list.
    [switch] $FromStdin
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

# A process started from PowerShell 7 passes on a PSModulePath that lists PowerShell 7's module folders
# first. Windows PowerShell 5.1 then finds PowerShell 7's copy of Microsoft.PowerShell.Security, fails to load
# it, and every SecureString cmdlet is missing. This process uses Windows PowerShell's own folders alone; the
# change reaches no other process.
if ($PSVersionTable.PSEdition -eq 'Desktop') {
    $env:PSModulePath = @(
        (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'WindowsPowerShell\Modules'),
        (Join-Path $env:ProgramFiles 'WindowsPowerShell\Modules'),
        (Join-Path $PSHOME 'Modules')
    ) -join ';'
}

<#
    The version of the stored record's shape. A record of another version is refused rather than guessed at,
    so a later script that changes the shape cannot misread an older record.
#>
$RECORD_VERSION = 1

<#
    The MCP protocol revision `configure` names in its `initialize` check. The server serves this revision and
    2026-07-28; the check needs only an answer to admission, which runs before protocol negotiation.
#>
$INITIALIZE_PROTOCOL_VERSION = '2025-06-18'

<#
    The enrolment check's time limit, in seconds. Admission runs zone discovery and one Autotask
    authentication, which the server bounds under its own call deadline; thirty seconds is that deadline with
    room for a slow network.
#>
$CHECK_TIMEOUT_SECONDS = 30

<#
    The hosts `configure` sends the credentials to: the Autotask MCP Regional endpoints, `mcp` followed by the
    zone's own token under `autotask.net` — `mcp3.autotask.net`, `mcpprde.autotask.net`. The Desktop
    extension's relay applies the same rule, so a mistyped or suggested endpoint receives the credentials
    from neither.
#>
$REGIONAL_ENDPOINT_HOST = '^mcp[a-z0-9]*\.autotask\.net$'

$storeDirectory = Join-Path $env:LOCALAPPDATA 'Kaseya\AutotaskMcp'
$recordPath = Join-Path $storeDirectory "$ProfileName.clixml"

function Write-Failure([string] $message) {
    [Console]::Error.WriteLine("autotask-auth: $message")
}

function Get-PlainText([securestring] $secureValue) {
    (New-Object System.Management.Automation.PSCredential('unused', $secureValue)).GetNetworkCredential().Password
}

function ConvertTo-SecureValue([string] $plainValue) {
    ConvertTo-SecureString -String $plainValue -AsPlainText -Force
}

function Assert-StoreUsable {
    # DPAPI needs the user's key, which some logon types (an SSH session among them) may not load. A round
    # trip of a throwaway value proves the key is there before anything real is written.
    try {
        $probe = ConvertTo-SecureValue 'autotask-auth-probe'
        $roundTripped = ConvertTo-SecureString (ConvertFrom-SecureString $probe)
        if ((Get-PlainText $roundTripped) -ne 'autotask-auth-probe') { throw 'mismatch' }
    }
    catch {
        Write-Failure "Windows could not encrypt a value for this user in this session ($($_.Exception.GetType().Name)). Enrol from an interactive or Remote Desktop session."
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
        Write-Failure "The credentials for profile `"$ProfileName`" could not be decrypted by this Windows user. Run: autotask-auth configure -Profile $ProfileName"
        exit 4
    }
    if ($record.Version -ne $RECORD_VERSION) {
        Write-Failure "The credentials for profile `"$ProfileName`" were stored by an incompatible version of autotask-auth. Run: autotask-auth configure -Profile $ProfileName"
        exit 4
    }
    return $record
}

function Build-HeaderJson([string] $userName, [string] $secret, [string] $integrationCode) {
    $headers = [ordered]@{
        ApiIntegrationCode = $integrationCode
        UserName           = $userName
        Secret             = $secret
    }
    ConvertTo-Json -InputObject $headers -Compress
}

function Write-StdoutUtf8([string] $text) {
    # Windows PowerShell 5.1 encodes piped output in the console code page, which would corrupt a non-ASCII
    # secret. Writing bytes to the raw stream sends UTF-8 with no byte-order mark, whatever the code page.
    $bytes = (New-Object System.Text.UTF8Encoding($false)).GetBytes($text)
    $stdout = [Console]::OpenStandardOutput()
    $stdout.Write($bytes, 0, $bytes.Length)
    $stdout.Flush()
}

function Assert-NoControlCharacter([string] $label, [string] $value) {
    if ($value -match '[\x00-\x1F\x7F]') {
        Write-Failure "$label contains a control character. Autotask credentials never do; check what was pasted."
        exit 2
    }
}

function Assert-RegionalEndpoint([string] $endpointUrl) {
    <#
        Returns the endpoint in canonical form when it is `https://` on the default port, a host that matches
        $REGIONAL_ENDPOINT_HOST, and the path `/mcp` with no user information, query, or fragment. Otherwise
        exits with code 2 before any request carries the credentials.
    #>
    $endpointUri = $null
    $isRegionalEndpoint = [Uri]::TryCreate($endpointUrl.Trim(), [UriKind]::Absolute, [ref] $endpointUri) -and
        $endpointUri.Scheme -eq 'https' -and
        $endpointUri.IsDefaultPort -and
        $endpointUri.UserInfo -eq '' -and
        $endpointUri.Host -cmatch $REGIONAL_ENDPOINT_HOST -and
        $endpointUri.AbsolutePath -eq '/mcp' -and
        $endpointUri.Query -eq '' -and
        $endpointUri.Fragment -eq ''
    if (-not $isRegionalEndpoint) {
        # The endpoint is not a secret, so the message quotes it: a value pasted twice is plain to see.
        Write-Failure "`"$endpointUrl`" is not an Autotask MCP endpoint. It is https://, then the mcp host for your Autotask zone, then /mcp, for example https://mcp3.autotask.net/mcp."
        exit 2
    }
    return $endpointUri.AbsoluteUri
}

function Invoke-EnrolmentCheck([string] $endpointUrl, [string] $userName, [string] $secret, [string] $integrationCode) {
    <#
        Sends one MCP `initialize`. Admission authenticates with Autotask before it answers, so a `200` proves
        the credentials, and a refusal carries the taxonomy code that says why. Returns an object with
        `Status`, `Code`, and `Message`; never includes a credential value.
    #>
    Add-Type -AssemblyName System.Net.Http
    # .NET Framework on older Windows builds offers TLS 1.0 by default, which Front Door refuses.
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    # A followed redirect would carry the three custom credential headers to wherever it points: the handler
    # drops only `Authorization` on a redirect, not a header it does not know is a credential. With redirects
    # off, a 3xx reaches the caller as a refusal and nothing is stored.
    $handler = New-Object System.Net.Http.HttpClientHandler
    $handler.AllowAutoRedirect = $false
    $httpClient = New-Object System.Net.Http.HttpClient($handler)
    $httpClient.Timeout = [TimeSpan]::FromSeconds($CHECK_TIMEOUT_SECONDS)
    try {
        $body = ConvertTo-Json -Compress -Depth 5 -InputObject ([ordered]@{
                jsonrpc = '2.0'
                id      = 1
                method  = 'initialize'
                params  = [ordered]@{
                    protocolVersion = $INITIALIZE_PROTOCOL_VERSION
                    capabilities    = @{}
                    clientInfo      = [ordered]@{ name = 'autotask-auth'; version = '0.1.0' }
                }
            })
        $request = New-Object System.Net.Http.HttpRequestMessage([System.Net.Http.HttpMethod]::Post, $endpointUrl)
        $request.Content = New-Object System.Net.Http.StringContent($body, [System.Text.Encoding]::UTF8, 'application/json')
        [void] $request.Headers.TryAddWithoutValidation('Accept', 'application/json, text/event-stream')
        [void] $request.Headers.TryAddWithoutValidation('ApiIntegrationCode', $integrationCode)
        [void] $request.Headers.TryAddWithoutValidation('UserName', $userName)
        [void] $request.Headers.TryAddWithoutValidation('Secret', $secret)

        try {
            $response = $httpClient.SendAsync($request).GetAwaiter().GetResult()
        }
        catch {
            return [pscustomobject]@{ Status = 0; Code = 'NETWORK'; Message = "Could not reach $endpointUrl." }
        }
        $status = [int] $response.StatusCode
        if ($status -eq 200) {
            return [pscustomobject]@{ Status = 200; Code = $null; Message = $null }
        }

        # Admission refusals carry `{ code, message }` and, for REGION_MISMATCH, `attemptedZoneHost`. The
        # server never puts a credential value in either field.
        $code = $null
        $message = $null
        try {
            $parsed = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult() | ConvertFrom-Json
            if ($parsed.PSObject.Properties['code']) { $code = [string] $parsed.code }
            if ($parsed.PSObject.Properties['message']) { $message = [string] $parsed.message }
        }
        catch { }
        return [pscustomobject]@{ Status = $status; Code = $code; Message = $message }
    }
    finally {
        $httpClient.Dispose()
    }
}

function Get-MaskedUserName([string] $userName) {
    $at = $userName.IndexOf('@')
    if ($at -lt 1) { return '***' }
    return $userName.Substring(0, 1) + '***' + $userName.Substring($at)
}

function Get-HelperCommand {
    $scriptPath = $PSCommandPath
    "powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$scriptPath`" headers -Profile $ProfileName"
}

function Write-ClientConfiguration([string] $endpointUrl) {
    $helperCommand = Get-HelperCommand
    $claudeEntry = ConvertTo-Json -Depth 3 -InputObject ([ordered]@{
            type          = 'http'
            url           = $endpointUrl
            headersHelper = $helperCommand
        })
    # TOML basic strings escape `\` and `"` the same way JSON does.
    $tomlCommand = ConvertTo-Json -InputObject $helperCommand

    Write-Host ''
    Write-Host 'Claude Code: add this server to the "mcpServers" object in %USERPROFILE%\.claude.json:'
    Write-Host ''
    Write-Host "`"autotask`": $claudeEntry"
    Write-Host ''
    Write-Host 'Codex CLI: add this to %USERPROFILE%\.codex\config.toml:'
    Write-Host ''
    Write-Host '[mcp_servers.autotask]'
    Write-Host "url = `"$endpointUrl`""
    Write-Host "http_headers_helper = $tomlCommand"
    Write-Host ''
    Write-Host 'Neither entry contains a credential. Start or reconnect the client to use it.'
}

function Invoke-Configure {
    Assert-StoreUsable

    $endpointUrl = $Endpoint
    if (-not $endpointUrl) {
        if ($FromStdin) { Write-Failure '-Endpoint is required with -FromStdin.'; exit 2 }
        $endpointUrl = Read-Host 'Autotask MCP endpoint (for example https://mcp3.autotask.net/mcp)'
    }
    $endpointUrl = Assert-RegionalEndpoint $endpointUrl

    if ($FromStdin) {
        $userName = [Console]::In.ReadLine()
        $secret = [Console]::In.ReadLine()
        $integrationCode = [Console]::In.ReadLine()
        if ($null -eq $userName -or $null -eq $secret -or $null -eq $integrationCode) {
            Write-Failure '-FromStdin expects three lines: the username, the secret, and the integration code.'
            exit 2
        }
    }
    else {
        $userName = Read-Host 'Autotask API username'
        $secret = Get-PlainText (Read-Host 'Autotask API secret' -AsSecureString)
        $integrationCode = Get-PlainText (Read-Host 'Autotask API integration code' -AsSecureString)
    }
    $userName = $userName.Trim()
    $secret = $secret.Trim()
    $integrationCode = $integrationCode.Trim()

    foreach ($field in @(@('The username', $userName), @('The secret', $secret), @('The integration code', $integrationCode))) {
        if ($field[1].Length -eq 0) { Write-Failure "$($field[0]) is empty."; exit 2 }
        Assert-NoControlCharacter $field[0] $field[1]
    }
    if ($secret.StartsWith('token::')) {
        Write-Failure 'The secret is a short-lived token::... value. Store the API user''s password, which does not expire.'
        exit 2
    }

    [Console]::Error.WriteLine("Checking the credentials with $endpointUrl ...")
    $result = Invoke-EnrolmentCheck $endpointUrl $userName $secret $integrationCode
    switch ($result.Status) {
        200 { }
        0 {
            Write-Failure "$($result.Message) Nothing was stored."
            exit 5
        }
        401 {
            Write-Failure "The server refused the credentials: $($result.Message) Nothing was stored."
            [Console]::Error.WriteLine('If you have just corrected the API user in Autotask without changing its secret, wait two minutes and try again.')
            exit 6
        }
        400 {
            Write-Failure "$($result.Message) Nothing was stored."
            exit 7
        }
        default {
            $detail = if ($result.Code) { " ($($result.Code))" } else { '' }
            Write-Failure "The server answered HTTP $($result.Status)$detail. Nothing was stored."
            exit 8
        }
    }

    if (-not (Test-Path -LiteralPath $storeDirectory)) {
        [void] (New-Item -ItemType Directory -Path $storeDirectory)
    }
    # Export-Clixml encrypts each SecureString with DPAPI for the current user. The endpoint is not a secret.
    [pscustomobject]@{
        Version            = $RECORD_VERSION
        Endpoint           = $endpointUrl
        UserName           = ConvertTo-SecureValue $userName
        Secret             = ConvertTo-SecureValue $secret
        ApiIntegrationCode = ConvertTo-SecureValue $integrationCode
    } | Export-Clixml -LiteralPath $recordPath -Force

    Write-Host "Credentials checked and stored for profile `"$ProfileName`", encrypted for this Windows user."
    Write-ClientConfiguration $endpointUrl
}

function Invoke-Headers {
    $record = Read-Record
    if ($null -eq $record) {
        Write-Failure "No Autotask credentials for profile `"$ProfileName`". Run: autotask-auth configure -Profile $ProfileName"
        exit 1
    }
    Write-StdoutUtf8 (Build-HeaderJson (Get-PlainText $record.UserName) (Get-PlainText $record.Secret) (Get-PlainText $record.ApiIntegrationCode))
}

function Invoke-Status {
    $record = Read-Record
    if ($null -eq $record) {
        Write-Host "Profile `"$ProfileName`": not configured."
        exit 1
    }
    $userName = Get-PlainText $record.UserName
    Write-Host "Profile:          $ProfileName"
    Write-Host "Storage:          DPAPI-encrypted file for this Windows user ($recordPath)"
    Write-Host "Endpoint:         $($record.Endpoint)"
    Write-Host "Username:         $(Get-MaskedUserName $userName)"
    Write-Host "Secret:           $(if ((Get-PlainText $record.Secret).Length -gt 0) { 'stored' } else { 'missing' })"
    Write-Host "Integration code: $(if ((Get-PlainText $record.ApiIntegrationCode).Length -gt 0) { 'stored' } else { 'missing' })"
    Write-Host "Helper command:   $(Get-HelperCommand)"

    if ($Verify) {
        $endpointUrl = Assert-RegionalEndpoint $record.Endpoint
        $result = Invoke-EnrolmentCheck $endpointUrl $userName (Get-PlainText $record.Secret) (Get-PlainText $record.ApiIntegrationCode)
        if ($result.Status -eq 200) {
            Write-Host 'Verification:     accepted by the server'
        }
        else {
            $detail = if ($result.Code) { "$($result.Code): $($result.Message)" } else { "HTTP $($result.Status)" }
            Write-Host "Verification:     refused, $detail"
            exit 6
        }
    }
}

function Invoke-Clear {
    if (-not (Test-Path -LiteralPath $recordPath)) {
        Write-Host "Profile `"$ProfileName`": nothing to clear."
        return
    }
    Remove-Item -LiteralPath $recordPath -Force
    Write-Host "Profile `"$ProfileName`" cleared. Remove any MCP client entry whose helper command ends in: headers -Profile $ProfileName"
}

switch ($Verb) {
    'configure' { Invoke-Configure }
    'headers' { Invoke-Headers }
    'status' { Invoke-Status }
    'clear' { Invoke-Clear }
}
