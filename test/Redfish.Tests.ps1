Import-Module Huawei.iBMC.Cmdlets -Force

$session = New-iBMCRedfishSession -Address "112.93.129.9" -Username "chajian1" -Password "chajian12#$" -TrustCert
$session | Format-List
Close-iBMCRedfishSession $session
$session | Format-List

# Describe "Connect-iBMC" {
#     It "Connect with account" {
#          |
#         Should BeExactly $False
#     }
# }