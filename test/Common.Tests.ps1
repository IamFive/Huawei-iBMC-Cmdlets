Import-Module Huawei.iBMC.Cmdlets -Force

Describe "Common Utils" {
  It "Get-OptionalMatchedSizeArray with null" {
    $Source = @(1)
    $Target = $null
    $Target2 = Get-OptionalMatchedSizeArray $Source $Target
    $Target2.Count | Should -Be 1
    $Target2 -is [Array] | Should -Be $true
  }

  It "Get-OptionalMatchedSizeArray with same size array" {
    $Source = @("source")
    $Target = @("target")
    $Target2 = Get-OptionalMatchedSizeArray $Source $Target
    $Target2.Count | Should -Be 1
    $Target2 -is [Array] | Should -Be $true
    $Target2[0] | Should -Be 'target'
  }

  It "Get-OptionalMatchedSizeArray with not same size array" {
    $Source = @("source1", "source2")
    $Target = @("target")
    $Target2 = Get-OptionalMatchedSizeArray $Source $Target
    $Target2.Count | Should -Be 2
    $Target2 -is [Array] | Should -Be $true
    $Target2 | Should -Be @('target', 'target')
  }
}

Describe "Common Utils" {
  It "Remove-EmptyValues " {
    $Source = @{
      "key1"= "";
      "key2"= "value2";
      "key3"= $null;
      "key4"= @();
    }

    $result = Remove-EmptyValues $Source
    $result.count | Should -Be 1
    $result.keys.count | Should -Be 1
    $result.key2 | Should -Be "value2"
  }
}
