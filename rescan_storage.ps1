#set the input options here as -vc and -cluster
param([string]$vc = "vc", [string]$cluster = "cluster")
 
#check to make sure we have both
if (($vc -eq "vc") -or ($cluster -eq "cluster"))
	{
	write-host `n "Rescan-Storage rescans all HBAs, then goes back and rescans VMFS for all hosts in a specific cluster" `n
	Write-host `n "Required parameters are vc and cluster" `n `n "Example: `"Rescan-Storage -vc 192.168.65.38 -cluster Compellent_Hosts`"" `n
	break
	}
 
#connect to VC
Connect-VIServer $vc
 
#get a list of physical servers in a specific cluster
$servers = get-vmhost -location $cluster |sort name

#refresh storage subsystem first
foreach ($server in $servers)
	{
	write-host "refresh storage subsystem on "$server
	get-VMHostStorage -VMHost $server -Refresh
	} 

#rescan all HBA
foreach ($server in $servers)
	{
	write-host "Scan all HBAs on "$server
	get-VMHostStorage -VMHost $server -RescanAllHba
	}
 
#go back and rescan all VMFS
foreach ($server in $servers)
	{
	write-host "Rescan VMFS on "$server
	get-VMHostStorage -VMHost $server -RescanVmfs
	}
 #80..89 | ForEach-Object { get-VMHostStorage -VMHost 192.168.64.$_ -Refresh}

#done, lets disconnect
Disconnect-VIServer -confirm:$false