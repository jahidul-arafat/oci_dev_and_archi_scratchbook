<#
This is such an awesome script - not
Better run as admin because some shit can not be queried without (e.g. BitLocker status)
Green = good
Red = Not good
Purple = possibly not good

Author: @LuemmelSec
License: BSD 3-Clause

#>



$elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

function Get-AuditPolicies {
    param (
        [string]$subkey,
        [string]$eventName,
        [string]$successPattern,
        [string]$failurePattern,
        [string]$notConfiguredText
    )

    $regPath = "HKLM:\System\CurrentControlSet\Control\Lsa\Audit\$subkey"
    $auditPolicies = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue

    if ($null -eq $auditPolicies) {
        Write-Host ("{0}: {1}" -f $eventName, $notConfiguredText) -ForegroundColor Magenta
    }
    else {
        $auditData = @{
            0 = $notConfiguredText
            1 = $successPattern
            2 = $failurePattern
            3 = "Success and Failure"
        }

        $policyNames = $auditPolicies.PSObject.Properties.Name
        foreach ($policyName in $policyNames) {
            $value = $auditPolicies.$policyName
            if ($auditData.ContainsKey($value)) {
                $status = $auditData[$value]
                if ($status -eq $successPattern) {
                    Write-Host ("{0} - {1}: {2}" -f $eventName, $policyName, $status) -ForegroundColor Green
                }
                elseif ($status -eq $notConfiguredText) {
                    Write-Host ("{0} - {1}: {2}" -f $eventName, $policyName, $status) -ForegroundColor Magenta
                }
                elseif ($status -eq $failurePattern) {
                    Write-Host ("{0} - {1}: {2}" -f $eventName, $policyName, $status) -ForegroundColor Red
                }
                else {
                    Write-Host ("{0} - {1}: {2}" -f $eventName, $policyName, $status) -ForegroundColor Magenta
                }
            }
            else {
                Write-Host ("{0} - {1}: Unknown value" -f $eventName, $policyName) -ForegroundColor Yellow
            }
        }
    }
}

