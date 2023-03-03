

param(
	[string]$folderOutput
)


#########################################################################
# BEGIN USER INFORMATION
#########################################################################
Import-Module -Name Microsoft.Graph.Authentication -UseWindowsPowerShell
Import-Module -Name Microsoft.Graph.Users.Actions -UseWindowsPowerShell
Select-MgProfile -Name 'beta'
Connect-MgGraph -Scopes 'Organization.Read.All, Directory.Read.All, Organization.ReadWrite.All, Directory.ReadWrite.All'  -	UseDeviceAuthentication 	
Select-MgProfile -Name 'beta'

# Power BI Licensing Types and Capabilities Official Docs: https://docs.microsoft.com/power-bi/admin/service-admin-licensing-organization#license-types-and-capabilities
# For a complete listing of all Licensing Service Plans visit: https://docs.microsoft.com/azure/active-directory/enterprise-users/licensing-service-plan-reference

$pbiSubscriptions = Get-MgSubscribedSku | Select-Object -Property Sku*,ConsumedUnits -ExpandProperty PrepaidUnits | Where-Object { ($_.SkuPartNumber.contains('POWER_BI') -or $_.SkuPartNumber.contains('PBI')) }
$pbiSubscriptions | Format-List


$licenseType = $pbiSubscriptions | Select-Object SkuPartNumber

# Graph licensing search: https://learn.microsoft.com/microsoft-365/enterprise/view-licensed-and-unlicensed-users-with-microsoft-365-powershell?view=o365-worldwide

foreach ($license in $licenseType)
{

	$licenseName = $license.SkuPartNumber
	Write-Host "Now Searching: $($licenseName)"
	$licenses = Get-MgSubscribedSku -All | Where-Object SkuPartNumber -EQ $licenseName
	$licenses | Select-Object -Property Id,Sku*,CapabilityStatus,ConsumedUnits

	if ($licenses.ConsumedUnits -ne 0)
	{

		Write-Host "Now Exporting Report: $($licenseName)`n"


		$csvFileName = $($licenseName) + '_' + $(Get-Date -Format 'yyyyMMdd') + '.csv'
		$csvPath = Join-Path $configPBI.pbiFolders.folderuserLicenses $csvFileName
		$licenses | Export-Csv -Path $csvPath -NoTypeInformation
		$jsonFileName = $licenseName + '_' + (Get-Date -Format yyyyMMdd) + '.json'
		$jsonPath = Join-Path $configPBI.pbiFolders.folderuserLicenses $jsonFileName
		$licenses | ConvertTo-Json -Compress | Out-File -FilePath $jsonPath

	}

}
#########################################################################
# END USER INFORMATION
#########################################################################
Write-Host "Finished with User Licenses"