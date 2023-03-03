param (
    [string]$scriptFolderLocation
)

$scriptsToRun = @(
         "pbiActivity.ps1"
        "pbiDatasetRefresh.ps1"
        "pbiUsers.ps1"
        "pbiBPA.ps1"
        #".\Fetch - DataSetRefresh.ps1"
)


$scriptFolderLocation =  "C:\GitHub\powerbiscannermetadata\v2 Solution\v3 - With Other Data\PSPowerShellLog"



Set-Variable -Name configFilePath -Value (Join-Path $scriptFolderLocation  "config.json")

$contentPath = (Get-Content $configFilePath | ConvertFrom-Json)
Set-Variable -Name configPBI -Value $contentPath

function Show-Menu {
    param (
        [string]$Title = 'Run What?'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Activity."
    Write-Host "2: Dataset Refresh."
    Write-Host "3: User Licenses."
    Write-Host "4: BPA."
    Write-Host "5: All."
    Write-Host "Q: Press 'Q' to quit."
}

function New-User{
{
    param([String]$UserName, [Switch]$Enabled, [ValidateSet('Administrator', 'IT', 'HR')]$Department)
    
}}

#########################################################################
# Configuration
#########################################################################

## Set Credentials 
$AppId = $configPBI.AppId
$TenantID = $configPBI.TenantId
$ClientSecret = $configPBI.AppSecret
$CurrentDateTime = (Get-Date).ToString('yyyyMMdd-HHmmss')
$PowerBIServicePrincipalClientId = $AppId
$PowerBIServicePrincipalSecret = $ClientSecret | ConvertTo-SecureString -AsPlainText -Force
$PowerBIServicePrincipalTenantId = $TenantID
$credential = New-Object System.Management.Automation.PSCredential ($PowerBIServicePrincipalClientId,$PowerBIServicePrincipalSecret)
Connect-PowerBIServiceAccount -ServicePrincipal -Credential $credential -Tenant $PowerBIServicePrincipalTenantId

$configFolderLocations =  @(
    $configPBI.pbiFolders.folderAcT,
    $configPBI.pbiFolders.folderRefresh,
    $configPBI.pbiFolders.folderuserLicense,
    $configPBI.pbiFolders.folderBPA
)



#########################################################################

#########################################################################

# $options = [System.Management.Automation.Host.ChoiceDescription[]] @("&1:Activity", "&2:RefreshHistory", "&3:Users", "&4:BPA", "&5:All", "&6:Cancel")
#  $Host.UI.PromptForChoice("Choose?", "What Do want to run?", $options, 5)
 Show-Menu
 $sel = Read-Host "Please select an option"
 switch($sel)
 {
    '1' {
        Write-Host "Running Activity"
        $ScriptPath = Join-Path $scriptFolderLocation $scriptsToRun[0]
        $scriptRun = $ScriptPath
        $folderOutput = $configFolderLocations[0]
        & $scriptRun -folderOutput $folderOutput
    }
    '2' {
        Write-Host "Running Dataset Refresh"
        $ScriptPath = Join-Path $scriptFolderLocation $scriptsToRun[1]
        $scriptRun = $ScriptPath
        $folderOutput = $configFolderLocations[1]
        & $scriptRun -folderOutput $folderOutput

    }
    '3' {
        Write-Host "Running User Licenses"
        $ScriptPath = Join-Path $scriptFolderLocation $scriptsToRun[2]
        $scriptRun = $ScriptPath
        $folderOutput = $configFolderLocations[2]
        & $scriptRun -folderOutput $folderOutput

    }
    '4' {
        Write-Host "Running BPA"
        $ScriptPath = Join-Path $scriptFolderLocation $scriptsToRun[3]
        $scriptRun = $ScriptPath
              $folderOutput = $configFolderLocations[3]
        & $scriptRun -folderOutput $folderOutput

        
    }
    '5' {
        Write-Host "Running All"
            $i = 0
            foreach($scriptRun in $scriptsToRun) {
                try{
                    Write-Host "Running $scriptRun"
                    
                    $folderOutput = $configFolderLocations[$i]
                    $ScriptPath = Join-Path $scriptFolderLocation $scriptsToRun[$i]
                & $ScriptPath 
                $i++
            }
            catch{
                Write-Error "Error on $scriptRun" -ErrorAction Continue
            }}
        }
    'Q' { Write-Host "Quitting" }
    default { Write-Host "Invalid Option" }
 }
