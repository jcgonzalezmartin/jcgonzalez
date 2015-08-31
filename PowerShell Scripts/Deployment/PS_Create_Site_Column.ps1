############################################################################################################################################
# This script allows to easily create a new Site Column in a SharePoint Site
# Required parameters:
#   ->$sSiteCollectionUrl: Site Collection Url.
#   ->$sFieldDisplayName: Display name for the New Column to be added.
#   ->$sFieldInternalName: Internal name for the New Column to be added.
#   ->$sFieldType: Field type (Text, Choice, ...)
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"


#Definition of the function that creates a New Site Column in a SharePoint Site.
function Create-SiteColumn
{
    param ($sSiteCollectionUrl,$sFieldDisplayName, $sFieldInternalName, $sFieldType)   
    try
    {
        $spSite = Get-SPSite -Identity $sSiteCollectionUrl
 	    $spWeb = $spSite.OpenWeb()    

    
        #We check the field type is not null
        if($sFieldType -ne '')
        {
            write-Host "Adding the field $sFieldDisplayName to the Site" -foregroundcolor blue            
            $spWeb.Fields.Add($sFieldInternalName,$sFieldType,$false)
            $spChoiceField=$spWeb.Fields.GetField($sFieldInternalName)
            $spChoiceField.Group="MVP Columns"
            $spChoiceField.Choices.Add("Developer")
            $spChoiceField.Choices.Add("IT Pro")
            $spChoiceField.Choices.Add("Architect")
            $spChoiceField.Title=$sFieldDisplayName
            $spChoiceField.DefaultValue="Developer"
            $spChoiceField.FillInChoice=$true
            $spChoiceField.Update()
        } 
        
        #Disposing SPSite and SPWeb objects
        $spWeb.Dispose()   
        $spSite.Dispose()   
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
} 

#Calling the function
Start-SPAssignment –Global
$sSiteCollectionUrl = "http://winsrv2012:80/sitios/compartimoss"
$sFieldDisplayName="MVP Type"
$sFieldInternalName="MVPType"
$sFieldType="Choice"
Create-SiteColumn -sSiteCollectionUrl $sSiteCollectionUrl -sFieldDisplayName $sFieldDisplayName -sFieldInternalName $sFieldInternalName -sFieldType $sFieldType
Stop-SPAssignment –Global

Remove-PsSnapin Microsoft.SharePoint.PowerShell