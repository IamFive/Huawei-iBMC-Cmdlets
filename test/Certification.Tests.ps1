Describe "Certification" {
  It "get current user cert" {
    $certs = Get-ChildItem -Path cert:\CurrentUser\My
    # foreach ($cert in $certs) {
    #   Write-Host $cert
    # }


    # [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    # $Store = New-Object System.Security.Cryptography.X509Certificates.X509Store(
    #         [System.Security.Cryptography.X509Certificates.StoreName]::My, "localmachine")
    # $Store.Open("MaxAllowed")
    # $Certificate = $Store.Certificates |  Where-Object Thumbprint -Eq "XXXXXXXXXXXXXXXX"
    # $Web = [System.Net.WebRequest]::Create($Url)
    # $Web.ClientCertificates.Add($Certificate)
    # $Response = $Web.GetResponse()


    #*************************************
    #********CERTIFICATE LOADING**********
    #*************************************

    # # LOAD CERTIFICATE FROM STORE
    # $Certificate = Get-ChildItem -Path Cert:\LocalMachine\My\$CertNumber
    # # CREATE WEB REQUEST
    # $req = [system.Net.HttpWebRequest]::Create($checkURL)
    # # ADD CERTS TO WEB REQUEST
    # $req.ClientCertificates.AddRange($Certificate)

    # #*************************************
    # #***********READING SITE**************
    # #*************************************

    # #SET TIMEOUT
    # $req.Timeout=10000
    # # GET WEB RESPONSE
    # $res = $req.GetResponse()
    # # GET DATA FROM RESPONSE
    # $ResponseStream = $res.GetResponseStream()
    # # Create a stream reader and read the stream returning the string value.
    # $StreamReader = New-Object System.IO.StreamReader -ArgumentList $ResponseStream
    # # BUILD STRING FROM RESPONSE
    # $strHtml = $StreamReader.ReadToEnd()
  }
}