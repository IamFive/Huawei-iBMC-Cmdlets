Import-Module Huawei.iBMC.Cmdlets -Force


Describe "Start Thread Script Block" {
  It "Start " {
    $tasks = @()
    $pool = New-RunspacePool 2
    1..2 | ForEach-Object {
        $ScriptBlock = {
            Start-Sleep -s 10
            return 'a'
        }
        $tasks += $(Start-ScriptBlockThread $pool $ScriptBlock)
    }

    $result = Get-AsyncTaskResults -AsyncTasks $tasks
    $result | foreach {
        Write-Host $_
    }
  }
}
