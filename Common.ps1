<# NOTE: Common Utilities #>

. $PSScriptRoot/I18n.ps1
. $PSScriptRoot/Logger.ps1
. $PSScriptRoot/Threads.ps1

function Convert-IPSegment($IPSegment) {
  <#
.DESCRIPTION
Convert a specified ip segment expression to all possible int ip segment array

.EXAMPLE
PS C:\> Convert-IPSegment 3-4,5,10
PS C:\> 3 4 5 10

#>
  $result = @()
  $IPSegment.Split(',') | ForEach-Object {
    $split = $_.Split('-')
    $result += $($([int]$split[0])..$([int]$split[-1]))
  }
  return $result
}

function ConvertFrom-IPRangeString {
  param (
    [System.String[]][parameter(Mandatory=$false)] $IPRangeString
  )

  $port_regex = ':([1-9]|[1-9]\d|[1-9]\d{2}|[1-9]\d{3}|[1-5]\d{4}|6[0-4]\d{3}|65[0-4]\d{2}|655[0-2]\d|6553[0-5])'

  $hostnameSection = "([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])"
  [regex] $hostnameRegex = "^$hostnameSection(\.$hostnameSection)+($port_regex)?`$"

  $ipv4Section = '(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])'
  $ipv4RangedSection = "$ipv4Section(-$ipv4Section)?"
  $ipv4RangeSectionWithComma = "$ipv4RangedSection(,$ipv4RangedSection)*"
  [regex] $ipv4_regex = "^($ipv4RangeSectionWithComma(\.$ipv4RangeSectionWithComma){3})($port_regex)?`$"

  # TODO add ipv6 range support
  # $ipv6Section='[0-9A-Fa-f]{1,4}'
  # $ipv6RangedSection="$ipv6Section(-$ipv6Section)?"
  # $ipv6RangedSectionWithComma="$ipv6RangedSection(,$ipv6RangedSection)*"

  $IPArray = New-Object System.Collections.ArrayList

  $AllIpRangeString = $IPRangeString -join ' '
  -split $AllIpRangeString | ForEach-Object {
    $matches = $ipv4_regex.Matches($_)
    if ($matches.Count -eq 1) {
      $singleIpRange = $matches[0].Groups[1].Value
      $port = $_ -replace $singleIpRange, ''

      $segments = $singleIpRange.Split('.')
      $segment1 = Convert-IPSegment $segments[0]
      $segment2 = Convert-IPSegment $segments[1]
      $segment3 = Convert-IPSegment $segments[2]
      $segment4 = Convert-IPSegment $segments[3]

      foreach ($s1 in $segment1) {
        foreach ($s2 in $segment2) {
          foreach ($s3 in $segment3) {
            foreach ($s4 in $segment4) {
              [Void] $IPArray.Add("$(@($s1, $s2, $s3, $s4) -join '.')$port")
            }
          }
        }
      }
    }
    elseif ($_ -match $hostnameRegex) {
      [Void] $IPArray.Add($_)
    }
    else {
      throw "Illegal Address: $_"
    }
  }

  return $IPArray
}


function Get-MatchedSizeArray($Source, $Target, $SourceName, $TargetName) {
  if ($Target.Count -eq 1 -and $Source.Count -ne 1) {
    $Target = $Target * $Source.Count
  }
  if ($Source.Count -ne $Target.Count) {
    throw $([string]::Format($Bundle.ERROR_PARAMETER_COUNT_DIFFERERNT, $SourceName, $TargetName))
  }
  return $Target
}


function Assert-NotNull($Parameter, $ParameterName) {
  if ($null -eq $Parameter) {
    throw $([string]::Format($Bundle.ERROR_PARAMETER_EMPTY, $ParameterName))
  }
}

function Assert-ArrayNotNull($Parameter, $ParameterName) {
  if ($null -eq $Parameter -or $Parameter.Count -eq 0 -or $Parameter -contains $null) {
    throw $([string]::Format($Bundle.ERROR_PARAMETER_ARRAY_EMPTY, $ParameterName))
  }
}