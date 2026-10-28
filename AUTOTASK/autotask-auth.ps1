<#
.SYNOPSIS
    Keeps Autotask API credentials encrypted for the current Windows user and prints them as MCP request
    headers for Claude Code's `headersHelper` and Codex CLI's `http_headers_helper`.

.DESCRIPTION
    The credentials rest in a DPAPI-encrypted file under %LOCALAPPDATA%, readable only by the Windows user
    who wrote it, on the machine that wrote it. No MCP client configuration holds a credential: it holds the
    `headers` command, which prints the two headers on stdout when the client connects.

    The API user must be created with the Integration Vendor "Autotask - MCP" as its API tracking identifier.
    The server sends that vendor's integration code itself, so this script stores and sends only the username
    and the secret.

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

    # `configure` only: read the username and the secret as two lines on stdin instead of prompting, for
    # scripted enrolment. The values never appear as arguments, which every same-user process
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
    so a later script that changes the shape cannot misread an older record. Version 2 holds the username and
    the secret alone. A version 1 record also held an integration code, and belongs to an API user the server
    refuses, so refusing it here keeps a client from spending a failed attempt on every connect.
#>
$RECORD_VERSION = 2

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

function Build-HeaderJson([string] $userName, [string] $secret) {
    $headers = [ordered]@{
        UserName = $userName
        Secret   = $secret
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

function Invoke-EnrolmentCheck([string] $endpointUrl, [string] $userName, [string] $secret) {
    <#
        Sends one MCP `initialize`. Admission authenticates with Autotask before it answers, so a `200` proves
        the credentials, and a refusal carries the taxonomy code that says why. Returns an object with
        `Status`, `Code`, and `Message`; never includes a credential value.
    #>
    Add-Type -AssemblyName System.Net.Http
    # .NET Framework on older Windows builds offers TLS 1.0 by default, which Front Door refuses.
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    # A followed redirect would carry the two custom credential headers to wherever it points: the handler
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
        if ($null -eq $userName -or $null -eq $secret) {
            Write-Failure '-FromStdin expects two lines: the username and the secret.'
            exit 2
        }
    }
    else {
        $userName = Read-Host 'Autotask API username'
        $secret = Get-PlainText (Read-Host 'Autotask API secret' -AsSecureString)
    }
    $userName = $userName.Trim()
    $secret = $secret.Trim()

    foreach ($field in @(@('The username', $userName), @('The secret', $secret))) {
        if ($field[1].Length -eq 0) { Write-Failure "$($field[0]) is empty."; exit 2 }
        Assert-NoControlCharacter $field[0] $field[1]
    }
    if ($secret.StartsWith('token::')) {
        Write-Failure 'The secret is a short-lived token::... value. Store the API user''s password, which does not expire.'
        exit 2
    }

    [Console]::Error.WriteLine("Checking the credentials with $endpointUrl ...")
    $result = Invoke-EnrolmentCheck $endpointUrl $userName $secret
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
        Version  = $RECORD_VERSION
        Endpoint = $endpointUrl
        UserName = ConvertTo-SecureValue $userName
        Secret   = ConvertTo-SecureValue $secret
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
    Write-StdoutUtf8 (Build-HeaderJson (Get-PlainText $record.UserName) (Get-PlainText $record.Secret))
}

function Invoke-Status {
    $record = Read-Record
    if ($null -eq $record) {
        Write-Host "Profile `"$ProfileName`": not configured."
        exit 1
    }
    $userName = Get-PlainText $record.UserName
    Write-Host "Profile:        $ProfileName"
    Write-Host "Storage:        DPAPI-encrypted file for this Windows user ($recordPath)"
    Write-Host "Endpoint:       $($record.Endpoint)"
    Write-Host "Username:       $(Get-MaskedUserName $userName)"
    Write-Host "Secret:         $(if ((Get-PlainText $record.Secret).Length -gt 0) { 'stored' } else { 'missing' })"
    Write-Host "Helper command: $(Get-HelperCommand)"

    if ($Verify) {
        $endpointUrl = Assert-RegionalEndpoint $record.Endpoint
        $result = Invoke-EnrolmentCheck $endpointUrl $userName (Get-PlainText $record.Secret)
        if ($result.Status -eq 200) {
            Write-Host 'Verification:   accepted by the server'
        }
        else {
            $detail = if ($result.Code) { "$($result.Code): $($result.Message)" } else { "HTTP $($result.Status)" }
            Write-Host "Verification:   refused, $detail"
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

# SIG # Begin signature block
# MIInTAYJKoZIhvcNAQcCoIInPTCCJzkCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAb8HVkbR4iz12J
# SDNyv33AW2DC5g7rkp5cttSQQFrK6KCCIMkwggWNMIIEdaADAgECAhAOmxiO+dAt
# 5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNV
# BAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEwMDAwMDBa
# Fw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3E
# MB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKy
# unWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsF
# xl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU1
# 5zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJB
# MtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObUR
# WBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6
# nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxB
# YKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5S
# UUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+x
# q4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjggE6MIIB
# NjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/57qYrhwP
# TzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8BAf8EBAMC
# AYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6oDigNoY0
# aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENB
# LmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEBAHCgv0Nc
# Vec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0aFPQTSnov
# Lbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNEm0Mh65Zy
# oUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZqaVSwuKFW
# juyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCsWKAOQGPF
# mCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9W9FcrBjDTZ9z
# twGpn1eqXijiuZQwggawMIIEmKADAgECAhAIrUCyYNKcTJ9ezam9k67ZMA0GCSqG
# SIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRy
# dXN0ZWQgUm9vdCBHNDAeFw0yMTA0MjkwMDAwMDBaFw0zNjA0MjgyMzU5NTlaMGkx
# CzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4
# RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEzODQg
# MjAyMSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDVtC9C0Cit
# eLdd1TlZG7GIQvUzjOs9gZdwxbvEhSYwn6SOaNhc9es0JAfhS0/TeEP0F9ce2vnS
# 1WcaUk8OoVf8iJnBkcyBAz5NcCRks43iCH00fUyAVxJrQ5qZ8sU7H/Lvy0daE6ZM
# swEgJfMQ04uy+wjwiuCdCcBlp/qYgEk1hz1RGeiQIXhFLqGfLOEYwhrMxe6TSXBC
# Mo/7xuoc82VokaJNTIIRSFJo3hC9FFdd6BgTZcV/sk+FLEikVoQ11vkunKoAFdE3
# /hoGlMJ8yOobMubKwvSnowMOdKWvObarYBLj6Na59zHh3K3kGKDYwSNHR7OhD26j
# q22YBoMbt2pnLdK9RBqSEIGPsDsJ18ebMlrC/2pgVItJwZPt4bRc4G/rJvmM1bL5
# OBDm6s6R9b7T+2+TYTRcvJNFKIM2KmYoX7BzzosmJQayg9Rc9hUZTO1i4F4z8ujo
# 7AqnsAMrkbI2eb73rQgedaZlzLvjSFDzd5Ea/ttQokbIYViY9XwCFjyDKK05huzU
# tw1T0PhH5nUwjewwk3YUpltLXXRhTT8SkXbev1jLchApQfDVxW0mdmgRQRNYmtwm
# KwH0iU1Z23jPgUo+QEdfyYFQc4UQIyFZYIpkVMHMIRroOBl8ZhzNeDhFMJlP/2NP
# TLuqDQhTQXxYPUez+rbsjDIJAsxsPAxWEQIDAQABo4IBWTCCAVUwEgYDVR0TAQH/
# BAgwBgEB/wIBADAdBgNVHQ4EFgQUaDfg67Y7+F8Rhvv+YXsIiGX0TkIwHwYDVR0j
# BBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMDMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0
# cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0
# cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8E
# PDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVz
# dGVkUm9vdEc0LmNybDAcBgNVHSAEFTATMAcGBWeBDAEDMAgGBmeBDAEEATANBgkq
# hkiG9w0BAQwFAAOCAgEAOiNEPY0Idu6PvDqZ01bgAhql+Eg08yy25nRm95RysQDK
# r2wwJxMSnpBEn0v9nqN8JtU3vDpdSG2V1T9J9Ce7FoFFUP2cvbaF4HZ+N3HLIvda
# qpDP9ZNq4+sg0dVQeYiaiorBtr2hSBh+3NiAGhEZGM1hmYFW9snjdufE5BtfQ/g+
# lP92OT2e1JnPSt0o618moZVYSNUa/tcnP/2Q0XaG3RywYFzzDaju4ImhvTnhOE7a
# brs2nfvlIVNaw8rpavGiPttDuDPITzgUkpn13c5UbdldAhQfQDN8A+KVssIhdXNS
# y0bYxDQcoqVLjc1vdjcshT8azibpGL6QB7BDf5WIIIJw8MzK7/0pNVwfiThV9zeK
# iwmhywvpMRr/LhlcOXHhvpynCgbWJme3kuZOX956rEnPLqR0kq3bPKSchh/jwVYb
# KyP/j7XqiHtwa+aguv06P0WmxOgWkVKLQcBIhEuWTatEQOON8BUozu3xGFYHKi8Q
# xAwIZDwzj64ojDzLj4gLDb879M4ee47vtevLt/B3E+bnKD+sEq6lLyJsQfmCXBVm
# zGwOysWGw/YmMwwHS6DTBwJqakAwSEs0qFEgu60bhQjiWQ1tygVQK+pKHJ6l/aCn
# HwZ05/LWUpD9r4VIIflXO7ScA+2GRfS0YW6/aOImYIbqyK+p/pQd52MbOoZWeE4w
# gga0MIIEnKADAgECAhANx6xXBf8hmS5AQyIMOkmGMA0GCSqGSIb3DQEBCwUAMGIx
# CzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3
# dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBH
# NDAeFw0yNTA1MDcwMDAwMDBaFw0zODAxMTQyMzU5NTlaMGkxCzAJBgNVBAYTAlVT
# MRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1
# c3RlZCBHNCBUaW1lU3RhbXBpbmcgUlNBNDA5NiBTSEEyNTYgMjAyNSBDQTEwggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC0eDHTCphBcr48RsAcrHXbo0Zo
# dLRRF51NrY0NlLWZloMsVO1DahGPNRcybEKq+RuwOnPhof6pvF4uGjwjqNjfEvUi
# 6wuim5bap+0lgloM2zX4kftn5B1IpYzTqpyFQ/4Bt0mAxAHeHYNnQxqXmRinvuNg
# xVBdJkf77S2uPoCj7GH8BLuxBG5AvftBdsOECS1UkxBvMgEdgkFiDNYiOTx4OtiF
# cMSkqTtF2hfQz3zQSku2Ws3IfDReb6e3mmdglTcaarps0wjUjsZvkgFkriK9tUKJ
# m/s80FiocSk1VYLZlDwFt+cVFBURJg6zMUjZa/zbCclF83bRVFLeGkuAhHiGPMvS
# GmhgaTzVyhYn4p0+8y9oHRaQT/aofEnS5xLrfxnGpTXiUOeSLsJygoLPp66bkDX1
# ZlAeSpQl92QOMeRxykvq6gbylsXQskBBBnGy3tW/AMOMCZIVNSaz7BX8VtYGqLt9
# MmeOreGPRdtBx3yGOP+rx3rKWDEJlIqLXvJWnY0v5ydPpOjL6s36czwzsucuoKs7
# Yk/ehb//Wx+5kMqIMRvUBDx6z1ev+7psNOdgJMoiwOrUG2ZdSoQbU2rMkpLiQ6bG
# RinZbI4OLu9BMIFm1UUl9VnePs6BaaeEWvjJSjNm2qA+sdFUeEY0qVjPKOWug/G6
# X5uAiynM7Bu2ayBjUwIDAQABo4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB/wIBADAd
# BgNVHQ4EFgQU729TSunkBnx6yuKQVvYv1Ensy04wHwYDVR0jBBgwFoAU7NfjgtJx
# XWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUF
# BwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGln
# aWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8EPDA6MDigNqA0hjJo
# dHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNy
# bDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZIhvcNAQEL
# BQADggIBABfO+xaAHP4HPRF2cTC9vgvItTSmf83Qh8WIGjB/T8ObXAZz8OjuhUxj
# aaFdleMM0lBryPTQM2qEJPe36zwbSI/mS83afsl3YTj+IQhQE7jU/kXjjytJgnn0
# hvrV6hqWGd3rLAUt6vJy9lMDPjTLxLgXf9r5nWMQwr8Myb9rEVKChHyfpzee5kH0
# F8HABBgr0UdqirZ7bowe9Vj2AIMD8liyrukZ2iA/wdG2th9y1IsA0QF8dTXqvcnT
# mpfeQh35k5zOCPmSNq1UH410ANVko43+Cdmu4y81hjajV/gxdEkMx1NKU4uHQcKf
# ZxAvBAKqMVuqte69M9J6A47OvgRaPs+2ykgcGV00TYr2Lr3ty9qIijanrUR3anzE
# wlvzZiiyfTPjLbnFRsjsYg39OlV8cipDoq7+qNNjqFzeGxcytL5TTLL4ZaoBdqbh
# OhZ3ZRDUphPvSRmMThi0vw9vODRzW6AxnJll38F0cuJG7uEBYTptMSbhdhGQDpOX
# gpIUsWTjd6xpR6oaQf/DJbg3s6KCLPAlZ66RzIg9sC+NJpud/v4+7RWsWCiKi9EO
# LLHfMR2ZyJ/+xhCx9yHbxtl5TPau1j/1MIDpMPx0LckTetiSuEtQvLsNz3Qbp7wG
# WqbIiOWCnb5WqxL3/BAPvIXKUjPSxyZsq8WhbaM2tszWkPZPubdcMIIG1zCCBL+g
# AwIBAgIQC0QuwHDAsQdAxK0FlbaRITANBgkqhkiG9w0BAQsFADBpMQswCQYDVQQG
# EwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0
# IFRydXN0ZWQgRzQgQ29kZSBTaWduaW5nIFJTQTQwOTYgU0hBMzg0IDIwMjEgQ0Ex
# MB4XDTI2MTAyNzAwMDAwMFoXDTI3MTAyNjIzNTk1OVowXzELMAkGA1UEBhMCVVMx
# EDAOBgNVBAgTB0Zsb3JpZGExDjAMBgNVBAcTBU1pYW1pMRYwFAYDVQQKEw1LYXNl
# eWEgVVMgTExDMRYwFAYDVQQDEw1LYXNleWEgVVMgTExDMIIBojANBgkqhkiG9w0B
# AQEFAAOCAY8AMIIBigKCAYEAuaYnbFZWZ5yKWYHtFznysPr+O9YYdq9yL/MqRIsx
# OagvCNgqvbqPYs3+jmUXqinhuHwsD+cMCd3v6/a2GIDwopicG9WKGzo0qdcIqw5q
# d1mnjYSKpk9h0OINsq1HYnO41k/mXN9H7+9e/qW7tJYx8BJ4RuPedRM5vuk/2i3j
# 1fA48GGv07Vy8xba/lQ2ZPhbKV+B631UsupMNLSgJ0wUbQqCOnY9vCFSke6GaZ50
# Jy4oVCfGhEDKYvMn3BbcJg1+t8a6AYKGA7ErvAh4reHaJMi2ZI2AW6NQ1qzPyhC4
# lQWW3Qg5Q47fpeUPGaWvJ7aSVCtkcCt3V5wNeFeIN9a8i15ZFg96WsmcXWip27is
# 3TxJw1PP60KJDw2SlGwNJLgrhybh6Fwj88mrjUps1KwRn5NTs/F8OPX/5Sk8RN5s
# 4ivre08irlwTfFcgVrxoBivyuhQYmzer79xHVAn2D32/4hJX06/nQzMqppaWBJve
# dri5pUU7fv+iy3gkuxHE7bE5AgMBAAGjggIDMIIB/zAfBgNVHSMEGDAWgBRoN+Dr
# tjv4XxGG+/5hewiIZfROQjAdBgNVHQ4EFgQU/MHak+Kr1pdKgGbH77ISlNkxrwMw
# PgYDVR0gBDcwNTAzBgZngQwBBAEwKTAnBggrBgEFBQcCARYbaHR0cDovL3d3dy5k
# aWdpY2VydC5jb20vQ1BTMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEF
# BQcDAzCBtQYDVR0fBIGtMIGqMFOgUaBPhk1odHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRUcnVzdGVkRzRDb2RlU2lnbmluZ1JTQTQwOTZTSEEzODQyMDIx
# Q0ExLmNybDBToFGgT4ZNaHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# VHJ1c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0MjAyMUNBMS5jcmwwgZQG
# CCsGAQUFBwEBBIGHMIGEMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2Vy
# dC5jb20wXAYIKwYBBQUHMAKGUGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9E
# aWdpQ2VydFRydXN0ZWRHNENvZGVTaWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEu
# Y3J0MAkGA1UdEwQCMAAwDQYJKoZIhvcNAQELBQADggIBAHhOs+WQGrN1bzGjEgBK
# 0/lax6080nSnI5XDYyVaqP58vGDUuEg6z8W/mFjngD/hjlvuX4XmGSzL6XYyRnXX
# iCy/M4QGXN40a496mCK+1bsCOI6BqykNK1Jm/hK63Igzq12Po+ygvsn6EqJ+zp7S
# srghLg7Cqr3iIPwnZvle4luiLWOG+KWGsBOHz1TjyozwLrZSi5iKu7FsvBfufaAs
# MfWBPejdGPhAa9rkG9q2M2tdciMg5cwJR27UYGXOC6/njMhjBe4ZdbcHxaWXpmsp
# Y1k99tIc/EBxjemskCr1vBskVVDAkqkCoTwSupmSufDOdTPVFAPCRbRj6FVTeAc2
# z87tuMm+utegcq4iaNSLu/0mjv8bAlu5ywR74u6Z5cnhhq2ZRD4IufnoSNuNzCUX
# 57Pei87U8MAA3TlUFfMsOFQgnRqPg1Rg202FzW+tiuIi8rh0Nhi0xpZLf6J6xiYq
# yxeaPyxjMHyvTrCNVjpJBQyEBzO8AArS0ADsG99pN3maNPnwAOQfb62VTcCOx48i
# M/oH6mDojsa46dEQ/hCvDkAzc85B5hNAaRDNk91d2BNXdhx1NSxma+ksvr9CbYlq
# a0VPJW8mvcKu7dLdy4qAT2eJcrA3ozhr0nlqAlfJMiFXgFUUkg5kxXjqvpXAfo37
# zPVLKunUK6uF7nBSnZsgYAUYMIIG7TCCBNWgAwIBAgIQCE/cM09+RU7bww+P+ZIY
# NTANBgkqhkiG9w0BAQsFADBpMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNl
# cnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0IFRydXN0ZWQgRzQgVGltZVN0YW1w
# aW5nIFJTQTQwOTYgU0hBMjU2IDIwMjUgQ0ExMB4XDTI2MDgwNTAwMDAwMFoXDTM3
# MTEwNDIzNTk1OVowYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJ
# bmMuMTswOQYDVQQDEzJEaWdpQ2VydCBTSEEyNTYgUlNBNDA5NiBUaW1lc3RhbXAg
# UmVzcG9uZGVyIDIwMjYgMTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# ALZ7pvLJ/s1K+NSbTGWz/TjGMPh8CQ6RucZCLv5anHzWJjF/NWJrFIhy24fcpKXl
# gRiky4WAawDfU3YP0BMxt9l3Dm5oCG5Z69AqEN1kgHg2epx+l+lZBcmJCcN0ASUR
# ML5uFIS80sZsDwO3BSkUxDjLJhBI+qiZP3aixAC/qEGLjsBNlLol9VZ7pfGEXiMl
# neJIC5/YKuizVzNFKZZEeoy/0B8Zm+nzKBgSWG52lCO1w+nCg6XpCtklTJXeIg28
# 3hw7TmmsZXR+SMbjbrEOvZ3fP2VxIgeR28Y90ZStd3F9VuA5RVynb/whITPAo9b7
# 5Zr4Ta6Mj3URm26QZYMn/FnbuTegcoRcFEZ9FOqM5T6MTdtr/n74lIT/ug0eeOzm
# Z6QTFg33otX+bFRsIolvykE1jive4PuESaT8zzVeFWDAMDtozNgLctkGD1ZjkEyZ
# tJrLl5ya0m5doH/ScpaZCZVl6pNUOCybMc/kxC6EAmSJY24L0yYKD1Nkddsnb/It
# VKi/2nXpQNMu1PT5prW83vV8d67WowuUs0HdY4H8AMLGvdL/WHEj3ZnqMqAQQP9u
# 3Ai9t+5eQ02GDwy0ODjdzi0xlp70W+ow63/0++YDEX1M0iwgUHwbrJvfpklkZQvw
# 3+kv3vUPItdwroczk9icflf55W1zOEKAcJVAIXpcMCU9AgMBAAGjggGVMIIBkTAM
# BgNVHRMBAf8EAjAAMB0GA1UdDgQWBBQUyWOKMC7USvtulPPm40B+9ezN4jAfBgNV
# HSMEGDAWgBTvb1NK6eQGfHrK4pBW9i/USezLTjAOBgNVHQ8BAf8EBAMCB4AwFgYD
# VR0lAQH/BAwwCgYIKwYBBQUHAwgwgZUGCCsGAQUFBwEBBIGIMIGFMCQGCCsGAQUF
# BzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wXQYIKwYBBQUHMAKGUWh0dHA6
# Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFRpbWVTdGFt
# cGluZ1JTQTQwOTZTSEEyNTYyMDI1Q0ExLmNydDBfBgNVHR8EWDBWMFSgUqBQhk5o
# dHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRUaW1lU3Rh
# bXBpbmdSU0E0MDk2U0hBMjU2MjAyNUNBMS5jcmwwIAYDVR0gBBkwFzAIBgZngQwB
# BAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUAA4ICAQCNxTphHp1SCt+ZrAmA
# fn0oQLFr0mLywSLaDXQIENoyKqxrFbJblzCVP/pkXmwXOdrOpWygLzlT12os5ipD
# Cy35RBCg2UMeApEtrfGhz45F4Wt4WGdNdIbRWt3YTYJmpR+b7lr4d7Uwn+H600u4
# D7RnOGf8Wj4UNgAdZkfHhHv1mx9EVh71SJelcEN/oORSjXzdjfw1iZH9d8Nh/thn
# 6hH23d+VsPAr6GAYyzSA02nXD1nYLI7Ijmiv+xLCiYC41DSFYL3GhTiy0PxpawPt
# GRyaBVGzq+UiTfM8pD7KVyF5aQyWP4KhVGUUTnmm/RlYJoW3TiXA/+t0YcT2oRVB
# m3JETjajHug2AL+v5jhtKVnd3D0rbHXEu27o+Q8p4sEWPMqKDB+qbceb6T/6WcwT
# wXmQ9lOCLLYcsQeSWmvKqzpAec9etE14jOQAzLKWdE3w/TCaKtLRaRT7LCkRYVnh
# A2D73FLje1O5b3HR5eHs0NzU/+xX7NbEdcofy0W3Wdwd1XOqtlpg/JgwtKfZM5dq
# O94lbUveOiJBI+xZEbGRsMNbXmMREUTgu+Oca7Y73MPWcslIx2VhkSKSXjDbD6rg
# g39H5Mh7QfieAIjWagkJNt68Yfim6cjEzVSiLSeZfdkr5dtFPTW6jATlWJdYeeDR
# GCyatf8R1hSjzSvdN8yWQPT9gzGCBdkwggXVAgEBMH0waTELMAkGA1UEBhMCVVMx
# FzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMUEwPwYDVQQDEzhEaWdpQ2VydCBUcnVz
# dGVkIEc0IENvZGUgU2lnbmluZyBSU0E0MDk2IFNIQTM4NCAyMDIxIENBMQIQC0Qu
# wHDAsQdAxK0FlbaRITANBglghkgBZQMEAgEFAKCBhDAYBgorBgEEAYI3AgEMMQow
# CKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcC
# AQsxDjAMBgorBgEEAYI3AgEVMC8GCSqGSIb3DQEJBDEiBCA7X9LxIWIY6G4G2PxJ
# y7rHJL5TEPU+NPhLdIeEGGAYBDANBgkqhkiG9w0BAQEFAASCAYCdGNdlQ+qVVkQr
# DLoJu5Ss0Jxham3mtZ4gRZOAb3lnCa96dtrQ1jCWpJV5LpwFdXwJIl51fA4AQngW
# Cfzq1HrR7DbwrPYJP2jLm9ewVm+1H4F2zcefsN7RHNU/Pr928YPTYoVOI8IUdrdn
# N11FfGYDO4H4DVwuq29nLCWuj4vJm2HU4g+apb8uLM/TASGL4lrAvl5XAf8+0fZi
# vkjF4UAVuwHyHe/TvX5N72xrZSCx5FY8ektgU9qxtWaZIhSHapdv15cMUanc2alm
# lksgLXhgUhAKAnZauwC5ZnD6D4nx8uqo4Rm0rU08kt1c7bFS0oYAcpIcnw4BNPpu
# 1EigkHDEXZno1J9LS5AUeW2r29h0lCrWUPd8ldkqQ7KjAWVyyGsH9z7CBV/IQgeE
# awAciSsX5fWXNYDp0qJ9DaAL4cedozTtVTAsdYLNQ8awA9VTWLSDwCE6UwWOgu/U
# 5ECrEXVnmMIcLlMF7HmyrY+d1yrrFkbraxT4N/67zgqV6JtM9JChggMmMIIDIgYJ
# KoZIhvcNAQkGMYIDEzCCAw8CAQEwfTBpMQswCQYDVQQGEwJVUzEXMBUGA1UEChMO
# RGlnaUNlcnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0IFRydXN0ZWQgRzQgVGlt
# ZVN0YW1waW5nIFJTQTQwOTYgU0hBMjU2IDIwMjUgQ0ExAhAIT9wzT35FTtvDD4/5
# khg1MA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAc
# BgkqhkiG9w0BCQUxDxcNMjYxMDI4MTg0NDU0WjAvBgkqhkiG9w0BCQQxIgQgrypz
# w83YxJZbgEQDtN4qTBtaKXknEjTYkJZDqMf3rpEwDQYJKoZIhvcNAQEBBQAEggIA
# OwSOdgEI5s5J2TNBPEtXyIlaStuqFKOHx5nLAZS5fsijCak7MWDI1Z9YAOMcVx5m
# tMQOUb7SImGMgZOP+h8FNy5ZsDf+7A/3SFu7TzxSSw4FgZ6iWO3mLxpDiZX6yM3Y
# u2pz3dvKjnKlQC2yxH8QUdEIKZZXIHeC9hMP6Nn4SUrE1//y7Gbo/O3C8S/TvuH7
# 7QnYsa4xk9mkzsicqfmCMeKqEdUU9Ki3mQCRK8RIkDw7rStDYpmYOwru91NHCXsu
# tPjY+CCCA4r3RJZXza+LCB7CmU6r6r0dXqwDu7yIOzZvLudbClZ3tbvCppL8a/T+
# bifzrtpKJ3tvpFlRt4mL99zslhE8S3z4LPnFJO6SCep2pgrw/q11j5J+/1gHZxBN
# qGgg5DOuGmxGC5iBg59s9NoXGn9S2JYetz3Mmtb2PH6S6z/TTP2/UKNnZsQkTMnT
# k0uqKE5KZGBw7C+O8d3HNQ1Bhm38/AGvnC1cKkmHbeHOM3W/8hC8tNGz8kjrXHAH
# i98OxLgxHVM9XsdJtxzZOyF86lFS5NXwXiEmncldL1rtBR6HK1tayDswdAksCMKZ
# +uqkFosaZTTBcdj5UGS0igcK7boR//BqYRlB2mDm+dg11w8QBQF6uXIz2PBsnTr+
# eEU2XSzCqLeC9Sx9tu8ojmTZJRUEjowPjSm0H3qbwno=
# SIG # End signature block
