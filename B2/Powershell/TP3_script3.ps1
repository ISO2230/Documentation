<#-------------------------------------------------------------------
Apprentissage PowerShell - Script n° 3
Auteur BD – 18/12/2013
---------------------------------------------------------------------#>
$listeCouleurs = @("Black","DarkBlue","DarkGreen","DarkCyan","DarkRed","DarkMagenta","DarkYellow","Gray","DarkGray","Blue","Green","Cyan","Red","Magenta","Yellow","White")
$invite = "saisissez une couleur"
$couleur =""
while ($couleur -ne 'stop') {
    $couleur = Read-Host $invite 
    $z = $listeCouleurs | where-object {$_ -match $couleur}
    if ($z -ne $null)  {
        Write-Host -ForegroundColor $couleur ("vous avez demandé à écrire en "+$couleur)
    }
    else {
        write-host ("la couleur "+$couleur+" n'existe pas.")
    }
}