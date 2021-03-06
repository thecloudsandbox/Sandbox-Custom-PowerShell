<#
Developed by The Cloud Sandbox - New User Creation Script for Hybrid 365/Azure Setup + License Assignment
By Jwitherspoon 4/8/22
(Work in Progress)


IMPORTANT: Line 28 -searchbase needs to be changed for the client. Currently working on making a universal variable if possible

#>
#Asks for domain and saves to $EmailDomain variable
$EmailDomain = Read-Host -Prompt "Enter the email domain including the @ symbol. ie @example.com"


#User Information 
$DisplayName = Read-Host -Prompt "Enter the Display Name for this user" 
$GivenName = Read-Host -Prompt "Enter the First Name for this User"
$SurName = Read-Host -Prompt "Enter the Last Name for this User"
$Mail = Read-Host -Prompt "Enter the Email Address for this User"
$SamAccountName = Read-Host "Enter the Username for this User"
$Password = Read-Host -AsSecureString "Enter the Password for this User"


#Static Variables DO NOT CHANGE
$UserPrincipleName = $SamAccountName + $EmailDomain


#Building a table of OUs, DOES NOT INCLUDE NON-ORGANIZATIONAL UNITS
Get-ADOrganizationalUnit -Filter * -Properties * -SearchBase "OU=Lab Users, DC=Lab, DC=local" | Select-Object -Property Name, DistinguishedName | Format-Table -AutoSize

Write-Host "`n Copy and Paste the Desired OU for the User Below"

$Path = Read-Host -Prompt  "Enter the OU Distinguished Name"

#We are confirming the user information is correct
$Confirm = "Please review the details of this new user, and then confirm creation"
Write-Warning $Confirm -WarningAction Inquire

Write-Host "`n Creating new AD user" -ForegroundColor Yellow
#We are creating the account here
New-ADUser -Name $DisplayName -GivenName $GivenName -Surname $SurName -EmailAddress $Mail -SamAccountName $SamAccountName -UserPrincipalName $UserPrincipleName -AccountPassword $Password -Path $Path -Enabled $true 
Write-Host "`n AD user has been created" -ForegroundColor Green

#We are going to Sync to Azure Now
Write-Host "`n Starting Sync to 365" -ForegroundColor Yellow

#Start-ADSyncSyncCycle -PolicyType Delta
$sync = Get-ADSyncScheduler

if ($sync.SyncCycleInProgress -eq $False)
{
Start-AdSyncSyncCycle -Policytype "Delta" |Out-Null
}

#Checks if the Sync Scheduler is Running Periodically
do {
    Write-Host "`n Azure AD Connect Sync Cycle in Progress..." -ForegroundColor "Yellow"
    $sync = Get-AdSyncScheduler
    
} until ($sync.SyncCycleInProgress -eq $False)

Start-Sleep -Seconds 30
Write-Host "`n Azure AD Connect Sync Cycle is finished." -ForegroundColor "Green"

Write-Host "`n Connecting to Azure"


#We are assigning the 365 license here 
Connect-AzureAD 

Write-Host "`n Starting 365 license assignment tasks" -ForegroundColor Yellow

#Sleeping to allow time for user to completely sync to 365
Start-Sleep -Seconds 30

#Set User Location for License Assignment
$365UN = $SamAccountName + $EmailDomain
Set-AzureADUser -ObjectID $365UN -UsageLocation US

#Get License Counts and SKUs
Get-AzureADSubscribedSku | Select-Object -Property SkuPartNumber,ConsumedUnits -ExpandProperty PrepaidUnits 
Pause
#We are choosing the license here
$SKU = Read-Host -Prompt "Enter the SkuPartNumber of the license you want to assign. from the list"
$ConfirmLicense = "Please confirm the correct license has been selected before proceeding"
Write-Warning -Message $ConfirmLicense -WarningAction Inquire

#No really, we are assigning the license here
$PlanSKU = $SKU
$License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
$License.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value $PlanSKU -EQ).SkuID
$LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
$LicensesToAssign.AddLicenses = $License
Set-AzureADUserLicense -ObjectId $365UN -AssignedLicenses $LicensesToAssign

Write-Host "`n License has been assigned" -ForegroundColor Green

#We are disconnecting and cleaning up here
#$Disconnect = "This message confirms that the AD account and 365 provisioning has completed, please click Yes to disconnect and clear all login data"
#Write-Warning -Message $Disconnect -WarningAction Inquire

Disconnect-AzureAD -Confirm
 

Write-Host "`n You have now been disconnected from Azure AD and the current user login session data has been cleared" -ForegroundColor Yellow
Write-Host "`n Active Directory and Microsoft 365 accounts are now setup. Enjoy your day!" -ForegroundColor Green
