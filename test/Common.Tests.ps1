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
      "key5"= $false;
      "key6"= $true;
    }

    $result = Remove-EmptyValues $Source
    $result.count | Should -Be 3
    $result.keys.count | Should -Be 3
    $result.key2 | Should -Be "value2"
    $result.key5 | Should -Be $false
    $result.key6 | Should -Be $true
  }

  It "Remove-EmptyValues with complex object" {
    $pwd = ConvertTo-SecureString -String old-user-password -AsPlainText -Force
    $Source = @{
      "key1"= "";
      "key2"= $pwd;
      "key3"= $null;
      "key4"= @();
      "key5"= $false;
      "key6"= $true;
    }

    $result = Remove-EmptyValues $Source
    $result.count | Should -Be 3
    $result.keys.count | Should -Be 3
    $result.key2 | Should -Be "value2"
    $result.key5 | Should -Be $false
    $result.key6 | Should -Be $true
  }
}
