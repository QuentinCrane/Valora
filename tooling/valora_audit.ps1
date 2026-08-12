[CmdletBinding()]
param(
    [string]$FlutterPath,
    [string]$AndroidSdkPath
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $repoRoot

function Get-RelativeRepoPath {
    param([string]$Path)

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    if ($fullPath.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $fullPath.Substring($repoRoot.Length).TrimStart('\', '/')
    }
    return $fullPath
}

function Test-SensitivePath {
    param([string]$Path)

    return $Path -match '(?i)(^|[\\/])(?:key\.properties|[^\\/]+\.(?:jks|keystore|p12|pem|der|mobileprovision))$|(^|[\\/])\.env(?:\.[^\\/]*)?$'
}

function Resolve-Executable {
    param(
        [string]$RequestedPath,
        [string]$CommandName
    )

    if (-not [string]::IsNullOrWhiteSpace($RequestedPath)) {
        if (-not (Test-Path -LiteralPath $RequestedPath -PathType Leaf)) {
            throw "Requested executable was not found: $CommandName"
        }
        return (Resolve-Path -LiteralPath $RequestedPath).Path
    }

    $command = Get-Command $CommandName -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $command) {
        return $null
    }
    return $command.Source
}

function Invoke-Captured {
    param(
        [string]$Executable,
        [string[]]$Arguments
    )

    $text = (& $Executable @Arguments 2>&1 | Out-String)
    return [pscustomobject]@{
        ExitCode = $LASTEXITCODE
        Text = $text.Trim()
    }
}

function Get-VersionFromDartOutput {
    param([string]$Text)

    $match = [regex]::Match($Text, 'Dart SDK version:\s*([0-9]+\.[0-9]+\.[0-9]+)')
    if ($match.Success) {
        return $match.Groups[1].Value
    }
    return 'unavailable'
}

function Get-VersionFromJavaOutput {
    param([string]$Text)

    $match = [regex]::Match($Text, 'version\s+"([^"]+)"')
    if ($match.Success) {
        return $match.Groups[1].Value
    }
    return 'unavailable'
}

function Get-DirectoryNames {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        return @()
    }
    return @(Get-ChildItem -LiteralPath $Path -Directory | Select-Object -ExpandProperty Name | Sort-Object)
}

Write-Output '=== Valora reproducible audit ==='
Write-Output ('audit_utc={0}' -f [DateTime]::UtcNow.ToString('o'))
Write-Output ('repository={0}' -f (Split-Path -Leaf $repoRoot))

$head = (& git rev-parse HEAD 2>$null | Out-String).Trim()
if ([string]::IsNullOrWhiteSpace($head)) {
    throw 'Git repository was not found.'
}
Write-Output ('git_head={0}' -f $head)

$statusLines = @(git -c core.quotePath=false status --short --untracked-files=all)
if ($statusLines.Count -eq 0) {
    Write-Output 'git_status=clean'
} else {
    Write-Output 'git_status=dirty'
}
Write-Output 'git_status_entries_begin'
foreach ($statusLine in $statusLines) {
    if ($statusLine -match '^(.{0,3})(.*)$') {
        $prefix = $matches[1]
        $statusPath = $matches[2].Trim()
        if (Test-SensitivePath -Path $statusPath) {
            Write-Output ('{0}[redacted sensitive path]' -f $prefix)
        } else {
            Write-Output $statusLine
        }
    }
}
Write-Output 'git_status_entries_end'

