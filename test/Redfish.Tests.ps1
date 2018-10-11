. "$PSScriptRoot\..\Redfish.ps1"

Connect-iBMC -Address "112.93.129.9" -Username "chajian1" -Password "chajian12#$" -TrustCert

# Describe "Connect-iBMC" {
#     It "Connect with account" {
#          |
#         Should BeExactly $False
#     }
# }