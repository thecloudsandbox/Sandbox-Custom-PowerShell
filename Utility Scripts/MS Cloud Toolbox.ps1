

Function Show-Menu {
    param (
        [string]$Title = 'Cloud Toolbox'
    )
    $Selection -eq "null"
    Write-Host "================ $Title ================"
    
    Write-Host "Available Tools: Microsoft Graph, AzureAD, MSOnline, Azure, Exchange Online (V2)"

    Write-Host "0: Press '0' to Install All Tools"
    Write-Host "1: Press '1' to Install Microsoft Graph."
    Write-Host "2: Press '2' to Install AzureAD."
    Write-Host "3: Press '3' to Install MSOnline."
    Write-Host "4: Press '4' to Install Azure."
    Write-Host "5: Press '5' to Install Exchange Online (V2)."

    Write-Host "Q: Press 'Q' to quit."
}
   


#Installing Required Repos for Module Installation and setting PS Gallery as Trusted
#Install-PackageProvider -name Nuget -minimumversion 2.8.5.201 -force
#Set-PSRepository "PSGallery" -InstallationPolicy Trusted

$AllModules = {
Write-Progress -Activity "Installing all modules..." -Id 1 -Status "Installing..." -PercentComplete 0
Write-Progress -Activity "Installing Microsoft Graph" -Id 2 -ParentId 1 -Status "Installing..." -PercentComplete 20
Install-Module -Name Microsoft.Graph -Force
Write-Progress -Activity "Installing Azure AD" -Id 3 -ParentId 1 -Status "Installing..." -PercentComplete 40
Install-Module -Name AzureAD -Force
Write-Progress -Activity "Installing MSOnline" -Id 4 -ParentId 1 -Status "Installing..." -PercentComplete 60
Install-Module -Name MSOnline -Force
Write-Progress -Activity "Installing Azure PS" -Id 5 -ParentId 1 -Status "Installing..." -PercentComplete 80
Install-Module -Name Az -Force
Write-Progress -Activity "Installing Exchange Online" -Id 6 -ParentId 1 -Status "Installing..." -PercentComplete 100
Install-Module -Name ExchangeOnlineManagement -Force
}

#Do/Until Loop for Installs and Menu Selection
    do
 {
$AllModules = {

Install-Module -Name Microsoft.Graph -Force
Install-Module -Name AzureAD -Force
Install-Module -Name MSOnline -Force
Install-Module -Name Az -Force
Install-Module -Name ExchangeOnlineManagement -Force

}

    Clear-Host
    Show-Menu
    $Selection = Read-Host "Please Make a Selection"
    switch ($Selection)
    {
    '0'{    

            Invoke-Command -ScriptBlock $AllModules  

        Break} 
    '1' {
            Install-Module -Name Microsoft.Graph -Force -Scope AllUsers
           
        Break}
    '2' {
            Install-Module -Name AzureAD -Force
            
        Break}       
    '3' {
            Install-Module -Name MSOnline -Force
       
        Break}
    '4' {
            Install-Module -Name Az -Force

        Break}
    '5' {
        Install-Module -Name ExchangeOnlineManagement -Force

        break
        }
    }

 
 }
 Until ($Selection -eq 'q')
