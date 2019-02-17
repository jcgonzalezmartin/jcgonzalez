############################################################################################################################################
#Script that allows to update a user profile property
# Required Parameters:
#  -> $sCSOMPath: Path for the Client Side Object Model for SPO.
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSPOAdminCenterUrl: SharePoint Online Administration Url.
#  -> $sProfileProperty: Profile Property to be updated
#  -> $sProfilePropertyValue: Value to be updated in the Profile Property.
#  -> $sProfileToUpdate: User Profile to update.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to update a User Profile Property
function Set-ValueUserProfileProperty
{
    param ($sCSOMPath,$sSPOAdminCenterUrl,$sUserName,$sPassword,$sProfileProperty,$sProfilePropertyValue,$sProfileToUpdate)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
        Write-Host "Updating User Profile Property $sProfileProperty for $sProfileToUpdate " -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
                    
        #Adding the Client OM Assemblies
        $sCSOMRuntimePath=$sCSOMPath +  "\Microsoft.SharePoint.Client.Runtime.dll"  
        $sCSOMUserProfilesPath=$sCSOMPath +  "\Microsoft.SharePoint.Client.UserProfiles.dll"        
        $sCSOMPath=$sCSOMPath +  "\Microsoft.SharePoint.Client.dll"             
        Add-Type -Path $sCSOMPath         
        Add-Type -Path $sCSOMRuntimePath
        Add-Type -Path $sCSOMUserProfilesPath

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSPOAdminCenterUrl) 
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUserName, $sPassword)  
        $spoCtx.Credentials = $spoCredentials      

        $spoPeopleManager=New-Object Microsoft.SharePoint.Client.UserProfiles.PeopleManager($spoCtx)
        $spoUserProfileToUpdate=$spoPeopleManager.GetPropertiesFor("i:0#.f|membership|"+$sProfileToUpdate)
        $spoCtx.Load($spoUserProfileToUpdate)
        $spoctx.ExecuteQuery()
        $spoPeopleManager.SetSingleValueProfileProperty($spoUserProfileToUpdate.AccountName,$sProfileProperty,$sProfilePropertyValue)     
        $spoCtx.ExecuteQuery()

        $spoCtx.Dispose()

        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
        Write-Host "$sProfileToUpdate profile has been successfully updated" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green

    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSPOAdminCenterUrl = "https://<Office365Domain>-admin.sharepoint.com/"
$sUserName = "<Usuario>@<Office365Domain>.onmicrosoft.com" 
$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString
$sCSOMPath="<CSOM_Path>"
$sProfileProperty="Division"
$sProfilePropertyValue="Marketing"
$sProfileToUpdate="<Usuario>@<Office365Domain>.onmicrosoft.com"

Set-ValueUserProfileProperty -sCSOMPath $sCSOMPath -sSPOAdminCenterUrl $sSPOAdminCenterUrl -sUserName $sUserName -sPassword $sPassword -sProfileProperty $sProfileProperty -sProfilePropertyValue $sProfilePropertyValue -sProfileToUpdate $sProfileToUpdate