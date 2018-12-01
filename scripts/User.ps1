<# NOTE: iBMC User Module Cmdlets #>

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
Returns the new created User object array if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

Create a new user with name "new-user" for a single iBMC server

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> $pwd = ConvertTo-SecureString -String new-user-password -AsPlainText -Force
PS C:\> $User = Add-iBMCUser -Session $session -Username new-user -Password $pwd -Role Operator
PS C:\> $User

Id       : 12
Name     : User Account
UserName : new-user
RoleId   : Operator
Locked   : True
Enabled  : True
Oem      : @{Huawei=}

.EXAMPLE

Create a new user with name "new-user" for a single iBMC server with pipelined session

PS C:\> $session = Connect-iBMC -Address 10.10.10.2-3 -Username username -Password password -TrustCert
PS C:\> $pwd = ConvertTo-SecureString -String new-user-password -AsPlainText -Force
PS C:\> ,$session | Add-iBMCUser -Username new-user -Password $pwd -Role Operator

Id       : 12
Name     : User Account
UserName : new-user
RoleId   : Operator
Locked   : True
Enabled  : True
Oem      : @{Huawei=}

.EXAMPLE

Create a new user with name "new-user" for multiple iBMC servers with pipelined session

PS C:\> $session = Connect-iBMC -Address 10.10.10.2-3 -Username username -Password password -TrustCert
PS C:\> $pwd = ConvertTo-SecureString -String new-user-password -AsPlainText -Force
PS C:\> ,$session | Add-iBMCUser -Username new-user,new-user2 -Password $pwd,$pwd -Role Operator,Administrator

