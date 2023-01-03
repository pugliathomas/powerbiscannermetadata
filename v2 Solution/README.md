# Solution v2 - Using the Dataflow Scanner API Solution
!!!  info Solution v1
    Looking for Solution v1 (Power Automate)? [You can find it here.](/v1%20Solution/)

## Introduction

The following is an updated solution to collect and store Power BI tenant metadata. To see version 1 (using Power Automate), see here: LINK.
This solution utilizes Dataflow Best Practices, and utilizes the "bronze / silver / gold" approach to dataflows to A) Send a single request for a new scan and B) use the silver/gold dataflow to collect the metadata from that scan.

Without the use of two dataflows, Power Query would attempt per query to post a new scan.

### Note About V2 & V3

There is currently a v3 solution that will not only incorporate the Scanner API, but utilize the same approach for collecting Activity Data from the Power BI Audit Log using incremental refresh to avoid the 30 day retrieve limit. V3 will also incorporate Refresh History of Datasets in a single solution.

V2 is focused on improving the Power Automate method which has limitations and errors.

### Solution v1 (Power Automate)


## Pre-Requisites

Before starting, you must have already completed the following in order to use the Scanner API at all. Please see the documentation for each to set up:

* [Enable Service Principal Authentication for Read-Only Admin API's](https://docs.microsoft.com/en-us/power-bi/admin/read-only-apis-service-principal-authentication)
* [Create an Azure AD app](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)
  * Ensure there are no Power BI admin-consent required permissions on the application
  * Create a client secret / key and copy the value for later use
* Create a new Security Group in AD, add the app to the group
* [Enable Allow Service Principals to use read-only Power BI admin API's in the Power BI Tenant](https://docs.microsoft.com/en-us/power-bi/admin/service-admin-enhanced-metadata-scanning#enabling-enhanced-metadata-scanning)

## What's In the Box?

The solution consists of 2 dataflows & a Power BI Template file. 

### Dataflows

#### bronzeGetScannerResultID

This is the first dataflow needed to be imported into your tenant. This dataflow should be imported into a development or staging workspace.

This is essential as in order to retrieve the metadata, you must post and retrieve a scan ID. The only purpose of this dataflow is to post, and then output the Scan ID to be used in the silverGetScannerResults dataflow.

!!!  caution Important
    Ensure you do not load this dataflow multiple times a day, or even go back to editing it. Everytime this dataflow is triggered it will post and return a new scan ID! 


#### silvergoldGetScanResults

This is the final dataflow that will be used to create the structured tables for the Power BI Template. This dataflow should be imported into a production workspace.

The only configuration needed in this dataflow is the the query _scanResultID_, which should be pointed to the location of the workspace/dataflow from bronzeGetScannerResultID, and the quey _scanResults_.

In order for this to work in your tenant, you must change the 2nd and 3rd step so the value is the workspace and dataflow id.

```
let
    Source = PowerBI.Dataflows(null),
    // Enter Your Workspace ID as string here
    workspaceID = "123",
    // Enter Your Dataflow ID as string here
    dataflowID = "123",
    EnterworkspaceID = Source{[workspaceId = workspaceID]}[Data],
    enterdataflowID = EnterworkspaceID{[dataflowId = dataflowID]}[Data],
    scanResults1 = enterdataflowID{[entity = "scanResults"]}[Data],
    #"Filtered Rows" = Table.SelectRows(scanResults1, each [Name] = "id"),
    Value = #"Filtered Rows"{0}[Value]
in
    Value
```


Simply refresh this report and you are ready to go!

### Power BI Data Catalog

The Power BI Template will connect to the dataflows from silvergoldGetScanResults. In order for the report to properly refresh, rather tha using parameters in the data connection strings, the following needs to be updated in the query editor:

baseloadGoldDataflow, the following in the code:

```
let
    Source = PowerPlatform.Dataflows(null),
    Workspaces = Source{[Id = "Workspaces"]}[Data],
    // Enter Your Workspace ID as string here
    workspaceID = "123",
    // Enter Your Dataflow ID as string here
    dataflowID = "123",
    EnterWorkspaceID = Workspaces{[workspaceId = workspaceID]}[Data],
    EnterDataflowID = EnterWorkspaceID{[dataflowId = dataflowID]}[Data]
in
    EnterDataflowID

```

Once updated, all the other queries will load correctly. 

## Known Issues & Roadmap

****