@echo off

REM ------------------------------------------------------
REM Sonaric bash install script
setlocal EnableDelayedExpansion
set LF=^


REM The above 2 empty lines are required - do not remove
set installScript=install -m 0755 -d /etc/apt/keyrings !LF! ^
curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg ^| gpg --dearmor --yes -o /etc/apt/keyrings/sonaric.gpg !LF! ^
chmod a+r /etc/apt/keyrings/sonaric.gpg !LF! ^
echo \"deb [arch=amd64 signed-by=/etc/apt/keyrings/sonaric.gpg] https://us-central1-apt.pkg.dev/projects/sonaric-platform sonaric-releases-apt main\" ^> /etc/apt/sources.list.d/sonaric.list !LF! ^
apt-get update !LF! ^
DEBIAN_FRONTEND=noninteractive apt-get install -y sonaric !LF! ^
echo \"Sonaric installed on WSL\" !LF!
REM End of script
REM ------------------------------------------------------

REM resume script after reboot
if "%1" == "continue" (
	choice /m "Do you want to continue with Sonaric installation?"
	if !errorlevel! neq 1 (
		exit
	)
	goto continue
)

REM check for NVIDIA drivers
echo Checking NVIDIA drivers...
set "tmpNvidia=%temp%\nvidia-%random%.tmp"
nvidia-smi --version > %tmpNvidia%
if %errorlevel% neq 0 (
	echo It looks like NVIDIA drivers are not installed. NVIDIA drivers are required for GPU support in Sonaric. If you have an NVIDIA GPU and wish to use Sonaric with GPU support, please install latest NVIDIA drivers from NVIDIA website (https://www.nvidia.com/Download/index.aspx^) and try again, or proceed without GPU support.
	choice /m "Do you want to open NVIDIA drivers download page?"
	if !errorlevel! equ 1 (
		start https://www.nvidia.com/Download/index.aspx
	)
	choice /m "Do you want to proceed without GPU support?"
	if !errorlevel! neq 1 (
		exit
	)
)

REM check if WSL is installed and if it is WSL 2
echo Checking WSL...
set "tmpWslVersion=%temp%\wsl-version-%random%.tmp"
wsl --version > %tmpWslVersion%
if %errorlevel% neq 0 (
	echo It looks like WSL is not installed. Please install WSL from Microsoft Store (https://aka.ms/wslstorepage^) and try again.
	choice /m "Do you want to open Microsoft Store WSL page?"
	if !errorlevel! neq 2 (
		start ms-windows-store://pdp/?productid=9P9TQF7MRM4R
	)
	exit
)
find "WSL version: 2" %tmpWslVersion% > nul
if %errorlevel% neq 0 (
	echo It looks like you are using WSL 1. Please upgrade to WSL 2 (https://aka.ms/wslstorepage^) and try again.
	choice /m "Do you want to open Microsoft Store WSL page?"
	if !errorlevel! neq 2 (
		start ms-windows-store://pdp/?productid=9P9TQF7MRM4R
	)
	exit
)

echo Ensuring Ubuntu-22.04 is installed...
set "wslInstall=%temp%\wsl-install-%random%.tmp"
wsl --install Ubuntu-22.04 --no-launch > %wslInstall%
find "Changes will not be effective until the system is rebooted" %wslInstall% > nul
if %errorlevel% neq 1 (
	echo System reboot is required to complete WSL installation. Please reboot your system and run this script again.
	choice /m "Do you want to reboot now?"
	if !errorlevel! equ 1 (
		REM set install script to be rerun after reboot
		reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "InstallSonaric" /t REG_SZ /d "\"%~dpnx0\" continue" /f
		REM reboot system
		shutdown /r /t 0
	)
	exit
)

:continue

REM check if Ubuntu-22.04 is installed
REM if not, install it
set "wslList=%temp%\wsl-list-%random%.tmp"
wsl --list > %wslList%
find "Ubuntu-22.04" %wslList% > nul
if %errorlevel% neq 0 (
	ubuntu2204 install --root
)

REM check if Sonaric is already installed
wsl -d Ubuntu-22.04 --user root --exec /bin/bash -c "dpkg-query -W sonaric" > nul
if %errorlevel% equ 0 (
	choice /m "Sonaric is already installed. Would you like to update it to the latest version instead?"
	if !errorlevel! neq 1 (
		exit
	)
	echo Updating Sonaric...
	wsl -d Ubuntu-22.04 --user root --exec /bin/bash -c "apt-get update && apt-get install -y sonaric sonaricd"
	if %errorlevel% neq 0 (
		echo Failed to update Sonaric. Please check the error message above and try again, or contact support.
		pause
		exit
	)
	echo Sonaric updated
	pause
	exit
)

echo Installing Sonaric...
wsl -d Ubuntu-22.04 --user root --exec /bin/bash -c "!installScript!"
if %errorlevel% neq 0 (
	echo Failed to install Sonaric. Please check the error message above and try again, or contact support.
	pause
	exit
)

echo Sonaric installed
pause
