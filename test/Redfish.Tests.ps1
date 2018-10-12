Import-Module Huawei.iBMC.Cmdlets -Force

$session = New-iBMCRedfishSession -Address "112.93.129.9" -Username "chajian1" -Password "chajian12#$" -TrustCert
Write-Host "Session:"
$session | fl

Write-Host "Close Session:"
Close-iBMCRedfishSession $session

Write-Host "Test Session:"
Test-iBMCRedfishSession $session


# Describe "Connect-iBMC" {
#     It "Connect with account" {
#          |
#         Should BeExactly $False
#     }
# }