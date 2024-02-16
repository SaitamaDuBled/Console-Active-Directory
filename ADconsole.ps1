#Déclaration de fonctions d'affichage
function display_row() {
    $largeur_window = $Host.UI.RawUI.WindowSize.Width 
    $display_row2 = "_" * $largeur_window
    Write-Host $display_row2
}
function display_row2() {
    $largeur_window = $Host.UI.RawUI.WindowSize.Width 
    $display_row2 = "*" * $largeur_window
    Write-Host $display_row2
}
function result($commande) {
    $largeurFenetre1 = $Host.UI.RawUI.WindowSize.Width - 8
    $largeur_window = $Host.UI.RawUI.WindowSize.Width 
    $moitie = $largeurFenetre1 / 2
    $display_row = "=" * $moitie
    $quart = " " * (1 / 4 * $largeur_window)
    $display_row2 = "_" * $largeur_window
    Write-Output ""
    Write-Host $display_row"RESULTAT"$display_row
    Write-Output ""
    Write-Host $quart $commande
    Write-Output ""
    Write-Host $display_row2
}
function loading () {
    # Définir les symboles de chargement
    $symboles = @('-', '\', '|', '/')

    # Boucle infinie pour l'animation

    for ($i = 0; $i -lt 5; $i++) {
        foreach ($symbole in $symboles) {
            Write-Host -NoNewline $symbole
            Start-Sleep -Milliseconds 100  # Ajustez la vitesse de l'animation si nécessaire
            Write-Host -NoNewline "`b `b `b `b `b"  # Effacer les symboles
        }
    }
}
# déclaration de fonction de l'active directory
# Creation d'utilisateur par default donc dans Users
function Creation_User() {
    $nomUtilisateur = Read-Host "Nom d'utilisateur                   ======>"
    $motDePasse = Read-Host     "Mot de passe                        ======>"
    $nomComplet = Read-Host     "Nom complet                         ======>"
    $email = Read-Host          "Email (ex : ilias.elhouzi)          ======>"
    result(dsadd user cn=$nomUtilisateur,cn=Users,dc=$domain,dc=$tld -samid $nomUtilisateur -upn "$email@$domain.$tld" -display $nomComplet -pwd $motDePasse -pwdneverexpires yes -disabled no )
}  
# Creation d'utilisateur directement dans un UO disponible
function Creation_User_UO() {
    $nomUtilisateur = Read-Host "Nom d'utilisateur                        ======>"
    $motDePasse =     Read-Host "Mot de passe                             ======>"
    $nomComplet =     Read-Host "Nom complet                              ======>"
    $email =          Read-Host "Email  (ex : elian.blanchard)            ======>"
    liste_UO
    $nameUO = Read-Host "Indiquer le nom de l'unitee organisationnelle "
    $Value = Read-Host "VOULEZ VOUS l'AJOUTER DANS UN GROUPE ? Y/N"
    
    if ($Value -eq "Yes" -or $Value -eq "Y") {
        $groupe = Read-Host "Groupe :"
        result(dsadd user cn=$nomUtilisateur,ou=$nameUO,dc=$domain,dc=$tld -samid $nomUtilisateur -upn "$email@$domain.$tld" -display $nomComplet -pwd $motDePasse -memberof cn=$groupe,ou=$nameUO,dc=$domain,dc=$tld -pwdneverexpires yes -disabled no)
    }
    elseif ($Value -eq "No" -or $Value -eq "N") {
        result(dsadd user cn=$nomUtilisateur,ou=$nameUO,dc=$domain,dc=$tld -samid $nomUtilisateur -upn "$email@$domain.$tld" -display $nomComplet -pwd $motDePasse)
    }
    else {
        Write-Host "Veuillez choisir :        Yes ou No "
    }
} 
# Creation de Unité Organisationnel (UO)
function Creation_UO() {
    $nameUO = Read-Host "indiquer le nom de l'unite organisationnelle  ======>"
    result(dsadd ou ou=$nameUO,dc=$domain,dc=$tld)
}
# Creation de groupe dans une UO disponible
function Creation_group() {
    Write-Output "`nListe des U0 disponible :`n"
    Get-ADOrganizationalUnit -Filter * -Properties * | Format-Table CanonicalName    
    $nameGroup = Read-Host "indiquer le nom du groupe a creer               ======>"
    $nameUO = Read-Host    "indiquer le nom de l'unite organisationnelle    ======>"  
    result(dsadd group cn=$nameGroup,ou=$nameUO,dc=$domain,dc=$tld)
}
# Déplacer un utilisateur de Users(endroit créer par defaut) à une UO disponible
function move_user_to_UO() {
    $nomUtilisateur = Read-Host "Nom d'utilisateur                            ======>"
    liste_UO
    $nameUO = Read-Host         "indiquer le nom de l'unité organisationnelle ======>"
    result(dsmove cn=$nomUtilisateur,cn=Users,dc=$domain,dc=$tld -newparent ou=$nameUO,dc=$domain,dc=$tld)
}
# Ajouter un utilisateur à un groupe
function add_user_group() {
    $nomUtilisateur = Read-Host " Nom d'utilisateur                            ======>"
    $nameGroup = Read-Host      " indiquer le nom du groupe                    ======>"
    $nameUO = Read-Host         " indiquer le nom de l'unite organisationnelle ======>"  
    result(dsmod group cn=$nameGroup,ou=$nameUO,dc=$domain,dc=$tld -addmbr cn=$nomUtilisateur,ou=$nameUO,dc=$domain,dc=$tld)
}
# Supprimer un utilisateur

function delete_user{
    liste_user
    $nomUtilisateur = Read-Host "Utilisateur à supprimer"
    Remove-ADUser -Identity $nomUtilisateur
}
# Lister les UO et Utilisateurs de l'AD
function liste_user() {
    Write-Output "`nListe des Utilisateurs disponible `n"
    Get-ADUser -Filter * | Format-Table Name, UserPrincipalName, DistinguishedName -A
}
function liste_UO() {
    Write-Output "`nListe des U0 disponible `n"
    Get-ADOrganizationalUnit -Filter * -Properties * | Format-Table CanonicalName
}
function display_domain() {
    # Obtenez la largeur de la console
    $largeurConsole = [console]::WindowWidth
    $text = "Domaine = "
    $positionX = $largeurConsole - ($text.Length + $domain.Length + $tld.Length + 2)
    [console]::SetCursorPosition($positionX, [console]::CursorTop)
    # Afficher
    Write-Host "$text $domain.$tld"
}
# Afficher le texte
function texte() {
    display_domain
    Write-Output "`t`t Que voulez-vous faire ?"
    display_row
    Write-Output "`t`t`t 1. Creation d utilisateur"
    display_row
    Write-Output "`t`t`t 2. Creation de Groupe"
    display_row
    Write-Output "`t`t`t 3. Creation de Unite Organisationnelle"
    display_row
    Write-Output "`t`t`t 4. Deplacer un utilisateur a une Unite Organisationnelle"
    display_row
    Write-Output "`t`t`t 5. Deplacer un utilisateur a un Groupe"
    display_row
    Write-Output "`t`t`t 6. Creer un utilisateur et le mettre dans un UO/groupe"
    display_row
    Write-Output "`t`t`t 7. Afficher la liste des Utilisateurs"
    display_row
    Write-Output "`t`t`t 8. Afficher la liste des Unite Organisationnelle"
    display_row
    Write-Output "`t`t`t 9. Supprimer un utilisateur"
    display_row
    Write-Output "`t`t`t 10. Quitter`n"
}
#Affichez l'ascii art au lancement du script
function ascii_art() {
    Write-Host "    
       _.-;;-._       _        _   _             ____  _               _                   
'-..-'|   ||   |     / \   ___| |_(_)_   _____  |  _ \(_)_ __ ___  ___| |_ ___  _ __ _   _ 
'-..-'|_.-;;-._|    / _ \ / __| __| \ \ / / _ \ | | | | | '__/ _ \/ __| __/ _ \| '__| | | |
'-..-'|   ||   |   / ___ \ (__| |_| |\ V /  __/ | |_| | | | |  __/ (__| || (_) | |  | |_| |
'-..-'|_.-''-._|  /_/   \_\___|\__|_| \_/ \___| |____/|_|_|  \___|\___|\__\___/|_|   \__, |
                                                                                     |___/ 
Bonjour et bienvenue sur le gestionnaire de l'Active Directory !
"
}
# ----------------------MAIN----------------------------------
Clear-Host
display_row2
ascii_art
display_row
# Déclaration du Domaine et du Chemin en variable globales
$domain = Read-Host "`t`t`t Nom de domaine " 
$tld = Read-Host   "`t`t`t Suffixe de domaine (TLD) "
Clear-Host
display_row2
ascii_art
texte
while ($true) {
    $value = Read-Host "Choisir un chiffre   (0 pour afficher les choix possibles) "
    Clear-Host
    switch ($value) {
        0 {
            texte
        }
        1 {
            display_row2
            Write-Host "Vous avez choisi    1 |   Creation d'utilisateur"
            display_row2
            Creation_User
        }
        2 {
            display_row2
            Write-Host "Vous avez choisi    2 |   Creation de Groupe"
            display_row2
            Creation_group
        }
        3 {
            display_row2
            Write-Host "Vous avez choisi    3 |   Creation de Unite Organisationnelle"
            display_row2
            Creation_UO
        }
        4 {
            display_row2
            Write-Host "Vous avez choisi    4 |   Ajouter un utilisateur à une Unité Organisationnelle"
            display_row2
            move_user_to_UO
        }
        5 {
            display_row2
            Write-Host "Vous avez choisi    5 |   Ajouter un utilisateur à un Groupe"
            display_row2
            add_user_group
        }
        6 {
            display_row2
            Write-Host "Vous avez choisi    6 |   Creer un utilisateur et le mettre dans un UO/groupe"
            display_row2
            Creation_User_UO
        }
        7 {
            display_row2
            Write-Host "Vous avez choisi    7 |   Liste Utilisateur"
            display_row2
            liste_user
        }
        8 {
            display_row2
            Write-Host "Vous avez choisi    8 |   Liste Unite Organisationnelle "
            display_row2
            liste_UO 
        }
        9 {
            display_row2
            Write-Host "Vous avez choisi    9 | Supprimer un utilisateur"
            delete_user
        }
        10 {
            Write-Host "Vous avez choisi    10|  fermeture du programme en cours "
            loading
            exit
        }
        Default {
            display_row
            Write-Host "    VEUILLEZ saisir un chiffre entre 1 et 9     "
            display_row
        }
    }
}