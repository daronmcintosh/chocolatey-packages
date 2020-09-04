# Windows Subsystem for Linux

*"Windows Subsystem for Linux lets developers run a GNU/Linux environment -- including most command-line tools, utilities, and applications -- directly on Windows, unmodified, without the overhead of a traditional virtual machine or dualboot setup"* - <https://docs.microsoft.com/en-us/windows/wsl/about>

## Package parameters

- `/Version:1` - the version of WSL to install. Defaults to `2`
- `/Retry:true` - whether to retry install on logon after computer is restarted for WSL 2. Ignored when `Version` is `1` and it defaults to `false`

Example: `choco install wsl2 --params "/Version:2 /Retry:true"`

## Note

- There are checks that are performed to ensure the system supports WSL 1 or 2. If any of these checks fail, the install will fail.
- WSL 1 requires a restart before it can be used if this is a fresh install of Windows.
- WSL 2 requires a restart before it can be installed if WSL 1 wasn't installed previously. Otherwise, it will be enabled if it detects WSL 1. <https://docs.microsoft.com/en-us/windows/wsl/install-win10#update-to-wsl-2>
- **Important**:
  - `/Retry:true` should only be set when installing WSL 2 on systems that didn't have WSL 1. Setting this param to `true` will schedule a self deleting task if script didn't detect WSL. That task if created will run `choco install wsl2 -y -f` in a powershell window after the computer is restarted.
  - `/Retry:false` you will have to run `choco install wsl2 -f` again manually after a restart if script didn't detect WSL.
