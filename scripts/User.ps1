function Add-iBMCUser {
<#
.SYNOPSIS
Add a new iBMC user account.

.DESCRIPTION
Add a new iBMC user account. The session user must have privilege to add new user.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.PARAMETER Username
Username specifies the new username to be added.
A string of 1 to 16 characters is allowed. It can contain letters, digits, and special characters (excluding <>&,'"/\%), but cannot contain spaces or start with a number sign (#).

.PARAMETER Password
Password specifies the password of this new add user.
A string of 1 to 20 characters is allowed.
- If password complexity check is enabled for other interfaces, the password must meet password complexity requirements.
- If password complexity check is not enabled for other interfaces, there is not restriction on the password

.PARAMETER Role
Role specifies the role of this new add user.
Available role value set is:
- "Administrator"
- "Operator"
- "Commonuser"
- "Noaccess"
- "CustomRole1"
- "CustomRole2"
- "CustomRole3"
- "CustomRole4"

.OUTPUTS
PSObject[]
Returns the new created User object array.

.EXAMPLE
PS C:\> $sessions = Connect-iBMC -Address 10.1.1.2 -Username root -Password password
PS C:\> $sessions



.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

#>
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
      param($Session, $Username, $SecurePasswd, $Role)
      $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePasswd)
      $PlainPasswd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
      $payload = @{
        'UserName' = "$Username";
        'Password' = "$PlainPasswd";
        'RoleId' = "$Role";
      }
      $response = Invoke-RedfishRequest $Session '/AccountService/Accounts' 'Post' $payload
      # $response = Invoke-RedfishRequest $Session '/AccountService/Accounts' 'Post' $payload -ContinueEvenFailed
      return $response | ConvertFrom-WebResponse
    }
    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx=0; $idx -lt $Session.Count; $idx++) {
        $Parameters = @($Session[$idx], $Username[$idx], $Password[$idx], $Role[$idx])
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $AddUserBlock $Parameters))
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
    $NewUsernames = Get-OptionalMatchedSizeArray $Session $NewUsername
    $NewPasswords = Get-OptionalMatchedSizeArray $Session $NewPassword
    $NewRoles = Get-OptionalMatchedSizeArray $Session $NewRole
    $Enableds = Get-OptionalMatchedSizeArray $Session $Enabled
    $Lockeds = Get-OptionalMatchedSizeArray $Session $Locked
  }

  process {
    $SetUserBlock = {
      param($Session, $Username, $Payload)
      # try load all users
      $Users = Invoke-RedfishRequest $Session '/AccountService/Accounts' | ConvertFrom-WebResponse
      $found = $false
      for ($idx=0; $idx -lt $Users.Members.Count; $idx++) {
        $member = $Users.Members[$idx]
        $UserResponse = Invoke-RedfishRequest $session $member.'@odata.id'
        $User = $UserResponse | ConvertFrom-WebResponse
        if ($User.UserName -eq $Username) {
          $found = $true
          # Update user with provided $Username
          Write-Log "User $($User.UserName) found, will patch user now"
          $Headers = @{'If-Match'=$UserResponse.Headers['Etag'];}
          Write-Log "User Etag is $($UserResponse.Headers['Etag'])"
          if ('Password' -in $Payload) {
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Payload.Password)
            $PlainPasswd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            $Payload.Password = $PlainPasswd
          }
          return Invoke-RedfishRequest $Session $member.'@odata.id' 'Patch' $Payload $Headers
        }
      }

      if (-not $found) {
        throw $([string]::Format($(Get-i18n FAIL_NO_USER_WITH_NAME_EXISTS), $Username))
      }
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx=0; $idx -lt $Session.Count; $idx++) {
        $Payload = Remove-EmptyValues @{
          "UserName"= $NewUsernames[$idx];
          "Password"= $NewPasswords[$idx];
          "RoleId"= $NewRoles[$idx];
          "Locked"= $Lockeds[$idx];
          "Enabled"= $Enableds[$idx];
        }

        if ($null -eq $Payload -or $Payload.Keys.Count -eq 0) {
          throw $(Get-i18n FAIL_NO_UPDATE_PARAMETER)
        } else {
          $Parameters = @($Session[$idx], $Username[$idx], $Payload)
          [Void] $tasks.Add($(Start-ScriptBlockThread $pool $SetUserBlock $Parameters))
        }
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
      $success = $false
      for ($idx=0; $idx -lt $Users.Members.Count; $idx++) {
        $member = $Users.Members[$idx]
        $user = Invoke-RedfishRequest $session $member.'@odata.id' | ConvertFrom-WebResponse
        if ($user.UserName -eq $Username) {
          # delete user with provided $Username
          Invoke-RedfishRequest $Session $member.'@odata.id' 'Delete' | Out-null
          $success = $true
        }
      }

      if (-not $success) {
        throw $([string]::Format($(Get-i18n FAIL_NO_USER_WITH_NAME_EXISTS), $Username))
      }
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