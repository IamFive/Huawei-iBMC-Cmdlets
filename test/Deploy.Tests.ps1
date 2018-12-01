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
      $OriginalSeq[0] -is [array] | Should -BeTrue
      $OriginalSeq[1] -is [array] | Should -BeTrue
      $OriginalSeq[0]| Should -HaveCount 4
      $OriginalSeq[1]| Should -HaveCount 4

      $sequence = ,@('Cd', 'Pxe', 'HDD', 'Others')
      Set-iBMCBootupSequence $session $sequence

      Set-iBMCBootupSequence $session $OriginalSeq
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
      $BootSourceOverrideTargets = @("None", "Pxe", "Floppy", "Cd", "Hdd", "BiosSetup")
      $BootSource[0] -in $BootSourceOverrideTargets | Should -Be $true
      $BootSource[1] -in $BootSourceOverrideTargets | Should -Be $true

      Set-iBMCBootSourceOverride $session @('Hdd', 'Floppy')
      $BootSource2 = Get-iBMCBootSourceOverride $session
      $BootSource2 | Should -Be @('Hdd', 'Floppy')

      Set-iBMCBootSourceOverride $session $BootSource
    }
    finally {
      Disconnect-iBMC $session
    }
  }
}