function Client-Checker{

    Write-host ""
    Write-host "#######################################################" -ForegroundColor DarkCyan
    Write-Host "#                   Client-Checker                    #" -ForegroundColor DarkCyan
    Write-Host "#                   by @LuemmelSec                    #" -ForegroundColor DarkCyan
    Write-Host "#          Automating Client Security Checks          #" -ForegroundColor DarkCyan
    Write-host "#######################################################" -ForegroundColor DarkCyan
    Write-host ""
    Write-Host "Stuff marked in green is good" -ForegroundColor Green
    Write-Host "Stuff marked in magenta is a 'might be' finding" -ForegroundColor Magenta
    Write-Host "Stuff marked in red is bad stuff" -ForegroundColor Red
    Write-Host "Stuff marked yellow are errors" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "If you happen to use PwnDoc or PwnDoc-ng, you can use my templates alongside this tool:"
    Write-Host "https://github.com/LuemmelSec/PwnDoc-Vulns/blob/main/SystemSecurity.yml"
    Write-Host ""

    ########### Preflight Checks ###########

    # Check if we run in elevated context so all checks can be done
    if($elevated -eq $true){
        Write-Host "Local Admin: " -ForegroundColor white -NoNewline; Write-Host $elevated -ForegroundColor Green
        Write-Host "We have superpowers. All checks should go okay." -ForegroundColor DarkGray
        Write-Host ""
    }
    else{
        Write-Host "Local Admin: " -ForegroundColor white -NoNewline; Write-Host $elevated -ForegroundColor Red
        Write-Host "You don't have super powers. Some checks might fail!" -ForegroundColor DarkGray
        Write-Host ""
    }

    # Check if all needed PS modules are installed that we need for the tests
    # Array of module names to check
    Write-Host "Checking for installed PowerShell modules..."
    $moduleNames = @("ActiveDirectory", "BitLocker")

    # Check if modules are installed
    $missingModules = @()
    $installedModules = @()
    foreach ($moduleName in $moduleNames) {
        if (Get-Module -ListAvailable -Name $moduleName) {
            $installedModules += $moduleName
            Write-Host "The '$moduleName' module is installed." -ForegroundColor Green
        } else {
            $missingModules += $moduleName
            Write-Host "The '$moduleName' module is not installed." -ForegroundColor Red
        }
    }

    # Prompt to install missing modules
    if ($missingModules.Count -gt 0) {
        $installModules = Read-Host "Do you want to install the missing modules? (Y/N)"
        if ($installModules -eq "Y" -or $installModules -eq "y") {
            foreach ($module in $missingModules) {
                Write-Host "Installing module '$module'..."
                Install-Module -Name $module -Scope CurrentUser
            }
        }
    }

    ########### Beginning of the actual checks ###########

    # Domain Password Policy checks
    Write-Host ""
    Write-Host "##############################################"
    Write-Host "# Now checking Default Domain Password stuff #"
    Write-Host "##############################################"
    Write-Host "References: https://learn.microsoft.com/en-us/microsoft-365/admin/misc/password-policy-recommendations?view=o365-worldwide" -ForegroundColor DarkGray
    Write-Host "References: https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/account-lockout-duration" -ForegroundColor DarkGray
    Write-Host "References: https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/account-lockout-threshold" -ForegroundColor DarkGray
    Write-Host "References: https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/store-passwords-using-reversible-encryption" -ForegroundColor DarkGray
    Write-Host ""

    try {
        $defaultPolicy = Get-ADDefaultDomainPasswordPolicy

        if ($defaultPolicy.ComplexityEnabled -eq $false){
            Write-Host "Complexity Enabled: $false" -ForegroundColor Red
        }
        else {
            Write-Host "Complexity Enabled: $true" -ForegroundColor Green
        }

        if ($defaultPolicy.lockoutduration.TotalMinutes -gt 14){
            Write-Host "Lockout Duration: $($defaultPolicy.lockoutduration.TotalMinutes)" -ForegroundColor Green
        }
        elseif ($defaultPolicy.lockoutduration.TotalMinutes -eq 0) {
            Write-Host "Lockout Duration: Will never lock" -ForegroundColor Red
        }
        else {
            Write-Host "Lockout Duration: $($defaultPolicy.lockoutduration.TotalMinutes)" -ForegroundColor Magenta
        }

        if ($defaultPolicy.lockoutthreshold -eq 0) {
            Write-Host "Lockout Threshold: Will never lock" -ForegroundColor Red
        }
        elseif ($defaultPolicy.lockoutthreshold -lt 11){
            Write-Host "Lockout Threshold: $($defaultPolicy.lockoutthreshold)" -ForegroundColor Green
        }
        else {
            Write-Host "Lockout Threshold: $($defaultPolicy.lockoutthreshold)" -ForegroundColor Magenta
        }

        if ($defaultPolicy.MinPasswordLength -lt 12){
            Write-Host "Min Password Length: $($defaultPolicy.MinPasswordLength)" -ForegroundColor Red
        }
        else {
            Write-Host "Min Password Length: $($defaultPolicy.MinPasswordLength)" -ForegroundColor Green
        }

        if ($defaultPolicy.ReversibleEncryptionEnabled -eq $true){
            Write-Host "Reversible Encryption Enabled: $true" -ForegroundColor Red
        }
        else {
            Write-Host "Reversible Encryption Enabled: $false" -ForegroundColor Green
        }

        Write-Host "Lockout Duration: $($defaultPolicy.LockoutDuration)" -ForegroundColor DarkGray
        Write-Host "Lockout Observation Window: $($defaultPolicy.LockoutObservationWindow)" -ForegroundColor DarkGray
    }
    catch {
        Write-Host "Failed to query domain information. Check if the domain is accessible." -ForegroundColor Yellow
    }


    # Run As PPL checks
    Write-host ""
    Write-host "#####################################"
    Write-host "# Now checking LSA Protection stuff #"
    Write-host "#####################################"
    Write-host "References: https://itm4n.github.io/lsass-runasppl/" -ForegroundColor DarkGray
    Write-host ""
    try {
        $value = Get-ItemPropertyvalue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL" -ErrorAction Stop

        if ($value -eq 1) {
            Write-Host "RunAsPPL: Enabled" -ForegroundColor Green
        }
        elseif ($value -eq 0) {
            Write-Host "RunAsPPL: Disabled" -ForegroundColor Red
        }
        else {
            Write-Host "RunAsPPL: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
        }
    }
    catch {
        Write-Host "RunAsPPL: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
    }

    <# Deprecated due to WDAC checks. According to MS Device Guard is no longer used: https://learn.microsoft.com/en-us/windows/security/threat-protection/device-guard/introduction-to-device-guard-virtualization-based-security-and-windows-defender-application-control
    # Device Guard checks
    Write-host ""
    Write-host "###################################"
    Write-host "# Now checking Device Guard stuff #"
    Write-host "###################################"
    Write-host "References: https://techcommunity.microsoft.com/t5/iis-support-blog/windows-10-device-guard-and-credential-guard-demystified/ba-p/376419" -ForegroundColor DarkGray
    Write-host "References: https://learn.microsoft.com/en-us/windows/security/threat-protection/device-guard/introduction-to-device-guard-virtualization-based-security-and-windows-defender-application-control" -ForegroundColor DarkGray
    Write-host ""
    $computerInfo = Get-ComputerInfo
    $DeviceGuardStatus = $computerInfo.DeviceGuardSmartStatus

    if ($DeviceGuardStatus -eq "Running") {
        Write-Host "Device Guard is enabled." -ForegroundColor Green
    } else {
        Write-Host "Device Guard is not enabled." -ForegroundColor Red
    } #>

    # WDAC checks
    Write-host ""
    Write-host "###########################"
    Write-host "# Now checking WDAC stuff #"
    Write-host "###########################"
    Write-host "References: https://learn.microsoft.com/en-us/windows/security/threat-protection/device-guard/introduction-to-device-guard-virtualization-based-security-and-windows-defender-application-control" -ForegroundColor DarkGray
    Write-host "References: https://learn.microsoft.com/en-us/answers/questions/536416/checking-microsoft-defender-application-control-is" -ForegroundColor DarkGray
    Write-host "References: https://www.stigviewer.com/stig/windows_paw/2017-11-21/finding/V-78163" -ForegroundColor DarkGray
    Write-host "References: https://www.stigviewer.com/stig/windows_paw/2017-11-21/finding/V-78157" -ForegroundColor DarkGray
    Write-host ""
    $deviceGuard = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard

    $CodeIntegrityPolicyEnforcementStatus = $deviceGuard.CodeIntegrityPolicyEnforcementStatus
    $UsermodeCodeIntegrityPolicyEnforcementStatus = $deviceGuard.UsermodeCodeIntegrityPolicyEnforcementStatus

    if ($CodeIntegrityPolicyEnforcementStatus -eq 2) {
        Write-Host "Code Integrity Policy Enforcement is enabled." -ForegroundColor Green
    }
    elseif ($CodeIntegrityPolicyEnforcementStatus -eq 0) {
        Write-Host "Code Integrity Policy Enforcement is disabled." -ForegroundColor Red
    }
    elseif ($CodeIntegrityPolicyEnforcementStatus -eq 1) {
        Write-Host "Code Integrity Policy Enforcement is set to observe." -ForegroundColor Magenta
    }
    else {
        Write-Host "Code Integrity Policy Enforcement status is unknown." -ForegroundColor Red
    }

    if ($UsermodeCodeIntegrityPolicyEnforcementStatus -eq 2) {
        Write-Host "Usermode Code Integrity Policy Enforcement is enabled." -ForegroundColor Green
    }
    elseif ($UsermodeCodeIntegrityPolicyEnforcementStatus -eq 0) {
        Write-Host "Usermode Code Integrity Policy Enforcement is disabled." -ForegroundColor Red
    }
    elseif ($UsermodeCodeIntegrityPolicyEnforcementStatus -eq 1) {
        Write-Host "Usermode Code Integrity Policy Enforcement is set to observe." -ForegroundColor Magenta
    }
    else {
        Write-Host "Usermode Code Integrity Policy Enforcement status is unknown." -ForegroundColor Red
    }

    # AppLocker checks
    Write-host ""
    Write-host "#################################"
    Write-host "# Now checking AppLocker stuff #"
    Write-host "################################"
    Write-host "References: https://learn.microsoft.com/de-de/windows/security/threat-protection/windows-defender-application-control/applocker/applocker-overview" -ForegroundColor DarkGray
    Write-host ""
    $appLockerService = Get-Service -Name AppIDSvc
    if ($appLockerService.Status -eq "Running") {
        Write-Host "AppLocker is running." -ForegroundColor Green
    } else {
        Write-Host "AppLocker is not running." -ForegroundColor Red
    }

    # Credential Guard checks
    Write-host ""
    Write-host "#######################################"
    Write-host "# Now checking Credential Guard stuff #"
    Write-host "#######################################"
    Write-host "References: https://learn.microsoft.com/en-us/windows/security/identity-protection/credential-guard/credential-guard-manage" -ForegroundColor DarkGray
    Write-host ""
    $credentialGuardEnabled = (Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard).SecurityServicesRunning

    if ($credentialGuardEnabled -eq 1) {
        Write-Host "Credential Guard is enabled." -ForegroundColor Green
    } else {
        Write-Host "Credential Guard  is not enabled." -ForegroundColor red
    }

        # DMA protection related stuff
    Write-host ""
    Write-host "#####################################"
    Write-host "# Now checking DMA Protection stuff #"
    Write-host "#####################################"
    Write-host "References: https://www.synacktiv.com/en/publications/practical-dma-attack-on-windows-10.html" -ForegroundColor DarkGray
    Write-host "References: https://www.scip.ch/?labs.20211209" -ForegroundColor DarkGray
    Write-host "References: https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-dataprotection" -ForegroundColor DarkGray
    Write-host ""
    try {
        $value = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceLock" -Name "AllowDirectMemoryAccess" -ErrorAction Stop

        if ($value -eq 1) {
            Write-Host "AllowDirectMemoryAccess: Enabled" -ForegroundColor Red
        }
        elseif ($value -eq 0) {
            Write-Host "AllowDirectMemoryAccess: Disabled" -ForegroundColor Green
        }
        else {
            Write-Host "AllowDirectMemoryAccess: Error (probably regkey doesn't exist - hence enabled)" -ForegroundColor Magenta
        }
    }
    catch {
        Write-Host "AllowDirectMemoryAccess: Error (probably regkey doesn't exist - hence enabled)" -ForegroundColor Magenta
    }

    try {
        $value = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -Name "EnableVirtualizationBasedSecurity" -ErrorAction Stop

        if ($value -eq 1) {
            Write-Host "EnableVirtualizationBasedSecurity: Enabled" -ForegroundColor Green
        }
        elseif ($value -eq 0) {
            Write-Host "EnableVirtualizationBasedSecurity: Disabled" -ForegroundColor Red
        }
        else {
            Write-Host "EnableVirtualizationBasedSecurity: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
        }
    }
    catch {
        Write-Host "EnableVirtualizationBasedSecurity: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
    }

    try {
        $value = Get-ItemPropertyValue -Path Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -ErrorAction Stop

        if ($value -eq 1) {
            Write-Host "HypervisorEnforcedCodeIntegrity: Enabled" -ForegroundColor Green
        }
        elseif ($value -eq 0) {
            Write-Host "HypervisorEnforcedCodeIntegrity: Disabled" -ForegroundColor Red
        }
        else {
            Write-Host "HypervisorEnforcedCodeIntegrity: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
        }
    }
    catch {
        Write-Host "HypervisorEnforcedCodeIntegrity: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
    }

    try {
        $value = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "LockConfiguration" -ErrorAction Stop

        if ($value -eq 1) {
            Write-Host "HypervisorEnforcedCodeIntegrity Config Locked: Enabled" -ForegroundColor Green
        }
        elseif ($value -eq 0) {
            Write-Host "HypervisorEnforcedCodeIntegrity Config Locked: Disabled" -ForegroundColor Red
        }
        else {
            Write-Host "HypervisorEnforcedCodeIntegrity Config Locked: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
        }
    }
    catch {
        Write-Host "HypervisorEnforcedCodeIntegrity Config Locked: Error (probably regkey doesn't exist - hence disabled)" -ForegroundColor Magenta
    }

    # BitLocker status
    Write-host ""
    Write-host "###################################"
    Write-host "# Now checking BitLocker settings #"
    Write-host "# If TPM only > possibly insecure #"
    Write-host "###################################"
    Write-host "References: https://learn.microsoft.com/en-us/powershell/module/bitlocker/add-bitlockerkeyprotector?view=windowsserver2022-ps" -ForegroundColor DarkGray
    Write-host "References: https://luemmelsec.github.io/Go-away-BitLocker-you-are-drunk/" -ForegroundColor DarkGray
    Write-host ""
    $volumes = $null

    try {
        $volumes = Get-BitLockerVolume -ErrorAction Stop
        foreach ($volume in $volumes) {
            $volumeLabel = $volume.MountPoint
            $bitLockerStatus = $volume.ProtectionStatus
            $keyProtectorType = $volume.KeyProtector.KeyProtectorType

            if ($bitLockerStatus -eq "On") {
                Write-Host "BitLocker on volume $volumeLabel - enabled" -ForegroundColor Green

                if ($keyProtectorType -like "*ExternalKey*") {
                    Write-Host "Protection of key material on volume $volumeLabel - possibly insecure" -ForegroundColor Magenta
                }
                elseif ($keyProtectorType -like "*key*" -or $keyProtectorType -like "*pin*") {
                    Write-Host "Protection of key material on volume $volumeLabel - okay" -ForegroundColor Green
                }
                else {
                    Write-Host "Protection of key material on volume $volumeLabel - possibly insecure" -ForegroundColor Magenta
                }
            }
            else {
                Write-Host "BitLocker on volume $volumeLabel - disabled" -ForegroundColor Red
            }
        }
    } catch {
        $errorMessage = $_.Exception.Message
        if ($errorMessage -like "*Access Denied*") {
            Write-Host "Could not query the information with current rights." -ForegroundColor Yellow
        } else {
            Write-Host "An error occurred: $errorMessage" -ForegroundColor Red
        }
    }



    # Secure Boot enabled?
    Write-host ""
    Write-host "#####################################"
    Write-host "# Now checking Secure Boot settings #"
    Write-host "#####################################"
    Write-host "References: https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/oem-secure-boot" -ForegroundColor DarkGray
    Write-host ""
    $firmwareType = $null

    try {
        $firmwareType = Get-CimInstance -Namespace root\cimv2\Security\MicrosoftTpm -ClassName Win32_Tpm -ErrorAction Stop | Select-Object -ExpandProperty SpecVersion
        if ($firmwareType -ne $null) {
            Write-Host "Secure Boot is enabled." -ForegroundColor Green
        } else {
            Write-Host "Secure Boot is not enabled." -ForegroundColor Red
        }
    } catch {
        if ($_.Exception.Message -like "*Access Denied*") {
            Write-Host "Could not query the information with current rights." -ForegroundColor Yellow
        } else {
            Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
        }
    }


    # Can the Users group write to SYSTEM PATH folders > Hijacking possibilities?
    Write-host ""
    Write-host "###########################################################"
    Write-host "# Now checking ACLs on folders from `$PATH System variable #"
    Write-host "###########################################################"
    Write-host "References: https://book.hacktricks.xyz/windows-hardening/windows-local-privilege-escalation/dll-hijacking/writable-sys-path-+dll-hijacking-privesc" -ForegroundColor DarkGray
    Write-host ""
    $env:Path -split ';' | ForEach-Object {
        $folder = $_

        if (Test-Path -Path $folder) {
            $acl = Get-Acl -Path $folder
            $usersGroup = New-Object System.Security.Principal.NTAccount("BUILTIN", "Users")
            $usersAccess = $acl.Access | Where-Object { $_.IdentityReference -eq $usersGroup -and $_.FileSystemRights -band [System.Security.AccessControl.FileSystemRights]::Write }

            if ($usersAccess -ne $null) {
                Write-Host "Members of the Users Group can write to folder: $folder" -ForegroundColor Red
            } else {
                Write-Host "Members of the Users Group cannot write to folder: $folder" - -ForegroundColor Green
            }
        } else {
            Write-Host "Folder does not exist: $folder"
        }
    }

    # Do we have unqoted service paths? > Hijacking possibilities?
    Write-host ""
    Write-host "###########################################"
    Write-host "# Now checking for unquoted service paths #"
    Write-host "###########################################"
    Write-host "References: https://book.hacktricks.xyz/windows-hardening/windows-local-privilege-escalation/dll-hijacking/writable-sys-path-+dll-hijacking-privesc" -ForegroundColor DarkGray
    Write-Host "References: https://github.com/itm4n/PrivescCheck/tree/master" -ForegroundColor DarkGray
    Write-host ""
    $services = Get-CimInstance -Class Win32_Service -Property Name, DisplayName, PathName, StartMode |
    Where-Object {
        $_.PathName -notlike "C:\Windows*" -and
        $_.PathName -notlike '"*"*' -and
        $_.PathName -ne $null
    }

    foreach ($service in $services) {
        $serviceName = $service.Name
        $path = $service.PathName
        $displayName = $service.DisplayName
        $startMode = $service.StartMode

        Write-Host "Service Name: $($serviceName)" -ForegroundColor Red
        Write-Host "Path: $($path)" -ForegroundColor Red
        Write-Host "Display Name: $($displayName)" -ForegroundColor Red
        Write-Host "Start Mode: $($startMode)" -ForegroundColor Red
        Write-Host "" -ForegroundColor Red
    }

    # Check if WSUS is fetching updates over HTTP instaed of HTTPS?
    Write-host ""
    Write-host "##############################"
    Write-host "# Now checking WSUS settings #"
    Write-host "##############################"
    Write-host "References: https://www.gosecure.net/blog/2020/09/03/wsus-attacks-part-1-introducing-pywsus/" -ForegroundColor DarkGray
    Write-host ""
    try {
        $wsusPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

        if (Test-Path -Path $wsusPath) {
            $wsusConfiguration = Get-ItemProperty -Path $wsusPath -Name "WUServer"
            $wsusServerUrl = $wsusConfiguration.WUServer

            if ($wsusServerUrl -match "^http://") {
                Write-Host "WSUS updates are fetched over HTTP." -ForegroundColor Red
            } else {
                Write-Host "WSUS updates are not fetched over HTTP." -ForegroundColor Green
            }
        } else {
            Write-Host "WSUS is not configured." -ForegroundColor Green
        }
    } catch {
        Write-Host "An error occurred while checking the WSUS configuration."
    }

    # PowerShell related checks
    Write-host ""
    Write-host "####################################"
    Write-host "# Now checking PowerShell settings #"
    Write-host "####################################"
    Write-host "References: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7.3" -ForegroundColor DarkGray
    Write-host ""

    # Check if PowerShell v2 can be run
    $psVersion2Enabled = $false

    $psInfo = New-Object System.Diagnostics.ProcessStartInfo
    $psInfo.FileName = 'powershell.exe'
    $psInfo.Arguments = '-Version 2 -NoExit -Command "exit"'
    $psInfo.RedirectStandardOutput = $true
    $psInfo.RedirectStandardError = $true
    $psInfo.UseShellExecute = $false
    $psInfo.CreateNoWindow = $true

    $psProcess = New-Object System.Diagnostics.Process
    $psProcess.StartInfo = $psInfo

    try {
        [void]$psProcess.Start()
        [void]$psProcess.WaitForExit()

        if ($psProcess.ExitCode -eq 0) {
            $psVersion2Enabled = $true
        }
    } finally {
        [void]$psProcess.Dispose()
    }

    if ($psVersion2Enabled) {
        Write-Host "PowerShell v2 can be run." -ForegroundColor Red
    } else {
        Write-Host "PowerShell v2 cannot be run." -ForegroundColor Green
    }

    # Check the execution policy
    $executionPolicy = Get-ExecutionPolicy
    if ($executionPolicy -eq "AllSigned") {
        Write-Host "Execution Policy is $executionPolicy" -ForegroundColor Green
    } elseif ($executionPolicy -eq "Unrestricted" -or $executionPolicy -eq "Bypass") {
        Write-Host "Execution Policy is $executionPolicy" -ForegroundColor Red
    } else {
        Write-Host "Execution Policy is $executionPolicy" -ForegroundColor Magenta
    }

    # Check the language mode
    $languageMode = $ExecutionContext.SessionState.LanguageMode
    if ($languageMode -eq "FullLanguage") {
        Write-Host "Language Mode is $languageMode" -ForegroundColor Red
    } else {
        Write-Host "Language Mode is $languageMode" -ForegroundColor Green
    }

    # IPv6 settings
    Write-host ""
    Write-host "##############################"
    Write-host "# Now checking IPv6 settings #"
    Write-host "##############################"
    Write-host "References: https://blog.fox-it.com/2018/01/11/mitm6-compromising-ipv4-networks-via-ipv6/" -ForegroundColor DarkGray
    Write-host "References: https://www.blackhillsinfosec.com/mitm6-strikes-again-the-dark-side-of-ipv6/" -ForegroundColor DarkGray
    Write-host ""

    $adapterStatus = Get-NetAdapterBinding | Where-Object {$_.ComponentID -eq "ms_tcpip6"} | Select-Object -Property Name, Enabled
    $adapterStatus | ForEach-Object {
        $adapterName = $_.Name
        if (-not $_.Enabled) {
            Write-Host "IPv6 is disabled on Adapter $adapterName." -ForegroundColor Green
        } else {
            Write-Host "IPv6 is enabled on Adapter $adapterName." -ForegroundColor Red
        }
    }

    # NetBIOS Name Resolution and LLMNR checks
    Write-host ""
    Write-host "#########################################"
    Write-host "# Now checking NetBIOS / LLMNR settings #"
    Write-host "#########################################"
    Write-host "References: https://luemmelsec.github.io/Relaying-101/" -ForegroundColor DarkGray
    Write-host ""

    # Check if LLMNR is enabled or disabled
    $dnsClientKey = "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient"
    try {
        $llmnrValue = (Get-ItemProperty -Path $dnsClientKey -Name "EnableMulticast" -ErrorAction Stop).EnableMulticast

        if ($llmnrValue -eq 0) {
            Write-Host "LLMNR status: disabled" -ForegroundColor Green
        } elseif ($llmnrValue -eq 1) {
            Write-Host "LLMNR status: enabled" -ForegroundColor Red
        }
    } catch {
        Write-Host "LLMNR status: reg key not found - hence enabled" -ForegroundColor Red
    }

    # Check if NetBIOS is enabled for each network adapter
    $netbtInterfacePath = "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces"
    $adapterKeys = Get-ChildItem -Path $netbtInterfacePath -ErrorAction SilentlyContinue

    $netbiosEnabled = $false
    $enabledAdapters = @()

    foreach ($adapterKey in $adapterKeys) {
        $adapterName = $adapterKey.PSChildName
        if ($adapterName -like "Tcpip_*") {
            $adapterName = $adapterName -replace "^Tcpip_", ""

            $netbiosOptions = (Get-ItemProperty -Path "$netbtInterfacePath\$($adapterKey.PSChildName)" -Name "NetbiosOptions" -ErrorAction SilentlyContinue).NetbiosOptions

            if ($netbiosOptions -eq 1 -or $netbiosOptions -eq 0) {
                $netbiosEnabled = $true
                $enabledAdapters += $adapterName
            }
        }
    }

    if ($netbiosEnabled) {
        Write-Host "NetBIOS status: Enabled on at least one network adapter" -ForegroundColor Red
        Write-Host ""
        foreach ($adapter in $enabledAdapters) {
            $adapterInstance = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.SettingID -like "*$adapter*" }
            Write-Host $adapterInstance.Description -ForegroundColor Red
        }
    }
    else {
        Write-Host "NetBIOS status: Not enabled on any network adapter" -ForegroundColor Green
        }


    # SMB Checks
    Write-host ""
    Write-host "####################################"
    Write-host "# Now checking SMB Server settings #"
    Write-host "####################################"
    Write-host "References: https://luemmelsec.github.io/Relaying-101/" -ForegroundColor DarkGray
    Write-host "References: https://techcommunity.microsoft.com/t5/storage-at-microsoft/configure-smb-signing-with-confidence/ba-p/2418102" -ForegroundColor DarkGray
    Write-host ""

    $smbConfig = Get-SmbServerConfiguration

    # Check SMB1 settings
    if ($smbConfig.EnableSMB1Protocol) {
        Write-Host "SMB version 1 is used. No Signing available here!!!" -ForegroundColor Red
    } else {
        Write-Host "SMB version 1 is not used" -ForegroundColor Green
    }

    # Check SMB Signing settings
    if ($smbConfig.RequireSecuritySignature) {
        Write-Host "SMB signing is enabled for SMB2 and newer" -ForegroundColor Green
    } else {
        Write-Host "SMB signing is disabled for SMB2 and newer" -ForegroundColor Red
    }

    # Firewall Checks
    Write-host ""
    Write-host "##################################"
    Write-host "# Now checking Firewall settings #"
    Write-host "##################################"
    Write-host "References: https://learn.microsoft.com/en-us/windows/security/operating-system-security/network-security/windows-firewall/best-practices-configuring" -ForegroundColor DarkGray
    Write-host ""

    try {
        $firewallProfile = Get-NetFirewallProfile -Profile Domain, Public, Private -ErrorAction Stop

        if ($firewallProfile.Enabled) {
            Write-Host "Windows Firewall is enabled." -ForegroundColor Magenta
            Write-Host "Firewall Rules (check them for dangerous stuff):" -ForegroundColor Magenta

            # Get all Firewall rules
            $firewallRules = Get-NetFirewallRule 2>&1

            if ($firewallRules -match "Access is denied") {
                Write-Host "Could not query the information with current rights." -ForegroundColor Yellow
            }
            elseif ($firewallRules) {
                $ruleTable = @()
                foreach ($rule in $firewallRules) {
                    $ruleName = $rule.Name

                    # The ports are not stored directly in the rules but in the associated Port Filter set
                    $portFilters = Get-NetFirewallPortFilter -AssociatedNetFirewallRule $rule -ErrorAction SilentlyContinue

                    $localAddresses = @()
                    $remoteAddresses = @()

                    # Local and remote addresses are not directly stored in the rule but in the associated Address Filter set
                    $addressFilters = Get-NetFirewallAddressFilter -AssociatedNetFirewallRule $rule -ErrorAction SilentlyContinue
                    foreach ($addressFilter in $addressFilters) {
                        if ($addressFilter.LocalAddress -ne "*") {
                            $localAddresses += $addressFilter.LocalAddress
                        }

                        if ($addressFilter.RemoteAddress -ne "*") {
                            $remoteAddresses += $addressFilter.RemoteAddress
                        }
                    }

                    $localAddress = if ($localAddresses) { $localAddresses -join ', ' } else { "N/A" }
                    $remoteAddress = if ($remoteAddresses) { $remoteAddresses -join ', ' } else { "N/A" }

                    $ruleEntry = [PSCustomObject]@{
                        "Rule Name"        = $rule.DisplayName
                        "Action"           = $rule.Action
                        "Enabled"          = $rule.Enabled
                        "Protocol"         = $rule.Protocol
                        "Allowed Ports"    = if ($portFilters) { $portFilters.LocalPort -join ', ' } else { "None" }
                        "Direction"        = $rule.Direction
                        "Local Address"    = $localAddress
                        "Remote Address"   = $remoteAddress
                    }

                    $ruleTable += $ruleEntry
                }

                $ruleTable | Format-Table -AutoSize
            } else {
                Write-Host "No firewall rules found." -ForegroundColor Green
            }
        } else {
            Write-Host "Windows Firewall is disabled." -ForegroundColor Red
        }
    } catch {
        Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    }



    # AV Checks
    Write-host ""
    Write-host "############################"
    Write-host "# Now checking AV settings #"
    Write-host "############################"
    Write-host "References: https://www.itnator.net/antivirus-status-auslesen-mit-powershell/" -ForegroundColor DarkGray
    Write-host ""

    # Produkt Status Flags
    [Flags()] enum ProductState {
        Off         = 0x0000
        On          = 0x1000
        Snoozed     = 0x2000
        Expired     = 0x3000
    }

    # Signature Status Flags
    [Flags()] enum SignatureStatus {
        UpToDate     = 0x00
        OutOfDate    = 0x10
    }

    # Product Owner Flags
    [Flags()] enum ProductOwner {
        NotMS        = 0x000
        Windows      = 0x100
    }

    [Flags()] enum ProductFlags {
        SignatureStatus = 0x00F0
        ProductOwner    = 0x0F00
        ProductState    = 0xF000
    }

    # Get installed AV software
    $avinfo = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntiVirusProduct

    # if more AV installed...
    foreach ($av in $avinfo) {
        # get status in decimal
        $state = $av.productState
        # convert decimal to hex
        $state = '0x{0:x}' -f $state

        # decode flags
        $productStatus = [ProductState]($state -band [ProductFlags]::ProductState)
        $signatureStatus = [SignatureStatus]($state -band [ProductFlags]::SignatureStatus)

        if ($productStatus -eq "On") {
            Write-Host "Name: $($av.displayName)"
            Write-Host "Product Status: $($productStatus.ToString())" -ForegroundColor Green

            if ($signatureStatus -ne "UpToDate") {
                Write-Host "Signature Status: $($signatureStatus.ToString())" -ForegroundColor Red
            } else {
                Write-Host "Signature Status: $($signatureStatus.ToString())" -ForegroundColor Green
            }

            Write-Host ""
        } elseif ($productStatus -eq "Snoozed") {
            Write-Host "Name: $($av.displayName)"
            Write-Host "Product Status: $($productStatus.ToString())" -ForegroundColor Magenta

            if ($signatureStatus -ne "UpToDate") {
                Write-Host "Signature Status: $($signatureStatus.ToString())" -ForegroundColor Red
            } else {
                Write-Host "Signature Status: $($signatureStatus.ToString())" -ForegroundColor Green
            }

            Write-Host ""
        } else {
            Write-Host "Name: $($av.displayName)"
            Write-Host "Product Status: $($productStatus.ToString())" -ForegroundColor Red

            if ($signatureStatus -ne "UpToDate") {
                Write-Host "Signature Status: $($signatureStatus.ToString())" -ForegroundColor Red
            } else {
                Write-Host "Signature Status: $($signatureStatus.ToString())" -ForegroundColor Green
            }

            Write-Host ""
        }
    }
    Write-Host "Don't forget to check exclusions!" -ForegroundColor Magenta

    # Proxy Checks
    Write-host ""
    Write-host "###############################"
    Write-host "# Now checking Proxy settings #"
    Write-host "###############################"
    Write-host "References: " -ForegroundColor DarkGray
    Write-host ""

    $proxySettings = Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'

    if ($proxySettings.ProxyEnable) {
        Write-Host "Proxy enabled: Yes - check if it does a good job or not" -ForegroundColor Magenta
        Write-Host "Proxy Server: $($proxySettings.ProxyServer)" -ForegroundColor Magenta
        Write-Host "Bypass list: $($proxySettings.ProxyOverride)" -ForegroundColor Magenta
    } else {
        Write-Host "Proxy enabled: No" -ForegroundColor Red
    }

    if ($proxySettings.AutoConfigUrl) {
        Write-Host "Auto Config set: Yes - check if it does a good job or not" -ForegroundColor Magenta
        Write-Host "Automatic Configuration URL: $($proxySettings.AutoConfigUrl)" -ForegroundColor Magenta
    } else {
        Write-Host "Auto Config set: No" -ForegroundColor Red
    }


    # Windows Update Checks
    Write-host ""
    Write-host "################################"
    Write-host "# Now checking Windows Updates #"
    Write-host "################################"
    Write-host "References: " -ForegroundColor DarkGray
    Write-host ""

    $UpdateSession = New-Object -ComObject "Microsoft.Update.Session"
    $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
    $SearchResult = $UpdateSearcher.Search("IsInstalled=0 and IsHidden=0")
    $pendingUpdates = $SearchResult.Updates | Where-Object { $_.Categories.Count -eq 0 -or $_.Categories.CategoryID -notcontains "Installed" }
    $importantUpdates = $pendingUpdates | Where-Object { $_.Categories.CategoryID -eq "ImportantUpdates" }
    $systemUpToDate = $importantUpdates.Count -eq 0

    if ($systemUpToDate) {
        Write-Host "System is up-to-date." -ForegroundColor Green
    } else {
        Write-Host "System is not up-to-date." -ForegroundColor Red
    }

    Write-Host ""

    if ($importantUpdates.Count -gt 0) {
        Write-Host "Pending Important Updates:" -ForegroundColor Red
        foreach ($update in $importantUpdates) {
            Write-Host "- $($update.Title)" -ForegroundColor Red
        }
    }

    $otherUpdates = $pendingUpdates | Where-Object { $_.Categories.CategoryID -ne "ImportantUpdates" }

    if ($otherUpdates.Count -gt 0) {
        Write-Host "Pending Other Updates:" -ForegroundColor Magenta
        foreach ($update in $otherUpdates) {
            Write-Host "- $($update.Title)" -ForegroundColor Magenta
        }
    }

    if ($systemUpToDate -and $otherUpdates.Count -eq 0) {
        Write-Host "No pending updates." -ForegroundColor Green
    }

    # Installed Software Checks
    Write-host ""
    Write-host "###################################"
    Write-host "# Now checking installed Software #"
    Write-host "###################################"
    Write-host "References: " -ForegroundColor DarkGray
    Write-host ""

    $InstalledSoftware = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall" |
                         Get-ItemProperty |
                         Select-Object DisplayName, DisplayVersion, @{n='InstallDate';e={([datetime]::ParseExact($_.InstallDate,'yyyyMMdd',$null)).ToString('dd-MM-yyyy')}}

    $InstalledSoftware += Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" |
                          Get-ItemProperty |
                          Select-Object DisplayName, DisplayVersion, @{n='InstallDate';e={([datetime]::ParseExact($_.InstallDate,'yyyyMMdd',$null)).ToString('dd-MM-yyyy')}}

    $InstalledSoftware += Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall" |
                          Get-ItemProperty |
                          Select-Object DisplayName, DisplayVersion, @{n='InstallDate';e={([datetime]::ParseExact($_.InstallDate,'yyyyMMdd',$null)).ToString('dd-MM-yyyy')}}
    $InstalledSoftware | Sort-Object DisplayName | Format-Table -AutoSize


    # RDP Checks
    Write-host ""
    Write-host "##########################"
    Write-host "# Now checking RDP stuff #"
    Write-host "##########################"
    Write-host "References: https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.TerminalServer::TS_SECURITY_LAYER_POLICY" -ForegroundColor DarkGray
    Write-host "References: https://viperone.gitbook.io/pentest-everything/everything/everything-active-directory/adversary-in-the-middle/rdp-mitm" -ForegroundColor DarkGray
    Write-host "References: https://www.tenable.com/plugins/nessus/18405" -ForegroundColor DarkGray
    Write-host ""

    # Check if RDP is enabled
    $rdpEnabled = Get-CimInstance -Namespace "root/CIMv2/TerminalServices" -ClassName "Win32_TerminalServiceSetting" | Select-Object -ExpandProperty AllowTSConnections
    if ($rdpEnabled -eq 1) {
        Write-Host "Remote Desktop is enabled." -ForegroundColor Magenta
    } else {
        Write-Host "Remote Desktop is disabled." -ForegroundColor Green
    }

    # Check Security Settings for RDP
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
    $securityLayer = (Get-ItemProperty -Path $regPath -Name "SecurityLayer").SecurityLayer
    switch ($securityLayer) {
        0 {
            Write-Host "RDP Security Layer: Disabled" -ForegroundColor Red
            break
        }
        1 {
            Write-Host "RDP Security Layer: Negotiate" -ForegroundColor Magenta
            break
        }
        2 {
            Write-Host "RDP Security Layer: SSL" -ForegroundColor Green
            break
        }
        default {
            Write-Host "RDP Security Layer: Unknown" -ForegroundColor Yellow
            break
        }
    }

    # Check local NLA enforcement
    $regKeyPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'
    $regValueName = 'UserAuthentication'

    $userAuthentication = (Get-ItemProperty -Path $regKeyPath -Name $regValueName).$regValueName

    if ($userAuthentication -eq 1) {
        Write-Host "NLA (Network Level Authentication) is enforced." -ForegroundColor Green
    } else {
        Write-Host "NLA (Network Level Authentication) is not enforced." -ForegroundColor Red
    }

    # WinRM Checks
    Write-host ""
    Write-host "############################"
    Write-host "# Now checking WinRM stuff #"
    Write-host "############################"
    Write-host "References: https://learn.microsoft.com/en-us/powershell/scripting/learn/remoting/winrmsecurity?view=powershell-7.3" -ForegroundColor DarkGray
    Write-host ""

    # Check if WinRM service is running
    $winrmService = Get-Service -Name "winrm"

    if ($winrmService.Status -eq "Running") {
        Write-Host "WinRM service is running." -ForegroundColor Magenta

        # Retrieve WinRM configuration
        $winrmSettings = winrm get winrm/config

        # Display the security settings
        Write-Host "WinRM Security Settings:" -ForegroundColor Magenta
        $winrmSettings
    }
    else {
        Write-Host "WinRM service is not running." -ForegroundColor Green
    }


    Write-Host ""
    Write-Host "#################################"
    Write-Host "# Checking Audit Policy Settings #"
    Write-Host "#################################"
    Write-Host ""

    Write-Host "## Account Logon ##"
    Get-AuditPolicies -subkey "Account Logon" -eventName "Account Logon" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"

    Write-Host "## Account Management ##"
    Get-AuditPolicies -subkey "Account Management" -eventName "Account Management" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"

    Write-Host "## Registry ##"
    Get-AuditPolicies -subkey "Registry" -eventName "Registry" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"

    # Add more audit policy subkeys as needed.

    Write-Host "## Detailed Tracking ##"
    Get-AuditPolicies -subkey "Detailed Tracking" -eventName "Detailed Tracking" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## DS Access ##"
    Get-AuditPolicies -subkey "DS Access" -eventName "DS Access" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"

    Write-Host "## Logon/Logoff ##"
    Get-AuditPolicies -subkey "Logon/Logoff" -eventName "Logon/Logoff" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## Object Access ##"
    Get-AuditPolicies -subkey "Object Access" -eventName "Object Access" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## Policy Change ##"
    Get-AuditPolicies -subkey "Policy Change" -eventName "Policy Change" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## Privilege Use ##"
    Get-AuditPolicies -subkey "Privilege Use" -eventName "Privilege Use" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## System ##"
    Get-AuditPolicies -subkey "System" -eventName "System" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## Global Object Access Auditing ##"
    Get-AuditPolicies -subkey "Global Object Access Auditing" -eventName "Global Object Access Auditing" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## Other System Events ##"
    Get-AuditPolicies -subkey "Other System Events" -eventName "Other System Events" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## Kernel Object ##"
    Get-AuditPolicies -subkey "Kernel Object" -eventName "Kernel Object" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## SAM ##"
    Get-AuditPolicies -subkey "SAM" -eventName "SAM" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## Certification Services ##"
    Get-AuditPolicies -subkey "Certification Services" -eventName "Certification Services" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## Application Generated ##"
    Get-AuditPolicies -subkey "Application Generated" -eventName "Application Generated" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## Handle Manipulation ##"
    Get-AuditPolicies -subkey "Handle Manipulation" -eventName "Handle Manipulation" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## File Share ##"
    Get-AuditPolicies -subkey "File Share" -eventName "File Share" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## Filtering Platform Packet Drop ##"
    Get-AuditPolicies -subkey "Filtering Platform Packet Drop" -eventName "Filtering Platform Packet Drop" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## Filtering Platform Connection ##"
    Get-AuditPolicies -subkey "Filtering Platform Connection" -eventName "Filtering Platform Connection" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## Other Object Access Events ##"
    Get-AuditPolicies -subkey "Other Object Access Events" -eventName "Other Object Access Events" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## Plug and Play Events ##"
    Get-AuditPolicies -subkey "Plug and Play Events" -eventName "Plug and Play Events" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## Detailed File Share ##"
    Get-AuditPolicies -subkey "Detailed File Share" -eventName "Detailed File Share" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## Removable Storage ##"
    Get-AuditPolicies -subkey "Removable Storage" -eventName "Removable Storage" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## Central Policy Staging ##"
    Get-AuditPolicies -subkey "Central Policy Staging" -eventName "Central Policy Staging" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## IPSec Driver ##"
    Get-AuditPolicies -subkey "IPSec Driver" -eventName "IPSec Driver" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## Hyper-V ##"
    Get-AuditPolicies -subkey "Hyper-V" -eventName "Hyper-V" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## Virtualization-based Security (VBS) ##"
    Get-AuditPolicies -subkey "Virtualization-based Security (VBS)" -eventName "Virtualization-based Security (VBS)" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## UEFI Security ##"
    Get-AuditPolicies -subkey "UEFI Security" -eventName "UEFI Security" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"


    Write-Host "## Others ##"
    Get-AuditPolicies -subkey "Others" -eventName "Others" -successPattern "Success" -failurePattern "Failure" -notConfiguredText "Not Configured"

    Write-host ""
    Write-host "########################################################" -ForegroundColor DarkCyan
    Write-host "# Thats it, all checks done. Off to the report^^ #" -ForegroundColor DarkCyan
    Write-host "########################################################" -ForegroundColor DarkCyan
    Write-host ""
}