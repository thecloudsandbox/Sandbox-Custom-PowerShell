#Function for the menu
Function Show-Menu {
    param (
        [string]$Title = 'MS Cloud Toolbox'
    )

    #$Selection -eq "null"
    Write-Output "================ $Title ================"
    Write-Output "Available Tools: Microsoft Graph, AzureAD, MSOnline, Azure, Exchange Online (V2)"
    Write-Output "0: Press '0' to Install Microsoft Graph"
    Write-Output "1: Press '1' to Install AzureAD"
    Write-Output "2: Press '2' to Install MSOnline"
    Write-Output "3: Press '3' to Install Azure PowerShell"
    Write-Output "4: Press '4' to Install Exchange Online (V2)"
    Write-Output "5: Press '5' to Install All Modules"
    Write-Output "Q: Press 'Q' to quit."
}


#Installing Required Repos for Module Installation and setting PS Gallery as Trusted
Install-PackageProvider -name Nuget -minimumversion 2.8.5.201 -force
Set-PSRepository "PSGallery" -InstallationPolicy Trusted


$AllModules = {
$Modules = "Microsoft.Graph","AzureAD","MSOnline","Az","ExchangeOnlineManagement" 

foreach ($Module in $Modules) {

    Write-Verbose "Installing $Module...This may take a few minutes" -Verbose
    Install-Module -Name $Module -Force -Verbose
}
}


#Do/Until Loop for Installs and Menu Selection
    do
 {
    Clear-Host
    Show-Menu
    $Selection = Read-Host "Please Make a Selection"
    switch ($Selection)
    {

    '0' {
            Install-Module -Name Microsoft.Graph -Force -Verbose
           
        }
    '1' {
            Install-Module -Name AzureAD -Force -Verbose
            
        }       
    '2' {
            Install-Module -Name MSOnline -Force -Verbose
       
        }
    '3' {
            Install-Module -Name Az -Force -Verbose

        }
    '4' {
            Install-Module -Name ExchangeOnlineManagement -Force

        }
    '5' {
           Invoke-Command -ScriptBlock $AllModules

        }
    }

 
 }
 Until ($Selection -eq 'q')





