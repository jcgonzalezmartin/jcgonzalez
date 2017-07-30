############################################################################################################################################
# Script that allows to send an e-mail message using Office 365 SMTP Service
# Required Parameters:
#  ->$O365Cred: Office 365 Credentials Object
#  ->$sFromEMail: From E-Mail
#  ->$sToEMail: Recipients e-mails
#  ->$sCcEMail: CC E-Mails
#  ->$sBccEMail: Bcc E-Mails
#  ->$sEMailSubject: E-Mail Subject
#  ->$sEMailBody: E-Mail Body
#  ->$sSMTPServer: SMTP Server to be used (Office 365 in this case)
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to send an e-mail message using Office 365 SMTP Service
function Send-EmailByO365
{   
    param($O365Cred,$sFromEMail,$sToEMail,$sCcEMail,$sBccEMail,$sEMailSubject,$sEMailBody,$sSMTPServer) 
    Try
    {   
        
    if($sToEmail -ne $null -and $sCcEMail -ne $null)
    {
        [string[]]$To=$sToEMail.Split(',',[System.StringSplitOptions]::RemoveEmptyEntries)
        [string[]]$cc=$sCcEMail.Split(',',[System.StringSplitOptions]::RemoveEmptyEntries) 
        [string[]]$bcc=$sBccEmail.Split(',',[System.StringSplitOptions]::RemoveEmptyEntries) 
        Send-MailMessage -From $sFromEMail -To $To -Cc $cc -Bcc $sBccEMail -Subject $sEMailSubject -Body $sEMailBody -BodyAsHtml -SmtpServer $sSMTPServer -Credential $O365Cred -UseSsl 
        }    
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()   
    } 
}

#Office 365 Credentials
$sUserName="<Your_Office365_Admin_Account>"
$sMessage="Introduce your Office 365 Credentials"
$O365Cred=Get-Credential -UserName $sUserName -Message $sMessage

#E-Mail configuration
$sFromEMail="<From_Email>"
$sToEMail="<ToEMail_1>,<To_Email2>"
$sCcEMail="<CcEMail_1>,<Cc_Email2>"
$sBccEMail="<BccEMail_1>,<Bcc_Email2>"
$sEMailSubject="<E-Mail Subject>"
$sEMailBody="<E-Mail Body (just add your HTML code)>"
$sSMTPServer="smtp.office365.com"

#Sending the e-mail
Send-EmailByO365 -O365Cred $O365Cred -sFromEMail $sFromEMail -sToEMail $sToEMail -sCcEMail $sCcEMail -sBccEMail $sBccEMail -sEMailSubject $sEMailSubject -sEMailBody $sEMailBody -sSMTPServer $sSMTPServer
