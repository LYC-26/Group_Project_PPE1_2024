#!/bin/bash

# Paramètre 1: Dossier dumps-text
DUMPS_DIR=$1
# Paramètre 2: Nom de base (actuellement non utilisé)
BASE_NAME=$2
# Paramètre 3: Dossier contextes
CONTEXTES_DIR=$3

# Chemin des fichiers de sortie
DUMPS_OUTPUT_FILE="pals/dump-francais.txt"
CONTEXTES_OUTPUT_FILE="pals/contextes-francais.txt"

# Créer le dossier pals si nécessaire
mkdir -p pals

# Obtenir la liste des fichiers de dumps-text triés par ordre numérique
DUMPS_FILES=$(ls "$DUMPS_DIR" | sort -t'-' -k2,2n)

# Traiter les fichiers du dossier dumps-text
for file in $DUMPS_FILES; do
    # Obtenir le chemin complet du fichier
    full_file_path="$DUMPS_DIR/$file"

    # Ne traiter que les fichiers ordinaires, ignorer les sous-répertoires
    if [[ -f "$full_file_path" ]]; then
        echo "Traitement du fichier dumps-text : $full_file_path"

        # Traitement de segmentation des mots et sauvegarde des résultats
        python3 - <<EOF >> "$DUMPS_OUTPUT_FILE"
import jieba

# Lire le contenu du fichier
with open("$full_file_path", "r", encoding="utf-8") as f:
    content = f.read()

# Segmentation en mots (librairie `jieba`)
words = jieba.cut(content)
print("\\n".join(words))
EOF

        echo "Résultats du fichier dumps-text ajoutés à : $DUMPS_OUTPUT_FILE"
        echo "----------------------"
    fi
done

# Obtenir la liste des fichiers de contextes triés par ordre numérique
CONTEXTES_FILES=$(ls "$CONTEXTES_DIR" | sort -t'-' -k2,2n)

# Traiter les fichiers du dossier contextes
for context_file in $CONTEXTES_FILES; do
    # Obtenir le chemin complet du fichier de contexte
    full_context_file_path="$CONTEXTES_DIR/$context_file"

    # Ne traiter que les fichiers ordinaires, ignorer les sous-répertoires
    if [[ -f "$full_context_file_path" ]]; then
        echo "Traitement du fichier contextes : $full_context_file_path"

        # Traitement de segmentation des mots et sauvegarde des résultats
        python3 - <<EOF >> "$CONTEXTES_OUTPUT_FILE"
import jieba

# Lire le contenu du fichier
with open("$full_context_file_path", "r", encoding="utf-8") as f:
    content = f.read()

# Segmentation en mots (librairie `jieba`)
words = jieba.cut(content)
print("\\n".join(words))
EOF

        echo "Résultats du fichier contextes ajoutés à : $CONTEXTES_OUTPUT_FILE"
        echo "----------------------"
    fi
done

# Supprimer toutes les lignes vides dans contextes-francais.txt
sed -i '/^$/d' "$CONTEXTES_OUTPUT_FILE"

echo "Tous les fichiers ont été traités !"
echo "Les résultats de dumps-text sont enregistrés dans : $DUMPS_OUTPUT_FILE"
echo "Les résultats de contextes sont enregistrés dans : $CONTEXTES_OUTPUT_FILE"

