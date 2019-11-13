<#
.NOTES
    Version:    2.0.0    
.SYNOPSIS
    PowerShell script to download and import spatial data into a database in MS SQL
.DESCRIPTION  
    This script will download spatial data, and import into MS SQL
.PARAMETER Help
    Show the full help.
    This is the default when no arguments are specified.
    Optional.
.PARAMETER Import
    When Import parameter is given, the script wil download and import temadata from external sources, that are screduled to run
.Example
    .\TemaDb.ps1 -Mode Help
    This will show the help screen
.Example
    .\TemaDb.ps1 -Mode Import 
    This will download and import spatial data
.Example    
    .\TemaDb.ps1 -Mode AddTema 
    Above will add a new Tema to download
.Example    
    .\TemaDb.ps1 -Mode TestDB 
    Above will test connection towards the database    
.Link
    http://www.sweco.dk   
#>
#REQUIRES -Version 5.1

[CmdletBinding()]
    param(        
        [Parameter(Mandatory = $false)]        
        [String]$mode="Help"    #Mode switch, can be either Help, Import, AddTema or TestDB
    )

    # Note start time
    $startTime = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    # Initialize Temalag der behandles
    $temalag = New-Object System.Collections.Generic.List[string]
    # Read Config JSON to global variable
    try {
        $configFile = (Get-Content -Raw -Path "$PSScriptRoot\Config\TemaDb.config.json")
        # Remove lines with //
        $configFile = $configFile -replace '(?m)\s*//.*?$' -replace '(?ms)/\*.*?\*/'
        $Global:MyCfg = $configFile | ConvertFrom-Json
    }
    catch [exception]
    {
        Write-Log -Message "Exception was: $_.Exception.Message" -Level "Fatal" |Out-Null        
    }

    #region IncludesImports

    # Import Log module
    Import-Module "$PSScriptRoot\manifests\logs.psd1" -Force
    
    # Import all module
    $files = Get-ChildItem "$PSScriptRoot\manifests\*.psd1"
        foreach ($file in $files) {
            try{
            Write-Log -Message "Importing module: $file" -Level "Info" | Out-Null             
            Import-Module $file -Force            
            }
            catch [exception]
            {
                Write-Log -Message "Fejl ved import af modul $file : $_.Exception.Message" -Level "Fatal" | Out-Null                                
            }
        }
    #endregion IncludesImports    

    # Switch to check the value of the mode switch
    # Defaults to help if not defined    
    switch($mode.ToLower()) {
        "import"
        {
            Write-Log -Message "Mode is Import" -Level "Info" | Out-Null   
            $ds = GetTemaLagToUpdate                 
            foreach ($Row in $ds.Tables[0].Rows)
            {
                # Add name to a list, that we use when/if sending an info mail
                $temalag.Add($Row[1]);
                ImportTemaLag -Row $Row                
            }                
            $endTime = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
            SendInfoMail -StartTime $startTime -EndTime $endTime -Temalag $temalag            
            break
        }
        "addtema"
        {
            Write-Host "Mode is Add Tema"
            Write-Host "Add Tema er ikke en del af POV" -ForegroundColor Red
            break
        }
        "testdb"
        {                         
            Write-Log -Message "Mode is TestDB" -Level "Info" | Out-Null            
            if (TestDB)
            {
                Write-Host "SQL OK" -ForegroundColor Green
            }
            else {
                Write-Host "SQL Fejl" -ForegroundColor Red
            }
            break
        }
        default
        {
            Get-Help $MyInvocation.MyCommand.Definition            
            break            
        }
    }

    Write-Log -Message "All Done, so exiting now" -Level "Info" | Out-Null 

