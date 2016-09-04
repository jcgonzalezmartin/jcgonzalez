#
# Script.ps1
#
$spoCmdlets=Get-Command | where {$_.ModuleName -eq “Microsoft.Online.SharePoint.PowerShell"}
$spoCmdlets.Count
$spoCmdlets
