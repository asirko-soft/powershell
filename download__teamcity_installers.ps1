[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

$wc=new-object system.net.webclient
$wc.UseDefaultCredentials = $false
$my_secure_password = convertto-securestring "123asdQ" -asplaintext -force
$wc.Credentials = New-Object System.Net.NetworkCredential("qa-softheme", $my_secure_password)
$wc.Headers.Add("AUTHORIZATION", "Basic YTph");


#loading xml for develop branch
[xml]$xml = $wc.DownloadString("https://tc.appassure.com/httpAuth/app/rest/builds/branch:%3Cdefault%3E,status:SUCCESS,buildType:AppAssure_Windows_Develop20_FullBuild/artifacts/children/installers")

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
$Drive = "U:"
$Net.RemoveNetworkDrive($Drive, 0)
$net.MapNetworkDrive("u:", "\\192.168.64.127\Share\Builds", $false, "administrator", "raid4us!")

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

;
#downloading files
foreach( $link in $xml.files.file.content.href){
           
           #Write-Host $Filename
  		$stop_watch = [Diagnostics.Stopwatch]::StartNew()
        
      	if ($link -like '*Core-X*' -or $link -like '*Agent-X*' -or $link -like '*CentralConsole-*' -or $link -like '*LocalMountUtility-X*'){
        ##$dlink=("https://iholoviy:123asdQ!@tc.appassure.com" +$link)
             
        $myMatch = ".*id\:([^\/]+)\/.*installers\/(.*)"
        $link -match $myMatch
        $id=$($Matches[1])
        $installer=$($Matches[2])
        $dlink=("https://tc.appassure.com/repository/download/AppAssure_Windows_Develop20_FullBuild/${id}:id/installers/$installer")
        #may not work
        $outfile=Join-Path U:\$buildnumber $installer
		Start-Process -FilePath "C:\Users\Administrator\Downloads\aria2-1.25.0-win-64bit-build1\aria2c.exe" -ArgumentList """-d U:\$buildnumber"" ""-o $installer"" ""-x 6"" ""-s 5"" ""--http-user=qa-softheme"" ""--http-passwd=123asdQ""  ""$dlink""" -Wait
        #$wc.DownloadFile($dlink, $outfile)
        $stop_watch.Stop()
        $elapsed_seconds = ($stop_watch.elapsedmilliseconds)/1000
        
        
		Write-Host $logfilename "Download took $("{0:N2}" -f $elapsed_seconds)s to finish, exiting." -1 "full"	
        
}


}

#loading xml for 6.1.3 branch
[xml]$xml = $wc.DownloadString("https://tc.appassure.com/httpAuth/app/rest/builds/branch:%3Cdefault%3E,status:SUCCESS,buildType:AppAssure_Windows_Release613_FullBuild2/artifacts/children/installers")

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
    Send-MailMessage -From aa5.soak.test@Gmail.com -To alexander.sirko@softheme.com -Subject "Download of new release 6.1.3 builds failed!" -SmtpServer smtpgw.ocarina.local -Body " The error message was $ErrorMessage" -Credential $Credentials
    Break
}

foreach( $link in $xml.files.file.content.href){
           Write-Host $link
       #measuring execution time is really hip these days
        $stop_watch = [Diagnostics.Stopwatch]::StartNew()
      if ($link -like '*Core-X*' -or $link -like '*Agent-X*' -or $link -like '*CentralConsole-*' -or $link -like '*LocalMountUtility-X*'){
        ##$dlink=("https://iholoviy:123asdQ!@tc.appassure.com" +$link)
             
        $myMatch = ".*id\:([^\/]+)\/.*installers\/(.*)"
        $link -match $myMatch
        $id=$($Matches[1])
        $installer=$($Matches[2])
        $dlink=("https://tc.appassure.com/repository/download/AppAssure_Windows_Release613_FullBuild2/${id}:id/installers/$installer")
        Start-Process -FilePath "C:\Users\Administrator\Downloads\aria2-1.25.0-win-64bit-build1\aria2c.exe" -ArgumentList """-d U:\$buildnumber"" ""-o $installer"" ""-x 6"" ""-s 5"" ""--http-user=qa-softheme"" ""--http-passwd=123asdQ""  ""$dlink""" -Wait
        $outfile=Join-Path U:\$buildnumber $installer        
        # $wc.DownloadFile($dlink, $outfile)
        $stop_watch.Stop()
        $elapsed_seconds = ($stop_watch.elapsedmilliseconds)/1000
        
        
		Write-Host $logfilename "Download took $("{0:N2}" -f $elapsed_seconds)s to finish, exiting." -1 "full"	
        
}

}


#loading xml for 6.1.2 branch
[xml]$xml = $wc.DownloadString("https://tc.appassure.com/httpAuth/app/rest/builds/branch:%3Cdefault%3E,status:SUCCESS,buildType:AppAssure_Windows_Release612_FullBuild2/artifacts/children/installers")

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
    Send-MailMessage -From aa5.soak.test@Gmail.com -To alexander.sirko@softheme.com -Subject "Download of new release 6.1.2 builds failed!" -SmtpServer smtpgw.ocarina.local -Body " The error message was $ErrorMessage" -Credential $Credentials
    Break
}

