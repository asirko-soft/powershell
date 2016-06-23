Connect-VIServer -Server 192.168.65.38
$licenseDataManager = Get-LicenseDataManager
$hostContainer = Get-Folder -Name R630 # here you can select any conatiner like DataCenter, Folder etc
$licenseData = New-Object VMware.VimAutomation.License.Types.LicenseData
$licenseKeyEntry = New-Object Vmware.VimAutomation.License.Types.LicenseKeyEntry
$licenseKeyEntry.TypeId = "vmware-vsphere"
$licenseKeyEntry.LicenseKey = "" ## put license key here
$licenseData.LicenseKeys += $licenseKeyEntry
$licenseDataManager.UpdateAssociatedLicenseData($hostContainer.Uid, $licenseData)
$licenseDataManager.QueryAssociatedLicenseData($hostContainer.Uid)

## now you may add hosts to container (folder named R630 in my case