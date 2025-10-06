<#-------------------------------------------------------------------
Apprentissage PowerShell - Script n° 4
Auteur CLB – 29/09/2025
Import et traitement d'un fichier csv
---------------------------------------------------------------------#>
ipcsv ".\utilisateurs sodecaf.csv" -Delimiter ";" | foreach { 
    $agence = $_.agency;
    if ((Test-Path ("c:\"+$agence)) -eq $false) {
        New-Item ("c:\"+$agence) -ItemType "Directory" | Out-Null
    }

    $couleur = switch($_.function) {
        comptable {"yellow"}
        accueil {"blue"}
        informatique {"cyan"}
        default {"white"}
    }

    $triGramme = $_.firstname.substring(0,1)+$_.lastname.substring(0,1)
    $triGramme = $triGramme + $_.lastname.substring($_.lastname.length-1,1)
    $trigramme = $triGramme.toUpper()

    if ((Test-Path ("c:\"+$agence+"\fic_"+$trigramme)) -eq $false) {
        New-Item ("c:\"+$agence+"\fic_"+$trigramme) -ItemType "Directory" 
    }
    else {
        write-Host ("Dossier utilisateur déjà existant")
    }

    Write-Host -ForegroundColor $couleur ($_.firstname+" "+$_.lastname+" ("+$triGramme+") "+$_.phone1)
    }
