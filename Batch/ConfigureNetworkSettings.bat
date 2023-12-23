:: View your TCP/IP settings
netsh interface ip show config

:: View the ARP cache table
arp -a

:: Delete ARP cache
netsh interface ip delete arpcache
:: or you can simply use
arp -d

:: Configure your computer’s IP address and other TCP/IP related settings. This command configures the interface named Local Area Connection with the static IP address 192.168.0.20, the subnet mask of 255.255.255.0, and a default gateway of 192.168.0.1
netsh interface ip set address name="Local Area Connection" static 192.168.0.20 255.255.255.0 192.168.0.1

:: Configure your NIC to automatically obtain an IP address from a DHCP server:
netsh interface ip set address "Local Area Connection" dhcp

:: Configure DNS:
netsh interface ip set dns "Local Area Connection" static 192.168.0.200

:: Configure WINS:
netsh interface ip set wins "Local Area Connection" static 192.168.0.200

:: Configure your NIC to dynamically obtain it’s DNS settings:
netsh interface ip set dns "Local Area Connection" dhcp

:: Export your current IP settings to a text file. Use the following command:
netsh -c interface dump > c:\\MySettings.txt

:: Import your IP settings and change them, just enter the following command in a Command Prompt window (CMD.EXE):
netsh -f c:\\MyAnotherSettings.txt

:: Enable/Disable Windows firewall
netsh firewall set opmode mode=disable
:: netsh firewall set opmode mode=enable

:: Add Ports to the Exception List
netsh firewall add portopening TCP 3234 MyTCPPort
netsh firewall add portopening UDP 7365 MyUDPPort

:: Add applications to exceptions list
netsh firewall add allowedprogram c:\MyProgram.exe

:: We can view the firewall configuration by running the following command:
netsh firewall show allowedprogram

:: Displays all of the Adapters:
netsh diag show adapter

:: Displays all categories:
netsh diag show all

:: Displays all network clients:
netsh diag show client

:: Displays computer information:
netsh diag show computer

:: Displays the DHCP servers for each adapter:
netsh diag show dhcp

:: Displays the DNS servers for each adapter:
netsh diag show dns

:: Displays the default gateway servers for each adapter:
netsh diag show gateway

:: Displays Internet Explorer’s server name and port number:
netsh diag show ieproxy

:: Displays the IP address for each adapter:
netsh diag show ip

:: Displays the mail server name and port number:
netsh diag show mail

:: Displays all modems:
netsh diag show modem

:: Displays the news server name and port number:
netsh diag show news

:: Displays operating system information:
netsh diag show os

:: Displays all categories and performs all tests:
netsh diag show test

:: Displays the Windows and WMI version:
netsh diag show version

:: Displays the primary and secondary WINS servers for each adapter:
netsh diag show wins

:: Launch the GUI Network Diagnostic Program:
netsh diag gui