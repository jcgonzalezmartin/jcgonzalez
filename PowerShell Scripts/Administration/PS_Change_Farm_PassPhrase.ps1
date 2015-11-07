############################################################################################################################################
# Script that allows to change the farm passphrase.
# Required parameters: 
#   -> $sPassPhrase: Value for the new Fram Passphrase.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to change the farm passphrase.
function Change-SPPassPhrase
{  
    param ($sPassPhrase)
    try
    {
        Write-Host "Changing Farm PassPhrase to $sPassPhrase"
        $SPPpassPhrase = ConvertTo-SecureString –String $sPassPhrase -AsPlainText –Force
        Set-SPPassPhrase -PassPhrase $SPPpassPhrase -Confirm:$true
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
$spPassPhrase="<Password>"
Change-SPPassPhrase -sPassPhrase $spPassPhrase
Stop-SPAssignment –Global

Remove-PsSnapin Microsoft.SharePoint.PowerShell