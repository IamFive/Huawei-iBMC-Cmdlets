Import-Module Huawei.iBMC.Cmdlets -Force

# Describe "User features" {
#   It "add user " {
#     $session = Connect-iBMC -Address 112.93.129.9 -Username chajian1 -Password "chajian12#$" -TrustCert

#     $pwd = ConvertTo-SecureString -String "chajian12#$" -AsPlainText -Force
#     Add-iBMCUser $session 'qianbiao' $pwd 'Administrator'

#     Disconnect-iBMC $session
#   }
# }

Describe "User features" {
  It "User Feature Workflow" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian1,chajian -Password "chajian12#$" -TrustCert
      $pwd = ConvertTo-SecureString -String "pwd12#$%^" -AsPlainText -Force

      Write-Host "Add ibmc user now"
      Add-iBMCUser -Session $session -Username powershell -Password $pwd -Role Operator

      Start-Sleep -Seconds 5
      Write-Host "Set ibmc user now"
      Set-iBMCUser -Session $session -Username powershell -NewUsername powershell2

    } finally {
        Start-Sleep -Seconds 5
        Write-Host "Remove ibmc user now"
        Remove-iBMCUser -Session $session -Username powershell2
        Remove-iBMCUser -Session $session -Username powershell
        Disconnect-iBMC $session
    }
  }
}

