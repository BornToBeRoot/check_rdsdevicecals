###############################################################################################################
# Language     :  PowerShell 4.0
# Filename     :  check_rds_device_cals.ps1
# Autor        :  https://github.com/BornToBeRoot
# Description  :  Check your available rds device cals with usage in percent using NRPE/NSClient++
# Repository   :  https://github.com/BornToBeRoot/Nagios_Plugins
###############################################################################################################

<#
    .SYNOPSIS
    Check your available rds device cals with usage in percent

    .DESCRIPTION
    Check your available remote desktop services (rds) device cals with usage in percent using NRPE/NSClient++.

	-- KeyPackType --
	0 - The Remote Desktop Services license key pack type is unknown.
	1 - The Remote Desktop Services license key pack type is a retail purchase.
	2 - The Remote Desktop Services license key pack type is a volume purchase.
	3 - The Remote Desktop Services license key pack type is a concurrent license.
	4 - The Remote Desktop Services license key pack type is temporary.
	5 - The Remote Desktop Services license key pack type is an open license.
	6 - Not supported.

	-- ProductVersionID --
	0 - Not supported.
	1 - Not supported.
	2 - Windows Server 2008
	3 - Windows Server 2008 R2
	4 - Windows Server 2012
	   
    .EXAMPLE
    .\check_rds_device_cals.ps1 -Warning 20 -Critical 5 -KeyPackTypes 2 -ProductVersionID 2,3
        
    .LINK
    https://github.com/BornToBeRoot/Nagios_Plugins/blob/master/Documentation/Windows_NRPE/check_rds_device_cals.README.md
#>

[CmdletBinding()]
Param(
	[Parameter(
		Position=0,
        Mandatory=$true,
        HelpMessage='Number of free licenses before the status "warning" is returned.')]
	[Int32]$Warning,

	[Parameter(
		Position=1,
        Mandatory=$true,
        HelpMessage='Number of free licenses before the status "critical" is returned.')]
	[Int32]$Critical,

    [Parameter(
        Position=2,
        HelpMessage="Select your license key pack [KeyPackType --> 0 = unkown, 1 = retail, 2 = volume, 3 = concurrent, 4 = temporary, 5 = open license, 6 = not supported] (More details under: https://msdn.microsoft.com/en-us/library/windows/desktop/aa383803%28v=vs.85%29.aspx)")]
    [Int32[]]$KeyPackTypes=(0,1,2,3,4,5,6),

    [Parameter(
        Position=3,
        HelpMessage="Select your product version [ProductVersionID --> 0 = not supported, 1 = not supported, 2 = 2008, 3 = 2008R2, 4 = 2012] (More details under: https://msdn.microsoft.com/en-us/library/windows/desktop/aa383803%28v=vs.85%29.aspx)")]
    [Int32[]]$ProductVersionID=(0,1,2,3,4),

    [Parameter(
        Position=4,
        HelpMessage="Hostname or IP-Address of the server where the rds cals are stored (Default=localhost)")]
    [String]$ComputerName=$env:COMPUTERNAME
)

Begin{

}

Process{
	# Get all license key packs from WMI
	try{
        # If you are using PowerShell 4 or higher, you can use Get-CimInstance instead of Get-WmiObject      
		$TSLicenseKeyPacks = Get-WmiObject -Class Win32_TSLicenseKeyPack -ComputerName $ComputerName -ErrorAction Stop
	} catch {
		Write-Host -Message "$($_.Exception.Message)" -NoNewline
		exit 3
	}

    [Int64]$TotalLicenses = 0
    [Int64]$AvailableLicenses = 0
    [Int64]$IssuedLicenses = 0
    
	# Go through each license key pack
	foreach($TSLicenseKeyPack in $TSLicenseKeyPacks)
	{
        # Check only license key packs, which you have selected with "-KeyPackTypes" and "-ProductVersionID" (Everything is checked by default)
        if(($KeyPackTypes -contains $TSLicenseKeyPack.KeyPackType) -and ($ProductVersionID -contains $TSLicenseKeyPack.ProductVersionID))
        {
            $TotalLicenses += $TSLicenseKeyPack.TotalLicenses
            $AvailableLicenses += $TSLicenseKeyPack.AvailableLicenses
            $IssuedLicenses += $TSLicenseKeyPack.IssuedLicenses
        }
	}
     
    $Message = ([String]::Format("{0} rds device cals available from {1} ({2}% usage)", $AvailableLicenses, $TotalLicenses, [Math]::Round((($IssuedLicenses / $TotalLicenses) * 100), 2))).Replace(',','.')

    # return critical OR warning OR ok
    if($AvailableLicenses -le $Critical)
    {
        Write-Host -Message "CRITICAL - $Message"
        exit 2
    }
    elseif($AvailableLicenses -le $Warning)
    {
        Write-Host -Message "WARNING - $Message"        
        exit 1
    }
    else
    {
        Write-Host -Message "OK - $Message"
        exit 0
    }     
}

End{

}
