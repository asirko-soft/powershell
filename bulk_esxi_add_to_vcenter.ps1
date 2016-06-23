Connect-VIServer
20..23 | ForEach-Object { Add-VMHost 192.168.64.$_ -Location (Get-Cluster Compellent_Hosts) -User root -Password Hy8r1d@ -RunAsync -force:$true }