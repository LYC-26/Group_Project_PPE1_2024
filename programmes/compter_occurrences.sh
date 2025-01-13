#!/usr/bin/env bash

word="liberté"
tableau="tableau_francais.html"

# Parcourir les fichiers texte et compter les occurrences
for text_file in dumps-text/*.txt; do
    line_number=$(basename "$text_file" | sed -E 's/[^0-9]*([0-9]+).*/\1/')  # Extraire le numéro du fichier
    occurrences=$(grep -o -i "$word" "$text_file" | wc -l)

    # Ajouter cette information au tableau (ou l'afficher pour vérification)
    echo "Fichier $text_file : $occurrences occurrences du mot '$word'"
    # Vous pouvez aussi automatiser l'ajout dans le tableau principal ici si nécessaire
done

