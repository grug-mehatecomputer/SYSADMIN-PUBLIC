# Composed by Grug
# WARNING - NOT FOR THOSE WITHOUT COMPREHENSION

#SCRIPT PURPOSE :
#Converts an O365 Tenant's federation.

#LOGGING
$SCRIPTNAME ="SeverFederation"
$DATETIME = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LOGPATH = "C:\TEMP\$SCRIPTNAME_$DATETIME.txt"
Start-Transcript -path $LOGPATH -append

#SCRIPT VARS

$TenantID = #<TenantID ie: "12345-234-12355-1235554"
$DomainID = #<Domain to remove federation from ie: "contoso.com"

# Install the Microsoft Graph PowerShell module if you haven't already
Install-Module Microsoft.Graph -Scope CurrentUser

# Set the execution policy to allow script execution
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Connect to Microsoft Graph with the necessary permissions
Connect-MgGraph -TenantID $TenantID -Scopes "Domain.ReadWrite.All", "Directory.AccessAsUser.All"

# Replace <yourdomain.com> with your actual federated domain
Update-MgDomain -DomainId $DomainID -AuthenticationType "Managed"

# Verify the change
Get-MgDomain -DomainId $DomainID

Stop-Transcript