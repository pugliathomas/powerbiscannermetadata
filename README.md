# Power BI Metadata Scanner API & Template

This is based on the PowerBI.Tips Blog Post about this repo. For full instructions, [please see the article here.](https://powerbi.tips/2021/10/using-the-power-bi-scanner-api-to-manage-tenants-entire-metadata/)

Building the Solution
=====================

The majority of credit needs to go to [Ferry Bouwman](https://www.linkedin.com/in/ferrybouwman/) who initially created a viable solution that can easily be integrated into a report. [He created a GitHub repo](https://github.com/ferrybouwman/Power-BI-Read-Only-REST-API) that included a Power Automate flow that truly covers the entire process of automating the API call.

The following is building off Ferry's solution, including the new metadata schema that is now available. There is more that I want to accomplish in this solution, but to get the Scanner API and a template to connect to the data, you can do so using the steps below.

Also many thanks to Rui Romano's solution and Power BI template. [You can find his full solution here](https://github.com/RuiRomano/pbimonitor): 

### Pre-Requisites Before Use

Before starting, you must have already completed the following in order to use the Scanner API at all. Please see the documentation for each to set up:

*   [Enable Service Principal Authentication for Read-Only Admin API's](https://docs.microsoft.com/en-us/power-bi/admin/read-only-apis-service-principal-authentication)
*   [Create an Azure AD app](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)
    *   Ensure there are no Power BI admin-consent required permissions on the application
    *   Create a client secret / key and copy the value for later use
*   Create a new Security Group in AD, add the app to the group
*   [Enable Allow Service Principals to use read-only Power BI admin API's in the Power BI Tenant](https://docs.microsoft.com/en-us/power-bi/admin/service-admin-enhanced-metadata-scanning#enabling-enhanced-metadata-scanning)

### The Solution Bundle

The solution includes the following to implement:

*   A Power Automate Flow that handles the entire API request and call
*   A Scheduled Refresh Flow that refreshing daily and triggers the Flow above
*   A Power BI Template report to connect to the metadata results

[Download the Solution on GitHub.](https://github.com/pugliathomas/powerbiscannermetadata)

Installing & Using
==================

#### Import the API Scanner Flow

The first step is to import the Flow pbitips\_ScannerAPI into your tenant. Once you do this, there are a few variables and actions to update before running.

*   **tenant**: The tenant of your Active Directory
*   **clientId**: The Client ID of your registered App
*   **clientSecret**: The Client Secret value of your registered App
*   **SharePoint Library**: What SharePoint library you want to save the files
    *   NOTE: Remember this location as it will be used in Power Query
*   **Folder Location**: The folder location to save all returned scans
    *   **NOTE: Remember this location as it will be used in Power Query**
*   **Folder Location Trigger**: A different folder with a different name, to trigger the refresh run.
