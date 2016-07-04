# check_rds_device_cals.ps1

Check your available rds device cals with usage in percent

* [view script](https://github.com/BornToBeRoot/Nagios_Plugins/blob/master/Windows_NRPE/check_rds_device_cals.ps1)

## Description

Check your available remote desktop services (rds) device cals with usage in percent using NRPE/NSClient++.

Could be useful for:
* Windows-/Citrix-Terminalserver

## Syntax (PowerShell)

```powershell
.\check_rds_device_cals.ps1 [-Warning] <Int32> [-Critical] <Int32> [[-KeyPackTypes] <Int32[]>] [[-ProductVersionID] <Int32[]>] [[-ComputerName] <String>] [<CommonParameters>]
```

## Example (PowerShell)

```powershell
.\check_rds_device_cals.ps1 -Warning 25 -Critical 10 -KeyPackTypes 2 -ProductVersionID 2,3
```

## Return Values

* `OK - 26 rds device cals available from 550 (95.27% usage)`
* `Warning - 21 rds device cals available from 550 (96.18% usage)`
* `Critical - 5 rds device cals available from 550 (99.09% usage)`
* `Invalid class "Win32_TSLicenseKeyPack"` - If WMI class is not available

## Install Guide for NSClient++

* Copy `check_rds_device_cals.ps1` to `NSClient++\Scripts\`
* Open up a PowerShell as an admin and set the execution policy: `Set-ExecutionPolicy RemoteSigned`
* Edit `NSC.ini`, add row:
```
check_rds_device_cals	= cmd /c echo scripts/check_rds_device_cals.ps1 $ARG1$ $ARG2$ $ARG3$ $ARG4$; exit($lastexitcode) | powershell.exe -command -
```
* Restart service NSClient++

## Create Nagios Command

* Command Name: `check_nrpe_rds_device_cals`
* Command Line: `$USER1$/plugins_app/check_nrpe -H $HOSTADDRESS$ -t 60 -c check_rds_device_cals -a $ARG1$ $ARG2$ $ARG3$ $ARG4$` 
* Argument Description: 
```
ARG1 : Warning
ARG2 : Critical
ARG3 : KeyPackType
ARG4 : ProductVersionID
```
## Create Host Service

* Description: `rds_device_cals`
* Service Template: `generic-service`
* Check Command: `check_nrpe_rds_device_cals`
* Args: 
```
25
10
2 
2,3
```  
* Link your hosts you want to check

## KeyPackType

Select which license packs you want to check

```
0 - The Remote Desktop Services license key pack type is unknown.
1 - The Remote Desktop Services license key pack type is a retail purchase.
2 - The Remote Desktop Services license key pack type is a volume purchase.
3 - The Remote Desktop Services license key pack type is a concurrent license.
4 - The Remote Desktop Services license key pack type is temporary.
5 - The Remote Desktop Services license key pack type is an open license.
6 - Not supported.
```

More details under: [Microsoft Technet - Win32_TSLicenseKeyPack](https://msdn.microsoft.com/en-us/library/windows/desktop/aa383803%28v=vs.85%29.aspx)

## ProductVersionID

Select which product version (Windows Server version) you want to check

```
0 - Not supported.
1 - Not supported.
2 - Windows Server 2008
3 - Windows Server 2008 R2
4 - Windows Server 2012
```

More details under: [Microsoft Technet - Win32_TSLicenseKeyPack](https://msdn.microsoft.com/en-us/library/windows/desktop/aa383803%28v=vs.85%29.aspx)
