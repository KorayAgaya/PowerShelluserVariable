Write-Host $PSScriptRoot 

# Set-ExecutionPolicy RemoteSigned
# PATH VARIABLE

# Add Static Route for SIM Net DEGISTIR

route -p ADD 224.0.0.0 MASK 240.0.0.0 192.168.32.54

[string]$KURULUM_PATH = $PSScriptRoot

$ROOT_PATH = $PSScriptRoot

# PRG PATH ###############################

$PrgPath = $KURULUM_PATH + "\ORTAK-KURULUM"

##########################################

$USER_LIST_FOLDER = $PSScriptRoot + "\ORTAK-KURULUM\USER\user-list.txt"

$LIBRARY_COPY_FOLDER = $PSScriptRoot + "\ORTAK-KURULUM\DisKutuphane\"

$BGINFO_COPY_FOLDER = $PSScriptRoot + "\ORTAK-KURULUM\BgInfo"

$BACKROUND_COPY_FOLDER = $PSScriptRoot + "\ORTAK-KURULUM\background"

$LGPO_RUN_FOLDER = $PSScriptRoot + "\ORTAK-KURULUM\LGPO"

#Change Administrator Password

$Password = ConvertTo-SecureString thyadmin -AsPlainText -Force
$UserAccount = Get-LocalUser -Name "Administrator"
$UserAccount | Set-LocalUser -Password $Password

# Change Administrator Username to hvladmin

Rename-LocalUser -Name "Administrator" -NewName "hvladmin"


# Change Keyboard language Settings

Set-WinUserLanguageList tr-TR

# CHANGE COMPUTER NAME

 [string]$hostname = {IOS-FFS3-A320}
 Rename-Computer -newname $hostname
 

# Power Options Turn Off Display


Powercfg /Change monitor-timeout-ac 0
Powercfg /Change monitor-timeout-dc 0


# Power Options Put the computer to sleep

Powercfg /Change standby-timeout-ac 0
Powercfg /Change standby-timeout-dc 0

# Firewall OFF 

netsh advfirewall set allprofiles state off

#BGINFO CONFIG
## Variables
New-Item -ItemType Directory -Force -Path c:\BgInfo

#Copy-Item -Path ("C:\Users\Administrator\Desktop\SETUP-POWERSHELL\ORTAK-KURULUM\BgInfo\StartUp.bgi") -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\" -Force
Copy-Item -Path ("$BACKROUND_COPY_FOLDER\Havelsan_Logo.jpg") -Destination "C:\Users\Public\Pictures\" -Force
Copy-Item -Path ("$BGINFO_COPY_FOLDER\BgInfo.exe") -Destination "C:\BgInfo\" -Force
Copy-Item -Path ("$BGINFO_COPY_FOLDER\StartUp.bgi") -Destination "C:\BgInfo\" -Force

$bgInfoFolder = "C:\BgInfo"
$bgInfoFolderContent = $bgInfoFolder + "\*"
$itemType = "Directory"
$bgInfoRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$bgInfoRegkey = "BgInfo"
$bgInfoRegType = "String"
$bgInfoRegkeyValue = "C:\BgInfo\Bginfo.exe C:\BgInfo\StartUp.bgi /timer:0 /nolicprompt"
$regKeyExists = (Get-Item $bgInfoRegPath -EA Ignore).Property -contains $bgInfoRegkey
$writeEmptyLine = "`n"
$writeSeperator = " - "
$time = Get-Date
$foregroundColor1 = "Yellow"
$foregroundColor2 = "Red"

## Create BgInfo folder on C: if not exists
 
