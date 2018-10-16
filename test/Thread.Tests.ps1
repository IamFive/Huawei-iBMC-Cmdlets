Import-Module Huawei.iBMC.Cmdlets -Force


Describe "Start Thread Script Block" {
  It "Start " {
    $tasks = New-Object System.Collections.ArrayList
    $pool = New-RunspacePool 2
    1..2 | ForEach-Object {
        $ScriptBlock = {
            New-iBMCRedfishSession -Address "112.93.129.9" -Username "chajian1" -Password "chajian12#$" -TrustCert
        }
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock))
    }

    $result = Get-AsyncTaskResults -AsyncTasks $tasks
    $result | foreach {
        Write-Host $_
    }
  }
}
