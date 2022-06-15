#Add Users to 365 Groups/Distribution Lists

#Developed by The Cloud Sandbox at some point.....Needs revision as of 6/13/22

#The two commands below should only need to be run once if the module has never been installed    
    #Install-Module AzureAD
 
#Import-Module -Name AzureAD

#Get all groups that are mail enabled
#Get-AzureADGroup  -Filter "SecurityEnabled eq false and MailEnabled eq true"

#Get-AzureADUser -ObjectID "enter ID"

#Add-AzureADGroupMember -ObjectId "Enter ID" -RefObjectId "Enter ID"

$EmailAddress = Read-Host "Enter the email address"
$ID = (get-azureaduser -Filter "UserPrincipalName eq '$EmailAddress'").objectid
$Memberships = (Get-AzureADUserMembership -ObjectId $ID).objectid

Foreach ($Membership in $Memberships) {

Remove-AzureADGroupMember -ObjectId $Membership -MemberId $ID }