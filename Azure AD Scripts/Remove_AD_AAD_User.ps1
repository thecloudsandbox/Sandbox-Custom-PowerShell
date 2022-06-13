<#
Deactivate a 365 account + Local AD Account
Developed by The Cloud Sandbox 4/9/22
(Work in Progress)
Additions in the works as time permits error handling, better semantics(spacing + readability improvements), adding a forward on a mailbox (input based), adding read and manage permissions (input based) 


The three commented commands below should only need to be run once if the modules have never been installed
Set-ExecutionPolicy RemoteSigned
Install-Module -Name ExchangeOnlineManagement
Install-Module -Name AzureAD
#>

Import-Module -Name ExchangeOnlineManagement
Import-Module -Name AzureAD

Write-Host "`n Connecting to the Microsoft Cloud" -ForegroundColor Green

Connect-AzureAD
Connect-ExchangeOnline

#Static Variables DO NOT CHANGE
$Email = Read-Host -Prompt "Enter the email address"
$ObjectID = (Get-AzureADUser -Filter "userPrincipalName eq '$Email'").ObjectID
$ADAccount = Read-Host -Prompt "Enter the user name without the domain"

#Here we are blocking sign-in
Write-Host "`n Blocking user sign-in" -ForegroundColor Yellow
Set-AzureADUser -ObjectId $Email -AccountEnabled $false
Write-Host "`n User has been blocked from signing in" -ForegroundColor Green

#Here we are resetting the password
Write-Host "`n Resetting the password" -ForegroundColor Yellow
$Password = Read-Host "Enter a secure password" -AsSecureString
Set-AzureADUserPassword -ObjectId $ObjectID -Password $Password -ForceChangePasswordNextLogin $false
Write-Host "`n Password has been reset" -ForegroundColor Green

#Kicking the user out of all sessions here
Write-Host "`n Signing user out of all active and logged in sessions" -ForegroundColor Yellow
Revoke-AzureADUserAllRefreshToken -ObjectId $ObjectID
Write-Host "`n User has been logged out of all active and logged in sessions" -ForegroundColor Green

#Now to remove the user from all groups. 

Write-Host "`n Starting removal of user from groups" -ForegroundColor Yellow

#The four variables below are only used and passed to the For loop to remove distros
$Mailbox = Get-Mailbox -Identity $Email
$DN = $Mailbox.DistinguishedName
$Members = "Members -like ""$DN"""
$DistributionGroupsList = Get-DistributionGroup -ResultSize Unlimited -Filter $Members

Write-Warning -Message "Please confirm this remove action by clicking Yes or No" -WarningAction Inquire

Write-Host "`n Removing the user from distribution groups" -ForegroundColor Yellow

#This loop removes the account from the distribution lists
    ForEach ($item in $DistributionGroupsList) {
          Remove-DistributionGroupMember -Identity $item.DisplayName –Member $Email –BypassSecurityGroupManagerCheck -Confirm:$false
          }

#Going to sleep until the distros are removed, so they are not a part of the next loop and show a bunch of false/positive erros
Start-Sleep -Seconds 15

#This loop removes the account from the 365 groups
    $ObjectID = (Get-AzureADUser -Filter "userPrincipalName eq '$Email'").ObjectID 
    $Membership = (Get-AzureADUserMembership -ObjectId $ObjectID).objectid
      Foreach ($Membership in $Membership) {
            Remove-AzureADGroupMember -ObjectId $Membership -MemberId $ObjectID
            }
      
Write-Host "`n Converting mailbox to a shared mailbox" -ForegroundColor Yellow
#We are going to convert the mailbox to a sharedmailbox here and then verify the conversion
Set-Mailbox -Identity $Email -Type Shared

#Going to back to sleep to allow the conversion to finish and propagate, epecially since license removal is next
Start-Sleep -Seconds 30

Write-Host "`n Mailbox has been converted. Review the output to ensure conversion took place" -ForegroundColor Green

Get-Mailbox -Identity $Email | Format-List RecipientTypeDetails

Write-Warning -Message "Confirm that the output is RecipientTypeDetails : Sharedmailbox before proceeding" -WarningAction Inquire

Write-Host "`n Removing licensing" -ForeGroundColor Yellow

#We are going to remove the 365 license here
$userUPN = $Email
$userList = Get-AzureADUser -ObjectID $userUPN
$Skus = $userList | Select -ExpandProperty AssignedLicenses | Select SkuID
if($userList.Count -ne 0) {
    if($Skus -is [array])
    {
        $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        for ($i=0; $i -lt $Skus.Count; $i++) {
            $Licenses.RemoveLicenses +=  (Get-AzureADSubscribedSku | Where-Object -Property SkuID -Value $Skus[$i].SkuId -EQ).SkuID   
        }
        Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $licenses
    } else {
        $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        $Licenses.RemoveLicenses =  (Get-AzureADSubscribedSku | Where-Object -Property SkuID -Value $Skus.SkuId -EQ).SkuID
        Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $licenses
    }
}

Write-Host "`n Licenses have been removed" -ForegroundColor Green

#We are going to query the local server to find out if this is a hybrid setup by looking for the ADSync Service
#Then we will take care of any configuartion needed on the local domain controller to wrap this up

#Check if the service is on the server and return a status value to the host. If found continues, exits if not found
$Service = "ADSync"
if(Get-Service $Service -ErrorAction SilentlyContinue)
{
   Write-Host "`n ADSync Service Exists, Checking if user exists" -ForegroundColor Green

   if(Get-ADUser -Identity $ADAccount -Properties *){
      Write-host "`n User was found. Account is being disabled and removed from the address book" -ForegroundColor Yellow
      Start-Sleep -Seconds 5
      Set-ADUser -Identity $ADAccount -Replace @{msexchhidefromaddresslists=$true}
      
      Set-ADuser -Identity $ADAccount -Enabled $false
      Write-host "`n Account is now disabled, and removed from the address book" -ForegroundColor Green
      }Else{
      
     

      }

   }Else{

   Write-Host "`n ADSync Does NOT Exist" -ForegroundColor Yellow
   Write-Host "`n User Does NOT Exist" -ForegroundColor Yelloe

   Exit
   }


   Disconnect-AzureAD -Confirm All
   Disconnect-ExchangeOnline -Confirm All

<#Check if the user is on the server and return a status value to the host. If found continues, exits if not found
if(Get-ADuser -Identity $samAccountName -ErrorAction SilentlyContinue)
{
    Write-host "User Exists on Local Domain" -ForegroundColor Green

    }Else{

    Write-host "User Does NOT Exist" -ForegroundColor Yellow
    Exit
    }

#>