# İlk olarak aşağıdaki komutu çalıştır gelen soruya yes to all diye cevapla
# Set-ExecutionPolicy RemoteSigned

$MachScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$MachScriptDir += "\machines.json"
#Getting information from the json file
#The we pass the output from Get-Content to ConvertFrom-Json Cmdlet
$MachJsonObject = Get-Content $MachScriptDir | ConvertFrom-Json
 
[string]$KURULUM_PATH = $PSScriptRoot

cd $KURULUM_PATH

foreach($json in $MachJsonObject) {
   # If(!(test-path $line)){
        
        $pspasswd = $KURULUM_PATH + "\pspasswd.exe"

         # SIFIRINCI MAKINA
        [string]$source0 = '\\' + $json.Machines[0].IP

        & $pspasswd $source0 -u $json.Machines[0].AdminUser -p $json.Machines[0].AdminPass $json.Machines[0].UserOne $json.Machines[0].PassOne -accepteula
        & $pspasswd $source0 -u $json.Machines[0].AdminUser -p $json.Machines[0].AdminPass $json.Machines[0].UserTwo $json.Machines[0].PassTwo -accepteula
        & $pspasswd $source0 -u $json.Machines[0].AdminUser -p $json.Machines[0].AdminPass $json.Machines[0].UserThree $json.Machines[0].PassThree -accepteula
        & $pspasswd $source0 -u $json.Machines[0].AdminUser -p $json.Machines[0].AdminPass $json.Machines[0].AdminUser $json.Machines[0].AdminPassNew -accepteula

        Write-Host $json.Machines[0].IP IP NUMARALI MAKINA KULLANICILARI BITTI


        # BIRINCI MAKINA
        [string]$source1 = '\\' + $json.Machines[1].IP

        & $pspasswd $source1 -u $json.Machines[1].AdminUser -p $json.Machines[1].AdminPass $json.Machines[1].UserOne $json.Machines[1].PassOne -accepteula
        & $pspasswd $source1 -u $json.Machines[1].AdminUser -p $json.Machines[1].AdminPass $json.Machines[1].UserTwo $json.Machines[1].PassTwo -accepteula
        & $pspasswd $source1 -u $json.Machines[1].AdminUser -p $json.Machines[1].AdminPass $json.Machines[1].UserThree $json.Machines[1].PassThree -accepteula
        & $pspasswd $source1 -u $json.Machines[1].AdminUser -p $json.Machines[1].AdminPass $json.Machines[1].AdminUser $json.Machines[1].AdminPassNew -accepteula

        Write-Host $json.Machines[1].IP IP NUMARALI MAKINA KULLANICILARI BITTI

         # IKINCI MAKINA
        [string]$source2 = '\\' + $json.Machines[2].IP

        & $pspasswd $source2 -u $json.Machines[2].AdminUser -p $json.Machines[2].AdminPass $json.Machines[2].UserOne $json.Machines[2].PassOne -accepteula
        & $pspasswd $source2 -u $json.Machines[2].AdminUser -p $json.Machines[2].AdminPass $json.Machines[2].UserTwo $json.Machines[2].PassTwo -accepteula
        & $pspasswd $source2 -u $json.Machines[2].AdminUser -p $json.Machines[2].AdminPass $json.Machines[2].UserThree $json.Machines[2].PassThree -accepteula
        & $pspasswd $source2 -u $json.Machines[2].AdminUser -p $json.Machines[2].AdminPass $json.Machines[2].AdminUser $json.Machines[2].AdminPassNew -accepteula

        Write-Host $json.Machines[2].IP IP NUMARALI MAKINA KULLANICILARI BITTI

        # UCUNCU MAKINA
        [string]$source3 = '\\' + $json.Machines[3].IP

        & $pspasswd $source3 -u $json.Machines[3].AdminUser -p $json.Machines[3].AdminPass $json.Machines[3].UserOne $json.Machines[3].PassOne -accepteula
        & $pspasswd $source3 -u $json.Machines[3].AdminUser -p $json.Machines[3].AdminPass $json.Machines[3].UserTwo $json.Machines[3].PassTwo -accepteula
        & $pspasswd $source3 -u $json.Machines[3].AdminUser -p $json.Machines[3].AdminPass $json.Machines[3].UserThree $json.Machines[3].PassThree -accepteula
        & $pspasswd $source3 -u $json.Machines[3].AdminUser -p $json.Machines[3].AdminPass $json.Machines[3].AdminUser $json.Machines[3].AdminPassNew -accepteula

        Write-Host $json.Machines[3].IP IP NUMARALI MAKINA KULLANICILARI BITTI
        
    #}
}