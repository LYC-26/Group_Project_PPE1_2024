#!/usr/bin/env bash

# Vérifier si un chemin de fichier a été fourni en argument
if [[ -z "$1" ]]; then
    echo "Veuillez fournir un chemin de fichier en tant qu'argument." >&2
    exit 1
fi

# Debug: afficher le chemin du fichier fourni
echo "Le fichier à lire : $1"

# Définir le chemin du fichier de sortie HTML
output_file="../tableaux/chinois.html"

# Créer le fichier HTML et ajouter l'en-tête
{
    echo "<html>"
    echo "<head><title></title></head>"
    echo "<meta charset='UTF-8'>"  # Définir l'encodage en UTF-8
    echo "<body>"
    echo "<table>"
    echo "<tr><th>Numéro de ligne</th><th>Code HTTP</th><th>Encodage</th><th>Nombre de mots</th><th>URL</th><th>Lien vers la page HTML</th><th>Lien vers le dump textuel</th><th>Compte</th><th>Contexte</th></tr>"
} > "$output_file"

# Initialiser un compteur pour le numéro de ligne et le nom des fichiers
line_number=1

# Fonction pour échapper les caractères spéciaux HTML
escape_html() {
    echo "$1" | sed -e 's/&/&amp;/g' -e 's/"/&quot;/g' -e 's/</&lt;/g' -e 's/>/&gt;/g'
}

# Définir le mot d'étude
study_word="自由"

# Lire chaque ligne du fichier
while read -r line; do
    # Échapper les caractères spéciaux de l'URL pour le HTML
    escaped_url=$(escape_html "$line")
    
    # Obtenir le code HTTP de la requête
    http_code=$(curl -o /dev/null -s -w "%{http_code}" "$line")
    
    # Si le code HTTP n'est pas 200, ignorer cette URL
    if [[ "$http_code" -ne 200 ]]; then
        echo "Erreur : L'URL $line renvoie un code HTTP $http_code. Elle ne sera pas traitée." >&2
        echo "<tr><td>$line_number</td><td>$http_code</td><td>Absence de résultat</td><td>Absence de résultat</td><td><a href=\"$escaped_url\" target=\"_blank\">$escaped_url</a></td><td>Absence de résultat</td><td>Absence de résultat</td><td>Absence de résultat</td></tr>" >> "$output_file"
    else
         # Nettoyer le nom de fichier pour éviter les caractères spéciaux
        html_filename="../aspirations/chinois-$line_number.html"
        text_filename="../dumps-text/chinois-$line_number.txt"
        context_filename="../contextes/chinois-$line_number.txt"
        
        # Télécharger la page HTML et l'enregistrer
        curl -sL "$line" -o "$html_filename"

        # Vérifier si le fichier a été créé
        if [[ ! -s "$html_filename" ]]; then
            echo "Erreur : Le fichier $html_filename n'a pas été généré correctement pour $line." >&2
            echo "<tr><td>$line_number</td><td>$http_code</td><td>Erreur</td><td>Erreur</td><td><a href=\"$escaped_url\" target=\"_blank\">$escaped_url</a></td><td>Erreur</td><td>Erreur</td><td>Erreur</td></tr>" >> "$output_file"
            continue
        fi
        
        # Obtenir le type de contenu et l'encodage si disponible
        content_type=$(curl -sI "$line" | grep -i "Content-Type")
        if [[ "$content_type" =~ charset=([a-zA-Z0-9-]+) ]]; then
            encoding="${BASH_REMATCH[1]}"
        else
            encoding=$(curl -sL "$line" | pcregrep -o '<meta\s+charset="[^"]+"' | sed 's/.*charset="\([^"]*\)".*/\1/')
        fi

        # Obtenir le contenu de la page et compter le nombre de mots
        nombre_de_mot=$(curl -sL "$line" | wc -w)

        # Télécharger le contenu textuel avec Lynx en utilisant l'option assume_charset=UTF-8
        w3m -dump -O UTF-8 "$line" > "$text_filename"

        # Extraire les contextes contenant le mot d'étude
        grep -B 1 -A 1 "$study_word" "$text_filename" > "$context_filename"

        # Compter le nombre d'occurrences du mot d'étude dans le dump
        count=$(grep -o "$study_word" "$text_filename" | wc -l)

        # Ajouter une ligne dans le tableau HTML avec les données
        echo "<tr><td>$line_number</td><td>$http_code</td><td>$encoding</td><td>$nombre_de_mot</td><td><a href=\"$escaped_url\" target=\"_blank\">$escaped_url</a></td><td><a href=\"$html_filename\" target=\"_blank\">Page HTML</a></td><td><a href=\"$text_filename\" target=\"_blank\">Dump Textuel</a></td><td>$count</td><td><a href=\"$context_filename\" target=\"_blank\">Contexte</a></td></tr>" >> "$output_file"

        # Créer un fichier HTML pour le concordancier
        output_concordance="../concordances/chinois-$line_number.html"
        {
            echo "<html>"
            echo "<head><title>Concordancier - Mot '自由'</title></head>"
            echo "<meta charset='UTF-8'>"
            echo "<body>"
            echo "<h1>Concordances pour le mot '自由'</h1>"
            echo "<table border='1'>"
            echo "<tr><th>Contexte Gauche</th><th>Mot d'étude</th><th>Contexte Droit</th></tr>"
        } > "$output_concordance"

        # Traiter le contexte et générer le tableau
        sed -n 's/\(.*自由.*\)/\1/p' "$context_filename" | while read -r line; do
            left_context=$(echo "$line" | sed -E 's/(.*)自由.*/\1/')
            right_context=$(echo "$line" | sed -E 's/.*自由(.*)/\1/')
            
            # Échapper les caractères spéciaux dans le HTML
            left_context=$(echo "$left_context" | sed 's/&/&amp;/g; s/"/&quot;/g; s/</&lt;/g; s/>/&gt;/g')
            right_context=$(echo "$right_context" | sed 's/&/&amp;/g; s/"/&quot;/g; s/</&lt;/g; s/>/&gt;/g')

            # Ajouter les données dans le tableau HTML
            echo "<tr><td>$left_context</td><td><strong>自由</strong></td><td>$right_context</td></tr>" >> "$output_concordance"
        done

        # Fermer les balises HTML
        echo "</table></body></html>" >> "$output_concordance"
    fi

    # Incrémenter le compteur de lignes
    ((line_number++))
done < "$1"

# Clôturer le fichier HTML
echo "</table></body></html>" >> "$output_file"
