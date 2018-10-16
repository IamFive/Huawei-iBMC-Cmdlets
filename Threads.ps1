<# NOTE: A PowerShell simple multiple thread support implementation. #>

# PowerShell 3+
# Foreach -parallel ( $srv in gc c:\input.txt )
# {
# Scriptblock..........
# }


try { [AsyncTask] | Out-Null } catch {
Add-Type @'
public class AsyncTask
{
  public System.String ID;
  public System.Management.Automation.PowerShell PowerShell;
  public System.IAsyncResult AsyncResult;
  public System.DateTime StartTime;
  public System.Boolean isRunning;
}
'@
}


# function New-Task([int]$Index,[scriptblock]$ScriptBlock) {
#   $ps = [Management.Automation.PowerShell]::Create()
#   $res = New-Object PSObject -Property @{
#       Index = $Index
#       Powershell = $ps
#       StartTime = Get-Date
#       Busy = $true
#       Data = $null
#       async = $null
#   }

#   [Void] $ps.AddScript($ScriptBlock)
#   [Void] $ps.AddParameter("TaskInfo",$Res)
#   $res.async = $ps.BeginInvoke()
#   $res
# }

# $ScriptBlock = {
#   param([Object]$TaskInfo)
#   $TaskInfo.Busy = $false
#   Start-Sleep -Seconds 1
#   $TaskInfo.Data = "test $($TaskInfo.Data)"
# }

# $a = New-Task -Index 1 -ScriptBlock $ScriptBlock
# $a.Data = "i was here"
# Start-Sleep -Seconds 5
# $a

function Get-RunspacePoolSize ($expectPoolSize) {
  $maxPoolSize = 16
  $poolSize = (@($expectPoolSize, $maxPoolSize) | Measure-Object -Minimum).Minimum
  return $poolSize
}


function New-RunspacePool {
  [Cmdletbinding()]
  Param
  (
    [Parameter(Position = 0, Mandatory = $true)][int]$ExpectPoolSize,
    [Parameter(Position = 1, Mandatory = $False)][Switch]$MTA
  )

  $PoolSize = Get-RunspacePoolSize $ExpectPoolSize
  Write-Log "Create thread pool, expect pool size: $ExpectPoolSize, real pool size: $PoolSize"

  $pool = [RunspaceFactory]::CreateRunspacePool(1, $PoolSize)
  If (!$MTA) {
    Write-Log "Thread pool apartment state: STA"
    $pool.ApartmentState = 'STA'
  } else {
    Write-Log "Thread pool apartment state: MTA"
    $pool.ApartmentState = 'MTA'
  }
  $pool.Open()
  return $pool
}

function Start-ScriptBlockThread {
  [Cmdletbinding()]
  Param
  (
    [Parameter(Position = 0, Mandatory = $True)]$ThreadPool,
    [Parameter(Position = 1, Mandatory = $True)][ScriptBlock]$ScriptBlock,
    [Parameter(Position = 2, Mandatory = $False)][Object[]]$Parameters
  )

  $PowerShell = [System.Management.Automation.PowerShell]::Create()
  $PowerShell.RunspacePool = $ThreadPool

  [Void] $PowerShell.AddScript($ScriptBlock)
  Foreach ($Arg in $Parameters) {
    [Void] $PowerShell.AddArgument($Arg)
  }

  Write-Log "Start script block thread" "DEBUG"
  $AsyncResult = $PowerShell.BeginInvoke()

  $Task = New-Object AsyncTask
  $Task.PowerShell = $PowerShell
  $Task.StartTime = Get-Date
  $Task.AsyncResult = $AsyncResult
  $Task.isRunning = $true
  return $Task
}

function Get-AsyncTaskResults {
  [Cmdletbinding()]
  Param
  (
    [Parameter(Position = 0, Mandatory = $True)][AsyncTask[]] $AsyncTasks,
    [Parameter(Position = 1, Mandatory = $false)][Switch] $ShowProgress
  )
  # incrementing for Write-Progress
  $i = 1
  foreach ($AsyncTask in $AsyncTasks) {
    try {
      # waiting for powershell invoke finished and return result
      $AsyncTask.PowerShell.EndInvoke($AsyncTask.AsyncResult)
      If ($AsyncTask.PowerShell.Streams.Error) {
        throw $AsyncTask.PowerShell.Streams.Error
      }
    }
    catch {
      $_
    }
    finally {
      $AsyncTask.isRunning = $false
      $AsyncTask.PowerShell.Dispose()
    }

    If ($ShowProgress) {
      Write-Progress -Activity $bundle.MSG_WAIT_PROGRESS_TITLE `
        -PercentComplete $(($i++ / $AsyncTasks.Count) * 100) `
        -Status $bundle.MSG_WAIT_PROGRESS_PERCENT
    }
  }
}
