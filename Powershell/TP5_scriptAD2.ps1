<#------------------------------------------------------------------
Apprentissage PowerShell - TP5_scriptAD2.ps1
Fonction : Création de comptes AD à partir d'un fichier csv
Auteur CLB – 06/10/2025
--------------------------------------------------------------------#>

Import-Module ActiveDirectory
$ADUsers=Import-csv "c:\users\Administrateur\Documents\utilisateurs sodecaf.csv" -Delimiter ";"

foreach ($user in $ADUsers) {
    $prenom=$user.firstname
    $nom=$user.lastname
    $fonction=$user.Function
    $login=$prenom.Substring(0,1)+$nom
    $login=$login.tolower()
    $password="Btssio2017"

    echo ($prenom+" "+$nom+" "+$fonction+" "+$login)

    #-------- Création des UO --------------
    if ((Get-ADOrganizationalUnit -filter "DistinguishedName -like 'ou=Employés,dc=sodecaf,dc=local'") -eq $null) {
            New-ADOrganizationalUnit -Name "Employés" -Path "dc=sodecaf,dc=local" -ProtectedFromAccidentalDeletion $false
    }
 
    if ((Get-ADOrganizationalUnit -filter "DistinguishedName -like 'ou=$fonction,ou=Employés,dc=sodecaf,dc=local'") -eq $null) {
            New-ADOrganizationalUnit -Name $fonction -Path "ou=Employés,dc=sodecaf,dc=local" -ProtectedFromAccidentalDeletion $false
    }

    #-------- Création des groupes --------------
    if (!(Get-ADGroup -Filter "DistinguishedName -like 'CN=$fonction,ou=Employés,dc=sodecaf,dc=local'")) {
        New-ADGroup -Name $fonction -GroupScope Global -GroupCategory Security -Path "ou=$fonction,ou=Employés,dc=sodecaf,dc=local"
    }

    #-------- Création des comptes --------------
    try {
        New-ADUser -Name $nom_complet -GivenName $prenom -Surname $nom `
        -SamAccountName $login `
        -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) `
        -Path "ou=$fonction,ou=Employés,dc=sodecaf,dc=local" `
        -Enabled $true

        Add-ADGroupMember -Identity $fonction -Members $login
    }
    catch {
        echo "L'utilisateur $login existe déjà"
    }

    #-------- Intégration des comptes dans les groupes --------------



}
