#!/usr/bin/env bash

# Vérifier si un fichier d'URLs est passé en argument
if [[ -z "$1" ]]; then
    echo "Veuillez fournir un fichier contenant des URLs en tant qu'argument." >&2
    exit 1
fi

# Nom du fichier d'URLs
input_file="$1"
echo "Le fichier d'URLs traité : $input_file"

# Définir les dossiers de sortie
output_html_dir="aspirations"
output_text_dir="dumps-text"

# Créer les dossiers si nécessaire
mkdir -p "$output_html_dir" "$output_text_dir"

# Initialiser un compteur
line_number=1

# Créer un fichier HTML pour le tableau
output_table="tableau_francais.html"
{
    echo "<html>"
    echo "<head><title>Tableau des Données</title></head>"
    echo "<meta charset='UTF-8'>"
    echo "<body>"
    echo "<h1>Tableau des Données en Français</h1>"
    echo "<table border='1'>"
    echo "<tr><th>Numéro</th><th>URL</th><th>Code HTTP</th><th>Encodage</th><th>Nombre de mots</th><th>HTML</th><th>Texte</th></tr>"
} > "$output_table"

# Lire chaque ligne du fichier contenant les URLs
while read -r line; do
    # Échapper les caractères HTML de l'URL
    escaped_url=$(echo "$line" | sed -e 's/&/&amp;/g' -e 's/</&lt;/g' -e 's/>/&gt;/g')
    
    # Obtenir le code HTTP
    http_code=$(curl -o /dev/null -s -w "%{http_code}" "$line")

    # Vérifier si l'URL est accessible
    if [[ "$http_code" -ne 200 ]]; then
        echo "URL inaccessible ($http_code) : $line" >&2
        continue
    fi

    # Télécharger le contenu HTML
    html_file="$output_html_dir/lang_fr-$line_number.html"
    curl -sL "$line" -o "$html_file"

    # Télécharger le contenu texte
    text_file="$output_text_dir/lang_fr-$line_number.txt"
    w3m -dump "$line" > "$text_file"

    # Compter les mots
    word_count=$(wc -w < "$text_file")

    # Détecter l'encodage
    encoding=$(file -bi "$html_file" | sed -n 's/.*charset=\(.*\)/\1/p')

    # Ajouter une ligne au tableau HTML
    echo "<tr><td>$line_number</td><td><a href=\"$escaped_url\">$escaped_url</a></td><td>$http_code</td><td>$encoding</td><td>$word_count</td><td><a href=\"$html_file\">HTML</a></td><td><a href=\"$text_file\">Texte</a></td></tr>" >> "$output_table"

    # Incrémenter le compteur
    ((line_number++))
done < "$input_file"

# Fermer le fichier HTML du tableau
{
    echo "</table>"
    echo "</body>"
    echo "</html>"
} >> "$output_table"

echo "Tableau généré : $output_table"

