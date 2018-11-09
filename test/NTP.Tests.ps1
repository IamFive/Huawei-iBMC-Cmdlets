Import-Module Huawei-iBMC-Cmdlets -Force

Describe "NTP Settings" {
  It "get" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Get-iBMCNTPSetting $session
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "set" {
    try {
      $session = Connect-iBMC -Address "112.93.129.9,96" -Username chajian -Password "chajian12#$" -TrustCert
      Set-iBMCNTPSetting $session -ServiceEnabled $true -PreferredNtpServer 'pre.huawei.com' `
        -AlternateNtpServer 'alt.huawei.com' -NtpAddressOrigin Static -ServerAuthenticationEnabled $false `
        -MinPollingInterval 10 -MaxPollingInterval 12
    }
    finally {
        Disconnect-iBMC $session
    }
  }


  It "import group key" {
    try {
      $session = Connect-iBMC -Address "112.93.129.9,96" -Username chajian -Password "chajian12#$" -TrustCert
      $KeyValue = "# ntpkey_RSA-MD5cert_VM-1-2-ubuntu.3750727345
      # Fri Nov  9 12:42:25 2018

      -----BEGIN CERTIFICATE-----
      MIIBQzCB7qADAgECAgTfj46xMA0GCSqGSIb3DQEBBAUAMBgxFjAUBgNVBAMMDVZN
      LTEtMi11YnVudHUwHhcNMTgxMTA5MDQ0MjI1WhcNMTkxMTA5MDQ0MjI1WjAYMRYw
      FAYDVQQDDA1WTS0xLTItdWJ1bnR1MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBANSL
      YecXr5z/a3LCXwpWUYh88DdeGRBrg+CZG5oCYzQ0GwKQdZA9Oq2RA2XfyLp4aFnF
      E6EggWv9xurNs9fnLo8CAwEAAaMgMB4wDwYDVR0TAQH/BAUwAwEB/zALBgNVHQ8E
      BAMCAoQwDQYJKoZIhvcNAQEEBQADQQAJ2BavvBu2KYvfn62m5cZeyriMVGVVcYXr
      vk0gQDh6rOBR7Ba7tjm+38Cxmdf3shL1yE6IUkNbYqc/PiGUy8Li
      -----END CERTIFICATE-----"
      Upload-iBMCNTPGroupKey $session -KeyValueType Text -KeyValue $KeyValue
    }
    finally {
        Disconnect-iBMC $session
    }
  }

}