[CmdletBinding()]
Param(
  [String]$branch='release'
    )

function install.net($vm)
{
        $argumentList = @()
        $ip = $vm.Guest.IPAddress | where {([IPAddress]$_).AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork}
        $argumentList += ("-node", "`"$ip`"")
        # Install .NET 4.5.2 on agent using DSC
        Invoke-Expression  ".\DSC_Net452Install.ps1 $argumentList"
        Write-Host ".NET installed"
}
   

function rebootAgents($vmS)
{
foreach ($vm in $vmS){
if ($vm.Name -match "Agent")
    {
    
    #$ip = $vm.Guest.IPAddress | where {([IPAddress]$_).AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork}
    Restart-VMGuest $vm.Name | Wait-Tools
    Write-Host "Agent is rebooted"
    }

}
}

Function WaitForAllJobs()
{
Get-Job | Foreach {
do {
Write-Host "Waiting for " $_.name" to finish, status is "$_.JobStateInfo
Sleep 7
} until ($_.JobStateInfo.ToString() -eq "Completed")
}
}
<#function wait_for_state($ip, $state)
{
        while ([bool](Test-Connection -ComputerName $ip -ErrorVariable Er -Count 1) -ne $state -and [bool]$Er -eq $state)
        {
        Clear-Variable Er -ErrorAction SilentlyContinue
        if ($state -eq $false) 
        {        
        Write-Host $ip  "Waiting for machine to go offline"
        }
        else
        {
        Write-Host $ip  "Waiting for machine to become online"
        }
        Start-Sleep -Seconds 1
        }

}#>



#<waiting for VMs to become online
<#$environment_vms | Foreach {
do {
$VM = Get-VM $_
$Toolsstatus = $VM.ExtensionData.Guest.ToolsRunningStatus
Write-Host "Waiting for $VM to start, tools status is $Toolsstatus"
Sleep 7
} until ($Toolsstatus -eq "guestToolsRunning")
}#>

function install_product($VMNAME, $IPP, $cred)
{
 
 if ($VMNAME -match "Core")
        {
                       
        $session = New-PSSession -ComputerName $IPP -Credential $cred
        Invoke-Command -Session $session -ScriptBlock {
        Start-Process C:\Downloads\Core*.exe -ArgumentList "/silent privacypolicy=accept" -Wait      
    } -AsJob -JobName $VMNAME
    }
      

    
 if ($VMNAME -match "Agent")
        {
        $session = New-PSSession -ComputerName $IPP -Credential $cred
        Invoke-Command -Session $session -ScriptBlock {
        Start-Process C:\Downloads\Agent-X64*.exe -ArgumentList "/silent privacypolicy=accept" -Wait      
    } -AsJob -JobName $VMNAME
    }
    

}


function CheckInstalledPrograms($vmS)
{
foreach ($vm in $vmS){
    $ip = $ipList[$vmS.IndexOf($vm)]
    if($product = Get-WmiObject -Class Win32_Product -ComputerName $ip -Credential $cred | where {$_.name -match "AppRecovery"})
    {
    Write-Host $product.name "Installed on "$vm.Name
    }
    else
    {
    Write-Host "There are no product on "$vm.Name
    }
    }

}

$ipList = @()
ipmo VMware.VimAutomation.Core -ErrorAction SilentlyContinue
Connect-VIServer -Server 192.168.64.76 -Password P@ssw0rd -SaveCredentials -User administrator@vsphere.local -ErrorAction SilentlyContinue

$environment_vms = Get-VM -Location retest -Name asirko*
#revert vm to clean state
foreach ($vm in $environment_vms)
{
    $snap = Get-Snapshot -VM $vm -Name "clean"
    Set-VM -VM $vm -Snapshot $snap -Confirm:$false | Out-Null
    Write-Host $vm.Name "is reverting to clean state"
}

#power on VMs
foreach ($vm in $environment_vms)
{
    Write-Host "Starting" $vm
    Start-VM -VM $vm -Confirm:$false -RunAsync | Out-Null
}

#waiting for VMs to become online
$environment_vms | Foreach {
do {
$VM = Get-VM $_
$Toolsstatus = $VM.ExtensionData.Guest.ToolsRunningStatus
Write-Host "Waiting for $VM to start, tools status is $Toolsstatus"
Sleep 7
} until ($Toolsstatus -eq "guestToolsRunning")
}

#getting VM guest IPv4 addresses and verifying connectivity:

for ($i = 0; $i –lt $environment_vms.Count; $i++) {

    $ipList += ($environment_vms[$i].Guest.IPAddress | where {([IPAddress]$_).AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork} )
}

foreach ($vm in $environment_vms)
{
    
    $ip = $ipList[$environment_vms.IndexOf($vm)]
    
    if ((Test-Connection -ComputerName $ip))
    {
        Write-Host $vm "has IP address" $ip "and is online"
    }
    if ([bool](Test-WSMan -ComputerName $ip -ErrorAction SilentlyContinue))
    {
       Write-Host $vm "has WinRM service running"
    }
    else
    {
        Write-Host $vm "doesn't have WinRM service running"
    }

}

#preparing credentials to connect to VM guest OS
$passwd = convertto-securestring -AsPlainText -Force -String raid4us!

$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist "administrator",$passwd

#Open remote session to VM guest OS


$destination = "C:\Downloads"


<# foreach ($vm in $environment_vms){
    $ip = $ipList[$environment_vms.IndexOf($vm)]
    $session = New-PSSession -ComputerName $ip -Credential $cred

    Invoke-Command -Session $session -ScriptBlock {
    $ar = new-object -ComObject WScript.Network
    $ar.MapNetworkDrive("Y:", "\\192.168.64.127\Share\Builds", "false", "administrator", "raid4us!")
    $path = (Get-ChildItem "Y:\" -Filter "6.1.0.*" | % { $_.fullname } | Sort-Object -Descending)| Select -First 1
    $buildnumber = $path | Split-Path -Leaf
    
    $orig_path = [io.path]::Combine($path, 'Agent-X64-'+$buildnumber+ ".exe")
    Write-Host $orig_path
    $final_destination = [io.path]::Combine("C:\Downloads", 'Agent-X64-'+$buildnumber+ ".exe")
    Write-Host $final_destination
    Copy-Item -Path $orig_path -Destination $final_destination -Force 
    
    }} #>



foreach ($vm in $environment_vms){
    $ip = $ipList[$environment_vms.IndexOf($vm)]
    $session = New-PSSession -ComputerName $ip -Credential $cred

    $scriptblock = {
    
    $ar = new-object -ComObject WScript.Network

    try
    {
    $ar.MapNetworkDrive("X:", "\\192.168.64.127\Share\Builds", "false", "administrator", "raid4us!")
   
    if (!(Test-Path $args[0]))
    {
        mkdir $args[0] -Force
    }
    if ($args[1] -eq 'release'){
    Write-Host $args[1]
    $path = (Get-ChildItem "X:\" -Filter "7.0.0.*" | % { $_.fullname } | Sort-Object -Descending)| Select -First 1
    Write-Host $path
    $buildnumber = $path | Split-Path -Leaf
    Write-Host $buildnumber   
    
    }
    if ($args[1] -eq 'develop'){
    $path = (Get-ChildItem "X:\" -Filter "7.1.0.*" | % { $_.fullname } | Sort-Object -Descending)| Select -First 1
    $buildnumber = $path | Split-Path -Leaf
    Write-Host $path
    }

    if ($args[2].Name -match "Agent"){
    $orig_path = [io.path]::Combine($path, 'Agent-X64-'+$buildnumber+ ".exe")
    Write-Host $orig_path
    $final_destination = [io.path]::Combine($args[0], 'Agent-X64-'+$buildnumber+ ".exe")
    Write-Host $final_destination
    Copy-Item -Path $orig_path -Destination $final_destination -Force 
    }

    if ($args[2].Name -match "Core"){
    $orig_path = [io.path]::Combine($path, 'Core-X64-'+$buildnumber+ ".exe")
    Write-Host $orig_path
    $final_destination = [io.path]::Combine($args[0], 'Core-X64-'+$buildnumber+ ".exe")
    Write-Host $final_destination
    Copy-Item -Path $orig_path -Destination $final_destination -Force 
    }
        
    }
    catch
    {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Write-Host $ErrorMessage
    Write-Host $FailedItem+"ololo"
    }
}

    Invoke-Command -Session $session -ScriptBlock $scriptblock -ArgumentList $destination, $branch, $vm
   
}

 
<#
foreach ($vm in $environment_vms){
    $ip = $ipList[$environment_vms.IndexOf($vm)]
    if ($vm.Name -match "Core")
    {
        $session = New-PSSession -ComputerName $ip -Credential $cred
        Invoke-Command -Session $session -ScriptBlock {
        Start-Process C:\Downloads\6.1.0.*\Core*.exe -ArgumentList "/silent" -Wait      
    } -AsJob -JobName $vm.Name
    }
    # $session = New-PSSession -ComputerName $ip -Credential $cred
    if ($vm.Name -match "Agent")
    {
        # set location to directory where scripts are located
        Set-Location C:\Users\Administrator\Documents\powershell
        # prepare list of arguments to pass to Invoke-Expression
        $argumentList = @()
        $argumentList += ("-node", "`"$ip`"")
        # Install .NET 4.5.2 on agent using DSC
        Invoke-Expression  ".\DSC_Net452Install.ps1 $argumentList" 
        # Installation will succeed but we need to wait for machine to come back online. Let's sleep for 150 seconds
        
        while ((Test-Connection -ComputerName $ip) -eq $true)
        {
        Write-Host $vm "has IP address" $ip "and is online"

        Start-Sleep -Seconds 5
        }
        while ((Test-Connection -ComputerName $ip) -eq $false)
        {
        Write-Host $vm "has IP address" $ip "and is offline"

        Start-Sleep -Seconds 5
        }
        #install Agent silently but don't reboot
        $session = New-PSSession -ComputerName $ip -Credential $cred
        Invoke-Command -Session $session -ScriptBlock {
        Start-Process C:\Downloads\6.1.0.*\Agent-X64*.exe  -ArgumentList "/silent reboot=never" -Wait
        
    } -AsJob -JobName $vm.Name
     Restart-Computer -ComputerName $ip -Force -Wait        
    }
}   #> 

