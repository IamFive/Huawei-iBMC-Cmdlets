function Add-iBMCUser {
  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position=0)]
    $Session,

    [string[]]
    [parameter(Mandatory = $true, Position=1)]
    $Username,

    [SecureString[]]
    [parameter(Mandatory = $true, Position=2)]
    $Password,

    [string[]]
    [parameter(Mandatory = $true, Position=3)]
    [ValidateSet('Administrator', 'Operator', 'Commonuser', 'NoAccess', 'CustomRole1', 'CustomRole2', 'CustomRole3', 'CustomRole4')]
    $Role
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
    Assert-ArrayNotNull $Username 'Username'
    Assert-ArrayNotNull $Password 'Password'
    Assert-ArrayNotNull $Role 'Role'

    $Username = Get-MatchedSizeArray $Session $Username 'Session' 'Username'
    $Password = Get-MatchedSizeArray $Session $Password 'Session' 'Password'
    $Role = Get-MatchedSizeArray $Session $Username 'Session' 'Role'
  }

  process {
    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      $Session | ForEach-Object {
        $Command = "Test-iBMCRedfishSession"
        [Void] $tasks.Add($(Start-CommandThread $pool $Command @($_)))
      }
      return Get-AsyncTaskResults -AsyncTasks $tasks
    } finally {
      $pool.close()
    }
  }

  end {
  }
}


function Get-iBMCUser {
  [CmdletBinding()]
  param (

  )

  begin {
  }

  process {
  }

  end {
  }
}

function Set-iBMCUser {
  [CmdletBinding()]
  param (

  )

  begin {
  }

  process {
  }

  end {
  }
}

function Remove-iBMCUser {
  [CmdletBinding()]
  param (

  )

  begin {
  }

  process {
  }

  end {
  }
}