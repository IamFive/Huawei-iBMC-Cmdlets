Import-Module Huawei-iBMC-Cmdlets -Force

Describe "User Module" {
  It "User Feature Workflow" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian,chajian -Password "chajian12#$" -TrustCert
      $pwd = ConvertTo-SecureString -String "pwd12#$%^" -AsPlainText -Force

      Remove-iBMCUser -Session $session -Username powershell,powershell | Out-Null
      $Add = Add-iBMCUser -Session $session -Username powershell,powershell -Password $pwd,$pwd -Role Operator,Administrator
      $Add -is [Array] | Should -Be $true
      $Add[0] -is [psobject] | Should -Be $true
      $Add[1] -is [psobject] | Should -Be $true
      $Add.UserName  | Should -Be @('powershell', 'powershell')
      $Add.RoleId  | Should -Be @('Operator', 'Administrator')


      $Set = Set-iBMCUser -Session $session -Username powershell,powershell -NewUsername powershell2 -Unlocked $true
      $Set -is [Array] | Should -Be $true
      $Set.UserName | Should -Be @('powershell2', 'powershell2')
      $Set.Locked | Should -Be @($false, $false)

    } finally {
        Remove-iBMCUser -Session $session -Username powershell2
        Disconnect-iBMC $session
    }
  }

  It "User Get" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian,chajian -Password "chajian12#$" -TrustCert
      $pwd = ConvertTo-SecureString -String "pwd12#$%^" -AsPlainText -Force

      Remove-iBMCUser -Session $session -Username powershell2 | Out-Null
      Remove-iBMCUser -Session $session -Username powershell | Out-Null

      $UsersList = Get-iBMCUser -Session $session
      $UsersList -is [Array] | Should -Be $true
      $UsersList.Count | Should -Be 2
      $UsersList[0] -is [Array] | Should -Be $true
      $UsersList[1] -is [Array] | Should -Be $true

      Add-iBMCUser -Session $session -Username powershell -Password $pwd -Role Operator

      $UsersList2 = Get-iBMCUser -Session $session
      $UsersList2 -is [Array] | Should -Be $true
      $UsersList2.Count | Should -Be 2
      $UsersList2[0] -is [Array] | Should -Be $true
      $UsersList2[1] -is [Array] | Should -Be $true

      $ExpectUserCount1 = $UsersList[0].Count + 1
      $ExpectUserCount2 = $UsersList[1].Count + 1
      $UsersList2[0].Count | Should -Be $ExpectUserCount1
      $UsersList2[1].Count | Should -Be $ExpectUserCount2
    } finally {
      Remove-iBMCUser -Session $session -Username powershell2
      Disconnect-iBMC $session
    }
  }
}

