Import-Module Huawei-iBMC-Cmdlets -Force

Describe "Virtual Media features" {
  It "Get" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert
      $Medias = Get-iBMCVirtualMedia $session

      $Medias -is [array] | Should -BeTrue
      $Medias | Should -BeOfType 'psobject'
      $Medias.Inserted  | Should -Be @($false, $false)
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "Connect" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert
      $Tasks = Connect-iBMCVirtualMedia $session 'nfs://10.10.10.10/usr/SLE-12-Server-DVD-x86_64-GM-DVD1.ISO'

      $Tasks -is [array] | Should -BeTrue
      $Tasks | Should -BeOfType 'psobject'
      $Tasks.TaskState  | Should -Be @('Exception', 'Exception')
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "Disconnect" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert
      $Tasks = Disconnect-iBMCVirtualMedia $session

      $Tasks -is [array] | Should -BeTrue
      $Tasks | Should -BeOfType 'psobject'
      $Tasks.TaskState  | Should -Be @('Completed', 'Completed')
      $Tasks.TaskStatus  | Should -Be @('OK', 'OK')
    }
    finally {
      Disconnect-iBMC $session
    }
  }
}


Describe "Boot Sequence" {

  It "workflow" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert
      $OriginalSeq = Get-iBMCBootupSequence $session
      $OriginalSeq -is [array] | Should -BeTrue
      $OriginalSeq | Should -BeOfType 'psobject'
      $OriginalSeq[0].BootupSequence | Should -HaveCount 4
      $OriginalSeq[1].BootupSequence | Should -HaveCount 4

      $sequence = ,@('Cd', 'Pxe', 'HDD', 'Others')
      Set-iBMCBootupSequence $session $sequence

      Set-iBMCBootupSequence $session @($OriginalSeq[0].BootupSequence, $OriginalSeq[1].BootupSequence)
    }
    finally {
      Disconnect-iBMC $session
    }
  }
}

Describe "Boot Override" {
  It "Workflow" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert
      $BootSource = Get-iBMCBootSourceOverride $session
      $BootSource -is [array] | Should -BeTrue
      $BootSource | Should -BeOfType 'psobject'

      $BootSourceOverrideTargets = @("None", "Pxe", "Floppy", "Cd", "Hdd", "BiosSetup")
      $BootSourceOverrideEnableds = @("Disabled", "Once", "Continuous")
      $BootSource[0].BootSourceOverrideTarget | Should -BeIn $BootSourceOverrideTargets
      $BootSource[1].BootSourceOverrideTarget | Should -BeIn $BootSourceOverrideTargets
      $BootSource[0].BootSourceOverrideEnabled | Should -BeIn $BootSourceOverrideEnableds
      $BootSource[1].BootSourceOverrideEnabled | Should -BeIn $BootSourceOverrideEnableds

      Set-iBMCBootSourceOverride $session @('Hdd', 'Floppy') @('Disabled', 'Once')
      $BootSource2 = Get-iBMCBootSourceOverride $session
      $BootSource2.BootSourceOverrideTarget | Should -Be @('Hdd', 'Floppy')
      $BootSource2.BootSourceOverrideEnabled | Should -Be @('Disabled', 'Once')

      Set-iBMCBootSourceOverride $session $BootSource.BootSourceOverrideTarget $BootSource.BootSourceOverrideEnabled
    }
    finally {
      Disconnect-iBMC $session
    }
  }
}

