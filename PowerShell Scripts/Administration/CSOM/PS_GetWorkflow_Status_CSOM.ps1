############################################################################################################################################
# Script that allows to get the workflow execution status for all the workflows deployed to a SharePoint Site
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sDomain: AD Domain for the user.
#  -> $sSiteColUrl: Site Collection Url.
#  -> $sCSOMPath: Path for the CSOM assemblies.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets the workflow execution status for all the workflows deployed to a SharePoint Site
function Get-SPSitesInSC
{
    param ($sSiteColUrl,$sUserName,$sDomain,$sPassword,$sCSOMPath)
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
        $spCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteColUrl) 
        $spCredentials = New-Object System.Net.NetworkCredential($sUserName,$sPassword,$sDomain)  
        $spCtx.Credentials = $spCredentials 

        if (!$spCtx.ServerObjectIsNull.Value) 
        {
            $spWeb = $spCtx.Web
            $spLists = $spWeb.Lists
            $spCtx.Load($spLists);
            $spCtx.ExecuteQuery();

            $spWorkflowServicesManager = New-Object Microsoft.SharePoint.Client.WorkflowServices.WorkflowServicesManager($spCtx, $spWeb);
            $spWorkflowSubscriptionService = $spWorkflowServicesManager.GetWorkflowSubscriptionService();
            $spWorkflowInstanceSevice = $spWorkflowServicesManager.GetWorkflowInstanceService();
            
            Write-Host ""
            Write-Host "Getting all the Lists in $sSiteColUrl" -ForegroundColor Green
            Write-Host ""

            foreach ($spList in $spLists)         
            {   
                $spWorkflowSubscriptions = $spWorkflowSubscriptionService.EnumerateSubscriptionsByList($spList.Id);
                $spCtx.Load($spWorkflowSubscriptions);                
                $spCtx.ExecuteQuery();                
                foreach($spWorkflowSubscription in $spWorkflowSubscriptions)
                {            
                    Write-Host "**************************************************************************************"
                    Write-Host "List: "$spList.Title " - Workflow: "$spWorkflowSubscription.Name -ForegroundColor Green
                    Write-Host "***************************************************************************************"
                    Write-Host ""

                    $spCamlQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
                    $spCamlQuery.ViewXml = "<View> <ViewFields><FieldRef Name='Title' /></ViewFields></View>";
                    $spListItems = $spList.GetItems($spCamlQuery);
                    $spCtx.Load($spListItems);
                    $spCtx.ExecuteQuery();

                    foreach($spListItem in $spListItems)
                    {
                        $spWorkflowInstanceCollection = $spWorkflowInstanceSevice.EnumerateInstancesForListItem($spList.Id,$spListItem.Id);
                        $spCtx.Load($spWorkflowInstanceCollection);
                        $spCtx.ExecuteQuery();
                        foreach ($spWorkflowInstance in $spWorkflowInstanceCollection)
                        {
                           Write-Host "List Item Title:"$spListItem["Title"] 
                           Write-Host "Workflow Status:"$spWorkflowInstance.Status 
                           Write-Host "Last Workflow Execution:"$spWorkflowInstance.LastUpdated
                           Write-Host ""
                        }
                    }                   
                    Write-Host ""
                }
            }
              
            $spCtx.Dispose() 
        }        
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteColUrl = "http://<SiteUrl>/" 
$sUserName = "<SharePointUser>" 
$sDomain="<OnPremisesDomain>"
$sPassword ="<Password>" 
$sCSOMPath="C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI"

Get-SPSitesInSC -sSiteColUrl $sSiteColUrl -sUserName $sUserName -sDomain $sDomain -sPassword $sPassword -sCSOMPath $sCSOMPath