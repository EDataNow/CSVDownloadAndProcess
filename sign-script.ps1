#requires -version 3
param([string]$scriptToSign)

$cert = Get-ChildItem cert:\CurrentUser\My -codesign

$title = "Certificate Setup"
$message = "It appears you do not have a valid certificate. Would you like to create one now? `n (Note: You will be prompted to enter a password multiple times. This is normal.)"
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Begins makecert setup."
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Cancel"
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)


function Make-Cert {
    makecert -n "CN=PowerShell Local Certificate Root" -a sha1 -eku 1.3.6.1.5.5.7.3.3 -r -sv root.pvk root.cer -ss Root -sr localMachine
    makecert -pe -n "CN=PowerShell User" -ss MY -a sha1 -eku 1.3.6.1.5.5.7.3.3 -iv root.pvk -ic root.cer
    Get-ChildItem cert:\CurrentUser\My -codesign
    Remove-Item ".\root.pvk"
    Remove-Item ".\root.cer"
}

function Check-and-Prompt{
    if ($cert -eq $null){
        $result = $host.ui.PromptForChoice($title, $message, $options, 1) 
        switch ($result)
        {
            0 {
                Make-Cert
            }
            1 {
                Write-Host "Script cannot be signed without a valid certificate." -ForegroundColor Red
                Exit
            }
        }   
    }
}

if (Test-Path -Path $scriptToSign) {
    Check-and-Prompt
    try { Set-AuthenticodeSignature $scriptToSign @(Get-ChildItem cert:\CurrentUser\My -codesign)[0] -ErrorAction Stop }
    catch { 
    Write-Host "Your script has not been signed." -ForegroundColor Red
    Break 
    }
    Write "Script was signed successfully."
}
else{
    Write-Host "Could not find script $($scriptToSign). Please check the path and try again." -ForegroundColor Red  
}


# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUHi0dJ540bvzvkbsnn0hXH0y5
# G6SgggI9MIICOTCCAaagAwIBAgIQc7n71kfTaZFCIkQ35aCOqDAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xNjAxMTgyMDM5MTdaFw0zOTEyMzEyMzU5NTlaMBoxGDAWBgNVBAMTD1Bvd2Vy
# U2hlbGwgVXNlcjCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAr8oVgX2hk1fs
# fH0CRopMh/atBJQD21y6k0v9yDEtO0XnR5x3HJaoCtI4SHIdIglF/TZKpAorAJyX
# hv3NB4t3I5dZEKKp7bdOgqJosKiKRR9SvzkRxRjCTD3W/4rT0/20WIqHxwC3ruEj
# so9yGvg1/DWojze00MR6ZaCRWjiM4EcCAwEAAaN2MHQwEwYDVR0lBAwwCgYIKwYB
# BQUHAwMwXQYDVR0BBFYwVIAQmDM8EUp5q3jo0Aw50D17J6EuMCwxKjAoBgNVBAMT
# IVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdIIQqRNC2qlDP7NJ/p+A
# fbu3JTAJBgUrDgMCHQUAA4GBAI93AE/Sqr/3Fu/ngqMPuPAyQIzAVpUxEGjfEKEW
# XBo3wm8/AZiAS37lKRGQjIMuAsjHLd+Z4I8XsRQzZIzSiRRG5lUCMFKJLzvkBY6M
# yWChuD6n4goczt3IkM0kS7y2ewwAXCYp7A8mGlzI62ybyAR4FjTFWBuGN7neO2rr
# 5uP8MYIBYDCCAVwCAQEwQDAsMSowKAYDVQQDEyFQb3dlclNoZWxsIExvY2FsIENl
# cnRpZmljYXRlIFJvb3QCEHO5+9ZH02mRQiJEN+WgjqgwCQYFKw4DAhoFAKB4MBgG
# CisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcC
# AQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYE
# FIHyokb49Q81wdvTb7LH/iICXiMFMA0GCSqGSIb3DQEBAQUABIGACRWooZ7FY+Wn
# hSI3hRB5e3v30E9aZTs/IkpUDTs4x4l7Fu+E+jV3ZvUuzgBluCZDxVD44zxUWTdE
# oEeqYWJN7dtDa7Cle2EkCRf7+LhTavwW+3hMJGk0vLDK9a17cl0LkJP6cRZs8A9W
# yz+l01lS6wOCM7t6muOLL/5UGh5N4Ws=
# SIG # End signature block
