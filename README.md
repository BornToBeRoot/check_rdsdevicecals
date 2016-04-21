# Nagios Plugins (Checks)

Some of my nagios plugins (checks) which might be helpful for some of you

## Checks

### Windows NRPE

* [check_rds_device_cals.ps1](Windows_NRPE/check_rds_device_cals.ps1) - PowerShell script to check your available rds device cals with usage in percent [view Doku](Doku/Windows_NRPE/check_rds_device_cals.README.md)

## NRPE Debug mode

### Windows

Stop the NSClient++ service on the Windows server where you want to test the check

For example (PowerShell):

```powershell
Get-Service NSCP | Stop-Service
```

Now start the NSClient++ in debug mode with the parameter `test`

```powershell
cd "C:\Program Files\NSClient++\"
nscp.exe test
```

Then connect via SSH to your linux server where nagios is running

```
/usr/lib/nagios/plugins/plugins_app/check_nrpe -H XXX.XXX.XXX.XXX -t 30 -C check_name_XXXX
```

If you are done testing... don't forget to start the NSClient++ service on your Windows server

```powershell
Get-Service NSCP | Start-Service
```

## Exit codes

0 = OK
1 = Warning
2 = Critical
3 = Unknown