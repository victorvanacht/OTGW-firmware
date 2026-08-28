# OTGW Firmware Development Container

This development container contains Python 3.12, PlatformIO, Git, compiler
tooling, USB utilities, and the Linux serial permissions needed to build and
flash the ESP32-S3 firmware. The complete workspace is mounted into the
container, and the PlatformIO cache persists in a Docker volume.

## Build

Open this repository with **Dev Containers: Reopen in Container**. The first
creation downloads the packages pinned in `platformio.ini`.

The optional `other-projects` Git submodule is a private, read-only reference
repository. It is not required to build the firmware. Authenticate GitHub in
the container, then initialize it only when you need those references:

```bash
git submodule update --init --recursive
```

Run the project build from the container with:

```bash
./build.sh --target esp32
python evaluate.py --quick
```

## USB on Windows

Windows does not expose USB devices directly to Docker containers. Install
[usbipd-win](https://github.com/dorssel/usbipd-win/releases) on the Windows
host, then attach the ESP32-S3 to the WSL distribution used by the container
workflow:

```powershell
.\scripts\attach-usb-to-devcontainer.ps1 -List
.\scripts\attach-usb-to-devcontainer.ps1 -BusId <BUSID> -Distribution <WSL_DISTRO>
```

The first attach needs an elevated PowerShell window because USB/IP binding is
a Windows device-sharing operation. Reconnect the device with the same command
after unplugging it or restarting WSL.

For a Docker engine installed directly in that WSL distribution, the attached
device appears in the container below `/dev-host`, usually as
`/dev-host/ttyACM0`. Flash it with:

```bash
pio run -e esp32 -t upload --upload-port /dev-host/ttyACM0
```

Docker Desktop uses its own Linux VM and cannot pass a USB device attached to a
normal WSL distribution through to the devcontainer. In that configuration,
use the container for builds and run `flash_otgw.bat --update` from Windows, or
run the Docker engine directly in the WSL distribution to enable the device
path above.