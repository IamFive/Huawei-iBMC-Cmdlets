<# NOTE: A Redfish Client PowerShell scripts. #>

. $PSScriptRoot/Common.ps1

try { [RedfishSession] | Out-Null } catch {
Add-Type @'
  public class RedfishSession
  {
    public System.String Id ;
    public System.String Name ;
    public System.String ManagerType ;
    public System.String FirmwareVersion ;
    public System.String UUID ;
    public System.String Model ;
    public System.String Health ;
    public System.String State ;
    public System.String DateTime ;
    public System.String DateTimeLocalOffset ;

    public System.String BaseUri ;
    public System.String Location ;
    public System.Boolean Alive ;
    public System.String AuthToken ;
    public System.Boolean TrustCert ;
    public System.String resourceId ;
  }
'@
}

function New-iBMCRedfishSession {
  <#
.SYNOPSIS
Create sessions for iBMC Redfish REST API.

.DESCRIPTION
Creates sessions for iBMC Redfish REST API. The session object returned which has members:
1. 'AuthToken' to identify the session
2. 'BaseUri' of the Redfish API
3. 'Location' which is used for logging out of the session.
4. 'TrustCert' to identify trust all SSL Certification or not
5. 'Alive' to identify whether the session is alive or not

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
New-iBMCRedfishSession returns a RedfishSession Object which contains - AuthToken, BaseUri, Location, TrustCert and Alive.

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
  [cmdletbinding(DefaultParameterSetName = 'AccountSet')]
  param
  (
    [System.String]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    $Address,

    [System.String]
    [parameter(ParameterSetName = "AccountSet", Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
    $Username,

    [System.String]
    [parameter(ParameterSetName = "AccountSet", Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2)]
    $Password,

    [PSCredential]
    [parameter(ParameterSetName = "CredentialSet", Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
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
    throw $i18n.ERROR_INVALID_CREDENTIALS
  }

  [IPAddress]$ipAddress = $null
  if ([IPAddress]::TryParse($Address, [ref]$ipAddress)) {
    if (([IPAddress]$Address).AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetworkV6 -and $Address.IndexOf('[') -eq -1) {
      $Address = '[' + $Address + ']'
    }
  }

  # create a new session object for redfish server of $address
  $session = New-Object RedfishSession
  $session.BaseUri = "https://$Address"
  $session.TrustCert = $TrustCert

  Write-Log "Create Redfish session For $($session.BaseUri) now"

  # New session
  $path = "/SessionService/Sessions"
  $method = "POST"
  $payload = @{'UserName' = $username; 'Password' = $passwd; } | ConvertTo-Json
  $response = Invoke-RedfishRequest -Path $path -Method $method -Payload $payload -Session $session
  $response.close()

  # set session properties
  $session.Location = $response.Headers['Location']
  $session.AuthToken = $response.Headers['X-Auth-Token']
  $session.Alive = $true

  # get bmc resource Id (BladeN, SwiN, N)
  $managers = Invoke-RedfishRequest -Path "/Managers" -Session $session | ConvertFrom-WebResponse
  $managerOdataId = $managers.Members[0].'@odata.id'
  $session.resourceId = $($managerOdataId -split '/')[-1]

  # get bmc manager
  $manager = Invoke-RedfishRequest -Path $managerOdataId -Session $session | ConvertFrom-WebResponse

  $session.Id = $manager.Id
  $session.Name = $manager.Name
  $session.ManagerType = $manager.ManagerType
  $session.FirmwareVersion = $manager.FirmwareVersion
  $session.UUID = $manager.UUID
  $session.Model = $manager.Model
  $session.DateTime = $manager.DateTime
  $session.DateTimeLocalOffset = $manager.DateTimeLocalOffset
  $session.State = $manager.Status.State
  $session.Health = $manager.Status.Health
  return $session
}


function Close-iBMCRedfishSession {
  <#
.SYNOPSIS
Close a specified session of iBMC Redfish Server.

.DESCRIPTION
Close a specified session of iBMC Redfish Server by sending HTTP Delete request to location holds by "Location" property in Session object passed as parameter.

.PARAMETER Session
Session object that created by New-iBMCRedfishSession cmdlet.

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
    [RedfishSession]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position=0)]
    $session
  )

  if ($null -eq $session -or $session -isnot [RedfishSession]) {
    throw $([string]::Format($bundle.ERROR_PARAMETER_ILLEGAL, 'Session'))
  }

  $method = "DELETE"
  $path = $session.Location
  $response = Invoke-RedfishRequest -Path $path -Method $method -Session $session
  $response.close()

  $success = $response.StatusCode.value__ -lt 400
  $session.Alive = !$success
  return $session
}


function Test-iBMCRedfishSession {
  <#
.SYNOPSIS
Test whether a specified session of iBMC Redfish Server is still alive

.DESCRIPTION
Test whether a specified session of iBMC Redfish Server is still alive by sending a HTTP get request to Session Location Uri.

.PARAMETER Session
Session object that created by New-iBMCRedfishSession cmdlet.

.INPUTS
You can pipe the session object to Test-iBMCRedfishSession. The session object is obtained from executing New-iBMCRedfishSession cmdlet.

.OUTPUTS
true if still alive else false


.EXAMPLE
PS C:\> Test-iBMCRedfishSession -Session $session
PS C:\>

true

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

#>
  param
  (
    [RedfishSession]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position=0)]
    $Session
  )

  if ($null -eq $session -or $session -isnot [RedfishSession]) {
    throw $([string]::Format($bundle.ERROR_PARAMETER_ILLEGAL, 'Session'))
  }

  $method = "GET"
  $path = $session.Location
  $response = Invoke-RedfishRequest -Path $path -Method $method -Session $session -ContinueEvenFailed
  $response.close()

  $success = $response.StatusCode.value__ -lt 400
  $session.Alive = $success
  return $session
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
    [parameter(Mandatory = $true)]
    $session,

    [Switch]
    [parameter(Mandatory = $false)]
    $ContinueEvenFailed
  )

  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12

  if ($Path.StartsWith("https://", "CurrentCultureIgnoreCase")) {
    $OdataId = $Path
  }
  elseif ($Path.StartsWith("/redfish/v1", "CurrentCultureIgnoreCase")) {
    $OdataId = "$($session.BaseUri)$($Path)"
  }
  else {
    $OdataId = "$($session.BaseUri)/redfish/v1$($Path)"
  }

  Write-Log "Send new request: [$Method] $OdataId"

  [System.Net.HttpWebRequest] $request = [System.Net.WebRequest]::Create($OdataId)
  $request.Method = $Method
  $request.AutomaticDecompression = [System.Net.DecompressionMethods]::GZip

  if ($null -ne $session.AuthToken) {
    $request.Headers.Add('X-Auth-Token', $session.AuthToken)
  }
  if ($true -eq $session.TrustCert) {
    $request.ServerCertificateValidationCallback = { $true }
  }

  try {
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

    # https://docs.microsoft.com/en-us/dotnet/framework/network-programming/how-to-request-data-using-the-webrequest-class
    return $request.GetResponse()
  }
  catch {
    # .Net HttpWebRequest will throw Exception if response is not success (status code is great than 400)
    # https://stackoverflow.com/questions/10081726/why-does-httpwebrequest-throw-an-exception-instead-returning-httpstatuscode-notf
    # [System.Net.HttpWebResponse] $response = $_.Exception.InnerException.Response
    $response = $_.Exception.InnerException.Response
    if ($null -ne $response) {
      if ($ContinueEvenFailed) {
        return $response
      }

      $result = $response | ConvertFrom-WebResponse
      $extendInfoList = $result.error.'@Message.ExtendedInfo'
      if ($extendInfoList.Count -gt 0) {
        $extendInfo0 = $extendInfoList[0]
        throw "[$($extendInfo0.Severity)] $($extendInfo0.Message)"
      }

      throw $_.Exception
    } else {
      throw $_.Exception
    }
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
    [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
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
    $streamReader.close()
    $stream.close()
    $response.close()
  }
}
