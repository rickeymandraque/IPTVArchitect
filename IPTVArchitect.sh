#!/bin/bash

#fonction de detection de l'OS, sera externalisé plus tard
# Fonction pour détecter le système d'exploitation
function detect_os() {
    if [[ "$(uname -a)" == *"Android"* ]]; then
        # Vérification des caractéristiques spécifiques à Android TV
        # getprop ro.build.version.release < autre piste
        # if pm list packages | grep -q "com.google.android.tv"; then < +1
        # getprop ro.build.version.sdk < et encore !
        if [[ -f /system/build.prop && $(grep -i 'tv' /system/build.prop) ]]; then
            echo "OS détecté : Android TV"
            os="Android TV"
        else
            echo "OS détecté : Android"
            os="Android"
        fi
    elif [[ "$(uname -a)" == *"Linux"* ]]; then
        if [[ -f /etc/os-release ]]; then
            # Lire le nom de la distribution Linux à partir de /etc/os-release
            . /etc/os-release
            os=$NAME
        else
            os="Linux (distribution inconnue)"
        fi
        echo "OS détecté : $os"
    else
        os="Inconnu"
        echo "OS détecté : $os"
    fi
}

# Appeler la fonction de détection de l'OS
detect_os

# Vérification si le dossier ./Scripts existe
if [ ! -d "./Scripts" ]; then
  echo "Le dossier ./Scripts n'existe pas."
  exit 1
fi

# Liste des scripts dans le dossier ./Scripts
scripts=($(ls ./Scripts/*.sh 2>/dev/null))

# Vérification s'il y a des scripts dans le dossier
if [ ${#scripts[@]} -eq 0 ]; then
  echo "Aucun script trouvé dans le dossier ./Scripts."
  exit 1
fi

# Affichage de la liste des scripts sans l'extension .sh
echo "Veuillez choisir un script à exécuter :"
for i in "${!scripts[@]}"; do
  script_name=$(basename "${scripts[$i]}" .sh)
  echo "$((i+1))) $script_name"
done

# Lecture du choix de l'utilisateur
read -p "Entrez le numéro du script à exécuter : " choix

# Vérification du choix de l'utilisateur
if [[ ! $choix =~ ^[0-9]+$ ]] || [ "$choix" -lt 1 ] || [ "$choix" -gt "${#scripts[@]}" ]; then
  echo "Choix invalide."
  exit 1
fi

# Demande du nom de la playlist
read -p "Entrez le nom de la playlist (sans extension) : " nom_playlist

# Ajout de l'extension .m3u
nom_de_fichier="${nom_playlist}.m3u"

# Exécution du script choisi et redirection de la sortie vers le fichier .m3u
script_a_executer="${scripts[$((choix-1))]}"
echo "Exécution de $script_a_executer..."
bash "$script_a_executer" > "$nom_de_fichier"

echo "Playlist créée : $nom_de_fichier"
