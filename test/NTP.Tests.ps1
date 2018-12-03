Import-Module Huawei-iBMC-Cmdlets -Force

Describe "NTP Settings" {

  It "workflow" {
    try {
      $session = Connect-iBMC -Address 112.93.129.98,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert
      $SettingResult =  Set-iBMCNTPSetting $session -ServiceEnabled $true -PreferredNtpServer 'pre.huawei.com' `
        -AlternateNtpServer 'alt.huawei.com' -NtpAddressOrigin Static -ServerAuthenticationEnabled $false `
        -MinPollingInterval 10 -MaxPollingInterval 12

      $SettingResult -is [array] | Should -BeTrue
      $SettingResult | Should -Be @($null, $null)
      $SettingResult | Should -HaveCount 2

      $Settings = Get-iBMCNTPSetting $session
      $Settings -is [array] | Should -BeTrue
      $Settings | Should -HaveCount 2
      $Settings | Should -BeOfType 'PSObject'

      $Settings.ServiceEnabled | Should -Be @($true, $true)
      $Settings.PreferredNtpServer | Should -Be @('pre.huawei.com', 'pre.huawei.com')
      $Settings.AlternateNtpServer | Should -Be @('alt.huawei.com', 'alt.huawei.com')
      $Settings.NtpAddressOrigin | Should -Be @('Static', 'Static')
      $Settings.ServerAuthenticationEnabled | Should -Be @($false, $false)
      $Settings.MinPollingInterval | Should -Be @(10, 10)
      $Settings.MaxPollingInterval | Should -Be @(12, 12)
    }
    finally {
      Disconnect-iBMC $session
    }
  }
}

Describe "NTP Group Key" {

  It "import" {
    try {
      $session = Connect-iBMC -Address "112.93.129.98,96" -Username chajian -Password "chajian12#$" -TrustCert
      $KeyValue = @"
# ntpkey_MD5key_VM-1-2-ubuntu.3752794009
# Mon Dec  3 10:46:49 2018

  1 MD5 )ejq^^EI$~`2os?+Gj5*  # MD5 key
  2 MD5 TDrpd79)/"@*Qxy((K$Q  # MD5 key
  3 MD5 U-O(ir=NkDV30pvGy1>S  # MD5 key
  4 MD5 IL*$Sn1b[Mhj57N4`bqI  # MD5 key
  5 MD5 Jx4,y8/Lf?QY}8?"mg1o  # MD5 key
  6 MD5 Ya%G-$dc{C,T1G~3(!0v  # MD5 key
  7 MD5 !BbD\YsK,:uW)^f.}7(+  # MD5 key
  8 MD5 7V5.HZe-fA1@U(rWI(YH  # MD5 key
  9 MD5 [ZF_`zu|*;`,yz{I3{z)  # MD5 key
10 MD5 ~f,vs*6qr"%wPRG):j6(  # MD5 key
11 SHA1 c5f0317fe7ae64043aa2c7982f8d861fa546937b  # SHA1 key
12 SHA1 d654d56d9aad939f11f1a1219414f6c093391e9e  # SHA1 key
13 SHA1 2cbeadcdc712ac3f901d2ef7fac8254a311daa67  # SHA1 key
14 SHA1 16eb17a7b70e137cb5ab36fc5a8558b3d9d4dda9  # SHA1 key
15 SHA1 f7c88681548defc5bf4bd8c4bd356834ca730d7a  # SHA1 key
16 SHA1 df86b579d559fef666a455546bada90a6fdc1f7a  # SHA1 key
17 SHA1 4d3ecc46fb58f98cf143ebca7e09c78cd65ccf2a  # SHA1 key
18 SHA1 cbd9d8e5d92e114c6cd8ec769da2e7bc37b763e4  # SHA1 key
19 SHA1 779c815e87508078f08a7ada6396905636ae92f1  # SHA1 key
20 SHA1 613bc0263c5967093fa8681c8e18cab9479c3416  # SHA1 key
"@
      Import-iBMCNTPGroupKey $session -KeyValueType Text -KeyValue $KeyValue
    }
    finally {
        Disconnect-iBMC $session
    }
  }
}