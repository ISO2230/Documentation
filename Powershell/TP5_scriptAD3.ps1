<#------------------------------------------------------------------
Apprentissage PowerShell - TP5_scriptAD3.ps1
Fonction : Création de comptes AD à partir d'un fichier csv
            Ajout des lecteurs réseaux
Auteur CLB – 06/10/2025
--------------------------------------------------------------------#>

Import-Module ActiveDirectory
$ADUsers=Import-csv "c:\users\Administrateur\Desktop\script\utilisateurs sodecaf.csv" -Delimiter ";"
$dossier="c:\donnees\"

#-------- Fonction de génération de mot de passe --------------
Function CreatePassword() {

    for ($i=0;$i -lt 3;$i++){
        $min += Get-Random -InputObject a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
    }

    for ($i=0;$i -lt 3;$i++){
        $maj += Get-Random -InputObject A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z
    }

    $nombre = Get-Random -Minimum 10 -Maximum 99

    $caracspec = Get-Random -InputObject !,?,$,*,_,+,=,:

    $pass = $min+$maj+$nombre+$caracspec

    return $pass
}

#-------- Parcours des utilisateurs dans le fichier csv --------------
foreach ($user in $ADUsers) {
    $prenom=$user.firstname
    $nom=$user.lastname
    $nom_complet=$prenom+" "+$nom
    $fonction=$user.Function
    $login=$prenom.Substring(0,1)+$nom
    $login=$login.tolower()
    $password="Btssio2017"

echo ($prenom+" "+$nom+" "+$fonction+" "+$login+" "+$password)

#-------- Création des UO --------------
if ((Get-ADOrganizationalUnit -filter "DistinguishedName -like 'ou=Employés,dc=sodecaf,dc=local'") -eq $null) {
        New-ADOrganizationalUnit -Name "Employés" -Path "dc=sodecaf,dc=local" -ProtectedFromAccidentalDeletion $false
}
 
if ((Get-ADOrganizationalUnit -filter "DistinguishedName -like 'ou=$fonction,ou=Employés,dc=sodecaf,dc=local'") -eq $null) {
        New-ADOrganizationalUnit -Name $fonction -Path "ou=Employés,dc=sodecaf,dc=local" -ProtectedFromAccidentalDeletion $false
}

#-------- Création des groupes --------------
if ((Get-ADGroup -filter "DistinguishedName -like'CN=$fonction,ou=$fonction,ou=Employés,dc=sodecaf,dc=local'") -eq $null) {
    New-ADGroup -Name $fonction -GroupScope Global -GroupCategory Security -Path "ou=$fonction,ou=Employés,dc=sodecaf,dc=local"
}

#-------- Création des comptes et intégration dans un groupe --------------
try {
        New-ADUser -Name $nom_complet -GivenName $prenom -Surname $nom `
        -SamAccountName $login `
        -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) `
        -Path "ou=$fonction,ou=Employés,dc=sodecaf,dc=local" `
        -HomeDrive "U:" `
        -HomeDirectory "\\172.16.0.1\donnees\$login" `
        -Enabled $true

        Add-ADGroupMember -Identity $fonction -Members $login
    }
    catch {
        echo "L'utilisateur $login existe déjà"
    }

#-------- Création du lecteur réseau par utilisateur --------------

    if (!(Test-Path ($dossier+$login))) {
        New-Item -Path $dossier -Name $login -ItemType "Directory"
        Set-NTFSOwner -Path ($dossier+$login) -Account "sodecaf.local\$login"
        Add-NTFSAccess -Path ($dossier+$login) -Account "sodecaf.local\$login" -AccessRights FullControl -AccessType Allow -PassThru
    }

}