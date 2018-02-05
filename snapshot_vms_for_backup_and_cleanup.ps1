$a = Get-VM -Location "CRT test"


foreach($vm in $a){
    
    New-Snapshot -Name "backup" -VM $vm
    
}




foreach($vm in Get-VM -Location "CWF_WinAgents_Pool"){
    $snap = Get-Snapshot -VM $vm | Sort-Object -Property Created -Descending | Select -First 1
    Set-VM -VM $vm -SnapShot $snap -Confirm:$false
}