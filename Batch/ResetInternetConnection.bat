:: Winsock Reset
netsh winsock reset

:: Reset TCP/IP Stack
netsh int ip reset

:: Release IP
ipconfig /release

:: Renew IP
ipconfig /renew

:: Flush DNS
ipconfig /flushdns

:: Registers DNS
ipconfig /registerdns

:: Restarts PC
shutdown -r