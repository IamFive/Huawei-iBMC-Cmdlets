# Implement your module commands in this script.

. $PSScriptRoot/Common.ps1
. $PSScriptRoot/Redfish.ps1

# Import all functional scripts
Get-ChildItem -Path $PSScriptRoot\scripts\ -Recurse -Filter *.ps1 | foreach {
  . $_.FullName
}


# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
