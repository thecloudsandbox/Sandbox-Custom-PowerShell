#Function for the menu
Function Show-Menu {
    param (
        [string]$Title = 'MS Cloud Toolbox'
    )

    $Selection -eq "null"
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

Function New-DotNetToast {
    [cmdletBinding()]
    Param(
        
        [Parameter(Mandatory, Position = 0)]
        [String]
        $Title,
        [Parameter(Mandatory,Position = 1)]
        [String]
        $Message,
        [Parameter(Position = 2)]
        [String]
        $Logo = "C:\Program Files\WindowsPowerShell\Modules\BurntToast\0.6.2\Images\BurntToast.png"
       
  
    )
}
  
#Code for the toast notification  
    $XmlString = @"
    <toast>
      <visual>
        <binding template="ToastGeneric">
          <text>$Title</text>
          <text>$Message</text>
          <image src="$Logo" placement="appLogoOverride" hint-crop="circle" />
        </binding>
      </visual>
      <audio src="ms-winsoundevent:Notification.Default" />
    </toast>
"@
$AppId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
$null = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
$null = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]
$ToastXml = [Windows.Data.Xml.Dom.XmlDocument]::new()
$ToastXml.LoadXml($XmlString)
$Toast = [Windows.UI.Notifications.ToastNotification]::new($ToastXml)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppId).Show($Toast)



$Modules = "Microsoft.Graph","AzureAD","MSOnline","Az","ExchangeOnlineManagement" 

$AllModules = foreach ($Module in $Modules) {

    Write-Verbose "Installing $Module...This may take a few minutes" -Verbose
     Install-Module -Name $Module -Force -Verbose
     New-DotNetToast -Title 'Success' -Message '$Module Installed'

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
    '5' {
           $AllModules

        }
    }

 
 }
 Until ($Selection -eq 'q')





