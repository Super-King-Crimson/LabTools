# Hi ok i guess we're doing this now
- Get git bash. it's busted and makes everything really easy
- Once you do that link your OneDrive folders by running git bash as admin and doing ln -s
- and don't forget to get ahk you wanker
- and make ~/Binaries/startup shell:startup in regedit
    - type `Win+r` and type regedit
    - in the top bar, navigate to "Computer\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
    - change the value to "%USERPROFILE%\Binaries\startup"
    - restart
- Oh you can make vim your editor btw. Remember this command, substitute %L with whatever the editor is
```
"C:\Program Files\Git\git-bash.exe" -c "vim $(cygpath -u \"%L\")"
```
