param(
$node = 'localhost'
)

Configuration RRAgentInstall
{
    Node $node
     {
         Package RRAgentInstall
         {
             Ensure = 'Present'
             Name = 'Rapid Recovery Agent'
             Path = 'C:\Downloads\6.1.0.391\Agent-X64-6.1.0.391.exe'
             ProductId = '82556F7B-51A3-45D8-8B9D-7C85B2B7B8C4'
             Arguments = "/silent reboot=never" # args for silent mode
         }
     }
}

RRAgentInstall -OutputPath $env:SystemDrive:\DSCconfig
Set-DscLocalConfigurationManager -ComputerName $node -Path $env:SystemDrive\DSCconfig -Verbose
Start-DscConfiguration -ComputerName $node -Path $env:SystemDrive:\DSCconfig -Verbose -Wait -Force