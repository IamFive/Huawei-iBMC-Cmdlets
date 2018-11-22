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

  LinkStatus = @{
    NoLink='NoLink';
    LinkUp='LinkUp';
  };

  TaskState = @{
    Completed='Completed';
  };

  FRUOperationSystem = 0;

  OutBandFirmwares = @(
    "ActiveBMC", "BackupBMC", "Bios", "MainBoardCPLD", "chassisDiskBP1CPLD"
  );

  InBandFirmwares = @(
    "PCIeCards"
  );

  SupportImageFileSchema = @(
    "https",
    "scp",
    "sftp",
    "cifs",
    "tftp",
    "nfs"
  )


}
