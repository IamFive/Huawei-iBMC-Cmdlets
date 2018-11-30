Import-Module Huawei-iBMC-Cmdlets -Force

Describe "Virtual Media features" {
  It "Get" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Get-iBMCVirtualMedia $session
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "Connect" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Connect-iBMCVirtualMedia $session 'nfs://10.10.10.10/usr/SLE-12-Server-DVD-x86_64-GM-DVD1.ISO'
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "Disconnect" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Disconnect-iBMCVirtualMedia $session
    }
    finally {
      Disconnect-iBMC $session
    }
  }

}


Describe "Boot Sequence" {
  It "Get" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Get-iBMCBootupSequence $session
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "Set" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      $sequence = ,@('Pxe', 'HDD', 'Cd', 'Others')
      Set-iBMCBootupSequence $session $sequence
    }
    finally {
      Disconnect-iBMC $session
    }
  }

}

Describe "Boot Override" {
  It "Get" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Get-iBMCBootSourceOverride $session
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "Set" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Set-iBMCBootSourceOverride $session 'Pxe'
    }
    finally {
      Disconnect-iBMC $session
    }
  }
}

