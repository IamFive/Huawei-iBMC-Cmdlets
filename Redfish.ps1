<# NOTE: A Redfish Client PowerShell scripts. #>

. $PSScriptRoot/Common.ps1

function New-iBMCRedfishSession {
  <#
.SYNOPSIS
Create sessions for iBMC Redfish REST API.

.DESCRIPTION
Creates sessions for iBMC Redfish REST API. The session object returned which has members:
1. 'X-Auth-Token' to identify the session
2. 'RootURI' of the Redfish API
3. 'Location' which is used for logging out of the session.
4. 'RootData' includes data from '/redfish/v1/'. It includes the refish data and the odata id of components like systems, chassis, etc.

.PARAMETER Address
IP address or Hostname of the target iBMC Redfish API.

.PARAMETER Username
Username of iBMC account to access the iBMC Redfish API.

.PARAMETER Password
Password of iBMC account to access the iBMC Redfish API.

.PARAMETER Credential
PowerShell PSCredential object having username and passwword of iBMC account to access the iBMC.

.PARAMETER TrustCert
If this switch parameter is present then server certificate authentication is disabled for this iBMC connection.
If not present, server certificate is enabled by default.

.NOTES
See typical usage examples in the Redfish.ps1 file installed with this module.

.INPUTS
System.String
You can pipe the Address i.e. the hostname or IP address to New-iBMCRedfishSession.

.OUTPUTS
System.Management.Automation.PSCustomObject
New-iBMCRedfishSession returns a PSObject that has session details - X-Auth-Token, RootURI, Location and RootData.

.EXAMPLE
PS C:\> $session = New-iBMCRedfishSession -Address 10.1.1.2 -Username root -Password password


PS C:\> $session | fl


RootUri      : https://10.1.1.2/redfish/v1/
X-Auth-Token : this-is-a-sample-token
Location     : https://10.1.1.2/redfish/v1/Sessions/{session-id}/
RootData     : @{@odata.context=/redfish/v1/$metadata#ServiceRoot/; @odata.id=/redfish/v1/; @odata.type=#ServiceRoot.1.0.0.ServiceRoot; AccountService=; Chassis=; EventService=; Id=v1; JsonSchemas=; Links=; Managers=; Name=HP RESTful Root Service; Oem=; RedfishVersion=1.0.0; Registries=; SessionService=; Systems=; UUID=8dea7372-23f9-565f-9396-2cd07febbe29}

.EXAMPLE
PS C:\> $credential = Get-Credential
PS C:\> $session = New-iBMCRedfishSession -Address 192.184.217.212 -Credential $credential
PS C:\> $session | fl

RootUri      : https://10.1.1.2/redfish/v1/
X-Auth-Token : this-is-a-sample-token
Location     : https://10.1.1.2/redfish/v1/Sessions/{session-id}/
RootData     : @{@odata.context=/redfish/v1/$metadata#ServiceRoot/; @odata.id=/redfish/v1/; @odata.type=#ServiceRoot.1.0.0.ServiceRoot; AccountService=; Chassis=; EventService=; Id=v1; JsonSchemas=; Links=; Managers=; Name=HP RESTful Root Service; Oem=; RedfishVersion=1.0.0; Registries=; SessionService=; Systems=; UUID=8dea7372-23f9-565f-9396-2cd07febbe29}

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

#>
  [cmdletbinding(DefaultParameterSetName = 'account')]
  param
  (
    [System.String]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    $Address,

    [System.String]
    [parameter(ParameterSetName = "account", Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
    $Username,

    [System.String]
    [parameter(ParameterSetName = "account", Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2)]
    $Password,

    [PSCredential]
    [parameter(ParameterSetName = "Credential", Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
    $Credential,

    [switch]
    [parameter(Mandatory = $false)]
    $TrustCert
  )

  # Fetch session with Credential by default if `Credential` is set
  if ($null -ne $Credential) {
    $username = $Credential.UserName
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
    $passwd = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
  }
  elseif ($Username -ne '' -and $Password -ne '') {
    $username = $username
    $passwd = $password
  }
  else {
    throw $(Get-Message('MSG_INVALID_CREDENTIALS'))
  }

  [IPAddress]$ipAddress = $null
  if ([IPAddress]::TryParse($Address, [ref]$ipAddress)) {
    if (([IPAddress]$Address).AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetworkV6 -and $Address.IndexOf('[') -eq -1) {
      $Address = '[' + $Address + ']'
    }
  }

  # create a new session object for redfish server of $address
  $session = New-Object PSObject
  $session | Add-Member -MemberType NoteProperty BaseUri "https://$Address"
  $session | Add-Member -MemberType NoteProperty TrustCert $TrustCert

  $path = "/SessionService/Sessions"
  $method = "POST"
  $payload = @{'UserName' = $username; 'Password' = $passwd; } | ConvertTo-Json
  $response = Invoke-RedfishRequest -Path $path -Method $method -Payload $payload -Session $Session

  $session | Add-Member -MemberType NoteProperty 'X-Auth-Token' $response.Headers['X-Auth-Token']
  $session | Add-Member -MemberType NoteProperty 'Location' $response.Headers['Location']

  # $rootData = Get-HPERedfishDataRaw -Odataid '/redfish/v1/' -Session $session
  # if ($rootData.Oem.PSObject.Properties.name.Contains('Hp') -eq $false) {
  #   throw $(Get-Message('MSG_INVALID_OEM'))
  # }
  # $session|Add-Member -MemberType NoteProperty 'RootData' $rootData

  return $session
}


function Close-iBMCRedfishSession
{
<#
.SYNOPSIS
Close a specified session of iBMC Redfish Server.

.DESCRIPTION
Close a specified session of iBMC Redfish Server by sending HTTP Delete request to location holds by "Location" property in Session object passed as parameter.

.PARAMETER Session
Session object that created by New-iBMCRedfishSession cmdlet.

.PARAMETER TrustCert
If this switch parameter is present then server certificate authentication is disabled for this iBMC connection.
If not present, server certificate is enabled by default.

.NOTES
The Session object will be detached from iBMC Redfish Server. And the Session can not be used by cmdlets which required Session parameter again.

.INPUTS
You can pipe the session object to Close-iBMCRedfishSession. The session object is obtained from executing New-iBMCRedfishSession cmdlet.

.OUTPUTS
This cmdlet does not generate any output.


.EXAMPLE
PS C:\> Close-iBMCRedfishSession -Session $session
PS C:\>

This will disconnect the session given in the variable $session

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

#>
  param
  (
      [PSObject]
      [parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
      $Session
  )

  $method = "DELETE"
  $path = $Session.Location
  $response = Invoke-RedfishRequest -Path $path -Method $method -Session $Session
  $response.close()
}


function Invoke-RedfishRequest {
  param (
    [System.String]
    $Path,

    [System.String]
    [ValidateSet('Get', 'Delete', 'Put', 'Post', 'Patch')]
    $Method = 'Get',

    [System.Object]
    $Payload,

    [PSObject]
    [parameter(Mandatory=$true)]
    $Session
  )

  Write-Log "Send new request: [$Method] $Path"
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12

  if ($Path.StartsWith("https://", "CurrentCultureIgnoreCase")) {
    $OdataId = $Path
  } elseif ($Path.StartsWith("/redfish/v1", "CurrentCultureIgnoreCase")) {
    $OdataId = "$($Session.BaseUri)$($Path)"
  } else {
    $OdataId = "$($Session.BaseUri)/redfish/v1$($Path)"
  }

  [System.Net.HttpWebRequest] $request = [System.Net.WebRequest]::Create($OdataId)
  $request.Method = $Method
  $request.AutomaticDecompression = [System.Net.DecompressionMethods]::GZip

  if ($null -ne $Session.'X-Auth-Token') {
    $request.Headers.Add('X-Auth-Token', $Session.'X-Auth-Token')
  }
  if ($true -eq $Session.TrustCert) {
    $request.ServerCertificateValidationCallback = { $true }
  }

  if ($method -in @('PUT', 'POST', 'PATCH')) {
    if ($null -eq $Payload -or '' -eq $Payload) {
      $Payload = '{}'
    }
    $request.ContentType = 'application/json'
    $request.ContentLength = $Payload.length

    $reqWriter = New-Object System.IO.StreamWriter($request.GetRequestStream(), [System.Text.Encoding]::ASCII)
    $reqWriter.Write($Payload)
    $reqWriter.Close()
  }

  try {
    # https://docs.microsoft.com/en-us/dotnet/framework/network-programming/how-to-request-data-using-the-webrequest-class
    return $request.GetResponse()
  }
  catch {
    # .Net HttpWebRequest will throw Exception if response is not success (status code is great than 400)
    # https://stackoverflow.com/questions/10081726/why-does-httpwebrequest-throw-an-exception-instead-returning-httpstatuscode-notf
    # [System.Net.HttpWebResponse] $response = $_.Exception.InnerException.Response
    return $_.Exception.InnerException.Response
  }
  finally {
    if ($null -ne $reqWriter -and $reqWriter -is [System.IDisposable]) {
      $reqWriter.Dispose()
    }
  }
}

function ConvertFrom-WebResponse {
  param (
    [System.Net.HttpWebResponse]
    [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    $Response
  )

  try {
    $stream = $response.GetResponseStream();
    $streamReader = New-Object System.IO.StreamReader($stream)
    $content = $streamReader.ReadToEnd();
    $json = $content | ConvertFrom-Json
    return $json
  }
  finally {
    $response.close()
    $stream.close()
    $streamReader.close()
  }
}
