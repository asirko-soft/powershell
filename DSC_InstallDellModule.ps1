param(
$node = 'localhost'
)

Configuration InstallDellModule
{
    Node "localhost"
    {
        File DirectoryCopy
        {
            Ensure = "Present"  # You can also set Ensure to "Absent"
            Type = "Directory" # Default is "File".
            Recurse = $true # Ensure presence of subdirectories, too
            SourcePath = "\\192.168.64.127\share\DellStoragePowerShellSDK_v3_4_1_23"            
            DestinationPath = "C:\DellStoragePowerShellSDK_v3_4_1_23"    
        }

        Log AfterDirectoryCopy
        {
            # The message below gets written to the Microsoft-Windows-Desired State Configuration/Analytic log
            Message = "Finished running the file resource with ID DirectoryCopy"
            DependsOn = "[File]DirectoryCopy" # This means run "DirectoryCopy" first.
        }
    }
}




InstallDellModule -OutputPath $env:SystemDrive:\DSCconfig
Set-DscLocalConfigurationManager -ComputerName $node -Path $env:SystemDrive\DSCconfig -Verbose
Start-DscConfiguration -ComputerName $node -Path $env:SystemDrive:\DSCconfig -Verbose -Wait -Force