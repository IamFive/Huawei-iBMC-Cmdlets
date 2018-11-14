try { [SnmpV3PrivProtocol] | Out-Null } catch {
  Add-Type -TypeDefinition @'
    public enum SnmpV3PrivProtocol {
      DES,
      AES
    }
'@
}

try { [SnmpV3AuthProtocol] | Out-Null } catch {
  Add-Type -TypeDefinition @'
    public enum SnmpV3AuthProtocol {
      MD5,
      SHA1
    }
'@
}

try { [TrapVersion] | Out-Null } catch {
  Add-Type -TypeDefinition @'
    public enum TrapVersion {
      V1,
      V2C,
      V3
    }
'@
}

try { [TrapMode] | Out-Null } catch {
  Add-Type -TypeDefinition @'
    public enum TrapMode {
      OID,
      EventCode,
      PreciseAlarm
    }
'@
}

try { [ServerIdentity] | Out-Null } catch {
  Add-Type -TypeDefinition @'
    public enum ServerIdentity {
      HostName,
      BoardSN,
      ProductAssetTag
    }
'@
}

try { [AlarmSeverity] | Out-Null } catch {
  Add-Type -TypeDefinition @'
    public enum AlarmSeverity {
      Critical,
      Major,
      Minor,
      Normal
    }
'@
}
