#!/usr/bin/env bash

word="liberté"
mkdir -p concordanciers

# Parcourir les fichiers texte et générer les concordanciers
for text_file in dumps-text/*.txt; do
    line_number=$(basename "$text_file" | sed -E 's/[^0-9]*([0-9]+).*/\1/')  # Extraire le numéro du fichier
    concordancier_file="concordanciers/concordancier_lang_fr-$line_number.html"

    {
        echo "<html>"
        echo "<head><title>Concordancier</title></head>"
        echo "<meta charset='UTF-8'>"
        echo "<body>"
        echo "<h1>Concordancier pour le mot '$word'</h1>"
        echo "<table border='1'>"
        echo "<tr><th>Contexte gauche</th><th>Mot</th><th>Contexte droit</th></tr>"

        grep -i -n "$word" "$text_file" | while IFS=: read -r line_num context; do
            left=$(sed -n "$((line_num - 1))p" "$text_file")
            right=$(sed -n "$((line_num + 1))p" "$text_file")
            echo "<tr><td>$left</td><td>$word</td><td>$right</td></tr>"
        done

        echo "</table>"
        echo "</body>"
        echo "</html>"
    } > "$concordancier_file"

    echo "Concordancier généré pour $text_file dans $concordancier_file"
done

