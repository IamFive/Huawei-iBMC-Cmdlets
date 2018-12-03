$ModuleManifestName = 'Huawei-iBMC-Cmdlets.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\$ModuleManifestName"

Describe 'Module Manifest Tests' {

  It 'Passes Test-ModuleManifest' {
    Test-ModuleManifest -Path $ModuleManifestPath | Should Not BeNullOrEmpty
    $? | Should Be $true
  }

  It 'Test Module Version' {
    $Module = Get-iBMCModuleVersion
    $Module.GUID | Should -be '89a819e4-4ce1-438a-bd57-ac9828aa5ef5'
    $Module.Name | Should -be 'Huawei-iBMC-Cmdlets'
    $Module.Version | Should -be '1.0.0'
    $Module.Path | Should -BeLike '*\Huawei-iBMC-Cmdlets.psm1'
    $Module.Description | Should -Be 'Huawei iBMC cmdlets provide cmdlets to quick access iBMC Redfish devices.
These cmdlets contains operation used most such as: bois setting, syslog, snmp, network, power and etc.'
  }

}

