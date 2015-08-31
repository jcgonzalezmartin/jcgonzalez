$username = "jcgonzalez@nuberosnet.onmicrosoft.com"
$password = "6805&DDT"
$url = "https://nuberosnet.sharepoint.com/sites/CloudShare/"
$urlToAdd = "http://www.mvpcluster.com"
$urlToAddTitle = "MVP CLUSTER"
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force

Add-Type -Path "G:\03 Docs\10 MVP\03 MVP Work\11 PS Scripts\Office 365\Microsoft.SharePoint.Client.dll"
Add-Type -Path "G:\03 Docs\10 MVP\03 MVP Work\11 PS Scripts\Office 365\Microsoft.SharePoint.Client.Runtime.dll"

$clientCtx = New-Object Microsoft.SharePoint.Client.ClientContext($url) 
$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($username,$securePassword)
$clientCtx.Credentials = $credentials

$web = $clientCtx.Web
$navColl = $web.Navigation.QuickLaunch

Function Add-QLNode {
#this works as advertised
$newNavNode = New-Object Microsoft.SharePoint.Client.NavigationNodeCreationInformation
$newNavNode.Title = $urlToAddTitle
$newNavNode.Url = $urlToAdd
$newNavNode.AsLastNode = $true
$newNavNode 
$clientCtx.Load($navColl.Add($newNavNode))
$clientCtx.ExecuteQuery()
}

Function List-QLNodes {
#this Fails
$navColl.Retrieve()
$Nodes = @()
$navColl | ForEach-Object { $Nodes = $Nodes + $_.id }
$Nodes | ForEach-Object {
$node = $web.Navigation.GetNodeById($_)
Write-Host $node 
}
}
#Add-QLNode
List-QLNodes