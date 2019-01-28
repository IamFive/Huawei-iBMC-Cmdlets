#
# Module manifest for module 'Huawei-iBMC-Cmdlets'
#
# Generated by: Woo
#
# Generated on: 2018-10-08
#

@{

  # Script module or binary module file associated with this manifest.
  RootModule             = 'Huawei-iBMC-Cmdlets.psm1'

  # Version number of this module.
  ModuleVersion          = '1.0.2'

  # Supported PSEditions
  # CompatiblePSEditions = @()

  # ID used to uniquely identify this module
  GUID                   = '89a819e4-4ce1-438a-bd57-ac9828aa5ef5'

  # Author of this module
  Author                 = 'Huawei Technologies Co., Ltd'

  # Company or vendor of this module
  CompanyName            = 'Huawei Technologies Co., Ltd'

  # Copyright statement for this module
  Copyright              = '(c) 2018 Huawei Technologies Co., Ltd. All rights reserved.'

  # Description of the functionality provided by this module
  Description            = 'Huawei iBMC cmdlets provide cmdlets to quick access iBMC Redfish devices.
These cmdlets contains operation used most such as: bois setting, syslog, snmp, network, power and etc.'

  # Minimum version of the Windows PowerShell engine required by this module
  PowerShellVersion      = '5.0'

  # Name of the Windows PowerShell host required by this module
  # PowerShellHostName = ''

  # Minimum version of the Windows PowerShell host required by this module
  # PowerShellHostVersion = ''

  # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
  DotNetFrameworkVersion = '4.5'

  # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
  CLRVersion             = '4.0'

  # Processor architecture (None, X86, Amd64) required by this module
  # ProcessorArchitecture = ''

  # Modules that must be imported into the global environment prior to importing this module
  # RequiredModules = @()

  # Assemblies that must be loaded prior to importing this module
  # RequiredAssemblies = @()

  # Script files (.ps1) that are run in the caller's environment prior to importing this module.
  # ScriptsToProcess = @()

  # Type files (.ps1xml) to be loaded when importing this module
  # TypesToProcess = @()

  # Format files (.ps1xml) to be loaded when importing this module
  # FormatsToProcess = @()

  # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
  # NestedModules = @()

  # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
  # FunctionsToExport = '*-iBMC*'

  # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
  CmdletsToExport        = '*'

  # Variables to export from this module
  VariablesToExport      = '*'

  # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
  AliasesToExport        = @()

  # DSC resources to export from this module
  # DscResourcesToExport = @()

  # List of all modules packaged with this module
  # ModuleList = @()

  # List of all files packaged with this module
  FileList               = @(
    "Huawei-iBMC-Cmdlets.psd1",
    "Huawei-iBMC-Cmdlets.psm1",
    "common/Common.ps1",
    "common/Constants.ps1",
    "common/i18n.ps1",
    "common/log4net.dll",
    "common/Log4Net.xml",
    "common/Logger.ps1",
    "common/Redfish.ps1",
    "common/Threads.ps1",
    "common/Types.ps1",
    "scripts/AssetTag.ps1",
    "scripts/BIOS-Settings.ps1",
    "scripts/Connection.ps1",
    "scripts/CPU.ps1",
    "scripts/Deploy.ps1",
    "scripts/Drive.ps1",
    "scripts/Fan.ps1",
    "scripts/Firmware.ps1",
    "scripts/iBMC-Setting.ps1",
    "scripts/Manager.ps1",
    "scripts/Memory.ps1",
    "scripts/NetworkAdapter.ps1",
    "scripts/NTP.ps1",
    "scripts/Power.ps1",
    "scripts/PowerControl.ps1",
    "scripts/RAID.ps1",
    "scripts/Service.ps1",
    "scripts/SMTP.ps1",
    "scripts/SNMP.ps1",
    "scripts/SPRAID.ps1",
    "scripts/Syslog.ps1",
    "scripts/System.ps1",
    "scripts/User.ps1",
    "scripts/Volume.ps1"
  )

  # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
  PrivateData            = @{

    PSData = @{

      # Tags applied to this module. These help with module discovery in online galleries.
      Tags         = @('Huawei', 'Enterprise', 'iBMC', 'Redfish', 'Huawei-iBMC-Cmdlets')

      # A URL to the license for this module.
      # LicenseUri = ''

      # A URL to the main website for this project.
      # ProjectUri = ''

      # A URL to an icon representing this module.
      # IconUri = ''

      # ReleaseNotes of this module
      ReleaseNotes = 'Huawei-iBMC-Cmdlets - Version 1.0.0'

    } # End of PSData hashtable

  } # End of PrivateData hashtable

  # HelpInfo URI of this module
  # HelpInfoURI = ''

  # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
  # DefaultCommandPrefix = ''

}


