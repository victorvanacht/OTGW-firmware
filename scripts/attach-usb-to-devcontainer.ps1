[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$BusId,

    [Parameter(Mandatory = $false)]
    [string]$Distribution,

    [switch]$List,
    [switch]$Detach
)

$usbipd = Get-Command usbipd.exe -ErrorAction SilentlyContinue
if (-not $usbipd) {
    Write-Error "usbipd-win is required. Install it from https://github.com/dorssel/usbipd-win/releases, then run this command again."
    exit 1
}

if ($List) {
    & $usbipd.Source list
    exit $LASTEXITCODE
}

if ([string]::IsNullOrWhiteSpace($BusId)) {
    & $usbipd.Source list
    Write-Error "Specify the ESP32-S3 bus ID with -BusId."
    exit 2
}

if ([string]::IsNullOrWhiteSpace($Distribution)) {
    $Distribution = (wsl.exe --list --quiet | Where-Object { $_.Trim() } | Select-Object -First 1).Trim()
}

if ([string]::IsNullOrWhiteSpace($Distribution)) {
    Write-Error "No WSL distribution was found. Install one, then rerun with -Distribution."
    exit 1
}

if ($Detach) {
    & $usbipd.Source detach --busid $BusId
    exit $LASTEXITCODE
}

& $usbipd.Source bind --busid $BusId
if ($LASTEXITCODE -ne 0) {
    Write-Error "USB/IP bind failed. Run PowerShell as Administrator for the first bind."
    exit $LASTEXITCODE
}

& $usbipd.Source attach --wsl --distribution $Distribution --busid $BusId
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$devices = & wsl.exe --distribution $Distribution -- bash -lc 'for device in /dev/ttyACM* /dev/ttyUSB*; do [ -e "$device" ] && printf "%s\n" "$device"; done'
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

if ($devices) {
    Write-Host "Attached to WSL distribution '$Distribution':"
    $devices | ForEach-Object { Write-Host "  $_" }
    Write-Host "With a Docker engine in that distribution, use the matching /dev-host path in the devcontainer."
} else {
    Write-Warning "The device attached, but no /dev/ttyACM* or /dev/ttyUSB* node is visible yet. Reconnect it or run 'usbipd list' to inspect its state."
}