$GuestCred = $Host.UI.PromptForCredential("Please enter credentials", "Enter Guest credentials for $VM", "", "")

Function Set-WinVMIP ($VM, $GC, $IP, $SNM, $GW){
 $netsh = "c:\windows\system32\netsh.exe interface ip set address ""Ethernet0"" static $IP $SNM $GW 1"
 Write-Host "Setting IP address for $VM..."
 Invoke-VMScript -VM $VM -GuestCredential $GC -ScriptType bat -ScriptText $netsh
 Write-Host "Setting IP address completed."
}

Import-Csv "C:\Users\Administrator\Documents\DeployVMs\vm_ip.csv" -UseCulture | %{
  $VM = Get-VM $_.VMname
  Set-WinVMIP $VM $GuestCred $_.IP $_.SNM $_.GW
}