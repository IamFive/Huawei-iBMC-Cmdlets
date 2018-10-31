Import-Module Huawei-iBMC-Cmdlets -Force

Describe "Virtual Media features" {
  It "Get" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian1 -Password "chajian12#$" -TrustCert
      Get-iBMCVirtualMedia $session
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "Connect" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian1 -Password "chajian12#$" -TrustCert
      Connect-iBMCVirtualMedia $session 'nfs://10.10.10.10/usr/SLE-12-Server-DVD-x86_64-GM-DVD1.ISO'
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "Disconnect" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian1 -Password "chajian12#$" -TrustCert
      Disconnect-iBMCVirtualMedia $session
    }
    finally {
      Disconnect-iBMC $session
    }
  }

}


Describe "Boot Sequence" {
  # It "Get" {
  #   try {
  #     $session = Connect-iBMC -Address 112.93.129.9 -Username chajian1 -Password "chajian12#$" -TrustCert
  #     Get-iBMCBootupSequence $session
  #   }
  #   finally {
  #     Disconnect-iBMC $session
  #   }
  # }

  It "Set" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian1 -Password "chajian12#$" -TrustCert
      $sequence = ,@('Pxe', 'Hdd', 'Cd', 'Others')
      Set-iBMCBootupSequence $session $sequence
    }
    finally {
      Disconnect-iBMC $session
    }
  }

}

