Function Write-And-Log {
 
[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [ValidateNotNullOrEmpty()]
   [string]$LogFile,
	
   [Parameter(Mandatory=$True,Position=2)]
   [ValidateNotNullOrEmpty()]
   [string]$line,
 
   [Parameter(Mandatory=$False,Position=3)]
   [int]$Severity=0,
 
   [Parameter(Mandatory=$False,Position=4)]
   [string]$type="terse"
 
   
)
 
$timestamp = (Get-Date -Format ("[yyyy-MM-dd HH:mm:ss] "))
$ui = (Get-Host).UI.RawUI
 
switch ($Severity) {
 
        {$_ -gt 0} {$ui.ForegroundColor = "red"; $type ="full"; $LogEntry = $timestamp + ":Error: " + $line; break;}
        {$_ -eq 0} {$ui.ForegroundColor = "green"; $LogEntry = $timestamp + ":Info: " + $line; break;}
        {$_ -lt 0} {$ui.ForegroundColor = "yellow"; $LogEntry = $timestamp + ":Warning: " + $line; break;}
 
}
switch ($type) {
   
        "terse"   {Write-Output $LogEntry; break;}
        "full"    {Write-Output $LogEntry; $LogEntry | Out-file $LogFile -Append; break;}
        "logonly" {$LogEntry | Out-file $LogFile -Append; break;}
     
}
 
$ui.ForegroundColor = "white" 
 
}
 
#constans
 
#variables
$ScriptRoot = Split-Path $MyInvocation.MyCommand.Path
$StartTime = Get-Date -Format "yyyyMMddHHmmss_"
$logdir = $ScriptRoot + "\prepare_environment_logs\"
$logfilename = $logdir + $StartTime + "prepare_environments.log"
$transcriptfilename = $logdir + $StartTime + "prepare_environment_Transcript.log"
$total_errors = 0
$total_vmhosts = 0
$index_vmhosts =0
$vCenterServer = 192.168.64.76

#test for log directory, create one if needed
if ( -not (Test-Path $logdir)) {
	New-Item -type directory -path $logdir 2>&1 > $null
}
 
#start PowerShell transcript... or don't do it...
#Start-Transcript -Path $transcriptfilename
 
#load PowerCLI snap-in
if ( !(Get-Module -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) ) {
 “C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1”
}

$Error.Clear()
if ($vmsnapin -eq $null) {
	#Add-PSSnapin VMware.VimAutomation.Core
	if ($error.Count -eq 0) {
		write-and-log $logfilename "PowerCLI VimAutomation.Core Snap-in was successfully enabled." 0 "full"
	}
	else{
		write-and-log $logfilename "Could not enable PowerCLI VimAutomation.Core Snap-in, exiting script." 1 "full"
		Exit
	}
}
else{
	write-and-log $logfilename "PowerCLI VimAutomation.Core Snap-in is already enabled." 0 "full"
}
 
#check PowerCLI version
if (($vmsnapin.Version.Major -gt 5) -or (($vmsnapin.version.major -eq 5) -and ($vmsnapin.version.minor -ge 1))) {
	
 
    #assume everything is OK at this point
	$Error.Clear()
 
	#connect vCenter 
	Connect-VIServer -Server 192.168.64.76 -Password P@ssw0rd -SaveCredentials -User administrator@vsphere.local -ErrorAction SilentlyContinue
 
	#execute only if connection successful
	if ($error.Count -eq 0){
	    
        #measuring execution time
        $stop_watch = [Diagnostics.Stopwatch]::StartNew()
    	
        #use previously defined function to inform what is going on, anything else than "terse" will cause the message to be written both in logfile and to screen
    	Write-And-Log $logfilename "vCenter $vCenterServer successfully connected." $error.count "full"


##todo

Get-VM


        $stop_watch.Stop()
        $elapsed_seconds = ($stop_watch.elapsedmilliseconds)/1000
        
        #farewell message before disconnect
		Write-And-Log $logfilename "Environment was prepared" $total_errors "full"
		Write-And-Log $logfilename "Script took $("{0:N2}" -f $elapsed_seconds)s to execute, exiting." -1 "full"	
 
		#disconnect vCenter
		Disconnect-VIServer -Confirm:$false -Force:$true
	}
else {
	write-and-log $logfilename "This script requires PowerCLI 5.1 or greater to run properly." 1 "full"
}
}