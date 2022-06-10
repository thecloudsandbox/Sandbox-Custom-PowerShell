

Function Show-Menu {
    param (
        [string]$Title = 'MS Cloud Toolbox'
    )
    $Selection -eq "null"
    Write-Host "================ $Title ================"
    
    Write-Host "Available Tools: Microsoft Graph, AzureAD, MSOnline, Azure, Exchange Online (V2)"


    Write-Host "1: Press '0' to Install Microsoft Graph."
    Write-Host "2: Press '1' to Install AzureAD."
    Write-Host "3: Press '2' to Install MSOnline."
    Write-Host "4: Press '3' to Install Azure."
    Write-Host "5: Press '4' to Install Exchange Online (V2)."

    Write-Host "Q: Press 'Q' to quit."
}
   


#Installing Required Repos for Module Installation and setting PS Gallery as Trusted
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
Install-PackageProvider -name Nuget -minimumversion 2.8.5.201 -force
Set-PSRepository "PSGallery" -InstallationPolicy Trusted

#Do/Until Loop for Installs and Menu Selection
    do
 {
    Clear-Host
    Show-Menu
    $Selection = Read-Host "Please Make a Selection"
    switch ($Selection)
    {

    '0' {
            Install-Module -Name Microsoft.Graph -Force -Scope AllUsers
           
        }
    '1' {
            Install-Module -Name AzureAD -Force
            
        }       
    '2' {
            Install-Module -Name MSOnline -Force
       
        }
    '3' {
            Install-Module -Name Az -Force

        }
    '4' {
            Install-Module -Name ExchangeOnlineManagement -Force

        }
    }

 
 }
 Until ($Selection -eq 'q')
