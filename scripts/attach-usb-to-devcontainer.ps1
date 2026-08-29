[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$BusId,

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

if ($Detach) {
    & $usbipd.Source detach --busid $BusId
    exit $LASTEXITCODE
}

& $usbipd.Source bind --busid $BusId
if ($LASTEXITCODE -ne 0) {
    Write-Error "USB/IP bind failed. Run PowerShell as Administrator for the first bind."
    exit $LASTEXITCODE
}

& $usbipd.Source attach --wsl --busid $BusId
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host "Attached to WSL 2. Check /dev-host/ttyACM0 or /dev-host/ttyUSB0 inside the devcontainer."