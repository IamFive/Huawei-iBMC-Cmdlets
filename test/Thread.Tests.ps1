Import-Module Huawei-iBMC-Cmdlets -Force

$CommonFiles = @(Get-ChildItem -Path $PSScriptRoot\..\common -Recurse -Filter *.ps1)
# $ScriptFiles = @(Get-ChildItem -Path $PSScriptRoot\..\scripts -Recurse -Filter *.ps1)
$CommonFiles | ForEach-Object {
  try {
    . $_.FullName
  } catch {
      Write-Error -Message "Failed to import file $FileFullPath"
  }
}

Describe "Start Thread Script Block" {
  It "Start " {
    $tasks = New-Object System.Collections.ArrayList
    $pool = New-RunspacePool 2
    1..2 | ForEach-Object {
        $ScriptBlock = {
            return $index
        }
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool "Write-Host" @($_)))
    }

    $result = Get-AsyncTaskResults -AsyncTasks $tasks
    $result | foreach {
        Write-Host $_
    }
  }
}
