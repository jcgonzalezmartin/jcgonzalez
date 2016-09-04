############################################################################################################################################
# Script that allows to demonstrates the use of some of the PnP PowerShell cmdlets for SharePoint Online
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that creates a SharePoint Online Site Collection
function Create-SPOSiteCollection
{
    param ($sUserName,$sSiteColTitle,$sSiteColUrl,$sOwner,$iLocaleID,$sTemplateID,$iStorageQuota)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
        Write-Host "Creating a new Site Collection in SharePoint Online" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green        
        #
        #Using New-SPOSite standard cmdlet
        #
        #Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $msolCred
        #New-SPOSite -Title $sSiteColTitle -Url $sSiteColUrl -Owner $sOwner -LocaleId $iLocaleID -Template $sTemplateID -StorageQuota $iStorageQuota

        #
        #Using New-SPOTenantSite PnP Cmdlet
        $spoTimeZone=Get-SPOTimeZoneId -Match Madrid
        #New-SPOTenantSite -Title $sSiteColTitle -Url $sSiteColUrl -Owner $sUserName -Lcid $iLocaleID -Template $sTemplateID -StorageQuota $iStorageQuota -TimeZone $spoTimeZone.Id
        #With the remove delete site option if required
        New-SPOTenantSite -Title $sSiteColTitle -Url $sSiteColUrl -Owner $sUserName -Lcid $iLocaleID -Template $sTemplateID -StorageQuota $iStorageQuota -TimeZone $spoTimeZone.Id -RemoveDeletedSite
                
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
        Write-Host "Site Collection succesfully created!!!" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Definition of the function that removes a SharePoint Online Site Collection
function Remove-SPOSiteCollection
{
    param ($sSiteColUrl)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
        Write-Host "Removing a Site Collection" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green    
       
        Remove-SPOTenantSite -Url $sSiteColUrl -Force:$true
        #Remove-SPOTenantSite -Url $sSiteColUrl -FromRecycleBin -Force:$true
                        
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
        Write-Host "Site Collection succesfully removed!!!" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
    } 
    catch [System.Exception]
    { 
        write-host -f red $_.Exception.ToString()          
    }    
}

#Definition of the function that allows to work with some of the PnP PowerShell cmdlets
function WorkWith-PnPCmdlets
{
    param ($sSiteColUrl,$sOperationType,$sListToCreate,$sListToCreateRelativeUrl)
    try
    {          
        switch ($sOperationType) 
        { 
        "GetSPOList" {
            Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
            Write-Host "Using GET-SPOList!!" -ForegroundColor Green
            Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
            Write-Host " -> Getting all the lists in the SPO Site"  -ForegroundColor Green
            Get-SPOList
            Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
            
            Write-Host " -> Getting information of a specific list"  -ForegroundColor Green
            $spoList=Get-SPOList -Identity "Documents"
            $spoList
            $spoList | Get-Member

            Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
            Write-Host " -> Getting a specific property"  -ForegroundColor Green
            $spoList.ParentWebUrl

            Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
            Write-Host " -> Working with Get-SPOContext"  -ForegroundColor Green            
            $spoCtx=Get-SPOContext
            $spoCtx
            $spoCtx.Load($spoList.Views)
            $spoCtx.ExecuteQuery()
            Write-Host "Number of views in the list is: " $spoList.Views.Count -ForegroundColor Green
            $spoCtx.Dispose()

            } 
            "NewSPOList" {
            Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
            Write-Host "Using New-SPOList!!" -ForegroundColor Green
            Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
            Write-Host " -> Creating a new List in SPO" -ForegroundColor Green            
            New-SPOList -Title $sListToCreate -Template GenericList -Url $sListToCreateRelativeUrl
            Get-SPOList -Identity $sListToCreate
            
            Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
            Write-Host " -> Adding a new field to the List" -ForegroundColor Green      
            Add-SPOField -List "SPS BCN Demo List" -DisplayName "SPS BCN Demo Field" -InternalName "SPSBCNDemoField" -Type Text -AddToDefaultView -Required

            }  
            "GetSPOGroup" {
            Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
            Write-Host "Getting all the Groups in a SPO Site!!" -ForegroundColor Green
            Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
            Get-SPOGroup
            <#
            $spoGroup=Get-SPOGroup -Identity 7
            Add-SPOUserToGroup -LoginName -Identity
            #>                  

            }        
        default {
            Write-Host "Requested Operation not valid!!" -ForegroundColor DarkBlue            
            }
        }               

    } 
    catch [System.Exception]
    { 
        write-host -f red $_.Exception.ToString()          
    }    
}

#Required parameters
$sUserName="jcgonzalez@nuberosnet.onmicrosoft.com"
$sMessage="Introduce your SPO Credentials"
$sSPOAdminCenterUrl="https://<O365Domain>-admin.sharepoint.com/"
$sSiteColTitle="SPS BCN PnP Site Collection"
$sSiteColUrl="https://<O365Domain>.sharepoint.com/sites/SPSBCN_PnP_2"
$sOwner="<SPOUser>@<O365Domain>.onmicrosoft.com"
$iLocaleID=1033
$sTemplateID="STS#0"
$iStorageQuota=1024
$msolCred = Get-Credential -UserName $sUserName -Message $sMessage

#Connection to SPO using PnP Connect-SPOnline cmdlet
Connect-SPOnline –Url $sSPOAdminCenterUrl –Credentials $msolCred

#Creating the SPO Site Collection
#Remove-SPOSiteCollection -sSiteColUrl $sSiteColUrl

#Create-SPOSiteCollection -sUserName $sUserName -sSiteColTitle $sSiteColTitle -sSiteColUrl $sSiteColUrl -sOwner $sOwner -iLocaleID $iLocaleID -sTemplateID $sTemplateID -iStorageQuota $iStorageQuota
Disconnect-SPOnline

Connect to the SPO Site Collection previously created
Connect-SPOnline –Url $sSiteColUrl –Credentials $msolCred

#Get-SPOList
WorkWith-PnPCmdlets -sSiteColUrl $sSiteColUrl -sOperationType "GetSPOList"

#New-SPOList
$sListToCreate="SPS BCN Demo List"
$sListToCreateRelativeUrl="lists/spsbcndemolist"
WorkWith-PnPCmdlets -sSiteColUrl $sSiteColUrl -sOperationType "NewSPOList" -sListToCreate $sListToCreate -sListToCreateRelativeUrl $sListToCreateRelativeUrl

#Get-SPOGrup
#WorkWith-PnPCmdlets -sSiteColUrl $sSiteColUrl -sOperationType "GetSPOGroup"

Disconnect-SPOnline


