<# NOTE: iBMC AssetTag module Cmdlets #>

function Get-iBMCSystemInfo {
<#
.SYNOPSIS
Get system resource details of the server.

.DESCRIPTION
Get system resource details of the server.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.OUTPUTS
String
Returns iBMC Asset Tag if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> $System = Get-iBMCSystemInfo $session
PS C:\> $System

@odata.context     : /redfish/v1/$metadata#Systems/Members/$entity
@odata.id          : /redfish/v1/Systems/1
@odata.type        : #ComputerSystem.v1_2_0.ComputerSystem
Id                 : 1
Name               : Computer System
AssetTag           :
Manufacturer       : Huawei
Model              : 2288H V5
SerialNumber       : 2102311TYBN0J3000293
UUID               : 877AA970-58F9-8432-E811-80345C184638
HostName           :
PartNumber         : 02311TYB
HostingRole        : {ApplicationServer}
Status             : @{State=Enabled; Health=OK}
PowerState         : On
Boot               : @{BootSourceOverrideTarget=None; BootSourceOverrideEnabled=Disabled; BootSourceOverrideMode=UEFI; Bo
                     otSourceOverrideTarget@Redfish.AllowableValues=System.Object[]}
TrustedModules     :
BiosVersion        : 0.81
ProcessorSummary   : @{Count=2; Model=Central Processor; Status=}
MemorySummary      : @{TotalSystemMemoryGiB=128; Status=}
Processors         : @{@odata.id=/redfish/v1/Systems/1/Processors}
Memory             : @{@odata.id=/redfish/v1/Systems/1/Memory}
EthernetInterfaces : @{@odata.id=/redfish/v1/Systems/1/EthernetInterfaces}
Storage            : @{@odata.id=/redfish/v1/Systems/1/Storages}
NetworkInterfaces  : @{@odata.id=/redfish/v1/Systems/1/NetworkInterfaces}
LogServices        : @{@odata.id=/redfish/v1/Systems/1/LogServices}
PCIeDevices        : {}
PCIeFunctions      : {}
Bios               : @{@odata.id=/redfish/v1/Systems/1/Bios}
Links              : @{Chassis=System.Object[]; Managers=System.Object[]}
Oem                : @{Huawei=}
Actions            : @{#ComputerSystem.Reset=; Oem=}


.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Connect-iBMC
Disconnect-iBMC
#>
  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    $Session
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
  }

  process {
    $Logger.info("Invoke Get iBMC System function")

    $ScriptBlock = {
      param($RedfishSession)
      $(Get-Logger).info($(Trace-Session $RedfishSession "Invoke Get iBMC System now"))
      $Path = "/Systems/$($RedfishSession.Id)"
      $Response = Invoke-RedfishRequest $RedfishSession $Path | ConvertFrom-WebResponse
      return $Response
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Logger.info($(Trace-Session $RedfishSession "Submit Get iBMC System task"))
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock @($RedfishSession)))
      }

      $Results = Get-AsyncTaskResults $tasks
      return $Results
    }
    finally {
      $pool.close()
    }
  }

  end {
  }
}


function Get-iBMCSystemNetworkSetting {
<#
.SYNOPSIS
Get system resource details of the server.

.DESCRIPTION
Get system resource details of the server.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.OUTPUTS
PSObject[][]
Returns iBMC System LinkUp Ethernet Interfaces if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> $Interfaces = Get-iBMCSystemInfo $session
PS C:\> $Interfaces

Id                  : mainboardLOMPort1
Name                : System Ethernet Interface
PermanentMACAddress : 58:F9:87:7A:A9:73
LinkStatus          : LinkUp
IPv4Addresses       : {}
IPv6Addresses       : {}
IPv6DefaultGateway  :
InterfaceType       : Physical
BandwidthUsage      :
BDF                 : 0000:1a:00.0

Id                  : mainboardLOMPort2
Name                : System Ethernet Interface
PermanentMACAddress : 58:F9:87:7A:A9:74
LinkStatus          : LinkUp
IPv4Addresses       : {}
IPv6Addresses       : {}
IPv6DefaultGateway  :
InterfaceType       : Physical
BandwidthUsage      :
BDF                 : 0000:1a:00.1

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Connect-iBMC
Disconnect-iBMC
#>
  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    $Session
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
  }

  process {
    $Logger.info("Invoke Get iBMC System Networking Settings function")

    $ScriptBlock = {
      param($RedfishSession)
      $(Get-Logger).info($(Trace-Session $RedfishSession "Invoke Get iBMC System Networking Settings now"))
      $GetInterfacesPath = "/Systems/$($RedfishSession.Id)/EthernetInterfaces"
      $EthernetInterfaces = Invoke-RedfishRequest $RedfishSession $GetInterfacesPath | ConvertFrom-WebResponse
      $Results = New-Object System.Collections.ArrayList
      for ($idx=0; $idx -lt $EthernetInterfaces.Members.Count; $idx++) {
        $Member = $EthernetInterfaces.Members[$idx]
        $EthernetInterface = Invoke-RedfishRequest $RedfishSession $Member.'@odata.id' | ConvertFrom-WebResponse
        $Logger.Debug($(Trace-Session $RedfishSession "Load EthernetInterface: $EthernetInterface"))
        if ($BMC.LinkStatus.LinkUp -eq $EthernetInterface.LinkStatus) {
          $Properties = @(
            "Id", "Name", "PermanentMACAddress", "LinkStatus",
            "IPv4Addresses", "IPv6Addresses", "IPv6DefaultGateway"
          )
          $Clone = Copy-ObjectProperties $EthernetInterface $Properties
          $Clone | Add-Member -MemberType NoteProperty "InterfaceType" $EthernetInterface.Oem.Huawei.InterfaceType
          $Clone | Add-Member -MemberType NoteProperty "BandwidthUsage" $EthernetInterface.Oem.Huawei.BandwidthUsage
          $Clone | Add-Member -MemberType NoteProperty "BDF" $EthernetInterface.Oem.Huawei.BDF
          [Void] $Results.add($Clone)
        }
      }

      if ($Results.Count -eq 0) {
        throw $(Get-i18n FAIL_NO_LINKUP_INTERFACE)
      }

      return ,$Results
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Logger.info($(Trace-Session $RedfishSession "Submit Get iBMC System Networking Settings task"))
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock @($RedfishSession)))
      }
      $Results = Get-AsyncTaskResults $tasks
      return ,$Results
    }
    finally {
      $pool.close()
    }
  }

  end {
  }
}