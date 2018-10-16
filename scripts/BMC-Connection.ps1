<# NOTE: BMC Connect related Cmdlets. #>

function Connect-iBMC {
  <#
.SYNOPSIS
Create connections for iBMC Servers used by other cmdlets.

.DESCRIPTION
Create connections for one or multiple iBMC servers. This cmdlet has following parameters:

- Address - Holds the iBMC server IP/hostname.
- Username - Holds  the iBMC server username.
- Password - Holds  the iBMC server password.
- Credential - Holds the iBMC server Credential.
- TrustCert - Using this bypasses the server certificate authentication.

.PARAMETER Address
IP address or Hostname of the iBMC server.

.PARAMETER Username
Username of iBMC account to access the iBMC server.

.PARAMETER Password
Password of iBMC account to access the iBMC server.

.PARAMETER Credential
PowerShell PSCredential object having username and passwword of iBMC account to access the iBMC.

.PARAMETER TrustCert
If this switch parameter is present then server certificate authentication is disabled for this iBMC connection.
If not present, server certificate is enabled by default.


.OUTPUTS
RedfishSession[]
Connect-iBMC returns a RedfishSession Object or List.


HPE.iLO.Response.Connection[]
    If the cmdlet executes successfully it returns HPE.iLO.Response.Connection or HPE.iLO.Response.Connection[] obj
    ect. In case of error or warning, the corresponding error message is displayed.


.EXAMPLE
PS C:\> $session = Connect-iBMC -Address 10.1.1.2 -Username root -Password password
PS C:\> $session | Format-List


.EXAMPLE
PS C:\> $credential = Get-Credential
PS C:\> $session = Connect-iBMC -Address 192.184.217.212 -Credential $credential
PS C:\> $session | fl


.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

#>
  [cmdletbinding(DefaultParameterSetName = 'AccountSet')]
  param
  (
    [System.String[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    $Address,

    [System.String[]]
    [parameter(ParameterSetName = "AccountSet", Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
    $Username,

    [System.String[]]
    [parameter(ParameterSetName = "AccountSet", Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2)]
    $Password,

    [PSCredential[]]
    [parameter(ParameterSetName = "CredentialSet", Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
    $Credential,

    [switch]
    [parameter(Mandatory = $false)]
    $TrustCert
  )

  $useCredential = $($null -ne $Credential)
  if ($useCredential) {
    Assert-ArrayNotNull $Credential 'Credential'
    $Credential = Get-MatchedSizeArray $Address $Credential 'Address' 'Credential'
  }
  else {
    # $null -ne $Username -and $null -ne $Password
    Assert-ArrayNotNull $Username 'Username'
    Assert-ArrayNotNull $Password 'Password'
    $Username = Get-MatchedSizeArray $Address $Username 'Address' 'Username'
    $Password = Get-MatchedSizeArray $Username $Password 'Username' 'Password'
  }

  $ParametersArray = New-Object System.Collections.ArrayList
  for ($index=0; $index -lt $Address.Count; $index++) {
    $IpList = ConvertFrom-IPRangeString $Address[$index]
    $IpList | ForEach-Object {
      $Parameters = New-Object System.Collections.ArrayList
      [Void] $Parameters.Add($_)
      if ($useCredential) {
        [Void] $Parameters.Add($Credential[$index])
      } else {
        [Void] $Parameters.Add($Username[$index])
        [Void] $Parameters.Add($Password[$index])
      }
      [Void] $Parameters.Add($($TrustCert -eq $true))

      [Void] $ParametersArray.Add($Parameters)
    }
  }

  try {
    $tasks = New-Object System.Collections.ArrayList
    $pool = New-RunspacePool $ParametersArray.Count
    $ParametersArray | ForEach-Object {
      $ScriptBlock = {
        if ($useCredential) {
          return New-iBMCRedfishSession -Address $_[0] -Credential $_[1] -TrustCert:$_[2]
        } else {
          return New-iBMCRedfishSession -Address $_[0] -Username $_[1] -Password $_[2] -TrustCert:$_[3]
        }
      }
      [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock))
    }

    Get-AsyncTaskResults $tasks
  } finally {
    $pool.close()
  }
}