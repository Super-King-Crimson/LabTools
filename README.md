# Windows verison of skconfig LOL
- Use along with skconfig!

# Getting Started
- Make a local windows account
- Turn on BitLocker and save the keys
- Run `wsl --install`

# Installations
## Misc
- [AutoHotkey](https://www.autohotkey.com/)
- [Parsec](https://parsec.app/downloads)
- [Tailscale](https://parsec.app/downloads)

## Git Bash
- Install [here](https://git-scm.com/install/windows)
- To pull this repository down:
```bash
cd
git clone --no-checkout git@github.com:Super-King-Crimson/LabTools.git
mv LabTools/.git ./.git
git reset --hard HEAD
mv .git .skconfig
/bin/rm -rf LabTools
```

## OpenSSH
- Open powershell as administrator
- Run this to install the SSH client and server
```sh
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# Set the service to start automatically on boot
Set-Service -Name sshd -StartupType Automatic

# Start the SSH server service right now
Start-Service sshd
```
- Explicitly disallow password logins:
```sh
notepad.exe C:\ProgramData\ssh\sshd_config
# Change this line
# PasswordAuthentication no
```
- Create a local ssh key by doing this:
```sh
ssh-keygen -t ed25519
```
- Then copy your ssh public key to the list of authorized admin keys
```sh
cat ~/.ssh/id_ed25519.pub | sc C:\ProgramData\ssh\administrators_authorized_keys
```
- **DO *NOT* THE REDIRECTION OPERATOR (>/>>)!**
    - Windows automatically encodes this as UTF-16, which will not be read by OpenSSH
    - To check if a file is encoded as UTF-16, run the following command.
    - If the first 2 numbers are 255 254 or 254 255, it is in UTF-16. Rewrite it with the `cat` | `sc` command above.
```sh
cat -Encoding Byte -TotalCount 4
```
- You should now be able to ssh by doing `ssh localhost`. To allow a different device to ssh:
    - Create the ssh key on that device (`ssh-keygen`)
    - Send the file to the host device and run this:
```sh
$path = "<INSERT-PATH-HERE>"
cat $path | ac C:\ProgramData\ssh\administrators_authorized_keys
```

## Get latest version of wt
```bash
winget upgrade --id Microsoft.WindowsTerminal --source winget
```

## Change shell:startup folder
- type `Win+r` and type regedit
- in the top bar, navigate to "Computer\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
- change the value of Startup to "%USERPROFILE%\path\to\Binaries\startup"
- restart

## Disable screen locking
- type `Win+r` and type regedit
- in the top bar, navigate to "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System"
    - If the System folder isn't there, right-click Policies -> New -> Key, and name it System
- Right-click inside the System folder -> New -> DWORD (32-bit) Value
- Name the new value DisableLockWorkstation, and change its value to 1
- restart

## You can make vim your editor using Binaries/vim.bat
