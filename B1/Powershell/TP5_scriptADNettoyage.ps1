<#------------------------------------------------------------------
Apprentissage PowerShell - TP5_scriptADNettoyage.ps1
Fonction : test de création de comptes
Auteur CLB – 06/10/2025
--------------------------------------------------------------------#>

Import-Module ActiveDirectory

Function effaceUO ($name) {
    if (Get-ADOrganizationalUnit -filter "DistinguishedName -like 'ou=$name,dc=sodecaf,dc=local'") {
        Remove-ADOrganizationalUnit -Identity "ou=$name,dc=sodecaf,dc=local" -Recursive -Confirm:$false
        Write-Host "UO $name a été supprimée"
    }
    else
    {
        Write-Host "UO $name n'existe pas"
    }
}

#----------------------------------------------------------
effaceUO ("Employés")
