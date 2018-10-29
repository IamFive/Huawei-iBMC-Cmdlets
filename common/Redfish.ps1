<# NOTE: A Redfish Client PowerShell scripts. #>

# . $PSScriptRoot/Common.ps1

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

    public System.String Address ;
    public System.String BaseUri ;
    public System.String Location ;
    public System.Boolean Alive ;
    public System.String AuthToken ;
    public System.Boolean TrustCert ;
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

  # create a new session object for redfish server of $address
  $session = New-Object RedfishSession
  $session.Address = $Address
  $session.TrustCert = $TrustCert

  [IPAddress]$ipAddress = $null
  if ([IPAddress]::TryParse($Address, [ref]$ipAddress)) {
    if (([IPAddress]$Address).AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetworkV6 -and $Address.IndexOf('[') -eq -1) {
      $Address = '[' + $Address + ']'
    }
  }

  $session.BaseUri = "https://$Address"


  $Logger.info("Create Redfish session For $($session.BaseUri) now")

  # New session
  $path = "/SessionService/Sessions"
  $method = "POST"
  $payload = @{'UserName' = $username; 'Password' = $passwd; }
  $response = Invoke-RedfishRequest -Session $session -Path $path -Method $method -Payload $payload
  $response.close()

  # set session properties
  $session.Location = $response.Headers['Location']
  $session.AuthToken = $response.Headers['X-Auth-Token']
  $session.Alive = $true

  # get bmc resource Id (BladeN, SwiN, N)
  $managers = Invoke-RedfishRequest -Session $session -Path "/Managers" | ConvertFrom-WebResponse
  $managerOdataId = $managers.Members[0].'@odata.id'
  # $session.resourceId = $($managerOdataId -split '/')[-1]

  # get bmc manager
  $manager = Invoke-RedfishRequest -Session $session -Path $managerOdataId | ConvertFrom-WebResponse

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
    throw $([string]::Format($(Get-i18n ERROR_PARAMETER_ILLEGAL), 'Session'))
  }

  $method = "DELETE"
  $path = $session.Location
  $response = Invoke-RedfishRequest -Session $session -Path $path -Method $method
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
    throw $([string]::Format($(Get-i18n ERROR_PARAMETER_ILLEGAL), 'Session'))
  }

  $method = "GET"
  $path = $session.Location
  $response = Invoke-RedfishRequest -Session $session -Path $path -Method $method -ContinueEvenFailed
  $response.close()

  $success = $response.StatusCode.value__ -lt 400
  $session.Alive = $success
  return $session
}

