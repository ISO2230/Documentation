<#------------------------------------------------------------------
Apprentissage PowerShell - Script n° 1
Fonction : Ce script cherche un fichier dans un dossier donné
Auteur BD – 17/12/2013
--------------------------------------------------------------------#>
$cherche = $args[0]
$dossier = $args[1]
echo "Recherche du fichier $cherche dans le dossier $dossier"
Get-ChildItem -Path $dossier -Recurse -ErrorAction SilentlyContinue | 
    Where-Object {$_.Name -eq $cherche} |
    forEach-Object {
            echo ("le fichier $cherche est dans "+$_.DirectoryName) 
    } 