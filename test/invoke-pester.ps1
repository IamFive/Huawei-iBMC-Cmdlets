Invoke-Pester -Script "$PSScriptRoot\Huawei.iBMC.Cmdlets.Tests.ps1"
Invoke-Pester -Script "$PSScriptRoot\Connection.Tests.ps1"
Invoke-Pester -Script "$PSScriptRoot\User.Tests.ps1"
Invoke-Pester -Script "$PSScriptRoot\Deploy.Tests.ps1"
Invoke-Pester -Script "$PSScriptRoot\Service.Tests.ps1"
Invoke-Pester -Script "$PSScriptRoot\SNMP.Tests.ps1"
Invoke-Pester -Script "$PSScriptRoot\SMTP.Tests.ps1"
Invoke-Pester -Script "$PSScriptRoot\Syslog.Tests.ps1"
Invoke-Pester -Script "$PSScriptRoot\AssetTag.Tests.ps1"
Invoke-Pester -Script "$PSScriptRoot\BIOS.Settings.Tests.ps1"
