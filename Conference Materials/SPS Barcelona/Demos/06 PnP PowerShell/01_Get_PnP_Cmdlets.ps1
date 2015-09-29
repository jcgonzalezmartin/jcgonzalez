$spoPnPCmdlets=Get-Command | where {$_.ModuleName -eq "OfficeDevPnP.PowerShell.Commands"}
$spoPnPCmdlets.Count
$spoPnPCmdlets