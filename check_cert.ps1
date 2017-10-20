function sendmail
{
$subject = $args[0]
$body = $args[1]
$smtpServer = "" 
$smtpPort = 587  
$username = ""
$password = ""  
$from = ""
$to = ""

$smtp = new-object Net.Mail.SmtpClient($smtpServer, $smtpPort)
$smtp.EnableSsl = $true 
$smtp.Credentials = new-object Net.NetworkCredential($username, $password)

$msg = new-object Net.Mail.MailMessage
$msg.From = $from
$msg.To.Add($to)
$msg.Subject = $subject
$msg.Body = $body
$smtp.Send($msg)
}

$minimumCertAgeDays = 10
 $timeoutMilliseconds = 10000
 $urls = @(

 )
 [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
foreach ($url in $urls)
 {
 Write-Host Checking $url -f Green
 $req = [Net.HttpWebRequest]::Create($url)
 $req.Timeout = $timeoutMilliseconds
try {$req.GetResponse() |Out-Null} catch {}
[datetime]$expiration = $req.ServicePoint.Certificate.GetExpirationDateString()
[int]$certExpiresIn = ($expiration - $(get-date)).Days
$certName = $req.ServicePoint.Certificate.GetName()
Write-Output "Certificat days left: $certExpiresIn"
Write-Output "Certificat expiration: $expiration"
#Write-Output $certName
if ($certExpiresIn -lt $minimumCertAgeDays)
  { Write-Host Cert for site $url expires in $certExpiresIn days [on $expiration] -f Green
	sendmail "[Certificate expires]" "Certificate for site $url will be expired in $certExpiresIn days on $expiration"
  }
	Remove-Variable req
	Remove-Variable expiration
	Remove-Variable certExpiresIn
  }
