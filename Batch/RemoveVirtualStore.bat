@ECHO OFF
ECHO.
ECHO Checking for VirtualStore...

SET "VSREGPATH=HKEY_CURRENT_USER\SOFTWARE\Classes\VirtualStore\MACHINE\SOFTWARE\WOW6432Node\PaperWise"
REG QUERY %VSRegPath%
IF %ERRORLEVEL% EQU 0 GOTO VirtualStoreRemove

SET "VSREGPATH=HKEY_CURRENT_USER\SOFTWARE\Classes\VirtualStore\MACHINE\SOFTWARE\PaperWise"
REG QUERY %VSRegPath%
IF %ERRORLEVEL% EQU 0 GOTO VirtualStoreRemove

ECHO.
ECHO VirtualStore not found.
GOTO END

:VirtualStoreRemove
ECHO.
ECHO VirtualStore Found.
SET "TempFileName=%random%-%random%-PWVirtualStore.reg"

ECHO.
ECHO Backing up VirtualStore PaperWise Hive.
REG EXPORT %VSRegPath% %TEMP%\%TEMPFILENAME%

ECHO.
ECHO Removing PaperWise VirtualStore
REG DELETE %VSRegPath% /f

ECHO.
ECHO Modifying backup...
powershell -Command "(gc %TEMP%\%TEMPFILENAME%) -replace 'HKEY_CURRENT_USER\\SOFTWARE\\Classes\\VirtualStore\\MACHINE\\', 'HKEY_LOCAL_MACHINE\' | Out-File %TEMP%\%TEMPFILENAME%"

ECHO.
ECHO Importing backup to local PaperWise hive.
REG IMPORT %TEMP%\%TEMPFILENAME%
IF %ERRORLEVEL% EQU 1 (
ECHO.
ECHO Unable to import registry.
ECHO Moving copy of the registry backup to the desktop. Adjust permissions in the registry to allow the file 
ECHO to import successfully to maintain settings of the PaperWise software.
MOVE %TEMP%\%TEMPFILENAME% %userprofile%\desktop\PW-VS-Backup.reg
GOTO END
) ELSE DEL %TEMP%\%TEMPFILENAME%

ECHO.
ECHO Registry Imported.

:END
PAUSE