foreach( $link in $xml.files.file.content.href){
           Write-Host $link
       #measuring execution time is really hip these days
        $stop_watch = [Diagnostics.Stopwatch]::StartNew()
      if ($link -like '*Core-X*' -or $link -like '*Agent-X*' -or $link -like '*CentralConsole-*' -or $link -like '*LocalMountUtility-X*'){
        ##$dlink=("https://iholoviy:123asdQ!@tc.appassure.com" +$link)
             
        $myMatch = ".*id\:([^\/]+)\/.*installers\/(.*)"
        $link -match $myMatch
        $id=$($Matches[1])
        $installer=$($Matches[2])
        $dlink=("https://tc.appassure.com/repository/download/AppAssure_Windows_Release612_FullBuild2/${id}:id/installers/$installer")
        Start-Process -FilePath "C:\Users\Administrator\Downloads\aria2-1.25.0-win-64bit-build1\aria2c.exe" -ArgumentList """-d U:\$buildnumber"" ""-o $installer"" ""-x 6"" ""-s 5"" ""--http-user=qa-softheme"" ""--http-passwd=123asdQ""  ""$dlink""" -Wait
        $outfile=Join-Path U:\$buildnumber $installer        
        # $wc.DownloadFile($dlink, $outfile)
        $stop_watch.Stop()
        $elapsed_seconds = ($stop_watch.elapsedmilliseconds)/1000
        
        
		Write-Host $logfilename "Download took $("{0:N2}" -f $elapsed_seconds)s to finish, exiting." -1 "full"	
        
}

}


#loading xml for 6.1.1 branch
[xml]$xml = $wc.DownloadString("https://tc.appassure.com/httpAuth/app/rest/builds/branch:%3Cdefault%3E,status:SUCCESS,buildType:AppAssure_Windows_Release611_FullBuild_2/artifacts/children/installers")

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
    Send-MailMessage -From aa5.soak.test@Gmail.com -To alexander.sirko@softheme.com -Subject "Download of new release 6.1.1 builds failed!" -SmtpServer smtpgw.ocarina.local -Body " The error message was $ErrorMessage" -Credential $Credentials
    Break
}

foreach( $link in $xml.files.file.content.href){
           Write-Host $link
       #measuring execution time is really hip these days
        $stop_watch = [Diagnostics.Stopwatch]::StartNew()
      if ($link -like '*Core-X*' -or $link -like '*Agent-X*' -or $link -like '*CentralConsole-*' -or $link -like '*LocalMountUtility-X*'){
        ##$dlink=("https://iholoviy:123asdQ!@tc.appassure.com" +$link)
             
        $myMatch = ".*id\:([^\/]+)\/.*installers\/(.*)"
        $link -match $myMatch
        $id=$($Matches[1])
        $installer=$($Matches[2])
        $dlink=("https://tc.appassure.com/repository/download/AppAssure_Windows_Release611_FullBuild_2/${id}:id/installers/$installer")
        Start-Process -FilePath "C:\Users\Administrator\Downloads\aria2-1.25.0-win-64bit-build1\aria2c.exe" -ArgumentList """-d U:\$buildnumber"" ""-o $installer"" ""-x 6"" ""-s 5"" ""--http-user=qa-softheme"" ""--http-passwd=123asdQ""  ""$dlink""" -Wait
        $outfile=Join-Path U:\$buildnumber $installer        
        # $wc.DownloadFile($dlink, $outfile)
        $stop_watch.Stop()
        $elapsed_seconds = ($stop_watch.elapsedmilliseconds)/1000
        
        
		Write-Host $logfilename "Download took $("{0:N2}" -f $elapsed_seconds)s to finish, exiting." -1 "full"	
        
}

}


# delete all net use mappings
#net use * /delete /y

#loading xml for 6.1.0 branch
[xml]$xml = $wc.DownloadString("https://tc.appassure.com/httpAuth/app/rest/builds/branch:%3Cdefault%3E,status:SUCCESS,buildType:AppAssure_Windows_Release610_FullBuild/artifacts/children/installers")

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
           Write-Host $link
       #measuring execution time is really hip these days
        $stop_watch = [Diagnostics.Stopwatch]::StartNew()
      if ($link -like '*Core-X*' -or $link -like '*Agent-X*' -or $link -like '*CentralConsole-*' -or $link -like '*LocalMountUtility-X*'){
        ##$dlink=("https://iholoviy:123asdQ!@tc.appassure.com" +$link)
             
        $myMatch = ".*id\:([^\/]+)\/.*installers\/(.*)"
        $link -match $myMatch
        $id=$($Matches[1])
        $installer=$($Matches[2])
        $dlink=("https://tc.appassure.com/repository/download/AppAssure_Windows_Release610_FullBuild/${id}:id/installers/$installer")
        Start-Process -FilePath "C:\Users\Administrator\Downloads\aria2-1.25.0-win-64bit-build1\aria2c.exe" -ArgumentList """-d U:\$buildnumber"" ""-o $installer"" ""-x 6"" ""-s 5"" ""--http-user=qa-softheme"" ""--http-passwd=123asdQ""  ""$dlink""" -Wait
        $outfile=Join-Path U:\$buildnumber $installer        
        # $wc.DownloadFile($dlink, $outfile)
        $stop_watch.Stop()
        $elapsed_seconds = ($stop_watch.elapsedmilliseconds)/1000
        
        
		Write-Host $logfilename "Download took $("{0:N2}" -f $elapsed_seconds)s to finish, exiting." -1 "full"	
        
}

}


# delete all net use mappings
#net use * /delete /y