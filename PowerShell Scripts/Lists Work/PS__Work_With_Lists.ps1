############################################################################################################################################
# Script that allows to do configuration operations with lists: Creating a List, Updating a List and Deleting a List
# Required Parameters:
#   ->$sOperationType: Operation Type.
#   ->$sSiteCollectionUrl: Site Collection Url.
#   ->$sListName: List Name.
#   ->$sListDescription: List Description.
#   ->$sListTemplate: List Template.
#   ->$sListTemplateFile: XML Definition file.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#We make a good usage of PowerShell in terms of performacne
$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to do configuration operations with lists: Creating a List, Updating a List and Deleting a List
function WorkWith-Lists
{
    param ($sOperationType,$sSiteCollectionUrl,$sListName,$sListDescription, $sListTemplate,$sListTemplateFile)
    try
    {
        $spSite=Get-SPSite -Identity $sSiteCollectionUrl
        $spWeb=$spSite.OpenWeb()
        $spListsCollection=$spWeb.Lists
        switch ($sOperationType) 
        { 
        "Read" {
            Write-Host "Lists in $sSiteCollectionUrl" -ForegroundColor Green            
            foreach($spList in $spListsCollection)
            {
                Write-Host "List Name: " $spList.Title " - List Template: " $spList.BaseTemplate
                }
            }
        "Create"{
            Write-Host "Creating List $sSListName in $sSiteCollectionUrl ..." -ForegroundColor Green                        	
            $spListTemplate = $spWeb.ListTemplates[$sListTemplate] 	            
	        $spListsCollection.Add($sListName, $sListDescription, $spListTemplate) 
            Write-Host "$sListName successfully created in $sSiteCollectionUrl ..." -ForegroundColor Green
            WorkWith-Lists -sOperationType "Read" -sSiteCollectionUrl $sSiteCollectionUrl
            }
        "Update"{                        
            $splList = $spWeb.Lists.TryGetList($sListName)
            If (($splList)) 
            {         
                Write-Host "-----------------------------------------"  -ForegroundColor Green
                Write-Host "Updating List $sListName" -ForegroundColor Green
                Write-Host "-----------------------------------------"  -ForegroundColor Green
        	    $xmlTemplate = [xml](Get-Content $sListTemplateFile)       
	            foreach ($xmlNode in $xmlTemplate.ListTemplate.Field){	                    
		            $splList.Fields.AddFieldAsXml($xmlNode.OuterXml, $true,[Microsoft.SharePoint.SPAddFieldOptions]::AddFieldToDefaultView)
	            }
	            $splList.Update()
            }
            else{
                Write-Host "List $sListName doesn't exist ..." -ForegroundColor Red
                }            
            }
        "Delete"{            
            $splList = $spWeb.Lists.TryGetList($sListName)
            If (($splList)) 
            {         
                Write-Host "-----------------------------------------"  -ForegroundColor Green
                Write-Host "Deleting List $sListName from $sSiteCollectionUrl  ..." -ForegroundColor Green
                Write-Host "-----------------------------------------"  -ForegroundColor Green
        	    $splList.Delete()
                Write-Host "List $sListName deleted from $sSiteCollectionUrl  ..." -ForegroundColor Green
                Write-Host "-----------------------------------------"  -ForegroundColor Green
            }
            else{
                Write-Host "List $sListName doesn't exist ..." -ForegroundColor Red
                }                        
            
            }
        default{
            Write-Host "Requested operation is not valid" -ForegroundColor Red
            }           
        }
        $spWeb.Dispose()
        $spSite.Dispose()   
    }
    catch [System.Exception]
    {
        write-host -ForegroundColor Red $_.Exception.ToString()
    }
}

# Variables necesarias
$sSiteCollectionUrl="http://<Url_Coleccion_Sitios>"
$sListName="Ciudades"
$sListDescription="Lista de ciudades"
$sListTemplate="Custom List"
$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
$sListTemplateFile=$ScriptDir + "\ListColumnsToAdd.xml"
Start-SPAssignment –Global
#Read
WorkWith-Lists -sOperationType "Read" -sSiteCollectionUrl $sSiteCollectionUrl
#Create
WorkWith-Lists -sOperationType "Create" -sSiteCollectionUrl $sSiteCollectionUrl -sListName $sListName -sListDescription $sListDescription -sListTemplate $sListTemplate
#Update
WorkWith-Lists  -sOperationType "Update" -sSiteCollectionUrl $sSiteCollectionUrl -sListName $sListName -sListTemplateFile $sListTemplateFile
#Delete
WorkWith-Lists -sOperationType "Delete" -sSiteCollectionUrl $sSiteCollectionUrl -sListName $sListName
Stop-SPAssignment –Global
Remove-PSSnapin Microsoft.SharePoint.PowerShell