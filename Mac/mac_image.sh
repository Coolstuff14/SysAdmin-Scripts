#!/bin/bash
#Jake Lee 2018
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

#Get host name from user input
echo 'Enter hostname'
read -p 'Hostname: ' hName

sudo scutil --set ComputerName "$hName" && \
sudo scutil --set HostName "$hName" && \
sudo scutil --set LocalHostName "$hName" && \
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$hName"
dscacheutil -flushcache

echo 'Hostname is: '
scutil --get HostName

#Get Username and Password for AD binding
echo 'Please enter credentials for binding'
read -p 'Username: ' uservar
read -sp 'Password: ' passvar

#Bind to Domain
echo 'Binding to domain...'
dsconfigad -f -a $hName -domain 'fsc.int' -ou "CN=Computers,DC=fsc,DC=int" -username $uservar -password $passvar -mobile enable -mobileconfirm enable -alldomains enable

#Login window set to name and password
echo 'Setting Login window to Name and Password...'
defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true

#Enable remote access and all options
echo 'Enabling Remote Access...'
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -users macadmin -allowAccessFor -specifiedUsers -restart -agent -menu

#Set user privs for all control
echo 'Set user privileges...'
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -users macadmin -access -on -privs -all

#Mount foundry
echo 'Mounting Foundry...'
/usr/bin/osascript > /dev/null << EOT

        tell application "Finder"
        activate
        mount volume "smb://foundry/software"
        end tell


EOT
killall cfprefsd
defaults write com.apple.finder ShowMountedServersOnDesktop true
killall -HUP Finder

#Install KACE
echo 'Installing kace...'
sudo installer -pkg /Volumes/software/KACE/kacemac7.pkg -target /

#Mount Fozzie
echo 'Mounting Fozzie...'
/usr/bin/osascript > /dev/null << EOT

        tell application "Finder"
        activate
        mount volume "smb://fozzie.fsc.int/TechVol"
        end tell


EOT
killall cfprefsd
defaults write com.apple.finder ShowMountedServersOnDesktop true
killall -HUP Finder

#Run filevault script
echo 'Setting up Filevault private Key...'
sudo /Volumes/TechVol/FileVault/Filevaultauto2

#Run Microsoft Office Installer
echo 'Installing Office...'
sudo installer -pkg /Volumes/TechVol/Microsoft/office.pkg -target /

#Run Microsoft Office Serial Installer
echo 'Installing Office Key...'
sudo installer -pkg /Volumes/TechVol/Microsoft/officekey.pkg -target /
