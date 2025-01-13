#!/usr/bin/env bash

word="liberté"
mkdir -p contextes

# Parcourir les fichiers texte et extraire les contextes
for text_file in dumps-text/*.txt; do
    line_number=$(basename "$text_file" | sed -E 's/[^0-9]*([0-9]+).*/\1/')  # Extraire le numéro du fichier
    context_file="contextes/lang_fr-$line_number.txt"

    grep -i -C 2 "$word" "$text_file" > "$context_file"
    echo "Contexte extrait pour $text_file dans $context_file"
done

