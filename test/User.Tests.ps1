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
  It "set user " {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian1 -Password "chajian12#$" -TrustCert
      $pwd = ConvertTo-SecureString -String "chajian12#$" -AsPlainText -Force
      Add-iBMCUser $session 'qianbiao2' $pwd 'Administrator'
      Set-iBMCUser -Session $session -Username qianbiao2 -NewUsername qianbiao3
    } finally {
      Remove-iBMCUser $session qianbiao3
      Disconnect-iBMC $session
    }
  }
}

