Import-Module Huawei.iBMC.Cmdlets -Force


Describe "Start Thread Script Block" {
  It "Start " {
    Write-Input 1
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
