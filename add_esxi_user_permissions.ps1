Connect-VIServer -Server 192.168.64.74 -User administrator@vsphere.local -Password "P@ssw0rd"

$servers = get-vmhost -location Compellent_Hosts |sort name

#refresh storage subsystem first
foreach ($server in $servers)
	{
	write-host "I found "$server "Trying to connect"
	} 

$account = "dcui"
$esxlist = Get-VMHost
foreach($esx in $esxlist){
    Connect-VIServer -Server $esx -User root -Password "Hy8r1d@"

    $rootFolder = Get-Folder -Name ha-folder-root
    New-VIPermission -Entity $rootFolder -Principal $account -Role admin

    Disconnect-VIServer -Confirm:$false
}