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
    [ValidateSet("Administrator", "Operator", "Commonuser", "Noaccess", "CustomRole1", "CustomRole2", "CustomRole3", "CustomRole4")]
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
        'Password' = $pwd;
        'RoleId' = $Role;
      } | ConvertTo-Json
      $response = Invoke-RedfishRequest $Session '/AccountService/Accounts' 'Post' $payload
      # $response = Invoke-RedfishRequest $Session '/AccountService/Accounts' 'Post' $payload -ContinueEvenFailed
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
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position=0)]
    $Session
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
  }

  process {
    $GetUserBlock = {
      param($Session)
      $users = New-Object System.Collections.ArrayList
      $response = Invoke-RedfishRequest $Session '/AccountService/Accounts' | ConvertFrom-WebResponse
      $response.Members | ForEach-Object {
        $userResponse = Invoke-RedfishRequest $session $_.'@odata.id'
        [Void] $users.Add($($userResponse | ConvertFrom-WebResponse))
      }
      return $users
    }
    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx=0; $idx -lt $Session.Count; $idx++) {
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $GetUserBlock @($Session[$idx])))
      }
      return Get-AsyncTaskResults -AsyncTasks $tasks
    } finally {
      $pool.close()
    }
  }

  end {
  }
}

function Set-iBMCUser {
  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position=0)]
    $Session,

    [string[]]
    [parameter(Mandatory = $true)]
    $Username,

    [string[]]
    [parameter(Mandatory = $false)]
    $NewUsername,

    [SecureString[]]
    [parameter(Mandatory = $false)]
    $NewPassword,

    [string[]]
    [parameter(Mandatory = $false)]
    [ValidateSet("Administrator", "Operator", "Commonuser", "Noaccess", "CustomRole1", "CustomRole2", "CustomRole3", "CustomRole4")]
    $NewRole,

    [Boolean[]]
    [parameter(Mandatory = $false)]
    $Enabled,

    [Switch[]]
    [parameter(Mandatory = $false)]
    $Locked
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
    Assert-ArrayNotNull $Username 'Username'
    $Username = Get-MatchedSizeArray $Session $Username 'Session' 'Username'
    $NewUsername = Get-OptionalMatchedSizeArray $Session $NewUsername 'Session' 'NewUsername'
    $NewPassword = Get-OptionalMatchedSizeArray $Session $NewPassword 'Session' 'NewPassword'
    $NewRole = Get-OptionalMatchedSizeArray $Session $NewRole 'Session' 'NewRole'
    $Enabled = Get-OptionalMatchedSizeArray $Session $Enabled 'Session' 'Enabled'
    $Locked = Get-OptionalMatchedSizeArray $Session $Locked 'Session' 'Locked'
  }

  process {
    # payload = {
    #   "UserName": args.newusername,
    #   "Password": args.newpassword,
    #   "RoleId": args.newrole,
    #   "Locked": args.locked,
    #   "Enabled": args.enabled == 'True'
    # }

    $SetUserBlock = {
      param($Session, $Username, $Payload)
      # try load all users
      $Users = Invoke-RedfishRequest $Session '/AccountService/Accounts' | ConvertFrom-WebResponse
      for ($idx=0; $idx -lt $Users.Members.Count; $idx++) {
        $member = $Users.Members[$idx]
        $User = Invoke-RedfishRequest $session $member.'@odata.id' | ConvertFrom-WebResponse
        if ($User.UserName -eq $Username) {
          # Update user with provided $Username
          Invoke-RedfishRequest $Session $member.'@odata.id' 'PUT'
        }
      }
      throw $([string]::Format($(Get-i18n FAIL_NO_USER_WITH_NAME_EXISTS), $Username))
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx=0; $idx -lt $Session.Count; $idx++) {
        $parameter = @($Session[$idx], $Username[$idx])
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $SetUserBlock $parameter))
      }
      return Get-AsyncTaskResults -AsyncTasks $tasks
    } finally {
      $pool.close()
    }
  }

  end {
  }
}

function Remove-iBMCUser {
  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position=0)]
    $Session,

    [string[]]
    [parameter(Mandatory = $true, Position=1)]
    $Username
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
    Assert-ArrayNotNull $Username 'Username'
    $Username = Get-MatchedSizeArray $Session $Username 'Session' 'Username'
  }

  process {
    $DeleteUserBlock = {
      param($Session, $Username)
      # try load all users
      $Users = Invoke-RedfishRequest $Session '/AccountService/Accounts' | ConvertFrom-WebResponse
      for ($idx=0; $idx -lt $Users.Members.Count; $idx++) {
        $member = $Users.Members[$idx]
        $user = Invoke-RedfishRequest $session $member.'@odata.id' | ConvertFrom-WebResponse
        if ($user.UserName -eq $Username) {
          # delete user with provided $Username
          Invoke-RedfishRequest $Session $member.'@odata.id' 'Delete' | Out-null
        }
      }

      throw $([string]::Format($(Get-i18n FAIL_NO_USER_WITH_NAME_EXISTS), $Username))
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx=0; $idx -lt $Session.Count; $idx++) {
        $parameter = @($Session[$idx], $Username[$idx])
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $DeleteUserBlock $parameter))
      }
      return Get-AsyncTaskResults -AsyncTasks $tasks
    } finally {
      $pool.close()
    }
  }

  end {
  }
}