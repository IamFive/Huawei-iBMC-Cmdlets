Import-Module Huawei-iBMC-Cmdlets -Force
$CommonFiles = @(Get-ChildItem -Path $PSScriptRoot\..\common -Recurse -Filter *.ps1)
# $ScriptFiles = @(Get-ChildItem -Path $PSScriptRoot\..\scripts -Recurse -Filter *.ps1)
$CommonFiles | ForEach-Object {
  try {
    . $_.FullName
  }
  catch {
    Write-Error -Message "Failed to import file $_"
  }
}

Describe "IPV6 Ranged" {
  It "Ipv6" {
    $result = ConvertFrom-IPRangeString "feef:2-3:3,4:4:5:6:7:8-9,a-b"
    $result | Should -Be @(
      "feef:2:3:4:5:6:7:8", "feef:2:3:4:5:6:7:9",  "feef:2:3:4:5:6:7:a", "feef:2:3:4:5:6:7:b",
      "feef:2:4:4:5:6:7:8", "feef:2:4:4:5:6:7:9",  "feef:2:4:4:5:6:7:a", "feef:2:4:4:5:6:7:b",
      "feef:3:3:4:5:6:7:8", "feef:3:3:4:5:6:7:9",  "feef:3:3:4:5:6:7:a", "feef:3:3:4:5:6:7:b",
      "feef:3:4:4:5:6:7:8", "feef:3:4:4:5:6:7:9",  "feef:3:4:4:5:6:7:a", "feef:3:4:4:5:6:7:b"
    )
  }
}


Describe "IPV6 Convertor" {


  It "Ipv6 segment reading" {
    $result = Convert-IPV6Segment "20F1-20F2,20F4,20F6-20F8"
    $result | Should -Be @('20F1', '20F2', '20F4', '20F6', '20F7', '20F8')

    $result = Convert-IPV6Segment "1-2,4,6-8"
    $result | Should -Be @('1', '2', '4', '6', '7', '8')

    $result = Convert-IPV6Segment "8-9,a-b"
    $result | Should -Be @('8', '9', 'a', 'b')
  }

  It "Ranged Ipv6" {
    $result = ConvertFrom-IPRangeString "feef:2-3:3,4:4:5:6:7:8-9,a-b"
    $result | Should -Be @(
      "feef:2:3:4:5:6:7:8", "feef:2:3:4:5:6:7:9",  "feef:2:3:4:5:6:7:a", "feef:2:3:4:5:6:7:b",
      "feef:2:4:4:5:6:7:8", "feef:2:4:4:5:6:7:9",  "feef:2:4:4:5:6:7:a", "feef:2:4:4:5:6:7:b",
      "feef:3:3:4:5:6:7:8", "feef:3:3:4:5:6:7:9",  "feef:3:3:4:5:6:7:a", "feef:3:3:4:5:6:7:b",
      "feef:3:4:4:5:6:7:8", "feef:3:4:4:5:6:7:9",  "feef:3:4:4:5:6:7:a", "feef:3:4:4:5:6:7:b"
    )
  }

  It "Ranged Ipv6" {
    $result = ConvertFrom-IPRangeString "[feef:2-3:3,4:4:5:6:7:8-9,a-b%eth2]:9000"
    $result | Should -Be @(
      "[feef:2:3:4:5:6:7:8%eth2]:9000", "[feef:2:3:4:5:6:7:9%eth2]:9000",  "[feef:2:3:4:5:6:7:a%eth2]:9000", "[feef:2:3:4:5:6:7:b%eth2]:9000",
      "[feef:2:4:4:5:6:7:8%eth2]:9000", "[feef:2:4:4:5:6:7:9%eth2]:9000",  "[feef:2:4:4:5:6:7:a%eth2]:9000", "[feef:2:4:4:5:6:7:b%eth2]:9000",
      "[feef:3:3:4:5:6:7:8%eth2]:9000", "[feef:3:3:4:5:6:7:9%eth2]:9000",  "[feef:3:3:4:5:6:7:a%eth2]:9000", "[feef:3:3:4:5:6:7:b%eth2]:9000",
      "[feef:3:4:4:5:6:7:8%eth2]:9000", "[feef:3:4:4:5:6:7:9%eth2]:9000",  "[feef:3:4:4:5:6:7:a%eth2]:9000", "[feef:3:4:4:5:6:7:b%eth2]:9000"
    )
  }


  It "standard Ipv6" {
    $result = ConvertFrom-IPRangeString "feef:2:3:4:5:6:7:8"
    $result | Should -Be @("feef:2:3:4:5:6:7:8")

    $result = ConvertFrom-IPRangeString "feef::8"
    $result | Should -Be @("feef::8")

    $result = ConvertFrom-IPRangeString "feef::"
    $result | Should -Be @("feef::")

    $result = ConvertFrom-IPRangeString "feef::7:8"
    $result | Should -Be @("feef::7:8")

    $result = ConvertFrom-IPRangeString "feef::5:6:7:8"
    $result | Should -Be @("feef::5:6:7:8")

    $result = ConvertFrom-IPRangeString "feef::4:5:6:7:8"
    $result | Should -Be @("feef::4:5:6:7:8")

    $result = ConvertFrom-IPRangeString "feef::3:4:5:6:7:8"
    $result | Should -Be @("feef::3:4:5:6:7:8")

    $result = ConvertFrom-IPRangeString "::3:4:5:6:7:8"
    $result | Should -Be @("::3:4:5:6:7:8")

    $result = ConvertFrom-IPRangeString "::255.255.255.255"
    $result | Should -Be @("::255.255.255.255")

    $result = ConvertFrom-IPRangeString "::ffff:255.255.255.255"
    $result | Should -Be @("::ffff:255.255.255.255")

    $result = ConvertFrom-IPRangeString "::ffff:0:255.255.255.255"
    $result | Should -Be @("::ffff:0:255.255.255.255")

    $result = ConvertFrom-IPRangeString "2001:db8:3:4::192.0.2.33"
    $result | Should -Be @("2001:db8:3:4::192.0.2.33")

    $result = ConvertFrom-IPRangeString "64:ff9b::192.0.2.33"
    $result | Should -Be @("64:ff9b::192.0.2.33")

    $result = ConvertFrom-IPRangeString "1:2:3:4::6:7:8"
    $result | Should -Be @("1:2:3:4::6:7:8")

    $result = ConvertFrom-IPRangeString "1:2:3:4:5:6:7::"
    $result | Should -Be @("1:2:3:4:5:6:7::")

    $result = ConvertFrom-IPRangeString "::"
    $result | Should -Be @("::")

    $result = ConvertFrom-IPRangeString "fe80::7:8%eth0"
    $result | Should -Be @("fe80::7:8%eth0")

    $result = ConvertFrom-IPRangeString "fe80::7:8%1"
    $result | Should -Be @("fe80::7:8%1")
  }


  # IPv6 RegEx
  # (
  # ([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|          # 1:2:3:4:5:6:7:8
  # ([0-9a-fA-F]{1,4}:){1,7}:|                         # 1::                              1:2:3:4:5:6:7::
  # ([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|         # 1::8             1:2:3:4:5:6::8  1:2:3:4:5:6::8
  # ([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|  # 1::7:8           1:2:3:4:5::7:8  1:2:3:4:5::8
  # ([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|  # 1::6:7:8         1:2:3:4::6:7:8  1:2:3:4::8
  # ([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|  # 1::5:6:7:8       1:2:3::5:6:7:8  1:2:3::8
  # ([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|  # 1::4:5:6:7:8     1:2::4:5:6:7:8  1:2::8
  # [0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|       # 1::3:4:5:6:7:8   1::3:4:5:6:7:8  1::8
  # :((:[0-9a-fA-F]{1,4}){1,7}|:)|                     # ::2:3:4:5:6:7:8  ::2:3:4:5:6:7:8 ::8       ::
  # fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|     # fe80::7:8%eth0   fe80::7:8%1     (link-local IPv6 addresses with zone index)
  # ::(ffff(:0{1,4}){0,1}:){0,1}
  # ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
  # (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|          # ::255.255.255.255   ::ffff:255.255.255.255  ::ffff:0:255.255.255.255  (IPv4-mapped IPv6 addresses and IPv4-translated addresses)
  # ([0-9a-fA-F]{1,4}:){1,4}:
  # ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
  # (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])           # 2001:db8:3:4::192.0.2.33  64:ff9b::192.0.2.33 (IPv4-Embedded IPv6 Address)
  # )
}



