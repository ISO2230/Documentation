<#------------------------------------------------------------------
Apprentissage PowerShell - TP5_scriptAD1.ps1
Fonction : test de création de comptes
Auteur CLB – 06/10/2025
--------------------------------------------------------------------#>

Import-Module ActiveDirectory

New-ADOrganizationalUnit -Name "Employés" -Path "dc=sodecaf,dc=local" -ProtectedFromAccidentalDeletion $false

New-ADUser -Name "Paul Bismuth" -GivenName Paul -Surname Bismuth `
-SamAccountName pbismuth -UserPrincipalName pbismuth@supinfo.com `
-AccountPassword (Read-Host -AsSecureString "Mettez ici votre mot de passe") `
-Path "ou=Employés,dc=sodecaf,dc=local" `
-PassThru | Enable-ADAccount

New-ADGroup -name "Politique" -groupscope Global -Path "ou=Employés,dc=sodecaf,dc=local"

Add-ADGroupMember -Identity "Politique" -Members "pbismuth"

