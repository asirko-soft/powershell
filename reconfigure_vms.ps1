if ( !(Get-Module -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) ) {
 “C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1”
}


Connect-VIServer -Server 192.168.64.76 -Password P@ssw0rd -SaveCredentials -User administrator@vsphere.local -ErrorAction SilentlyContinue

$vms = Get-VM -Location "ESXI Agentless Agents"

foreach ($vm in $vms)
{
    Stop-VM -VM $vm -Confirm:$false -ErrorAction SilentlyContinue -RunAsync
    Set-VM -NumCpu 2 -MemoryGB 2 -VM $vm -Confirm:$false -ErrorAction SilentlyContinue -RunAsync
    Start-VM -VM $vm -Confirm:$false
}