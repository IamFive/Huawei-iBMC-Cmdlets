Import-Module Huawei-iBMC-Cmdlets -Force

Describe "Virtual Media features" {
  It "Get" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert
      $Medias = Get-iBMCVirtualMedia $session

      $Medias -is [Array] | Should -Be $true
      $Medias[0] -is [psobject] | Should -Be $true
      $Medias[1] -is [psobject] | Should -Be $true
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

      $Tasks -is [Array] | Should -Be $true
      $Tasks[0] -is [psobject] | Should -Be $true
      $Tasks[1] -is [psobject] | Should -Be $true
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

      $Tasks -is [Array] | Should -Be $true
      $Tasks[0] -is [psobject] | Should -Be $true
      $Tasks[1] -is [psobject] | Should -Be $true
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
      $OriginalSeq -is [Array] | Should -Be $true
      $OriginalSeq[0] -is [Array] | Should -Be $true
      $OriginalSeq[1] -is [Array] | Should -Be $true
      $OriginalSeq[0].Count | Should -Be 4
      $OriginalSeq[1].Count | Should -Be 4

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
      $BootSource -is [Array] | Should -Be $true
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

