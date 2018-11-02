try {
  $session = Connect-iBMC -Address 112.93.129.9 -Username chajian1 -Password "chajian12#$" -TrustCert
  Remove-iBMCUser -Session $session -Username powershell
}
finally {
    Disconnect-iBMC $session
}