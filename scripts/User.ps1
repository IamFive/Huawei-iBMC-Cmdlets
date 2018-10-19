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

    [String[]]
    [parameter(Mandatory = $true, Position=3)]
    [ValidateSet("Administrator", "Operator", "Commonuser", "NoAccess", "CustomRole1", "CustomRole2", "CustomRole3", "CustomRole4")]
    $Role
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
    Assert-ArrayNotNull $Username 'Username'
    Assert-ArrayNotNull $Password 'Password'
    Assert-ArrayNotNull $Role 'Role'

    $Username = Get-MatchedSizeArray $Session $Username 'Session' 'Username'
    $Password = Get-MatchedSizeArray $Session $Password 'Session' 'Password'
    $Role = Get-MatchedSizeArray $Session $Role 'Session' 'Role'
  }

  process {
    $AddUserBlock = {
      param($Session, $Username, $Password, $Role)
      $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
      $pwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
      $payload = @{
        'UserName' = $Username;
        'Password' = $Password;
        'RoleId' = $Role;
      } | ConvertTo-Json
      $response = Invoke-RedfishRequest $Session '/AccountService/Accounts' 'POST' $payload
      return $response | ConvertFrom-WebResponse
    }
    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx=0; $idx -lt $Session.Count; $idx++) {
        $parameter = @($Session[$idx], $Username[$idx], $Password[$idx], $Role[$idx])
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $AddUserBlock $parameter))
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