# SIG # Begin signature block
# MIIbIAYJKoZIhvcNAQcCoIIbETCCGw0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUnGqykJMwOKl/Q+/Tfz1B1Er3
# PKygghZ+MIIEmTCCA4GgAwIBAgIQcaC3NpXdsa/COyuaGO5UyzANBgkqhkiG9w0B
# AQsFADCBqTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDHRoYXd0ZSwgSW5jLjEoMCYG
# A1UECxMfQ2VydGlmaWNhdGlvbiBTZXJ2aWNlcyBEaXZpc2lvbjE4MDYGA1UECxMv
# KGMpIDIwMDYgdGhhd3RlLCBJbmMuIC0gRm9yIGF1dGhvcml6ZWQgdXNlIG9ubHkx
# HzAdBgNVBAMTFnRoYXd0ZSBQcmltYXJ5IFJvb3QgQ0EwHhcNMTMxMjEwMDAwMDAw
# WhcNMjMxMjA5MjM1OTU5WjBMMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMdGhhd3Rl
# LCBJbmMuMSYwJAYDVQQDEx10aGF3dGUgU0hBMjU2IENvZGUgU2lnbmluZyBDQTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJtVAkwXBenQZsP8KK3TwP7v
# 4Ol+1B72qhuRRv31Fu2YB1P6uocbfZ4fASerudJnyrcQJVP0476bkLjtI1xC72Ql
# WOWIIhq+9ceu9b6KsRERkxoiqXRpwXS2aIengzD5ZPGx4zg+9NbB/BL+c1cXNVeK
# 3VCNA/hmzcp2gxPI1w5xHeRjyboX+NG55IjSLCjIISANQbcL4i/CgOaIe1Nsw0Rj
# gX9oR4wrKs9b9IxJYbpphf1rAHgFJmkTMIA4TvFaVcnFUNaqOIlHQ1z+TXOlScWT
# af53lpqv84wOV7oz2Q7GQtMDd8S7Oa2R+fP3llw6ZKbtJ1fB6EDzU/K+KTT+X/kC
# AwEAAaOCARcwggETMC8GCCsGAQUFBwEBBCMwITAfBggrBgEFBQcwAYYTaHR0cDov
# L3QyLnN5bWNiLmNvbTASBgNVHRMBAf8ECDAGAQH/AgEAMDIGA1UdHwQrMCkwJ6Al
# oCOGIWh0dHA6Ly90MS5zeW1jYi5jb20vVGhhd3RlUENBLmNybDAdBgNVHSUEFjAU
# BggrBgEFBQcDAgYIKwYBBQUHAwMwDgYDVR0PAQH/BAQDAgEGMCkGA1UdEQQiMCCk
# HjAcMRowGAYDVQQDExFTeW1hbnRlY1BLSS0xLTU2ODAdBgNVHQ4EFgQUV4abVLi+
# pimK5PbC4hMYiYXN3LcwHwYDVR0jBBgwFoAUe1tFz6/Oy3r9MZIaarbzRutXSFAw
# DQYJKoZIhvcNAQELBQADggEBACQ79degNhPHQ/7wCYdo0ZgxbhLkPx4flntrTB6H
# novFbKOxDHtQktWBnLGPLCm37vmRBbmOQfEs9tBZLZjgueqAAUdAlbg9nQO9ebs1
# tq2cTCf2Z0UQycW8h05Ve9KHu93cMO/G1GzMmTVtHOBg081ojylZS4mWCEbJjvx1
# T8XcCcxOJ4tEzQe8rATgtTOlh5/03XMMkeoSgW/jdfAetZNsRBfVPpfJvQcsVncf
# hd1G6L/eLIGUo/flt6fBN591ylV3TV42KcqF2EVBcld1wHlb+jQQBm1kIEK3Osgf
# HUZkAl/GR77wxDooVNr2Hk+aohlDpG9J+PxeQiAohItHIG4wggSeMIIDhqADAgEC
# AhAcxLkSdn4Iz9HlrReliMa0MA0GCSqGSIb3DQEBCwUAMEwxCzAJBgNVBAYTAlVT
# MRUwEwYDVQQKEwx0aGF3dGUsIEluYy4xJjAkBgNVBAMTHXRoYXd0ZSBTSEEyNTYg
# Q29kZSBTaWduaW5nIENBMB4XDTE5MDgyMDAwMDAwMFoXDTIyMDgxOTIzNTk1OVow
# XDELMAkGA1UEBhMCREsxFTATBgNVBAcMDEvDuGJlbmhhdm4gUzEaMBgGA1UECgwR
# U3dlY28gRGFubWFyayBBL1MxGjAYBgNVBAMMEVN3ZWNvIERhbm1hcmsgQS9TMIIB
# IjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA586u0iGHpB+AcmgYDrt3F9zR
# rnggW7Cn7nlJEoOKChY0qPSJWbW74aViECjvwK/UWOjU98UEYAj/2+u1t0XwjDQj
# qOI0gVqB2YanQqk2E/oiI8kIMPgbwpFzNtR01IvjD2lCFV/8WAaScmIYPVCbeC/x
# vi7bO74e0IHn6itwBXVf5x7nEB2OH513QFyCdrR/cRw0fgVwTPM8LRBkvzMrjatG
# BPMmaNtc6pHCJJL25Faqt5F0JTdo6hji1khtsR6FCun02I+gI8q9cACJDq2fgXge
# XnbM/4BDaIw/QQ/y7+a9r3eOznSG4yvtFB3XV0LsvVZvp0fFxPW3uDfIAgtcowID
# AQABo4IBajCCAWYwCQYDVR0TBAIwADAfBgNVHSMEGDAWgBRXhptUuL6mKYrk9sLi
# ExiJhc3ctzAdBgNVHQ4EFgQUSk14l95qZkK4sFVGptiGqnEtDxkwKwYDVR0fBCQw
# IjAgoB6gHIYaaHR0cDovL3RsLnN5bWNiLmNvbS90bC5jcmwwDgYDVR0PAQH/BAQD
# AgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMG4GA1UdIARnMGUwYwYGZ4EMAQQBMFkw
# JgYIKwYBBQUHAgEWGmh0dHBzOi8vd3d3LnRoYXd0ZS5jb20vY3BzMC8GCCsGAQUF
# BwICMCMMIWh0dHBzOi8vd3d3LnRoYXd0ZS5jb20vcmVwb3NpdG9yeTBXBggrBgEF
# BQcBAQRLMEkwHwYIKwYBBQUHMAGGE2h0dHA6Ly90bC5zeW1jZC5jb20wJgYIKwYB
# BQUHMAKGGmh0dHA6Ly90bC5zeW1jYi5jb20vdGwuY3J0MA0GCSqGSIb3DQEBCwUA
# A4IBAQCA/iOomAX5EPUHIITqCYCZNWNv9wNQ2CetSI45fTJZi8ZmIsZT4FS+H9JJ
# W4kG98HqG+qlrRxOaB9Jh4QMVngNZwKbV/JoNp1Pje9mrjs3OxT9NIfysgCUnoU5
# cjB9Mba3f/TbcEhAJ1n99EUfzbuXnYSLgMA2+u1g8Nya+EObuEOEEPhYL0HLkI1v
# 55EXcEJfCL6547SEc+D1Mv0SntTES3W8m6LMlmB3xMRoYMCLot4tD5mT0Nf61un4
# MyEUQhTYyAiwIg/wPDY8SQCyYGDZQY/D5YsEhXqXoLQGWGyuVEm1NUjA33WzWptz
# weJUKSIPdLU/opom6n8T80TKvE37MIIGajCCBVKgAwIBAgIQAwGaAjr/WLFr1tXq
# 5hfwZjANBgkqhkiG9w0BAQUFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGln
# aUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhE
# aWdpQ2VydCBBc3N1cmVkIElEIENBLTEwHhcNMTQxMDIyMDAwMDAwWhcNMjQxMDIy
# MDAwMDAwWjBHMQswCQYDVQQGEwJVUzERMA8GA1UEChMIRGlnaUNlcnQxJTAjBgNV
# BAMTHERpZ2lDZXJ0IFRpbWVzdGFtcCBSZXNwb25kZXIwggEiMA0GCSqGSIb3DQEB
# AQUAA4IBDwAwggEKAoIBAQCjZF38fLPggjXg4PbGKuZJdTvMbuBTqZ8fZFnmfGt/
# a4ydVfiS457VWmNbAklQ2YPOb2bu3cuF6V+l+dSHdIhEOxnJ5fWRn8YUOawk6qhL
# LJGJzF4o9GS2ULf1ErNzlgpno75hn67z/RJ4dQ6mWxT9RSOOhkRVfRiGBYxVh3lI
# RvfKDo2n3k5f4qi2LVkCYYhhchhoubh87ubnNC8xd4EwH7s2AY3vJ+P3mvBMMWSN
# 4+v6GYeofs/sjAw2W3rBerh4x8kGLkYQyI3oBGDbvHN0+k7Y/qpA8bLOcEaD6dpA
# oVk62RUJV5lWMJPzyWHM0AjMa+xiQpGsAsDvpPCJEY93AgMBAAGjggM1MIIDMTAO
# BgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEF
# BQcDCDCCAb8GA1UdIASCAbYwggGyMIIBoQYJYIZIAYb9bAcBMIIBkjAoBggrBgEF
# BQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzCCAWQGCCsGAQUFBwIC
# MIIBVh6CAVIAQQBuAHkAIAB1AHMAZQAgAG8AZgAgAHQAaABpAHMAIABDAGUAcgB0
# AGkAZgBpAGMAYQB0AGUAIABjAG8AbgBzAHQAaQB0AHUAdABlAHMAIABhAGMAYwBl
# AHAAdABhAG4AYwBlACAAbwBmACAAdABoAGUAIABEAGkAZwBpAEMAZQByAHQAIABD
# AFAALwBDAFAAUwAgAGEAbgBkACAAdABoAGUAIABSAGUAbAB5AGkAbgBnACAAUABh
# AHIAdAB5ACAAQQBnAHIAZQBlAG0AZQBuAHQAIAB3AGgAaQBjAGgAIABsAGkAbQBp
# AHQAIABsAGkAYQBiAGkAbABpAHQAeQAgAGEAbgBkACAAYQByAGUAIABpAG4AYwBv
# AHIAcABvAHIAYQB0AGUAZAAgAGgAZQByAGUAaQBuACAAYgB5ACAAcgBlAGYAZQBy
# AGUAbgBjAGUALjALBglghkgBhv1sAxUwHwYDVR0jBBgwFoAUFQASKxOYspkH7R7f
# or5XDStnAs0wHQYDVR0OBBYEFGFaTSS2STKdSip5GoNL9B6Jwcp9MH0GA1UdHwR2
# MHQwOKA2oDSGMmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3Vy
# ZWRJRENBLTEuY3JsMDigNqA0hjJodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGln
# aUNlcnRBc3N1cmVkSURDQS0xLmNybDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDov
# L2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEQ0EtMS5jcnQw
# DQYJKoZIhvcNAQEFBQADggEBAJ0lfhszTbImgVybhs4jIA+Ah+WI//+x1GosMe06
# FxlxF82pG7xaFjkAneNshORaQPveBgGMN/qbsZ0kfv4gpFetW7easGAm6mlXIV00
# Lx9xsIOUGQVrNZAQoHuXx/Y/5+IRQaa9YtnwJz04HShvOlIJ8OxwYtNiS7Dgc6aS
# wNOOMdgv420XEwbu5AO2FKvzj0OncZ0h3RTKFV2SQdr5D4HRmXQNJsQOfxu19aDx
# xncGKBXp2JPlVRbwuwqrHNtcSCdmyKOLChzlldquxC5ZoGHd2vNtomHpigtt7BIY
# vfdVVEADkitrwlHCCkivsNRu4PQUCjob4489yq9qjXvc2EQwggbNMIIFtaADAgEC
# AhAG/fkDlgOt6gAK6z8nu7obMA0GCSqGSIb3DQEBBQUAMGUxCzAJBgNVBAYTAlVT
# MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5j
# b20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0wNjEx
# MTAwMDAwMDBaFw0yMTExMTAwMDAwMDBaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNV
# BAMTGERpZ2lDZXJ0IEFzc3VyZWQgSUQgQ0EtMTCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBAOiCLZn5ysJClaWAc0Bw0p5WVFypxNJBBo/JM/xNRZFcgZ/t
# LJz4FlnfnrUkFcKYubR3SdyJxArar8tea+2tsHEx6886QAxGTZPsi3o2CAOrDDT+
# GEmC/sfHMUiAfB6iD5IOUMnGh+s2P9gww/+m9/uizW9zI/6sVgWQ8DIhFonGcIj5
# BZd9o8dD3QLoOz3tsUGj7T++25VIxO4es/K8DCuZ0MZdEkKB4YNugnM/JksUkK5Z
# ZgrEjb7SzgaurYRvSISbT0C58Uzyr5j79s5AXVz2qPEvr+yJIvJrGGWxwXOt1/HY
# zx4KdFxCuGh+t9V3CidWfA9ipD8yFGCV/QcEogkCAwEAAaOCA3owggN2MA4GA1Ud
# DwEB/wQEAwIBhjA7BgNVHSUENDAyBggrBgEFBQcDAQYIKwYBBQUHAwIGCCsGAQUF
# BwMDBggrBgEFBQcDBAYIKwYBBQUHAwgwggHSBgNVHSAEggHJMIIBxTCCAbQGCmCG
# SAGG/WwAAQQwggGkMDoGCCsGAQUFBwIBFi5odHRwOi8vd3d3LmRpZ2ljZXJ0LmNv
# bS9zc2wtY3BzLXJlcG9zaXRvcnkuaHRtMIIBZAYIKwYBBQUHAgIwggFWHoIBUgBB
# AG4AeQAgAHUAcwBlACAAbwBmACAAdABoAGkAcwAgAEMAZQByAHQAaQBmAGkAYwBh
# AHQAZQAgAGMAbwBuAHMAdABpAHQAdQB0AGUAcwAgAGEAYwBjAGUAcAB0AGEAbgBj
# AGUAIABvAGYAIAB0AGgAZQAgAEQAaQBnAGkAQwBlAHIAdAAgAEMAUAAvAEMAUABT
# ACAAYQBuAGQAIAB0AGgAZQAgAFIAZQBsAHkAaQBuAGcAIABQAGEAcgB0AHkAIABB
# AGcAcgBlAGUAbQBlAG4AdAAgAHcAaABpAGMAaAAgAGwAaQBtAGkAdAAgAGwAaQBh
# AGIAaQBsAGkAdAB5ACAAYQBuAGQAIABhAHIAZQAgAGkAbgBjAG8AcgBwAG8AcgBh
# AHQAZQBkACAAaABlAHIAZQBpAG4AIABiAHkAIAByAGUAZgBlAHIAZQBuAGMAZQAu
# MAsGCWCGSAGG/WwDFTASBgNVHRMBAf8ECDAGAQH/AgEAMHkGCCsGAQUFBwEBBG0w
# azAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUF
# BzAChjdodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVk
# SURSb290Q0EuY3J0MIGBBgNVHR8EejB4MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMDqgOKA2hjRodHRw
# Oi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3Js
# MB0GA1UdDgQWBBQVABIrE5iymQftHt+ivlcNK2cCzTAfBgNVHSMEGDAWgBRF66Kv
# 9JLLgjEtUYunpyGd823IDzANBgkqhkiG9w0BAQUFAAOCAQEARlA+ybcoJKc4HbZb
# Ka9Sz1LpMUerVlx71Q0LQbPv7HUfdDjyslxhopyVw1Dkgrkj0bo6hnKtOHisdV0X
# FzRyR4WUVtHruzaEd8wkpfMEGVWp5+Pnq2LN+4stkMLA0rWUvV5PsQXSDj0aqRRb
# poYxYqioM+SbOafE9c4deHaUJXPkKqvPnHZL7V/CSxbkS3BMAIke/MV5vEwSV/5f
# 4R68Al2o/vsHOE8Nxl2RuQ9nRc3Wg+3nkg2NsWmMT/tZ4CMP0qquAHzunEIOz5HX
# J7cW7g/DvXwKoO4sCFWFIrjrGBpN/CohrUkxg0eVd3HcsRtLSxwQnHcUwZ1PL1qV
# CCkQJjGCBAwwggQIAgEBMGAwTDELMAkGA1UEBhMCVVMxFTATBgNVBAoTDHRoYXd0
# ZSwgSW5jLjEmMCQGA1UEAxMddGhhd3RlIFNIQTI1NiBDb2RlIFNpZ25pbmcgQ0EC
# EBzEuRJ2fgjP0eWtF6WIxrQwCQYFKw4DAhoFAKBwMBAGCisGAQQBgjcCAQwxAjAA
# MBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgor
# BgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTpzXUeEVcxvCdlNJlfyWr00pP6lDAN
# BgkqhkiG9w0BAQEFAASCAQAD9sfx2VmD1DVIFiW2ptDsGAzSgA1LJxxSB+wrAjI3
# bXH1pBppkAW8Qq9KFrwMAKJeZDuXASJ4mJzxA2nTIgbyXF7ljgaQ5l1lhhNZjAZa
# jloa5eW22D7W5mXKIsb+cVqchmTul4PsBxd/JKmwZxahxU8t1Ftxo5Kq5Byb7XaF
# Ev1/pljpMuYODt1Rp9NdJwBRGgTVcQItdBv2ihwHi4/dnKJPISKNqPqVY21547L3
# n9a6ii1WWhQ8VWG633gyV7u3YxHgjlozQKR6/3odviiSfJdf7LquFOSoA3SNGU62
# ccX+qSxci1Pz0bqakPNaM4WhT0IIM3cgd0fhSRUQAppQoYICDzCCAgsGCSqGSIb3
# DQEJBjGCAfwwggH4AgEBMHYwYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lD
# ZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGln
# aUNlcnQgQXNzdXJlZCBJRCBDQS0xAhADAZoCOv9YsWvW1ermF/BmMAkGBSsOAwIa
# BQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0x
# OTA4MjExMTM3MzFaMCMGCSqGSIb3DQEJBDEWBBTENyWG4hFnosdpnu47HkMg1gHY
# rDANBgkqhkiG9w0BAQEFAASCAQANhMcsaH3tZLQnXxrCNpook3ONSHcr2lhr6UJ6
# 0Qg+MvHsgjHwI8F9UWjKwBOOz87e6E5ghXtuqN8dzphMIGZUYeBy+rcghYzeICTH
# nUw5grp39zPZNFjRb2kT6jisHvJZTxRRzNZTDbRYy+eWNyxSjwzeZgXP9HknjamY
# em1vCIxKRVDDWElWC2Ok6MmLN+lKkeICnsN8V/2zc8F/n3vsoq6rAUsWcv952NcI
# GYhWOfYLvMHrSTa7TzjPaQrJpX01jjG/ZLxdKqJOdqOuM6RtXXIBrlpRtQKQXKL3
# rLMrO8eeaXvxfEHwHFXy2KdQew/Ih8mJPpuRz2M138lOgPbJ
# SIG # End signature block
