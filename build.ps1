param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('mobile', 'desktop')]
    [string]$App,

    [ValidateSet('debug', 'release')]
    [string]$Mode = 'debug',

    [ValidateSet('windows', 'chrome', 'android')]
    [string]$Device,

    [switch]$Run,

    [string]$ApiUrl
)

if (-not $ApiUrl) {
    # Android emulator ne vidi host kao 'localhost' - 10.0.2.2 je alias za host masinu.
    $ApiUrl = if ($Device -eq 'android') { 'http://10.0.2.2:5000' } else { 'http://localhost:5000' }
}

$ErrorActionPreference = 'Continue'

$flutterBin = 'C:\flutter\bin'
if (-not (Test-Path (Join-Path $flutterBin 'flutter.bat'))) {
    throw "Flutter SDK nije pronaden na: $flutterBin"
}
if ($env:Path -notlike "*$flutterBin*") {
    $env:Path = "$env:Path;$flutterBin"
}

$platformTools = 'C:\Users\Tarik\AppData\Local\Android\sdk\platform-tools'
if ((Test-Path $platformTools) -and ($env:Path -notlike "*$platformTools*")) {
    $env:Path = "$env:Path;$platformTools"
}

$root = $PSScriptRoot
$projects = @{
    mobile  = Join-Path $root 'mobile\skipass_mobile'
    desktop = Join-Path $root 'desktop\skipass_desktop'
}
$projectPath = $projects[$App]
if (-not (Test-Path $projectPath)) {
    throw "Projekat nije pronaden: $projectPath"
}

if (-not $Device) {
    $Device = if ($App -eq 'desktop') { 'windows' } else { 'chrome' }
}

Write-Host ''
Write-Host "=== SkiPass build ===" -ForegroundColor Cyan
Write-Host "Aplikacija : $App"
Write-Host "Putanja    : $projectPath"
Write-Host "Mode       : $Mode"
Write-Host "Uredaj     : $Device"
Write-Host ''

Write-Host '[1/4] Zatvaram zaostale Dart/Flutter procese...' -ForegroundColor Yellow
$stray = Get-Process -ErrorAction SilentlyContinue |
    Where-Object { $_.ProcessName -match '^(dart|dartaotruntime|flutter_tester|skipass_desktop)$' }
if ($stray) {
    $stray | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "      zatvoreno: $($stray.Count)"
} else {
    Write-Host '      nema zaostalih procesa'
}

Set-Location $projectPath

Write-Host '[2/4] flutter clean...' -ForegroundColor Yellow
flutter clean | Out-Null
Remove-Item -Recurse -Force (Join-Path $projectPath '.dart_tool') -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force (Join-Path $projectPath 'build') -ErrorAction SilentlyContinue
if ($App -eq 'desktop') {
    Remove-Item -Recurse -Force (Join-Path $projectPath 'windows\flutter\ephemeral') -ErrorAction SilentlyContinue
}

Write-Host '[3/4] flutter pub get...' -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'flutter pub get nije uspio.' }

$symlinks = Join-Path $projectPath 'windows\flutter\ephemeral\.plugin_symlinks'
if ($App -eq 'desktop' -and (Test-Path $symlinks)) {
    $count = (Get-ChildItem $symlinks -ErrorAction SilentlyContinue).Count
    if ($count -eq 0) {
        Write-Host '      plugin symlinks prazni, ponavljam pub get...' -ForegroundColor Yellow
        flutter pub get
    }
}

$defines = @("--dart-define=API_BASE_URL=$ApiUrl")

$targetDevice = $Device
if ($Device -eq 'android') {
    $adbLine = & adb devices 2>$null | Select-String '^emulator-\d+\s+device$' | Select-Object -First 1
    if (-not $adbLine) { throw 'Nijedan Android emulator nije pokrenut (adb devices ne prijavljuje emulator-*).' }
    $targetDevice = ($adbLine -split '\s+')[0]
}

if ($Run) {
    Write-Host '[4/4] flutter run...' -ForegroundColor Yellow
    $runArgs = @('run', '-d', $targetDevice, "--$Mode") + $defines
    if ($Device -eq 'chrome') { $runArgs += @('--web-port=8080') }
    & flutter @runArgs
} else {
    Write-Host '[4/4] flutter build...' -ForegroundColor Yellow
    $target = switch ($Device) {
        'chrome'  { 'web' }
        'android' { 'apk' }
        default   { 'windows' }
    }
    $buildArgs = @('build', $target, "--$Mode") + $defines
    & flutter @buildArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Host ''
        Write-Host "Build NIJE uspio (exit $LASTEXITCODE)." -ForegroundColor Red
        exit $LASTEXITCODE
    }
    Write-Host ''
    Write-Host 'Build uspjesan.' -ForegroundColor Green
}
