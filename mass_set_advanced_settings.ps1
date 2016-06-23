Clear-Host
 
if ( (Get-PSSnapin -Name 'VMware.VimAutomation.Core' -ErrorAction SilentlyContinue) -eq $null )
{
    Add-Pssnapin 'VMware.VimAutomation.Core' -ErrorAction SilentlyContinue
}
 
#===============================================================================================
 
Write-Host "Setting various Advanced settings as per this script!" -ForegroundColor Yellow
 
do {
$servername = Read-Host 'What is your vC name (FQDN)?'
}until ($servername -ne $null -and $servername -ne "")
 
Write-Host

if($global:DefaultVIServer){
Write-Host "vCenter Connection found. Disconnecting to continue..."
Disconnect-ViServer -Server * -Confirm:$False -Force
}
 
 Write-Host "Connecting to [$servername]" -ForegroundColor Yellow
 $connection = connect-viserver $servername
 if($connection.isconnected -eq "true"){Write-Host "Connected!" -ForegroundColor Green}else{Write-Host "Something Went Wrong..." -ForegroundColor Red}
 
write-Host
write-Host "StandBy .. doing stuff!" -ForegroundColor Yellow
 
$esxHosts = Get-VMHost | Where { $_.PowerState -eq "PoweredOn" -and $_.ConnectionState -eq "Connected" } | Sort Name
 
foreach($esx in $esxHosts) {
 
    Write-Host "Updating Advanced Configuration Settings on $esx"
 
    # Update Shell warning Settings
 
    Get-AdvancedSetting -Entity $esx -Name UserVars.SuppressShellWarning | Set-AdvancedSetting -Value '1' -Confirm:$false
 
 	# Update Network redundancy warning Settings
    
	Get-AdvancedSetting -Entity $esx -Name das.ignoreRedundantNetWarning | Set-AdvancedSetting -Value 'true' -Confirm:$false
 
}
 
Write-Host
 
Write-Host "Done" -ForegroundColor Green