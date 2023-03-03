# The PowerShell Activity Script Bundle

The following set of scripts are meant to provide you will a full scale view of your entire tenant. Like with all of the other solutions, you must ensure you have configured your tenant settings and have configured the appropriate App Registrations ([See The Readme](README.md).

## The Configuration File

Before running any scripts, you must first set up the [config.json file](config.json) with the following:

### Credentials

* AppID = Your App / Client ID to access Power BI
* AppSecret = The App Secret
* TenantID = The Tenant Id of your organization
* Username = Your Email

### Folder Output

Note: Ensure that any folder target is backspaced in the JSON file. For example:
C:\\Folder\\Folder

* folderAct: The location of the folder where all of the Activity Log data will go
* configFilePath: The file path of the the config.json file in this repo
* folderuserlicenses: The folder path for the User Licenses information to go
* folderBPA: The folder path for all of the Best Practice Analyzer data
* folderRefresh: The folder for all of the refresh history

## Before You Run

The last step that is needed is to change line 14 on [pbiRun.ps1](pbiRun.ps1) to the base folder location of all of the scripts. For example, if you downloaded this solution to your C drive under "PowerBI Stuff", and you downloaded the entire repository (not just the folder), then the script location would be at:


C:\PowerBIStuff\powerbiscannermetadata\v2 Solution\PSPowerShellLog

Just ensure wherever the scripts are located is what you ahve for $ScriptFolderLocation.

