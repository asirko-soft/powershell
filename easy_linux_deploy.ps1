# using this script and simple CSV named VMLIST.csv in format
# Name,IP
# asirko_CCR-E7-Node1,192.168.95.225
# asirko_CCR-E7-Node2,192.168.95.226
# you can deploy simple Linux VMs

if ( !(Get-Module -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) ) {
 “C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1”
}

# connect to vSphere
Connect-VIServer -Server 192.168.64.76 -Password P@ssw0rd -SaveCredentials -User administrator@vsphere.local -ErrorAction SilentlyContinue

# import CSV with VM details
$vmList = Import-Csv C:\Users\Administrator\Documents\VMList.csv


# Create the VMs, put them into array of asynchronous tasks


$deployList = @()
for ($i = 0; $i –lt $vmList.Count; $i++) {

$deployList += New-VM –Name $vmList[$i].Name –ResourcePool $vmList[$i].Pool -Location $vmList[$i].Folder -Datastore $vmList[$i].Datastore -DiskStorageFormat Thick –Template $vmList[$i].Template -RunAsync

}

# wait until the last deployment task finishes
Wait-Task -Task $deployList 

# create base Linux OS customiztion spec
$linuxspec = New-OSCustomizationSpec -Name LinuxCustomization -Domain vmware.com -DnsServer "10.250.240.4" -NamingScheme vm -OSType Linux
# now create it's clone and work with the clone
$specclone = New-OSCustomizationSpec -Spec $linuxspec -Type NonPersistent

# for each VM prepare NIC configuration and apply it to the VM
for ($i =0; $i -lt $vmList.Count; $i++) {
$ip = $vmList[$i].IP
$nicmapping = Get-OSCustomizationNicMapping -OSCustomizationSpec $specclone
$nicmapping | Set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $ip -SubnetMask "255.255.224.0" -DefaultGateway "192.168.64.3"
Set-VM -VM $vmList[$i].Name -OSCustomizationSpec $specclone -Confirm:$false
}
# cleanup
Remove-OSCustomizationSpec $specclone -Confirm:$false
Remove-OSCustomizationSpec $linuxspec -Confirm:$false