Describe "IPV4 Convertor" {

  It "standard Ipv4" {
    $result = ConvertFrom-IPRangeString "192.168.100.200"
    $result | Should -Be @("192.168.100.200")

    $result = ConvertFrom-IPRangeString "10.10.10.10"
    $result | Should -Be @("10.10.10.10")

    $result = ConvertFrom-IPRangeString "1.1.1.1"
    $result | Should -Be @("1.1.1.1")

    $result = ConvertFrom-IPRangeString "114.114.114.114"
    $result | Should -Be @("114.114.114.114")

    $result = ConvertFrom-IPRangeString "192.168.1.200:8080"
    $result | Should -Be @("192.168.1.200:8080")
  }

  It "Range IPV4" {
    $IPArray = ConvertFrom-IPRangeString "10.1-2.1,3.1-2,3-4:80"
    $IPArray | Should -Be @(
      "10.1.1.1:80", "10.1.1.2:80", "10.1.1.3:80", "10.1.1.4:80",
      "10.1.3.1:80", "10.1.3.2:80", "10.1.3.3:80", "10.1.3.4:80",
      "10.2.1.1:80", "10.2.1.2:80", "10.2.1.3:80", "10.2.1.4:80",
      "10.2.3.1:80", "10.2.3.2:80", "10.2.3.3:80", "10.2.3.4:80"
    )

    $IPArray = ConvertFrom-IPRangeString "10.3.1.3-4:81"
    $IPArray | Should -Be @(
      "10.3.1.3:81", "10.3.1.4:81"
    )

    $IPArray = ConvertFrom-IPRangeString "10.4.1.5-6:82"
    $IPArray | Should -Be @(
      "10.4.1.5:82", "10.4.1.6:82"
    )
  }
}



Describe "Host Convertor" {

  It "standard hostname" {
    $result = ConvertFrom-IPRangeString "w-1-w.baidu123.com:80"
    $result | Should -Be @("w-1-w.baidu123.com:80")

    $result = ConvertFrom-IPRangeString "w-1-w.baidu123.com"
    $result | Should -Be @("w-1-w.baidu123.com")

    $result = ConvertFrom-IPRangeString "www.baidu.com:80"
    $result | Should -Be @("www.baidu.com:80")

    $result = ConvertFrom-IPRangeString "www.baidu.com:8080"
    $result | Should -Be @("www.baidu.com:8080")

    $result = ConvertFrom-IPRangeString "baidu.com"
    $result | Should -Be @("baidu.com")

    $result = ConvertFrom-IPRangeString "www.999.com"
    $result | Should -Be @("www.999.com")

    $result = ConvertFrom-IPRangeString "123.999.com"
    $result | Should -Be @("123.999.com")

    $result = ConvertFrom-IPRangeString "123.999.net"
    $result | Should -Be @("123.999.net")
  }

}