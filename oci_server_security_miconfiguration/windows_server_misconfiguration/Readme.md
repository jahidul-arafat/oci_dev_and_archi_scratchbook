# Overview  
This is my PowerShell script to automate client pentest / checkups - at least to a certain extend.  


# What does it do  
You should run it as admin, as certain stuff can only be queries with elevated rights.  
It is used to check a client for common misconfigurations. The list currently includes:  
  - Default Domain Password Policy
  - LSA Protection Settings
  - WDAC Usage
  - AppLocker Usage
  - Credential Guard Settings
  - DMA Protection Settings
  - BitLocker Settings
  - Secure Boot Settings
  - System PATH ACL checks
  - WSUS Settings
  - PowerShell Settings
  - IPv6 Settings
  - NetBIOS / LLMNR Settings
  - SMB Server Settings
  - Firewall Settings
  - AV Settings
  - Proxy Settings
  - Windows Updates
  - 3rd Party Installations
  - RDP Settings
  - WinRM Settings
  
# How
If possible run as Admin, otherwise some checks might / will fail.  

```
. .\Client-Checker.ps1
```
or
```
import-module .\Client-Checker.ps1
```
or
```
iex(new-object net.webclient).downloadstring("https://raw.githubusercontent.com/LuemmelSec/Pentest-Tools-Collection/main/tools/Client-Checker/Client-Checker.ps1")
```
then just
```
Client-Checker
```

![image](https://github.com/LuemmelSec/Pentest-Tools-Collection/assets/58529760/0dad7fa1-7516-433d-ab2d-2e4a8eb912ee)
