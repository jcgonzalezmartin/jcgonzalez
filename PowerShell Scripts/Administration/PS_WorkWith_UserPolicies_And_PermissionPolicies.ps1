############################################################################################################################################
# Script that allows to work with policies (Users and Permissions) at the Web Aplication Level
# Required Parameters:
#   ->$sWebAppUrl: Web Application Url.
#   ->$sOperatitonType: Operation Type.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#We make a good usage of PowerShell in terms of performance
$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to work with policies (Users and Permissions) at the Web Aplication Level
function WorkWith-WebApplicationPolicies
{
    param ($sOperationType,$sWebAppUrl)
    try
    {
        $spWebApplication=Get-SPWebApplication -Identity $sWebAppUrl       
        switch ($sOperationType) 
        { 
        "ReadUserPolicies" {
            Write-Host "User Policies for $sWebAppUrl" -ForegroundColor Green
            $spWebAppUserPolicies=$spWebApplication.Policies           
            foreach($spWebAppUserPolicy in $spWebAppUserPolicies){
                Write-Host "Name: " $spWebAppUserPolicy.DisplayName " - User Name: " $spWebAppUserPolicy.UserName
                Write-Host " -> Roles available for " $spWebAppUserPolicy.DisplayName
                $spPolicyRoleBidings=$spWebAppUserPolicy.PolicyRoleBindings
                foreach($spPolicyRoleBinding in $spPolicyRoleBidings){
                    Write-Host "    * Rol Name: " $spPolicyRoleBinding.Name " - Role Description: " $spPolicyRoleBinding.Description
                    }
                }
            }
        "ReadPermissionPolicies"{
            Write-Host "Permission Policies for $sWebAppUrl" -ForegroundColor Green
            $spWebAppPolicyRoles=$spWebApplication.PolicyRoles
            foreach($spWebAppPolicyRol in $spWebAppPolicyRoles){                
                Write-Host "Name: " $spWebAppPolicyRol.Name" - Descripction: " $spWebAppPolicyRol.Description
                Write-Host " -> Rights Mask for the Permission Policy: " $spWebAppPolicyRol.GrantRightsMask
                }
            }
        default{
            Write-Host "Requested Operation is not valid" -ForegroundColor Red
            }           
        }    
    }
    catch [System.Exception]
    {
        write-host -ForegroundColor Red $_.Exception.ToString()
    }
}
# Required variables
$sWebAppUrl="http://<Web_Application_Url>"
Start-SPAssignment –Global
#Read User Policies
#WorkWith-WebApplicationPolicies -sOperationType "ReadUserPolicies" -sWebAppUrl $sWebAppUrl
#Read PermissionPolicies
WorkWith-WebApplicationPolicies -sOperationType "ReadPermissionPolicies" -sWebAppUrl $sWebAppUrl
Stop-SPAssignment –Global
Remove-PSSnapin Microsoft.SharePoint.PowerShell