$trackedFiles = @(git -c core.quotePath=false ls-files | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
Write-Output ('tracked_file_count={0}' -f $trackedFiles.Count)
Write-Output 'tracked_file_extensions_begin'
$extensionCounts = @{}
foreach ($trackedFile in $trackedFiles) {
    $extension = [System.IO.Path]::GetExtension($trackedFile).ToLowerInvariant()
    if ([string]::IsNullOrWhiteSpace($extension)) {
        $extension = '[none]'
    }
    if (-not $extensionCounts.ContainsKey($extension)) {
        $extensionCounts[$extension] = 0
    }
    $extensionCounts[$extension]++
}
foreach ($extension in ($extensionCounts.Keys | Sort-Object)) {
    Write-Output ('{0}={1}' -f $extension, $extensionCounts[$extension])
}
Write-Output 'tracked_file_extensions_end'
Write-Output 'tracked_files_begin'
foreach ($trackedFile in $trackedFiles) {
    if (Test-SensitivePath -Path $trackedFile) {
        Write-Output '[redacted sensitive path]'
    } else {
        Write-Output $trackedFile
    }
}
Write-Output 'tracked_files_end'

$flutterExecutable = Resolve-Executable -RequestedPath $FlutterPath -CommandName 'flutter'
if ($null -eq $flutterExecutable) {
    Write-Output 'flutter_status=unavailable'
    Write-Output 'flutter_version=unavailable'
    Write-Output 'dart_version=unavailable'
} else {
    $flutterResult = Invoke-Captured -Executable $flutterExecutable -Arguments @('--version', '--machine')
    $flutterInfo = $null
    try {
        $flutterInfo = $flutterResult.Text | ConvertFrom-Json
    } catch {
        $flutterInfo = $null
    }
    if ($null -eq $flutterInfo) {
        Write-Output ('flutter_status=unavailable(exit={0})' -f $flutterResult.ExitCode)
        Write-Output 'flutter_version=unavailable'
        Write-Output 'dart_version=unavailable'
    } else {
        Write-Output 'flutter_status=available'
        Write-Output ('flutter_version={0}' -f $flutterInfo.flutterVersion)
        Write-Output ('flutter_channel={0}' -f $flutterInfo.channel)
        Write-Output ('flutter_framework_revision={0}' -f $flutterInfo.frameworkRevision)
        Write-Output ('dart_version={0}' -f $flutterInfo.dartSdkVersion)
    }
}

$dartExecutable = Resolve-Executable -RequestedPath $null -CommandName 'dart'
if ($null -eq $dartExecutable) {
    Write-Output 'dart_command_status=unavailable'
} else {
    $dartResult = Invoke-Captured -Executable $dartExecutable -Arguments @('--version')
    Write-Output ('dart_command_status={0}' -f $(if ($dartResult.ExitCode -eq 0) { 'available' } else { 'unavailable' }))
    Write-Output ('dart_command_version={0}' -f (Get-VersionFromDartOutput -Text $dartResult.Text))
}

$javaExecutable = Resolve-Executable -RequestedPath $null -CommandName 'java'
if ($null -eq $javaExecutable) {
    Write-Output 'java_status=unavailable'
    Write-Output 'java_version=unavailable'
} else {
    $javaResult = Invoke-Captured -Executable $javaExecutable -Arguments @('-version')
    Write-Output ('java_status={0}' -f $(if ($javaResult.Text -match 'version') { 'available' } else { 'unavailable' }))
    Write-Output ('java_version={0}' -f (Get-VersionFromJavaOutput -Text $javaResult.Text))
}

$gradleProperties = Join-Path $repoRoot 'android/gradle/wrapper/gradle-wrapper.properties'
$gradleVersion = 'unavailable'
if (Test-Path -LiteralPath $gradleProperties -PathType Leaf) {
    $distributionLine = Get-Content -LiteralPath $gradleProperties | Where-Object { $_ -match '^distributionUrl=' } | Select-Object -First 1
    $gradleMatch = [regex]::Match($distributionLine, 'gradle-([^/]+)-(?:all|bin)\.zip')
    if ($gradleMatch.Success) {
        $gradleVersion = $gradleMatch.Groups[1].Value
    }
}
Write-Output ('gradle_wrapper_version={0}' -f $gradleVersion)

$sdkPath = $null
$sdkSource = 'unavailable'
if (-not [string]::IsNullOrWhiteSpace($AndroidSdkPath)) {
    $sdkPath = $AndroidSdkPath
    $sdkSource = 'parameter'
} elseif (-not [string]::IsNullOrWhiteSpace($env:ANDROID_SDK_ROOT)) {
    $sdkPath = $env:ANDROID_SDK_ROOT
    $sdkSource = 'ANDROID_SDK_ROOT'
} elseif (-not [string]::IsNullOrWhiteSpace($env:ANDROID_HOME)) {
    $sdkPath = $env:ANDROID_HOME
    $sdkSource = 'ANDROID_HOME'
} else {
    $localProperties = Join-Path $repoRoot 'android/local.properties'
    if (Test-Path -LiteralPath $localProperties -PathType Leaf) {
        $sdkLine = Get-Content -LiteralPath $localProperties | Where-Object { $_ -match '^sdk\.dir=' } | Select-Object -First 1
        if ($sdkLine) {
            $sdkPath = ($sdkLine -replace '^sdk\.dir=', '') -replace '\\\\', '\'
            $sdkSource = 'android/local.properties'
        }
    }
}
if ($null -eq $sdkPath -or -not (Test-Path -LiteralPath $sdkPath -PathType Container)) {
    Write-Output 'android_sdk_status=unavailable'
    Write-Output ('android_sdk_source={0}' -f $sdkSource)
} else {
    $platforms = @(Get-DirectoryNames -Path (Join-Path $sdkPath 'platforms'))
    $buildTools = @(Get-DirectoryNames -Path (Join-Path $sdkPath 'build-tools'))
    Write-Output 'android_sdk_status=available'
    Write-Output ('android_sdk_source={0}' -f $sdkSource)
    Write-Output ('android_sdk_platforms={0}' -f $(if ($platforms.Count) { $platforms -join ',' } else { 'none' }))
    Write-Output ('android_sdk_build_tools={0}' -f $(if ($buildTools.Count) { $buildTools -join ',' } else { 'none' }))
}

$adbExecutable = Resolve-Executable -RequestedPath $null -CommandName 'adb'
if ($null -eq $adbExecutable) {
    Write-Output 'adb_status=unavailable'
} else {
    $adbResult = Invoke-Captured -Executable $adbExecutable -Arguments @('version')
    $adbMatch = [regex]::Match($adbResult.Text, 'Android Debug Bridge version\s+([^\r\n]+)')
    Write-Output ('adb_status={0}' -f $(if ($adbMatch.Success) { 'available' } else { 'unavailable' }))
    if ($adbMatch.Success) {
        Write-Output ('adb_version={0}' -f $adbMatch.Groups[1].Value.Trim())
    }
}

$sensitiveFiles = @(
    Get-ChildItem -LiteralPath $repoRoot -Force -File -Recurse -ErrorAction SilentlyContinue |
        Where-Object {
            $relativePath = Get-RelativeRepoPath -Path $_.FullName
            $relativePath -notmatch '(?i)(^|[\\/])(?:\.git|\.dart_tool|build|\.gradle)(?:[\\/]|$)' -and
                (Test-SensitivePath -Path $relativePath)
        }
)
Write-Output ('sensitive_file_count={0}' -f $sensitiveFiles.Count)

Write-Output 'apk_artifacts_begin'
$apkPaths = @(
    'build/app/outputs/flutter-apk/app-debug.apk',
    'build/app/outputs/flutter-apk/app-release.apk'
)
foreach ($apkPath in $apkPaths) {
    $absoluteApkPath = Join-Path $repoRoot $apkPath
    if (-not (Test-Path -LiteralPath $absoluteApkPath -PathType Leaf)) {
        Write-Output ('path={0};status=missing' -f $apkPath)
        continue
    }
    $apk = Get-Item -LiteralPath $absoluteApkPath
    $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $absoluteApkPath).Hash
    Write-Output ('path={0};status=present;length={1};creation_utc={2};last_write_utc={3};sha256={4}' -f `
        $apkPath,
        $apk.Length,
        $apk.CreationTimeUtc.ToString('o'),
        $apk.LastWriteTimeUtc.ToString('o'),
        $hash)
}
Write-Output 'apk_artifacts_end'

Write-Output '=== End Valora reproducible audit ==='
