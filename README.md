# sonaric-install

## Windows

1. (optional but required for GPU support) Requires supported Nvidia GPU. Install the latest Nvidia driver from [here](https://www.nvidia.com/Download/index.aspx).
2. Install WSL2 from [Microsoft Store](https://aka.ms/wslstorepage).
3. Download and run `windows-install-sonaric.bat` script.

## MacOS

Paste that in a macOS Terminal.

```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/monk-io/homebrew-sonaric/HEAD/installer/install.sh)"
```

## Linux

Execute the following command in a terminal.
Currently supported distributions are Ubuntu, Debian, CentOS, Fedora

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/monk-io/sonaric-install/main/linux-install-sonaric.sh)"
```

Alternatively, you can download and unpack the binaries, that requires prerequisites:

* Podman >=3.4.0 https://podman.io/docs/installation
* Wireguard https://www.wireguard.com/install/

```
curl -skSL --retry 3 https://storage.googleapis.com/sonaric-releases/stable/linux/sonaric-amd64-latest.tar.gz | tar -xz -C /usr/local/bin
```
