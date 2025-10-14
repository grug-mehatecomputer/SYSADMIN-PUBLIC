# Composed by Grug
# WARNING - NOT FOR THOSE WITHOUT COMPREHENSION

#SCRIPT PURPOSE : This should make everything required for Azure VPN. I have no idea.

#LOGGING
$SCRIPTNAME ="AzureVPNCert"
$DATETIME = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LOGPATH = "C:\TEMP\$SCRIPTNAME_$DATETIME.txt"
Start-Transcript -path $LOGPATH -append

#SCRIPT VARS TO MODIFY
$CLIENTNAME = "SNE" #Used In FileNames
$FOLDERPATH = "C:\temp\CLIENT-AZURE-VPN" #Folder for File Outouts
$PASSWORD = "PASSWORD"
$COUNTRYCODE = "US"
$STATE = "SA"
$CITY = "CITY"
$ORGANIZATION = $CLIENTNAME
$COMMONNAME = "contoso.com" #Not really used in P2S
$EMAILADDRESS ="ADMIN@contoso.com"



#SCRIPT

#Plan file names...
$ROOTKEYPATH = $FOLDERPATH+"\"+$CLIENTNAME+"-AZURE-ROOT-KEY.key"
$ROOTPATH = $FOLDERPATH+"\"+$CLIENTNAME+"-AZURE-ROOT.crt"
$ROOTPATHCER = $FOLDERPATH+"\"+$CLIENTNAME+"-AZURE-ROOT.cer"
$ROOTPATHBASE64 = $FOLDERPATH+"\"+$CLIENTNAME+"-AZURE-ROOT-BASE64.cer"

$CLIENTKEYPATH = $FOLDERPATH+"\"+$CLIENTNAME+"-AZURE-CLIENT.key"
$CLIENTSIGNPATH = $FOLDERPATH+"\"+$CLIENTNAME+"-AZURE-CLIENT.csr"
$CLIENTCERTPATH = $FOLDERPATH+"\"+$CLIENTNAME+"-AZURE-CLIENT.crt"

$SUBJECT = "/C="+$COUNTRYCODE+"/ST="+$STATE+"/L="+$CITY+"/O="+$ORGANIZATION+"/OU="+$ORGANIZATION+"/CN="+$COMMONNAME+"/emailAddress="+$EMAILADDRESS

#Generate Signing Key and CRT
openssl genrsa -aes256 -passout pass:$PASSWORD -out $ROOTKEYPATH 4096
openssl req -x509 -new -key $ROOTKEYPATH -passin pass:$PASSWORD -sha256 -days 3650 -out $ROOTPATH -subj $SUBJECT

#Generate CSR for the client cert
openssl genrsa -aes256 -passout pass:$PASSWORD -out $CLIENTKEYPATH 4096
openssl req -new -key $CLIENTKEYPATH -passin pass:$PASSWORD -out $CLIENTSIGNPATH -subj $SUBJECT

#Generate Client Cert by signing the cert with ROOT CA

openssl x509 -req -days 3650 -in $CLIENTSIGNPATH -CA $ROOTPATH -CAkey $ROOTKEYPATH -passin pass:$PASSWORD -out $CLIENTCERTPATH

#Generate CER File for AzureVPN, using ROOT CA.

openssl x509 -in $ROOTPATH -outform der -out $ROOTPATHCER
certutil -encode $ROOTPATHCER $ROOTPATHBASE64

Stop-Transcript