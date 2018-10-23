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
      $pwd = ConvertTo-SecureString -String "pwd12#$%^" -AsPlainText -Force
      $pwd2 = ConvertTo-SecureString -String "newpwd12#$" -AsPlainText -Force
      Add-iBMCUser $session turnbig $pwd 'Administrator'
      Set-iBMCUser -Session $session -Username turnbig -NewUsername turnbig2 -NewPassword $pwd2 -NewRole 'Operator' -Enabled $false -Unlocked $true
    } finally {
      Remove-iBMCUser $session turnbig2
      Disconnect-iBMC $session
    }
  }
}

