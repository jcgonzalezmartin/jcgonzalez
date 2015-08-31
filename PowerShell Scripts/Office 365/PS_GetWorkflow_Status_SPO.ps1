############################################################################################################################################
# Script that allows to get the workflow execution status for all the workflows deployed to a SharePoint Online Site
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteColUrl: Site Collection Url.
#  -> $sCSOMPath: Path for the CSOM assemblies.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets the workflow execution status for all the workflows deployed to a SharePoint Online Site
function Get-SPSitesInSC
{
    param ($sSiteColUrl,$sUserName,$sPassword,$sCSOMPath)
    try
    {    
        Write-Host "-----------------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting the workflow execution status for all the workflows deployed in sSiteColUrl" -foregroundcolor Green
        Write-Host "-----------------------------------------------------------------------------------"  -foregroundcolor Green
     
        #Adding the Client OM Assemblies
        $sCSOMRuntimePath=$sCSOMPath +  "\Microsoft.SharePoint.Client.Runtime.dll"
        $sCSOMWorkflowPath=$sCSOMPath + "\Microsoft.SharePoint.Client.WorkflowServices.dll"
        $sCSOMPath=$sCSOMPath +  "\Microsoft.SharePoint.Client.dll"             
        Add-Type -Path $sCSOMPath         
        Add-Type -Path $sCSOMRuntimePath
        Add-Type -Path $sCSOMWorkflowPath

        #SharePoint Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteColUrl) 
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUsername, $sPassword)        
        $spoCtx.Credentials = $spoCredentials 

        if (!$spoCtx.ServerObjectIsNull.Value) 
        {
            $spoWeb = $spoCtx.Web
            $spoLists = $spoWeb.Lists
            $spoCtx.Load($spoLists);
            $spoCtx.ExecuteQuery();

            $spoWorkflowServicesManager = New-Object Microsoft.SharePoint.Client.WorkflowServices.WorkflowServicesManager($spoCtx, $spoWeb);
            $spoWorkflowSubscriptionService = $spoWorkflowServicesManager.GetWorkflowSubscriptionService();
            $spoWorkflowInstanceSevice = $spoWorkflowServicesManager.GetWorkflowInstanceService();
            
            Write-Host ""
            Write-Host "Getting all the Lists in $sSiteColUrl" -ForegroundColor Green
            Write-Host ""

            foreach ($spoList in $spoLists)         
            {   
                $spoWorkflowSubscriptions = $spoWorkflowSubscriptionService.EnumerateSubscriptionsByList($spoList.Id);
                $spoCtx.Load($spoWorkflowSubscriptions);                
                $spoCtx.ExecuteQuery();                
                foreach($spoWorkflowSubscription in $spoWorkflowSubscriptions)
                {            
                    Write-Host "**************************************************************************************"
                    Write-Host "List: "$spoList.Title " - Workflow: "$spoWorkflowSubscription.Name -ForegroundColor Green
                    Write-Host "***************************************************************************************"
                    Write-Host ""

                    $spoCamlQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
                    $spoCamlQuery.ViewXml = "<View> <ViewFields><FieldRef Name='Title' /></ViewFields></View>";
                    $spoListItems = $spoList.GetItems($spoCamlQuery);
                    $spoCtx.Load($spoListItems);
                    $spoCtx.ExecuteQuery();

                    foreach($spoListItem in $spoListItems)
                    {
                        $spoWorkflowInstanceCollection = $spoWorkflowInstanceSevice.EnumerateInstancesForListItem($spoList.Id,$spoListItem.Id);
                        $spoCtx.Load($spoWorkflowInstanceCollection);
                        $spoCtx.ExecuteQuery();
                        foreach ($spoWorkflowInstance in $spoWorkflowInstanceCollection)
                        {
                           Write-Host "List Item Title:"$spoListItem["Title"] 
                           Write-Host "Workflow Status:"$spoWorkflowInstance.Status 
                           Write-Host "Last Workflow Execution:"$spoWorkflowInstance.LastUpdated
                           Write-Host ""
                        }
                    }                   
                    Write-Host ""
                }
            }
              
            $spoCtx.Dispose() 
        }        
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteColUrl = "https://<SPO_Site>" 
$sUserName = "<SPO_User>" 
$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
#$sPassword=convertto-securestring "<User_Password>" -asplaintext -force
$sCSOMPath="<SPO_Path>"

Get-SPSitesInSC -sSiteColUrl $sSiteColUrl -sUserName $sUserName -sPassword $sPassword -sCSOMPath $sCSOMPath