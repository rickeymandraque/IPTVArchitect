#!/bin/bash

# Script pour récupérer les chaine de kool.to
# Pré-release instable. (WIP)
# À NE PAS UTILISER EN PRODUCTION
# Rickey Mandraque 08/2024
# plugin pour IPTVArchitect

# Lancez le script "./koolto.sh > fichier_de_sorti.m3u"

# Constantes pour les URLs des API
url_base="https://www.kool.to"
# non-utilisé pour le moment :
# mirror1="https://www.vavoo.to/channels"
# mirror2="http://oha.to/channels"
# mirror3="http://huhu.to/channels"
# permet la recherche du nom et des logos des chaines
# recherche basé sur le nom d'origine.
iptv_org_url="https://iptv-org.github.io/api"
iptv_org_channels_url="$iptv_org_url/channels.json"
iptv_org_countries_url="$iptv_org_url/countries.json"

# URL pour les chaînes
json="$url_base/channels"

# Fonction pour nettoyer le nom de la chaîne
clean_channel_name() {
    local name="$1"
    # Supprimer les suffixes spécifiés
    local name_clean_suffix
    name_clean_suffix=$(echo "$name" | sed -E 's/( \.c| \.s| \.b| FHD| HD| \(BACKUP\)| \|D| \|H| \|E| \([0-9]\))//gi')

    # Supprimer les préfixes spécifiés (décommenter pour activer)
    # local name_clean_prefix=$(echo "$name_clean_suffix" | sed -E 's/^prefixe1 //i')
    # local name_clean_prefix=$(echo "$name_clean_prefix" | sed -E 's/^prefixe2 //i')

    echo "$name_clean_suffix"
}

# Fonction pour rechercher le nom, l'id et le logo correspondants à un nom et un pays dans l'API d'iptv-org
find_channel_info_by_name_and_country() {
    local tvg_name="$1"
    local country="$2"
    local country_iso
    country_iso=$(get_country_iso_from_api "$country")
    local tvg_name_clean
    tvg_name_clean=$(clean_channel_name "$tvg_name")
    local channel_info

    # Recherche en utilisant le nom nettoyé et le pays spécifié
    channel_info=$(curl -sL "$iptv_org_channels_url" --compressed | jq ".[] | select(.name | test(\"(?i)$tvg_name_clean\")) | select(.country | test(\"(?i)$country_iso\")) | select(.name | test(\"(?i)(pluto|rakuten)\") | not) | {name: .name, id: .id, logo: .logo}")

    local num_results
    num_results=$(echo "$channel_info" | jq 'length' | wc -l)
    # Vérifier si aucun résultat n'a été trouvé
    if [ -z "$channel_info" ] || [ "$num_results" -ne 1 ]; then
        # Si aucun résultat n'est trouvé avec le nom nettoyé et le pays spécifié, rechercher en supprimant les espaces du nom
        local tvg_name_no_spaces
        tvg_name_no_spaces=$(echo "$tvg_name_clean" | tr -d ' ')
        channel_info=$(curl -sL "$iptv_org_channels_url" | jq ".[] | select(.id | test(\"(?i)$tvg_name_no_spaces.$country_iso\")) | select(.name | test(\"(?i)(pluto|rakuten)\") | not) | {name: .name, id: .id, logo: .logo}")
        local num_results
        num_results=$(echo "$channel_info" | jq 'length' | wc -l)

        # Si aucun résultat n'est trouvé avec le nom nettoyé sans espaces et le pays spécifié, rechercher uniquement par le nom sans espaces
        if [ -z "$channel_info" ] || [ "$num_results" -ne 1 ]; then
            channel_info=$(curl -sL "$iptv_org_channels_url" | jq ".[] | select(.id | test(\"(?i)$tvg_name_no_spaces\")) | select(.name | test(\"(?i)(pluto|rakuten)\") | not) | {name: .name, id: .id, logo: .logo, country: .country}")
                else
        # Si des informations sont trouvées, retourner les résultats
        echo "$channel_info"
        return
        fi
    else
        # Si des informations sont trouvées, retourner les résultats
        echo "$channel_info"
        return
    fi

    echo "$channel_info"
}


# Fonction pour récupérer l'abréviation ISO du pays à partir de l'API iptv-org
get_country_iso_from_api() {
    local country_name="$1"
    local country_iso
    country_iso=$(curl -sL "$iptv_org_countries_url" --compressed | jq -r ".[] | select(.name | test(\"(?i)$country_name\")) | .code")
    echo "$country_iso"
}

# Fonction pour imprimer les informations de la chaîne
print_channel_info() {
    local id
    id=$(echo "$channel" | jq -r '.id')
    local name
    name="$(echo "$channel" | jq -r '.name')"
    local country
    country="$(echo "$channel" | jq -r '.country')"
    local logo=""
    local channel_info="$1"
    local num_results
    num_results=$(echo "$channel_info" | jq 'length' | wc -l)

    if [[ "$num_results" -eq 1 ]]; then
        tvg_id=$(echo "$channel_info" | jq -r '.id')
        tvg_name=$(echo "$channel_info" | jq -r '.name')
        tvg_logo=$(echo "$channel_info" | jq -r '.logo')
    else
        # Si aucun résultat ou plusieurs résultats sont trouvés, utiliser les informations de Kool.to
        tvg_name=$(clean_channel_name "$name")
        tvg_logo="$logo"
        tvg_id=""
    fi

    echo -e "#EXTINF:-1 tvg-id=\"$tvg_id\" tvg-name=\"$tvg_name\" tvg-logo=\"$tvg_logo\" group-title=\"Kool$country\",$tvg_name"
    echo -e "$url_base/play/$id/index.m3u8"
}

# initialisation de la playlist
# à commenter si on build une playlist complete avec d'autre sources venant d'un autre script.
echo -e "#EXTM3U"

# Liste des mots-clés à filtrer (en minuscules)
# Liste de mots d'exemple pour blacklister certaine chaines.
# cette fonctionnalité sera améliorée plus tard pour prendre en charge un fichier de conf générale.
# veuillez noter dans cette exemple que les mot avec accent ont été simplfiés, "l'équipe 21" est souvent orthographié "l'equipe 21" ou "lequipe",
# pour ressoudre ça sans en mettre trop, j'ai mis le nom partiel qui ne soit un probleme.
keywords=("bein" "sport" "foot" "amazon" "moto" "quipe" "leagu" "fashion" "top 14" "disney" "golf" "match" "nickel" "bfm" "news" "dieu")

while IFS= read -r channel; do
    if [[ $(echo "$channel" | jq -r '.country') == "France" ]]; then
        name=$(echo "$channel" | jq -r '.name' | tr '[:upper:]' '[:lower:]')
        country=$(echo "$channel" | jq -r '.country')
        skip_channel=false

        # Vérifier si le nom de la chaîne contient l'un des mots-clés
        for keyword in "${keywords[@]}"; do
            if [[ $name == *"$keyword"* ]]; then
                skip_channel=true
                break
            fi
        done

        # Si la chaîne ne contient pas de mots-clés, l'imprimer
        if [ "$skip_channel" = false ]; then
            # Rechercher le nom, l'id et le logo correspondants dans l'API iptv-org
            channel_info=$(find_channel_info_by_name_and_country "$name" "$country")
            print_channel_info "$channel_info"
        fi
    fi
done < <(curl -s "$json" --compressed | jq -c 'sort_by(.country, .name) | .[]')

