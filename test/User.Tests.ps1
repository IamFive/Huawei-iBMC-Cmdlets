Import-Module Huawei.iBMC.Cmdlets -Force

Describe "User features" {
  It "add user " {
    $session = Connect-iBMC -Address 112.93.129.9 -Username chajian1 -Password "chajian12#$" -TrustCert

    $pwd = ConvertTo-SecureString -String "chajian12#$" -AsPlainText -Force
    Add-iBMCUser $session 'qianbiao' $pwd 'Administrator'

    Disconnect-iBMC $session
  }
}