function Wait-RedfishTasks {
<#
.SYNOPSIS
Wait redfish tasks util success or failed

.DESCRIPTION
Wait redfish tasks util success or failed

.PARAMETER Session
Session array that created by New-iBMCRedfishSession cmdlet.

.PARAMETER Task
Task array that return by redfish async job API

.OUTPUTS

.EXAMPLE
PS C:\> Wait-RedfishTasks $Sessions $Tasks
PS C:\>

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

#>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    $ThreadPool,

    [RedfishSession[]]
    [parameter(Mandatory = $true, Position=1)]
    $Sessions,

    [PSObject[]]
    [parameter(Mandatory = $true, Position=2)]
    $Tasks,

    [Parameter(Mandatory = $false, Position = 3)]
    [switch]
    $ShowProgress
  )

  begin {
    Assert-NotNull $ThreadPool
    Assert-ArrayNotNull $Sessions
    Assert-ArrayNotNull $Tasks
  }

  process {
    function Write-TaskProgress($Task) {
      if ($ShowProgress) {
        if ($Task -isnot [Exception]) {
          $TaskState = $Task.TaskState
          if ($TaskState -eq 'Running') {
            $TaskPercent = $Task.Oem.Huawei.TaskPercentage
            if ($null -eq $TaskPercent) {
              $TaskPercent = 0
            } else {
              $TaskPercent = [int]$TaskPercent.replace('%', '')
            }
            Write-Progress -Id $Task.Guid -Activity $Task.ActivityName -PercentComplete $TaskPercent `
              -Status "$($TaskPercent)% $(Get-i18n MSG_PROGRESS_PERCENT)"
          }
          elseif ($TaskState -eq 'Completed') {
            Write-Progress -Id $Task.Guid -Activity $Task.ActivityName -Completed -Status $(Get-i18n MSG_PROGRESS_COMPLETE)
          }
          elseif ($TaskState -eq 'Exception') {
            Write-Progress -Id $Task.Guid -Activity $Task.ActivityName -Completed -Status $(Get-i18n MSG_PROGRESS_FAILED)
          }
        }
      }
    }

    $Logger.info("Start wait for all redfish tasks done")

    $GuidPrefix = [string] $(Get-RandomIntGuid)
    # initialize tasks
    for ($idx=0; $idx -lt $Tasks.Count; $idx++) {
      $Task = $Tasks[$idx]
      $Session = $Sessions[$idx]
      if ($Task -isnot [Exception]) {
        $TaskGuid = [int]$($GuidPrefix + $idx)
        $Task | Add-Member -MemberType NoteProperty 'index' $idx
        $Task | Add-Member -MemberType NoteProperty 'Guid' $TaskGuid
        $Task | Add-Member -MemberType NoteProperty 'ActivityName' "[$($Session.Address)] $($Task.Name)"
        Write-TaskProgress $Task
      }
    }

    while ($true) {
      $RunningTasks = @($($Tasks | Where-Object {$_ -isnot [Exception]} | Where-Object TaskState -eq 'Running'))
      $Logger.info("Remain running task count: $($RunningTasks.Count)")
      $Logger.info("Remain running tasks: $RunningTasks")
      if ($RunningTasks.Count -eq 0) {
        break
      }
      Start-Sleep -Seconds 1
      # filter running task and fetch task new status
      $AsyncTasks = New-Object System.Collections.ArrayList
      for ($idx=0; $idx -lt $RunningTasks.Count; $idx++) {
        $RunningTask = $RunningTasks[$idx]
        $Parameters = @($Sessions[$RunningTask.index], $RunningTask)
        [Void] $AsyncTasks.Add($(Start-CommandThread $pool "Get-RedfishTask" $Parameters))
      }
      # new updated task list
      $ProcessedTasks = @($(Get-AsyncTaskResults $AsyncTasks))
      for ($idx=0; $idx -lt $ProcessedTasks.Count; $idx++) {
        $ProcessedTask = $ProcessedTasks[$idx]
        $Tasks[$ProcessedTask.index] = $ProcessedTask # update task
        Write-TaskProgress $ProcessedTask
      }
    }

    $Logger.info("All redfish tasks done")
    return $Tasks
  }

  end {
  }
}


function Get-RedfishTask {
<#
.SYNOPSIS
Wait a redfish task util success or failed

.DESCRIPTION
Wait a redfish task util success or failed

.PARAMETER Session
Session object that created by New-iBMCRedfishSession cmdlet.

.PARAMETER Task
Task object that return by redfish async job API

Completed Task object sample:
{
    "@odata.context": "/redfish/v1/$metadata#TaskService/Tasks/Members/$entity",
    "@odata.type": "#Task.v1_0_2.Task",
    "@odata.id": "/redfish/v1/TaskService/Tasks/1",
    "Id": "1",
    "Name": "Export Config File Task",
    "TaskState": "Completed",
    "StartTime": "2018-10-25T13:31:52+08:00",
    "EndTime": "2018-10-25T13:32:28+08:00",
    "TaskStatus": "OK",
    "Messages": {
        "@odata.type": "/redfish/v1/$metadata#MessageRegistry.1.0.0.MessageRegistry",
        "MessageId": "iBMC.1.0.CollectingConfigurationOK",
        "RelatedProperties": [],
        "Message": "Successfully collected the configuration file.",
        "MessageArgs": [],
        "Severity": "OK",
        "Resolution": "None"
    },
    "Oem": {
        "Huawei": {
            "TaskPercentage": "100%"
        }
    }
}


Exception Task object sample:

{
    "@odata.context": "/redfish/v1/$metadata#TaskService/Tasks/Members/$entity",
    "@odata.type": "#Task.v1_0_2.Task",
    "@odata.id": "/redfish/v1/TaskService/Tasks/1",
    "Id": "1",
    "Name": "Export Config File Task",
    "TaskState": "Exception",
    "StartTime": "2018-10-25T15:19:40+08:00",
    "EndTime": "2018-10-25T15:20:26+08:00",
    "TaskStatus": "Warning",
    "Messages": {
        "@odata.type": "/redfish/v1/$metadata#MessageRegistry.1.0.0.MessageRegistry",
        "MessageId": "iBMC.1.0.FileTransferErrorDesc",
        "RelatedProperties": [],
        "Message": "An error occurred during the file transfer process. Details: unknown error.",
        "MessageArgs": [
            "unknown error"
        ],
        "Severity": "Warning",
        "Resolution": "Rectify the fault and submit the request again."
    },
    "Oem": {
        "Huawei": {
            "TaskPercentage": "10%"
        }
    }
}

.OUTPUTS

.EXAMPLE
PS C:\> Wait-RedfishTask $session $task
PS C:\>

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

#>
  [CmdletBinding()]
  param (
    [RedfishSession]
    [parameter(Mandatory = $true, Position=0)]
    $Session,

    [PSObject]
    [parameter(Mandatory = $true, Position=1)]
    $Task
  )

  begin {
    Assert-NotNull $Session
    Assert-NotNull $Task
  }

  process {
    $TaskOdataId = $Task.'@odata.id'
    $NewTask = Invoke-RedfishRequest $Session $TaskOdataId | ConvertFrom-WebResponse
    $NewTask | Add-Member -MemberType NoteProperty 'index' $Task.index
    $NewTask | Add-Member -MemberType NoteProperty 'Guid' $Task.Guid
    $NewTask | Add-Member -MemberType NoteProperty 'ActivityName' $Task.ActivityName
    return $NewTask
  }

  end {
  }
}

function Invoke-RedfishFirmwareUpload {
  [cmdletbinding()]
  param (
    [RedfishSession]
    [parameter(Mandatory = $true, Position=0)]
    $Session,

    [System.String]
    [parameter(Mandatory = $true, Position=1)]
    $FileName,

    [System.String]
    [parameter(Mandatory = $true, Position=2)]
    $FilePath,

    [Switch]
    [parameter(Mandatory = $false, Position=3)]
    $ContinueEvenFailed
  )

  $Logger.info("Uploading $FilePath as $FileName to ibmc");
  $Request = New-RedfishRequest $Session '/UpdateService/FirmwareInventory' 'POST'
  try {
    # $ASCIIEncoder = [System.Text.Encoding]::ASCII
    $UTF8Encoder = [System.Text.Encoding]::UTF8
    $Boundary = "---------------------------$($(Get-Date).Ticks)"
    $BoundaryAsBytes = $UTF8Encoder.GetBytes("`r`n--$Boundary`r`n")

    $Request.ContentType = "multipart/form-data; boundary=$Boundary"
    $Request.KeepAlive = $true

    $RequestStream = $Request.GetRequestStream()
    $RequestStream.Write($BoundaryAsBytes, 0, $BoundaryAsBytes.Length);

    $Header = "Content-Disposition: form-data; name=`"imgfile`"; filename=`"$($FileName)`"`
      \r\nContent-Type: application/octet-stream`r`n`r`n";
    $HeaderAsBytes = $UTF8Encoder.GetBytes($Header);
    $RequestStream.Write($HeaderAsBytes, 0, $HeaderAsBytes.Length);

    $bytesRead = 0
    $Buffer = New-Object byte[] 4096;
    $FileStream = New-Object IO.FileStream $FilePath ,'Open','Read'
    while (($bytesRead = $FileStream.Read($Buffer, 0, $Buffer.Length)) -gt 0) {
      $RequestStream.Write($Buffer, 0, $bytesRead)
    }
    $FileStream.Close()

    $Trailer = $UTF8Encoder.GetBytes("`r`n--$boundary--`r`n")
    $RequestStream.Write($Trailer, 0, $Trailer.Length)
    $RequestStream.Close()

    # https://docs.microsoft.com/en-us/dotnet/framework/network-programming/how-to-request-data-using-the-webrequest-class
    $Response = $Request.GetResponse() | ConvertFrom-WebResponse
    return $Response.success
  }
  catch {
    # .Net HttpWebRequest will throw Exception if response is not success (status code is great than 400)
    # https://stackoverflow.com/questions/10081726/why-does-httpwebrequest-throw-an-exception-instead-returning-httpstatuscode-notf
    # [System.Net.HttpWebResponse] $response = $_.Exception.InnerException.Response
    Resolve-RedfishFailtureResponse $_ $ContinueEvenFailed
  }
  finally {
    if ($null -ne $RequestStream -and $RequestStream -is [System.IDisposable]) {
      $RequestStream.Dispose()
    }
  }
}


function Invoke-RedfishRequest {
  [cmdletbinding()]
  param (
    [RedfishSession]
    [parameter(Mandatory = $true, Position=0)]
    $Session,

    [System.String]
    [parameter(Mandatory = $true, Position=1)]
    $Path,

    [System.String]
    [parameter(Mandatory = $false, Position=2)]
    [ValidateSet('Get', 'Delete', 'Put', 'Post', 'Patch')]
    $Method = 'Get',

    [System.Object]
    [parameter(Mandatory = $false, Position=3)]
    $Payload,

    [System.Object]
    [parameter(Mandatory = $false, Position=4)]
    $Headers,

    [Switch]
    [parameter(Mandatory = $false, Position=5)]
    $ContinueEvenFailed
  )

  $Request = New-RedfishRequest $Session $Path $Method $Headers

  try {
    if ($method -in @('Put', 'Post', 'Patch')) {
      if ($null -eq $Payload -or '' -eq $Payload) {
        $PayloadString = '{}'
      } else {
        $PayloadString = $Payload | ConvertTo-Json
      }
      $Request.ContentType = 'application/json'
      $Request.ContentLength = $PayloadString.length

      $StreamWriter = New-Object System.IO.StreamWriter($Request.GetRequestStream(), [System.Text.Encoding]::ASCII)
      $StreamWriter.Write($PayloadString)
      $StreamWriter.Close()
      $Logger.debug("Send request payload: $PayloadString")
    }

    # https://docs.microsoft.com/en-us/dotnet/framework/network-programming/how-to-request-data-using-the-webrequest-class
    return $Request.GetResponse()
  }
  catch {
    # .Net HttpWebRequest will throw Exception if response is not success (status code is great than 400)
    # https://stackoverflow.com/questions/10081726/why-does-httpwebrequest-throw-an-exception-instead-returning-httpstatuscode-notf
    # [System.Net.HttpWebResponse] $response = $_.Exception.InnerException.Response
    $Logger.info($Request)
    $Logger.info($Request.Headers)
    $Logger.Error($_)
    Resolve-RedfishFailtureResponse $_ $ContinueEvenFailed
  }
  finally {
    if ($null -ne $StreamWriter -and $StreamWriter -is [System.IDisposable]) {
      $StreamWriter.Dispose()
    }
  }
}

function New-RedfishRequest {
  [cmdletbinding()]
  param (
    [RedfishSession]
    [parameter(Mandatory = $true, Position=0)]
    $Session,

    [System.String]
    [parameter(Mandatory = $true, Position=1)]
    $Path,

    [System.String]
    [parameter(Mandatory = $false, Position=2)]
    [ValidateSet('Get', 'Delete', 'Put', 'Post', 'Patch')]
    $Method = 'Get',

    [System.Object]
    [parameter(Mandatory = $false, Position=4)]
    $Headers
  )

  if ($Path.StartsWith("https://", "CurrentCultureIgnoreCase")) {
    $OdataId = $Path
  }
  elseif ($Path.StartsWith("/redfish/v1", "CurrentCultureIgnoreCase")) {
    $OdataId = "$($session.BaseUri)$($Path)"
  }
  else {
    $OdataId = "$($session.BaseUri)/redfish/v1$($Path)"
  }

  if ('If-Match' -notin $Headers.Keys -and $method -in @('Put', 'Patch')) {
    $Response = Invoke-RedfishRequest -Session $Session -Path $Path
    $Response.close()
    $etag = $Response.Headers.ETag
    $Logger.info("Odata $OdataId 's etag is $etag")
  }

  $Logger.info("Invoke redfish request: [$Method] $OdataId")

  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
  [System.Net.HttpWebRequest] $Request = [System.Net.HttpWebRequest]::Create($OdataId)
  # $cert = Get-ChildItem -Path cert:\CurrentUser\My | where-object Thumbprint -eq B2536A31C7A7462BBA542B4A8B0C34E315D16AB9
  # Write-Host $cert
  # $Store = New-Object System.Security.Cryptography.X509Certificates.X509Store(
  #         [System.Security.Cryptography.X509Certificates.StoreName]::My, "CurrentUser")
  # $Store.Open("MaxAllowed")
  # $Certificate = $Store.Certificates |  Where-Object Thumbprint -Eq "B2536A31C7A7462BBA542B4A8B0C34E315D16AB9"
  # Write-Host $Certificate
  # # $Request.ClientCertificates.Add($Certificate)
  # $Request.ClientCertificates.AddRange($Certificate)

  $Request.ServerCertificateValidationCallback = {
    param($sender, $certificate, $chain, $errors)
    if ($true -eq $session.TrustCert) {
      # $Logger.debug("TrustCert present, Ignore HTTPS certification")
      return $true
    }
    if ($Request -eq $sender) {
      $Certificates = $(Get-ChildItem -Path cert:\ -Recurse | where-object Thumbprint -eq $certificate.Thumbprint)
      if ($null -ne $Certificates -and $Certificates.count -gt 0) {
        return $true
      } else {
        return $false
      }
    }
    return $($errors -eq 'None')
  }


  $Request.Method = $Method
  $Request.UserAgent = "PowerShell Huawei iBMC Cmdlet - by xmfive@qq.com"
  $Request.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
  # $Request.AutomaticDecompression = [System.Net.DecompressionMethods]::GZip

  if ($null -ne $session.AuthToken) {
    $Request.Headers.Add('X-Auth-Token', $session.AuthToken)
  }

  if ($null -ne $Headers) {
    $Headers.Keys | ForEach-Object {
      $Request.Headers.Add($_, $Headers.Item($_))
    }
  }

  if ($null -ne $etag) {
    $Request.Headers.Add('If-Match', $etag)
  }

  return $Request;
}


function Resolve-RedfishFailtureResponse ($Ex, $ContinueEvenFailed) {
  $response = $Ex.Exception.InnerException.Response
  if ($null -ne $response) {
    if ($ContinueEvenFailed) {
      return $response
    }

    $StatusCode = $response.StatusCode.value__
    $Content = Get-WebResponseContent $response
    $Logger.warn("[$Method] $OdataId -> code: $StatusCode , content: $Content")
    if ($StatusCode -eq 403){
      throw $(Get-i18n "FAIL_NO_PRIVILEGE")
    }
    elseif ($StatusCode -eq 500) {
      throw $(Get-i18n "FAIL_INTERNAL_SERVICE")
    }
    elseif ($StatusCode -eq 501) {
      throw $(Get-i18n "FAIL_NOT_SUPPORT")
    }

    $result = $Content | ConvertFrom-Json
    $extendInfoList = $result.error.'@Message.ExtendedInfo'
    if ($extendInfoList.Count -gt 0) {
      $extendInfo0 = $extendInfoList[0]
      throw "Failure: [$($extendInfo0.Severity)] $($extendInfo0.Message)"
    }
    throw $Ex.Exception
  } else {
    throw $Ex.Exception
  }
}

function ConvertFrom-WebResponse {
  param (
    [System.Net.HttpWebResponse]
    [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $Response
  )
  return Get-WebResponseContent $Response | ConvertFrom-Json
}

function Get-WebResponseContent {
  param (
    [System.Net.HttpWebResponse]
    [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $Response
  )
  try {
    $stream = $response.GetResponseStream();
    $streamReader = New-Object System.IO.StreamReader($stream)
    $content = $streamReader.ReadToEnd();
    # $Logger.debug("Redfish API Response: [$($response.StatusCode.value__)] $content")
    return $content
  }
  finally {
    $streamReader.close()
    $stream.close()
    $response.close()
  }
}
