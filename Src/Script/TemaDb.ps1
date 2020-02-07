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
.Example    
    .\TemaDb.ps1 -Mode CreateAESKey 
    Above will create an encryption file for passwords
.Example    
    .\TemaDb.ps1 -Mode SetPwd 
    Above will create an encryption file for passwords
.Example
    .\TemaDb.ps1 -Mode TestMail
    Above will send a test mail

.Link
    http://www.sweco.dk   
#>
#REQUIRES -Version 5.1

[CmdletBinding(HelpURI = 'https://sweco.dk')]    
    param(        
        [Parameter(Mandatory = $false)]        
        [String]$mode="Help"    #Mode switch. For possible modes, see get-help
    )

    # Note start time
    $startTime = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    # Initialize Temalag to handle
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
            if ($temalag.Count -eq 0)
            {
                SendInfoMail -StartTime $startTime -EndTime $endTime -Temalag "Ingen temalag blev hentet ned"    
            }
            else
            {
                SendInfoMail -StartTime $startTime -EndTime $endTime -Temalag $temalag
            }            
            break
        }
        "addtema"
        {
            Write-Host "Mode is Add Tema"
            Write-Host "Add Tema er ikke en implimenteret, og afventer godkendelse af et menu system" -ForegroundColor Red
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
        "CreateAESKey"
        {
            Write-Log -Message "Mode is CreateAESKey" -Level "Info" | Out-Null            
            if (CreateAESKey)
            {
                Write-Host "AES Key file created ok" -ForegroundColor Green
            }
            else {
                Write-Host "AES Key file creation error" -ForegroundColor Red
            }
            break
        }
        "SetPwd"
        {
            Write-Log -Message "Mode is SetPwd" -Level "Info" | Out-Null            
            if (SetPwd)
            {
                Write-Host "Password set ok" -ForegroundColor Green
            }
            else {
                Write-Host "Password set error" -ForegroundColor Red
            }
            break
        }
        "TestMail"
        {
            Write-Log -Message "Mode is TestMail" -Level "Info" | Out-Null
            if (TestMail)
            {
                Write-Host "Test mail send ok" -ForegroundColor Green
            }
            else {
                Write-Host "Test mail error" -ForegroundColor Red
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
