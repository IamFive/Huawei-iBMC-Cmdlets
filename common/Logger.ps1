<# NOTE: A PowerShell Logger implementation. #>

function Enable-Log4Net() {
  $env:LogFileRoot = "$PSScriptRoot\..\logs"
  $Log4NetDllPath = "$PSScriptRoot\log4net.dll"
  $Log4NetConfigFilePath = "$PSScriptRoot\Log4Net.xml"

  # load the log4net library
  [void][Reflection.Assembly]::LoadFile($Log4NetDllPath)
  # configure logging
  [log4net.LogManager]::ResetConfiguration()

  $LogConfigFileInfo = New-Object System.IO.FileInfo($Log4NetConfigFilePath)
  [log4net.Config.XmlConfigurator]::Configure($LogConfigFileInfo)

  $global:Logger = [log4net.LogManager]::GetLogger("root")
  $Logger.info("Log4Net initialized.")
  return $Logger
}

function Get-Logger ($name) {
  return [log4net.LogManager]::GetLogger($name)
}

# to null to avoid output
$Null = @(
  Enable-Log4Net
)