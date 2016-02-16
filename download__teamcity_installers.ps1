[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

$wc=new-object system.net.webclient
$wc.UseDefaultCredentials = $false
$my_secure_password = convertto-securestring "123asdQ!" -asplaintext -force
$wc.Credentials = New-Object System.Net.NetworkCredential("iholoviy", $my_secure_password)
$wc.Headers.Add("AUTHORIZATION", "Basic YTph");


#loading xml for 6.0.0 branch
[xml]$xml = $wc.DownloadString("https://tc.appassure.com/httpAuth/app/rest/builds/branch:%3Cdefault%3E,status:SUCCESS,buildType:AppAssure_Windows_Develop_FullBuild/artifacts/children/installers")

#getting Core installer file name
$link = $xml.files.file.content.href -like "*Core-X*"
$Filename = [System.IO.Path]::GetFileName($link)
#Write-Host $Filename

#extracting build number from file name
$Filename -match "Core-X64-(?<content>.*).exe"
$buildnumber = $Matches['content']


# delete all net use mappings and map network share
net use * /delete /y
$net = new-object -ComObject WScript.Network
$net.MapNetworkDrive("u:", "\\192.168.64.127\Share", $false, "administrator", "raid4us!")

#creating subfolder on share
try{
New-Item -ItemType Directory -Path U:\$buildnumber -ErrorAction Stop
}
catch 
{
    $my_secure_password = convertto-securestring "123asdQ!" -asplaintext -force
    $Credentials = New-Object System.Management.Automation.PSCredential ("aa5.soak.test", $my_secure_password)
    $ErrorMessage = $_.Exception.Message
    Send-MailMessage -From aa5.soak.test@Gmail.com -To alexander.sirko@softheme.com -Subject "Download of new develop builds failed!" -SmtpServer smtpgw.ocarina.local -Body " The error message was $ErrorMessage" -Credential $Credentials
    Break
}


#downloading files
foreach( $link in $xml.files.file.content.href){
           
           #Write-Host $Filename
        
      if ($link -like '*Core-X*' -or $link -like '*Agent-X*' -or $link -like '*CentralConsole-*' -or $link -like '*LocalMountUtility-X*'){
        ##$dlink=("https://iholoviy:123asdQ!@tc.appassure.com" +$link)
             
        $myMatch = ".*id\:([^\/]+)\/.*installers\/(.*)"
        $link -match $myMatch
        $id=$($Matches[1])
        $installer=$($Matches[2])
        $dlink=("https://tc.appassure.com/repository/download/AppAssure_Windows_Develop_FullBuild/${id}:id/installers/$installer")
        #may not work
        $outfile=Join-Path U:\$buildnumber $installer

        $wc.DownloadFile($dlink, $outfile)
        
}


}



#loading xml for 6.0.2 branch
[xml]$xml = $wc.DownloadString("https://tc.appassure.com/httpAuth/app/rest/builds/branch:%3Cdefault%3E,status:SUCCESS,buildType:AppAssure_Windows_Release602_FullBuild/artifacts/children/installers")

#getting Core installer file name
$link = $xml.files.file.content.href -like "*Core-X*"
$Filename = [System.IO.Path]::GetFileName($link)
#Write-Host $Filename

#extracting build number from file name
$Filename -match "Core-X64-(?<content>.*).exe"
$buildnumber = $Matches['content']

#creating subfolder on share
try{
New-Item -ItemType Directory -Path U:\$buildnumber -ErrorAction Stop
}
catch 
{
    $my_secure_password = convertto-securestring "123asdQ!" -asplaintext -force
    $Credentials = New-Object System.Management.Automation.PSCredential ("aa5.soak.test", $my_secure_password)
    $ErrorMessage = $_.Exception.Message
    Send-MailMessage -From aa5.soak.test@Gmail.com -To alexander.sirko@softheme.com -Subject "Download of new release builds failed!" -SmtpServer smtpgw.ocarina.local -Body " The error message was $ErrorMessage" -Credential $Credentials
    Break
}

foreach( $link in $xml.files.file.content.href){
           #Write-Host $link
        
      if ($link -like '*Core-X*' -or $link -like '*Agent-X*' -or $link -like '*CentralConsole-*' -or $link -like '*LocalMountUtility-X*'){
        ##$dlink=("https://iholoviy:123asdQ!@tc.appassure.com" +$link)
             
        $myMatch = ".*id\:([^\/]+)\/.*installers\/(.*)"
        $link -match $myMatch
        $id=$($Matches[1])
        $installer=$($Matches[2])
        $dlink=("https://tc.appassure.com/repository/download/AppAssure_Windows_Release602_FullBuild/${id}:id/installers/$installer")
        $outfile=Join-Path U:\$buildnumber $installer

        $wc.DownloadFile($dlink, $outfile)
        
}

}


# delete all net use mappings
#net use * /delete /y