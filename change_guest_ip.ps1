$GuestCred = $Host.UI.PromptForCredential("Please enter credentials", "Enter Guest credentials for $VM", "", "")

Function Set-WinVMIP ($VM, $GC, $IP, $SNM, $GW){
 $netsh = "c:\windows\system32\netsh.exe interface ip set address ""Local Area Network"" static $IP $SNM $GW 1"
 Write-Host "Setting IP address for $VM..."
 Invoke-VMScript -VM $VM -GuestCredential $GC -ScriptType bat -ScriptText $netsh
 Write-Host "Setting IP address completed."
 Write-Host "Setting DNS for $VM..."
 $netsh1 = "c:\windows\system32\netsh.exe interface ipv4 set dnsservers ""Local Area Network"" static 10.250.240.4 primary"
 Invoke-VMScript -VM $VM -GuestCredential $GC -ScriptType bat -ScriptText $netsh1
 Write-Host "Setting DNS completed."
 Write-Host "Disabling IPv6 for $VM..."
 $netsh2 = "c:\windows\system32\netsh.exe interface teredo set state disabled"
 $netsh3 = "c:\windows\system32\netsh.exe interface ipv6 6to4 set state state=disabled undoonstop=disabled"
 $netsh4 = "c:\windows\system32\netsh.exe interface ipv6 isatap set state state=disabled"
 Invoke-VMScript -VM $VM -GuestCredential $GC -ScriptType bat -ScriptText $netsh2
 Invoke-VMScript -VM $VM -GuestCredential $GC -ScriptType bat -ScriptText $netsh3
 Invoke-VMScript -VM $VM -GuestCredential $GC -ScriptType bat -ScriptText $netsh4
 Write-Host "IPv6 disabled"
}

Import-Csv "C:\Users\Administrator\Documents\DeployVMs\vm_ip.csv" -UseCulture | %{
  $VM = Get-VM $_.VMname
  Set-WinVMIP $VM $GuestCred $_.IP $_.SNM $_.GW
}