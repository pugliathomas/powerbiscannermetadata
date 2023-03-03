param (
	[string]$folderOutput,
	[string]$stateFilePath
)


$state = $configPBI.pbiState
$maxHistoryDate = [datetime]::UtcNow.Date.AddDays(-30)

if ($state.Activity.LastRun) {
	if (!($state.Activity.LastRun -is [datetime])) {
		$state.Activity.LastRun = [datetime]::Parse($state.Activity.LastRun).ToUniversalTime()
	}
	$pivotDate = $state.Activity.LastRun
}
else {
	$state | Add-Member -NotePropertyName "Activity" -NotePropertyValue @{ "LastRun" = $null } -Force
	$pivotDate = $maxHistoryDate
}

if ($pivotDate -lt $maxHistoryDate)
{
	Write-Host "Last run was more than 30 days ago"
	$pivotDate = $maxHistoryDate
}

Write-Host "Since: $($pivotDate.ToString("s"))"

#########################################################################
# Configuration
#########################################################################

$pbiActivityFolder = $configPBI.pbiFolders.folderAcT
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
# END Configuration
#########################################################################



Write-Host 'Outputting all metadata of the datasets to disk...'
$folderBPA = $configPBI.pbiFolders.folderBPA
$datasetsOutputPath = Join-Path -Path $folderBPA -ChildPath "\BPAA_datasets.json"
$biglistofdatasets | ConvertTo-Json -Compress | Out-File -FilePath $datasetsOutputPath

Write-Host "Script finished."

while ($pivotDate -lt [datetime]::UtcNow.Date)
{
	# Configure the Dates and Run
	$dayStartNumber = $pivotDate.Day
	$currentDayNumber = $dayStartNumber
	$currentDayNumber = $pivotDate.Day
	$mNumber = $pivotDate.Month
	$yNumber = $pivotDate.Year

	$curDayFancy = '{0:00}' -f $currentDayNumber
	$curMonthFancy = '{0:00}' -f $mNumber
	$curYearFancy = '{0:0000}' -f $yNumber

	$curDayFancy = '{0:00}' -f $currentDayNumber
	$curMonthFancy = '{0:00}' -f $mNumber
	$curYearFancy = '{0:0000}' -f $yNumber
	$curDayText = "$curDayFancy"
	$curMonthText = "$curMonthFancy"
	$curYearText = "$curYearFancy"
	$base = (Get-Date -Year $yNumber -Month $mNumber -Day $currentDayNumber)


	"Running Day $($base.ToString('MM/dd/yyyy'))"
	$startdate = $curYearText + '-' + $curMonthText + '-' + $curDayText + 'T00:00:00'
	$enddate = $curYearText + '-' + $curMonthText + '-' + $curDayText + 'T23:59:59'

	# Begin to Pull in Power BI Act
	$activities = Get-PowerBIActivityEvent -StartDateTime $startdate -EndDateTime $enddate
	$jsonActivities = $activities | ConvertTo-Json -Compress
	$csvActivities = $activities | ConvertFrom-Json

	# Configure Folders & Files for Both JSON & CSV
	#JSON 
	$actJSONName = $curYearText + $curMonthText + $curDayText + 'Export.json'
	$actFolderLocationJson = $pbiActivityFolder + 'Json'
	$actJSONFullPath = Join-Path $actFolderLocationJson $actJSONName

	# CSV
	$actCSVName = $curYearText + $curMonthText + $curDayText + 'Export.csv'
	$actFolderLocationCSV = $pbiActivityFolder
	$actCSVFullPath = Join-Path $actFolderLocationCSV $actCSVName

	# Export the Files
	$jsonActivities | Out-File -FilePath $actJSONFullPath
	$csvActivities | Export-Csv -Path $actCSVFullPath -NoTypeInformation

	# Loop Through

	"Completed Day $($base.ToString('MM/dd/yyyy'))"

	$pivotDate = $pivotDate.AddDays(1)
	$configPBI.pbiState.Activity.LastRun =  $pivotDate.Date.ToString('o')

	Write-Host "Saving State"
	Out-Null
	ConvertTo-Json $configPBI | Out-File $configFilePath -Force -Encoding utf8

}

$pivotDate = $pivotDate.AddDays(-1)
$configPBI.pbiState.Activity.LastRun =  $pivotDate.Date.ToString('o')

Write-Host "Saving State"
Out-Null
ConvertTo-Json $configPBI | Out-File $configFilePath -Force -Encoding utf8


Write-Host "Activity Finished, Last Run was $pivotDate"

#########################################################################
# END Activity REfresh
#########################################################################


