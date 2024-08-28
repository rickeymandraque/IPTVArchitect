#!/bin/bash

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