Id       : 12
Name     : User Account
UserName : new-user
RoleId   : Operator
Locked   : True
Enabled  : True
Oem      : @{Huawei=}

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Get-iBMCUser
Set-iBMCUser
Remove-iBMCUser
Connect-iBMC
Disconnect-iBMC
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

    [UserRole[]]
    [parameter(Mandatory = $true, Position=3)]
    $Role
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
    Assert-ArrayNotNull $Username 'Username'
    Assert-ArrayNotNull $Password 'Password'
    Assert-ArrayNotNull $Role 'Role'

    $UsernameList = Get-MatchedSizeArray $Session $Username 'Session' 'Username'
    $PasswordList = Get-MatchedSizeArray $Session $Password 'Session' 'Password'
    $RoleList = Get-MatchedSizeArray $Session $Role 'Session' 'Role'
  }

  process {
    $AddUserBlock = {
      param($Session, $Username, $SecurePasswd, $Role)
      $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePasswd)
      $PlainPasswd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
      $payload = @{
        'UserName' = "$Username";
        'Password' = "$PlainPasswd";
        'RoleId' = $Role;
      } | Resolve-EnumValues
      $response = Invoke-RedfishRequest $Session '/AccountService/Accounts' 'Post' $payload | ConvertFrom-WebResponse
      # $response = Invoke-RedfishRequest $Session '/AccountService/Accounts' 'Post' $payload -ContinueEvenFailed

      $Properties = @("Id", "Name", "UserName", "RoleId", "Locked", "Enabled", "Oem")
      $User = Copy-ObjectProperties $Response $Properties
      return $User
    }
    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx=0; $idx -lt $Session.Count; $idx++) {
        $Parameters = @($Session[$idx], $UsernameList[$idx], $PasswordList[$idx], $RoleList[$idx])
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
<#
.SYNOPSIS
Get all iBMC user account details

.DESCRIPTION
Get all iBMC user account information, excluding password.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.


.OUTPUTS
Array[PSObject[]]
Returns array of the user object array if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

Get all user account infomation for multiple iBMC servers

PS C:\> $session = Connect-iBMC -Address 10.10.10.2-10 -Username username -Password password -TrustCert
PS C:\> $Users = Get-iBMCUser -Session $session
PS C:\> $Users

Id       : 2
Name     : User Account
UserName : Administrator
RoleId   : Administrator
Locked   : False
Enabled  : True
Oem      : @{Huawei=}

Id       : 3
Name     : User Account
UserName : root
RoleId   : Administrator
Locked   : True
Enabled  : True
Oem      : @{Huawei=}

Id       : 4
Name     : User Account
UserName : zxh
RoleId   : Administrator
Locked   : False
Enabled  : True
Oem      : @{Huawei=}


.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Add-iBMCUser
Set-iBMCUser
Remove-iBMCUser
Connect-iBMC
Disconnect-iBMC

#>
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
      $Users = New-Object System.Collections.ArrayList
      $response = Invoke-RedfishRequest $Session '/AccountService/Accounts' | ConvertFrom-WebResponse
      $Properties = @("Id", "Name", "UserName", "RoleId", "Locked", "Enabled", "Oem")
      $response.Members | ForEach-Object {
        $UserResponse = Invoke-RedfishRequest $session $_.'@odata.id' | ConvertFrom-WebResponse
        $User = Copy-ObjectProperties $UserResponse $Properties
        [Void] $Users.Add($User)
      }
      return ,$Users.ToArray()
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
<#
.SYNOPSIS
Modify an existing iBMC user account's infomation.

.DESCRIPTION
Modify an existing iBMC user account's infomation. The NewUsername parameter must not exists in all user accounts.

Modify the following properties of a user:
- User name
- Password
- Rights
- Lockout status
- Whether the user is enabled

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.PARAMETER Username
Username specifies the user to be modified.

.PARAMETER NewUsername
NewUsername specifies the new username of the modified user.
A string of 1 to 16 characters is allowed. It can contain letters, digits, and special characters (excluding <>&,'"/\%), but cannot contain spaces or start with a number sign (#).

.PARAMETER NewPassword
NewPassword specifies the new password of the modified user.

A string of 1 to 20 characters is allowed.
- If password complexity check is enabled for other interfaces, the password must meet password complexity requirements.
- If password complexity check is not enabled for other interfaces, there is not restriction on the password

.PARAMETER NewRole
NewRole specifies the new role of the modified user.
Available role value set is:
- "Administrator"
- "Operator"
- "Commonuser"
- "Noaccess"
- "CustomRole1"
- "CustomRole2"
- "CustomRole3"
- "CustomRole4"

.PARAMETER Enabled
Enabled specifies Whether the user is enabled. A power shell bool($true|$false) value is accept.

.PARAMETER Unlocked
If this switch parameter is $true then the modified user's lockout status is set to false.
If this switch parameter is $false then lockout status will not be modified.

.OUTPUTS
PSObject[]
Returns the modified User object array if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

Create a user account with name powershell and then modify "username", "password", "role", "Enabled", "Locked" properties of this user for a single iBMC server

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> $oldPwd = ConvertTo-SecureString -String old-user-password -AsPlainText -Force
PS C:\> Add-iBMCUser $session powershell $pwd 'Administrator'
PS C:\> $newPwd = ConvertTo-SecureString -String new-user-password -AsPlainText -Force
PS C:\> $User = Set-iBMCUser -Session $session -Username powershell -NewUsername powershell2 -NewPassword $newPwd -NewRole Operator -Enabled $true -Unlocked $true
PS C:\> $User

Id       : 12
Name     : User Account
UserName : powershell
RoleId   : Operator
Locked   : True
Enabled  : True
Oem      : @{Huawei=}

.EXAMPLE

Create a user account with name powershell and then modify the "username", "password", "role" properties of this user for multiple iBMC servers

PS C:\> $session = Connect-iBMC -Address 10.10.10.2,10.10.10.4 -Username username -Password password -TrustCert
PS C:\> $oldPwd = ConvertTo-SecureString -String old-user-password -AsPlainText -Force
PS C:\> Add-iBMCUser $session powershell $pwd 'Administrator'
PS C:\> $newPwd = ConvertTo-SecureString -String new-user-password -AsPlainText -Force
PS C:\> Set-iBMCUser -Session $session -Username powershell -NewUsername powershell2 -NewPassword $newPwd -NewRole Operator

Id       : 12
Name     : User Account
UserName : powershell
RoleId   : Operator
Locked   : True
Enabled  : True
Oem      : @{Huawei=}

.EXAMPLE

Modify "username", "password", "role" properties of a user with name "username" for multiple iBMC servers

PS C:\> $session = Connect-iBMC -Address 10.10.10.2-3 -Username username -Password password -TrustCert
PS C:\> $newPwd = ConvertTo-SecureString -String new-user-password -AsPlainText -Force
PS C:\> ,$session | Set-iBMCUser -Username username -NewUsername new-user2 -NewPassword $newPwd -NewRole Administrator

Id       : 12
Name     : User Account
UserName : powershell
RoleId   : Operator
Locked   : True
Enabled  : True
Oem      : @{Huawei=}

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Add-iBMCUser
Get-iBMCUser
Remove-iBMCUser
Connect-iBMC
Disconnect-iBMC

#>
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

    [UserRole[]]
    [parameter(Mandatory = $false)]
    $NewRole,

    [Boolean[]]
    [parameter(Mandatory = $false)]
    $Enabled,

    [switch[]]
    [parameter(Mandatory = $false)]
    $Unlocked
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
    Assert-ArrayNotNull $Username 'Username'
    $Usernames = Get-MatchedSizeArray $Session $Username 'Session' 'Username'
    $NewUsernames = Get-OptionalMatchedSizeArray $Session $NewUsername
    $NewPasswords = Get-OptionalMatchedSizeArray $Session $NewPassword
    $NewRoles = Get-OptionalMatchedSizeArray $Session $NewRole
    $Enableds = Get-OptionalMatchedSizeArray $Session $Enabled
    $Unlockeds = Get-OptionalMatchedSizeArray $Session $Unlocked
  }

  process {
    $SetUserBlock = {
      param($Session, $Username, $Payload)
      # try load all users
      $Users = Invoke-RedfishRequest $Session '/AccountService/Accounts' | ConvertFrom-WebResponse
      $found = $false
      for ($idx=0; $idx -lt $Users.Members.Count; $idx++) {
        $Member = $Users.Members[$idx]
        $UserResponse = Invoke-RedfishRequest $session $Member.'@odata.id'
        $User = $UserResponse | ConvertFrom-WebResponse
        if ($User.UserName -eq $Username) {
          $found = $true
          # Update user with provided $Username
          $Logger.info($(Trace-Session $Session "User $($User.UserName) found, will patch user now"))
          $Headers = @{'If-Match'=$UserResponse.Headers['Etag'];}
          $Logger.info($(Trace-Session $Session "User Etag is $($UserResponse.Headers['Etag'])"))
          if ($null -ne $Payload.Password) {
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Payload.Password)
            $PlainPasswd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            $Payload.Password = $PlainPasswd
          }
          $Response = Invoke-RedfishRequest $Session $User.'@odata.id' 'Patch' $Payload $Headers
          # $response = Invoke-RedfishRequest $Session '/AccountService/Accounts' 'Post' $payload -ContinueEvenFailed
          $SetUser = Resolve-RedfishPartialSuccessResponse $Session $Response
          $Properties = @("Id", "Name", "UserName", "RoleId", "Locked", "Enabled", "Oem")
          $PrettyUser = Copy-ObjectProperties $SetUser $Properties
          return $PrettyUser
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
        $Payload = @{
          "UserName"= $NewUsernames[$idx];
          "Password"= $NewPasswords[$idx];
          "RoleId"= $NewRoles[$idx];
          "Enabled"= $Enableds[$idx];
        } | Resolve-EnumValues

        $Playload_ = Remove-EmptyValues $Payload
        if ($Unlockeds[$idx] -eq $true) {
          $Playload_.Locked = $false
        }

        if ($null -eq $Playload_ -or $Playload_.Keys.Count -eq 0) {
          throw $(Get-i18n FAIL_NO_UPDATE_PARAMETER)
        } else {
          $Parameters = @($Session[$idx], $Usernames[$idx], $Playload_)
          [Void] $tasks.Add($(Start-ScriptBlockThread $pool $SetUserBlock $Parameters))
        }
      }
      return Get-AsyncTaskResults -AsyncTasks $tasks
    }
    finally {
      $pool.close()
    }
  }

  end {
  }
}

