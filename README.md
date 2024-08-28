![Bannière](./assets/IPTVArchitect.webp)
# IPTVArchitect
Ensemble de scripts et d'outils pour la construction et la manipulations de playlist IPTV

# Pourquoi ce projet ?

J'étais un peu fatigué de devoir courir vers différentes sources pour récupérer des playlists problématiques soit parce que :
- il manquait des balises.
- les chaînes n'étaient pas les bonnes.
- les logos étaient manquants.
- les playlists étaient trop importantes et faisaient planter le lecteur.
- les playlists n'étaient pas compatibles avec les lecteurs utilisés.
- des liens morts
- des chaînes qui ne m'intéresse pas (sport par exemple)
- ...


## Logigiels necéssaires (présent et futur) :

- curl
- jq
- recode
- ffmpeg
- ffprobe
- wget
- ftp (lequel ?!)
- fpcalc
- imagemagik
- dig


# Qu'est-ce qui fonctionne actuellement ?

En date du 28/08/2024 voilà les fonctionnalités :
- ajouts du scraper pour Koolto.
- Ajout de fonctions de base.
- detection de l'OS.

# W.I.P.
Ce script est pensé pour les utilisations suivantes :
- configurable
- modulaire
- installation possible sur Github
- upload des playlists sur serveur FTP/dépot github
- mise à jour automatique.
- détection de doublons
- pseudo intelligence artificielle pour la détection des chaînes avec FFMPEG, FFPROBE, imagemagik et fpcalc. (extrement difficile à mettre en place)
- système de plugins et d'ajout de fonctions
- construction de l'EPG.
- vérification des comptes Xtream et de leurs utilisations.
- Notification par SMS pour les abonnés Free mobile.
- Système de Blacklist et de Whitelist des chaînes.
- Scraper d'open directories.
- module d'analyse des flux
- construction d'un fichier json comme base de données locale/distante générale.
- ...

# Prochaine étape :

- Ajout de scripts pour PlutoTV, RakutenTV et Samsung TV Plus.
- export des playlists compatible avec différents lecteur.