If (!(Test-Path -Path $bgInfoFolder)){New-Item -ItemType $itemType -Force -Path $bgInfoFolder
    Write-Host ($writeEmptyLine + "# BgInfo folder created" + $writeSeperator + $time)`
    -foregroundcolor $foregroundColor1 $writeEmptyLine
 }

## Create BgInfo Registry Key to AutoStart
 
If ($regKeyExists -eq $True){Write-Host ($writeEmptyLine + "BgInfo regkey exists, script wil go on" + $writeSeperator + $time)`
-foregroundcolor $foregroundColor2 $writeEmptyLine
}Else{
New-ItemProperty -Path $bgInfoRegPath -Name $bgInfoRegkey -PropertyType $bgInfoRegType -Value $bgInfoRegkeyValue
Write-Host ($writeEmptyLine + "# BgInfo regkey added" + $writeSeperator + $time)`
-foregroundcolor $foregroundColor1 $writeEmptyLine}
 
## Run BgInfo
 
C:\BgInfo\Bginfo.exe C:\BgInfo\StartUp.bgi /timer:0 /nolicprompt
Write-Host ($writeEmptyLine + "# BgInfo has run" + $writeSeperator + $time)`
-foregroundcolor $foregroundColor1 $writeEmptyLine

# BGINFO END OF LINE

# All Users Set ( This command have a error but not important continue ) 

## Invoke-Command -ScriptBlock {.\LGPO.exe /b $LGPO_FOLDER_BACKUP /v}
cd $LGPO_RUN_FOLDER
cmd /c "LGPO.exe /g {F3383D51-089F-4AB0-8763-029AEA239632}"


# UAC Never Notify

New-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA -PropertyType DWord -Value 0 -Force

# Change Lock Screen Image 

# New-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\Personalization -Name LockScreenImage -PropertyType DWord -Value 1 -Force

# Change Remote Desktop Settings to ENABLE

Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0

# Create Symbol Link Add User DEV, SIM, TEST 
$SECPOL_Security_Policy_PATH = $KURULUM_PATH + "\ORTAK-KURULUM\USER\defltbase.inf"

secedit /export /cfg $SECPOL_Security_Policy_PATH
(gc $SECPOL_Security_Policy_PATH).replace("SeCreateSymbolicLinkPrivilege = *S-1-5-32-544", "SeCreateSymbolicLinkPrivilege = dev,sim,test,*S-1-5-32-544") | Out-File $SECPOL_Security_Policy_PATH
secedit /configure /cfg $SECPOL_Security_Policy_PATH /db defltbase.sdb /verbose
rm -force $SECPOL_Security_Policy_PATH -confirm:$false

# Create Projects Folder

New-Item -ItemType Directory -Force -Path c:\Projects

# Create DEV, SIM, TEST Folder and Under this folder create COTS, DATA, RELEASE

foreach($line in Get-Content $USER_LIST_FOLDER) {
   # If(!(test-path $line)){
        New-Item -ItemType Directory -Force -Path c:\Projects\$line
        New-Item -ItemType Directory -Force -Path c:\Projects\$line\application
        New-Item -ItemType Directory -Force -Path c:\Projects\$line\application\cots
        New-Item -ItemType Directory -Force -Path c:\Projects\$line\application\data
        New-Item -ItemType Directory -Force -Path c:\Projects\$line\application\release
        New-Item -ItemType Directory -Force -Path c:\Projects\$line\application\script

        $Password = ConvertTo-SecureString $line -AsPlainText -Force

        Write-Host $line 
        New-LocalUser $line -Password $Password -FullName $line -Description "Simulation account."
        Add-LocalGroupMember -Group "Users" -Member "$line"
        Set-LocalUser -Name $line -PasswordNeverExpires:$true
        Set-LocalUser -Name $line -Password $Password -PasswordNeverExpires:$true
    #}
}

# Add Remote Desktop Users

Add-LocalGroupMember -Group "Remote Desktop Users" -Member "dev"
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "sim"
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "test"

# ADD FOLDER PERMISSIONS DEV, SIM, TEST

$hstname = $env:computername

#DEV
$devacl1 = Get-Acl C:\Projects\dev
$devAccessRule1 = New-Object System.Security.AccessControl.FileSystemAccessRule("$hstname\test","FullControl","ContainerInherit,ObjectInherit","NoPropagateInherit","Deny")
$devacl1.AddAccessRule($devAccessRule1)
Set-Acl -Path "C:\Projects\dev" -AclObject $devacl1

$devacl2 = Get-Acl C:\Projects\dev
$devAccessRule2 = New-Object System.Security.AccessControl.FileSystemAccessRule("$hstname\sim","FullControl","ContainerInherit,ObjectInherit","NoPropagateInherit","Deny")
$devacl2.AddAccessRule($devAccessRule2)
Set-Acl -Path "C:\Projects\dev" -AclObject $devacl2

$devacl3 = Get-Acl C:\Projects\dev
$devAccessRule3 = New-Object System.Security.AccessControl.FileSystemAccessRule("$hstname\dev","FullControl","ContainerInherit,ObjectInherit","NoPropagateInherit","Allow")
$devacl3.AddAccessRule($devAccessRule3)
Set-Acl -Path "C:\Projects\dev" -AclObject $devacl3

#SIM
$simacl1 = Get-Acl C:\Projects\sim
$simAccessRule1 = New-Object System.Security.AccessControl.FileSystemAccessRule("$hstname\test","FullControl","ContainerInherit,ObjectInherit","NoPropagateInherit","Deny")
$simacl1.AddAccessRule($simAccessRule1)
Set-Acl -Path "C:\Projects\sim" -AclObject $simacl1

$simacl2 = Get-Acl C:\Projects\sim
$simAccessRule2 = New-Object System.Security.AccessControl.FileSystemAccessRule("$hstname\dev","FullControl","ContainerInherit,ObjectInherit","NoPropagateInherit","Deny")
$simacl2.AddAccessRule($simAccessRule2)
Set-Acl -Path "C:\Projects\sim" -AclObject $simacl2

$simacl3 = Get-Acl C:\Projects\sim
$simAccessRule3 = New-Object System.Security.AccessControl.FileSystemAccessRule("$hstname\sim","FullControl","ContainerInherit,ObjectInherit","NoPropagateInherit","Allow")
$simacl3.AddAccessRule($simAccessRule3)
Set-Acl -Path "C:\Projects\sim" -AclObject $simacl3

#TEST 
$testacl1 = Get-Acl C:\Projects\test
$testAccessRule1 = New-Object System.Security.AccessControl.FileSystemAccessRule("$hstname\dev","FullControl","ContainerInherit,ObjectInherit","NoPropagateInherit","Deny")
$testacl1.AddAccessRule($testAccessRule1)
Set-Acl -Path "C:\Projects\test" -AclObject $testacl1

$testacl2 = Get-Acl C:\Projects\test
$testAccessRule2 = New-Object System.Security.AccessControl.FileSystemAccessRule("$hstname\sim","FullControl","ContainerInherit,ObjectInherit","NoPropagateInherit","Deny")
$testacl2.AddAccessRule($testAccessRule2)
Set-Acl -Path "C:\Projects\test" -AclObject $testacl2

$testacl3 = Get-Acl C:\Projects\test
$testAccessRule3 = New-Object System.Security.AccessControl.FileSystemAccessRule("$hstname\test","FullControl","ContainerInherit,ObjectInherit","NoPropagateInherit","Allow")
$testacl3.AddAccessRule($testAccessRule3)
Set-Acl -Path "C:\Projects\test" -AclObject $testacl3


# Install Notepad++

start-process -FilePath "$PrgPath\npp.7.Installer.x64.exe" -ArgumentList '/S' -Verb runas -Wait

# Install WinMerge

start-process -FilePath "$PrgPath\WinMerge-2.16.4-Setup.exe" /VERYSILENT

# INSTALL WIRESHARK

#http://www.get-itsolutions.com/wireshark-silent-install-uninstall-msi/#124 npcap-0.86.exe

start-process -FilePath "$PrgPath\Wireshark-win64-3.0.7.exe" -Wait -ArgumentList @('/NCRC', '/S', '/desktopicon=no' ,'/quicklaunchicon=no');
start-process -FilePath "$PrgPath\npcap-0.86.exe" -ArgumentList @('/S', '/winpcap_mode=yes')

#Wireshark File Permisson

#WIRESHARK
$Wiresharkacl1 = Get-Acl C:\'Program Files'\Wireshark
$WiresharkAccessRule1 = New-Object System.Security.AccessControl.FileSystemAccessRule("$hstname\test","FullControl","ContainerInherit,ObjectInherit","NoPropagateInherit","Allow")
$Wiresharkacl1.AddAccessRule($WiresharkAccessRule1)
Set-Acl -Path C:\'Program Files'\Wireshark -AclObject $Wiresharkacl1

$Wiresharkacl2 = Get-Acl C:\'Program Files'\Wireshark
$WiresharkAccessRule2 = New-Object System.Security.AccessControl.FileSystemAccessRule("$hstname\sim","FullControl","ContainerInherit,ObjectInherit","NoPropagateInherit","Allow")
$Wiresharkacl2.AddAccessRule($WiresharkAccessRule2)
Set-Acl -Path C:\'Program Files'\Wireshark -AclObject $Wiresharkacl2

$Wiresharkacl3 = Get-Acl C:\'Program Files'\Wireshark
$WiresharkAccessRule3 = New-Object System.Security.AccessControl.FileSystemAccessRule("$hstname\dev","FullControl","ContainerInherit,ObjectInherit","NoPropagateInherit","Allow")
$Wiresharkacl3.AddAccessRule($WiresharkAccessRule3)
Set-Acl -Path C:\'Program Files'\Wireshark -AclObject $Wiresharkacl3


# BOOTS, QT, Xerces, Cmake, PHP Copy to DEV, SIM, TEST

ROBOCOPY /MIR "$LIBRARY_COPY_FOLDER" "C:\Projects\dev\application\cots\" | Out-Null

ROBOCOPY /MIR "$LIBRARY_COPY_FOLDER" "C:\Projects\sim\application\cots\" | Out-Null

ROBOCOPY /MIR "$LIBRARY_COPY_FOLDER" "C:\Projects\test\application\cots\" | Out-Null