Set-Location C:\Users\Administrator\Documents\powershell

foreach ($vm in $environment_vms){
    $ip = $ipList[$environment_vms.IndexOf($vm)]
     if ($vm.Name -match "Agent")
    {
    install.net -vm $vm
    Restart-VMGuest $vm
    Write-Host “Waiting for VM Tools to Stop on $VM”
    do {
    Set-Variable -name ToolsStatus -Value (Get-VM $VM).extensiondata.Guest.ToolsRunningStatus
    Write-Host $toolsStatus
    sleep 1
    }
    until ($toolsStatus -eq ‘guestToolsNotRunning’)
    Write-Host “Waiting for VM Tools to Start on $VM”
    do {
    Set-Variable -name ToolsStatus -Value (Get-VM $VM).extensiondata.Guest.ToolsRunningStatus
    Write-Host $toolsStatus
    sleep 3
    }
    until ($toolsStatus -eq ‘guestToolsRunning’)
    Write-Host "VM rebooted"
    install_product -VMNAME $vm.Name -IPP $ip -cred $cred
    # 
    }
     if ($Vm.Name -match "Core")
    {
    install_product -VMNAME $vm.Name -IPP $ip -cred $cred
    }
    }
    WaitForAllJobs
    CheckInstalledPrograms -vmS $environment_vms
    # license Core with QA license and restart core service

    foreach ($vm in $environment_vms){
    if ($Vm.Name -match "Core"){
    $key="xVv0DcWCfnm7yJ/JTuYxzUHoEJxGSFCFNF281/DRSSjI4g4CR58SWjNSMt2wCfqboiIxLh38Q9XHYNI2i3bZ2avLGNN/sRrtViZZ8qZ1T68hIBigZgR4lH1yYnoKSHQsR4qUqXMohC/gUDFStbx0gh5GV1Kp5fnNXcgvlnmnbkoxViDhN7g8EqOWXpSEln/Di9/g2uQJPV5PetEn7rIardsSYzl27uYKa9vGML2bej7arFkUaCaY+zim7Lvc9WBc66Hgca4hyBhwbtvMBHA+1jzPbpP+nEbipI6UBiGy5b2XRfjqgyJkUKeSQbdC4KVSppXaSHE+tObUh4fSDDDmapRfNRdfu8Bc81ugC8vJhycfHeQ27HfMlcgiERWbkDDw4xWVRhqlpNLqRkJgxWYSid7AvtbsPJfKNPGvl5lzvMh0EWv8/dxGsUELLM1VLbLsUcNDSUvXln4zKkhgXm7QBE6eXIxHSd5ZpVEvKppZWjndvBAHl2O0owtZickspx3v70rcqt7nEJ8ZmFFDY0Pfe4IRL1e+a4dlkivWvNgLsAbNvnLECPtAtmBaNY38puJdZjAxZ8DC34cvLzprErPkZo1k5GPw1SYGGEhQkRBkbEJjXK0dFb7ITWSM4YStmE3u4Hj9i8NZeMMB0F2RPu5Imd2Ig0ZR2qHdfrC4P9o8WmQnu5fSrjPxcdfusaTBEAhRyfgf+8XX+c54GNTj3U/JuNQXU57jB+nzn90uCeh3TvVAZr0KBvPmiykdZQy6AQ2SRaiq2lcUzNEvSDwPX/MsxQ2+ka2OTkFLTMa9R+prRFYKQicYIGpSsdx4MTxm7ELFxm6xyj7v2XtUDhggRe1ULigE2YQw3Guz40y5R18RIKbttIW30nMtyObbI506jpwEdLY2YBwwb947knCNEPrWQiPiC9tPvRtL8tHo+SgeaWy2FriCZNYRvuT6R2H0v2R277KJEzx3UR3JQH3HyOnTPCACXlPi5G9PIMukJO24iutnBI4BiiyL4S0vgyMIQiIVLmtPjb1Zxg6FFGW8pDhif3sa/eJHLL8KSLIV6yR7raIVV2/uwaNqR0KSCXAKpDzAV31PzAy4Qm47UZ43HuusXXRS++E1RisBTKy3MNtBDTCZcDCvhYdG30vDbwB8dxW6BUKTd0XNsHGe/bVJfB6uvjCi5TB5/9235K/ZYcRRCpZgHVsIgs+mFZVu141yO1EcUXY2QTt0VaKU0A9Vuh37hb/MRXzLpbZmtx2+3sFl0iuZzHyypxV1T3TPKf1Ks95hAw4g2pIr31NmqYxfObT0PsjNtCRS5Hl/KarZo559jux1rQM9T+BUrPS2OtP0N9MwOF6ibp8YnuQioAs2lNeOSx/1j5PaHbeusppGyTwtLGx/9xhUEo7fZh/XuOZlcj8xZbj/m3lYsTz/k5N9/QoqX50iVv8BwPfNy9voLZN+lUzfMKaHgJ4k6MApm+PM3HcGx0MKlbTp2oxkHwobByjsU8ZHdvss5Ju4qPhrjS+p0Dh10bZ/LZvo6O1cF/LBPE3sMX2aWy3QhG6iapIopFuo0kN2iDZZWpmifa5uz7HVwWzT7oZTiUEDJXkBfLfKPiy0IBEjWy1WGxOJJNtSsz9n0dCpFshQbYDt5+yZgY0+9cgmg52OUDx0ReZH1tdljufvf/pYGRdaSUC/GRxgNexnmKSIiBiXfd36OrR8R60SvE4Dc4uZg+wmOGtDKeoNhOt5gfaC79cxXvlJsQlQqh46tEK0VejJ/PMOVhjyv1vmTlk="
    $setkey =  "Set-ItemProperty -Path HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\AppRecovery\Core\LicenseInfo -Name GroupKey -Value $key"
    Invoke-VMScript -VM $vm -GuestUser "administrator" -GuestPassword "raid4us!" -ScriptText $setkey
    $restartservice = "Restart-Service RapidRecoveryCore"
    Invoke-VMScript -VM $vm -GuestUser "administrator" -GuestPassword "raid4us!" -ScriptText $restartservice
    }
    
    }
    
    rebootAgents -vmS $environment_vms
    Get-Job | Remove-Job -Force