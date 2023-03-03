
param(
	[string]$folderOutput
)

$PBIRefreshFolder = $configPBI.pbiFolders.folderRefresh
$folderBPA = $configPBI.pbiFolders.folderBPA
$AppId = $configPBI.AppId
$TenantID = $configPBI.TenantId
$ClientSecret = $configPBI.AppSecret
$CurrentDateTime = (Get-Date).ToString('yyyyMMdd-HHmmss')
$PowerBIServicePrincipalClientId = $AppId
$PowerBIServicePrincipalSecret = $ClientSecret | ConvertTo-SecureString -AsPlainText -Force
$PowerBIServicePrincipalTenantId = $TenantID
$credential = New-Object System.Management.Automation.PSCredential ($PowerBIServicePrincipalClientId,$PowerBIServicePrincipalSecret)
Connect-PowerBIServiceAccount -ServicePrincipal -Credential $credential -Tenant $PowerBIServicePrincipalTenantId

#########################################################################
# BEGIN dataset REfresh
#########################################################################

## Refresh all Workspaces
Write-Host 'Retrieving all Premium Power BI workspaces (that the Service Principal has a membership in)...'
$workspaces = Get-PowerBIWorkspace -All #-Include All -Scope Organization (commented this, I'm getting an 'Unauthorized' for this approach)
if ($workspaces)
{
	Write-Host 'Retrieving all datasets in all workspaces...'
	New-Item -Path $folderBPA -Name $CurrentDateTime -ItemType Directory -ErrorAction Stop
	Write-Host 'Outputting all workspace info to disk...'
	$workspacesOutputPath = Join-Path -Path $folderBPA -ChildPath "\$CurrentDateTime\BPAA_workspaces.json"
	$workspaces | ConvertTo-Json -Compress | Out-File -FilePath $workspacesOutputPath

	Write-Host 'Done. Now iterating the workspaces...'
	$workspaces | Where-Object { $_.IsOnDedicatedCapacity -eq $True } | ForEach-Object {
		Write-Host '=================================================================================================================================='
		$workspaceName = $_.Name
		$WorkspaceId = $_.Id
		Write-Host "Found Premium workspace: $workspaceName.`n"

		# Base API for Power BI REST API
		$PbiRestApi = 'https://api.powerbi.com/v1.0/myorg/'

		# Export data parameters

		$DatePrefix = Get-Date -Format 'yyyyMMdd_HHmm'
		$reDefaultFilePath = $PBIRefreshFolder + '\' + $DatePrefix + '_' + $workspaceName + '_'

		# Create folder to dump results
		$reFullPath = $PBIRefreshFolder
		if (-not (Test-Path $reFullPath))
		{
			# Destination path does not exist, let's create it
			try
			{
				New-Item -Path $reDefaultFilePath -ItemType Directory -ErrorAction Stop
			}
			catch
			{
				throw "Could not create path '$reFullPath'!"
			}
		}

		Write-Host 'Collecting dataset metadata...'
		$GetDatasetsApiCall = $PbiRestApi + 'groups/' + $WorkspaceId + '/datasets'
		$AllDatasets = Invoke-PowerBIRestMethod -Method GET -Url $GetDatasetsApiCall | ConvertFrom-Json
		$ListAllDatasets = $AllDatasets.value

		# Write dataset metadata json
		$DatasetsMetadataOutputLocation = $reDefaultFilePath + 'DatasetsMetadata.json'
		$ListAllDatasets | ConvertTo-Json | Out-File $DatasetsMetadataOutputLocation -ErrorAction Stop
		Write-Host 'Dataset metadata saved on defined location' -ForegroundColor Green

		# Function to get dataset refresh results
		function GetDatasetRefreshResults
		{
			[CmdletBinding()]
			param(
				[Parameter(Mandatory = $true)] [string]$DatasetId
			)
			$ErrorActionPreference = 'SilentlyContinue'
			Write-Host 'Collecting dataset refresh history...' $DatasetId
			$GetDatasetRefreshHistory = $PbiRestApi + 'groups/' + $WorkspaceId + '/datasets/' + $DatasetId + '/refreshes'
			$DatasetRefreshHistory = Invoke-PowerBIRestMethod -Method GET -Url $GetDatasetRefreshHistory | ConvertFrom-Json
			return $DatasetRefreshHistory.value
		}

		# Create empty json array
		$DatasetResults = @()

		# Get refresh history for each dataset in defined workspace
		foreach ($Dataset in $ListAllDatasets)
		{
			$DatasetHistories = GetDatasetRefreshResults -DatasetId $Dataset.Id
			foreach ($DatasetHistory in $DatasetHistories)
			{
				Add-Member -InputObject $DatasetHistory -NotePropertyName 'DatasetId' -NotePropertyValue $Dataset.Id
				$DatasetResults += $DatasetHistory
			}
		}

		# Write dataset refresh history json to output location
		$DatasetRefreshOutputLocation = $reDefaultFilePath + 'DatasetRefreshHistory.json'
		$DatasetResults | ConvertTo-Json | Out-File $DatasetRefreshOutputLocation -ErrorAction Stop

	}

}

#########################################################################
# END dataset REfresh
#########################################################################
Write-Host 'Finished with dataset refresh' -ForegroundColor Green