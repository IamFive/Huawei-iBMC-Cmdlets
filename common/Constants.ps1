$global:BMC = @{

  'V52V3Mapping' = @{
    'HardDiskDrive'='HDD';
    'DVDROMDrive'='Cd';
    'PXE'='Pxe';
    'Others'='Others';
  };

  'V32V5Mapping' = @{
    'HDD'='HardDiskDrive';
    'Cd'='DVDROMDrive';
    'Pxe'='PXE';
    'Others'='Others';
  };

  Severity = @{
    OK='OK';
  };

  FRUOperationSystem = 0;

}
