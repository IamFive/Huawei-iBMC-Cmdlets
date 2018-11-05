Import-Module Huawei-iBMC-Cmdlets -Force

try {
  $RedfishSession = New-iBMCRedfishSession -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert

  $Path = "/Managers/$($RedfishSession.Id)/SnmpService"
  # $snmp = Invoke-RedfishRequest $RedfishSession $Path
  # $etag = $snmp.Headers.get('ETag')
  # $snmp.close()

  # $Headers = @{'If-Match'=$etag;}


  $Payload = @{
    "SnmpV1Enabled"=$true;
  }
  Invoke-RedfishRequest $RedfishSession $Path 'Patch' $Payload $Headers
}
finally {
    Close-iBMCRedfishSession $RedfishSession
}