$server = "192.168.93.60"
$rps= Get-RecoveryPoints -ProtectedServer $server -Number all
$idx = $rps.Count
$failures = @()
Clear-Content C:\Log.txt
$failures.Clear()
foreach ($rp in $rps)
{
    $path = "C:\ProgramData\AppRecovery\MountPoints"
    $mount = New-Mount -ProtectedServer $server -MountType read -Path (Join-Path -Path $path -Childpath $rp.Number) -Volumes "C:" -Rpn $idx -ShowProgress
    
    if ($mount -eq $null)
    {
          "Mount of RP "+ $rp.DateTimestamp + " was succesfull, dismounting" | Out-Host
          #Start-Sleep -Seconds 1
          Remove-Mount -protectedserver $server
          "Mount of RP "+ $rp.DateTimestamp + " was succesfull" | Out-File -FilePath C:\Log.txt -Append
          
    }
    else
    { 
        "Mount of RP  "+ $rp.DateTimestamp + " was NOT succesfull, dismounting" | Out-Host
        "Exception message is "+$mount.Exception.Message | Out-Host
        $failures+= $rp
        #Start-Sleep -Seconds 1
        Remove-Mount -protectedserver $server
        "Mount of RP  "+ $rp.DateTimestamp + " was NOT succesfull" | Out-File -FilePath C:\Log.txt -Append
    }
    $idx--
}

$first_failing_rp = $failures | Select-Object -Last 1
Write-Host "First failing RP number is "+ $first_failing_rp.Number + "and date is "$first_failing_rp.DateTimestamp