function Remove-iBMCUser {
<#
.SYNOPSIS
Remove an existing iBMC user account.

.DESCRIPTION
Remove an existing iBMC user account identified by "Username" parameter

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.PARAMETER Username
Username specifies the user to be removed.

.OUTPUTS
None
Nothing returned if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

Remove a iBMC user account that has a username "user1"

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> Remove-iBMCUser -Session $session -Username user1


.EXAMPLE

Remove a iBMC user account that has a username "user1"

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> $session | Remove-iBMCUser -Username user1


.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Add-iBMCUser
Get-iBMCUser
Set-iBMCUser
Connect-iBMC
Disconnect-iBMC

#>
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
    $UsernameList = Get-MatchedSizeArray $Session $Username 'Session' 'Username'
  }

  process {
    $DeleteUserBlock = {
      param($Session, $Username)
      # try load all users
      $Users = Invoke-RedfishRequest $Session '/AccountService/Accounts' | ConvertFrom-WebResponse
      $success = $false
      for ($idx=0; $idx -lt $Users.Members.Count; $idx++) {
        $Member = $Users.Members[$idx]
        $User = Invoke-RedfishRequest $session $Member.'@odata.id' | ConvertFrom-WebResponse
        if ($User.UserName -eq $Username) {
          # delete user with provided $Username
          $Logger.info($(Trace-Session $Session "User found, Delete User $($User.UserName) now"))
          Invoke-RedfishRequest $Session $User.'@odata.id' 'Delete' | Out-null
          $Logger.info($(Trace-Session $Session "Delete User $($User.UserName) succeed"))
          $success = $true
          break
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
        $parameter = @($Session[$idx], $UsernameList[$idx])
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