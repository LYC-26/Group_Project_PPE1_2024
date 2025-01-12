import re
from collections import Counter
import os

def clean_text(text):
    """
    Nettoie le texte en supprimant les espaces invisibles et les caractères spéciaux.
    """
    return text.replace("\u200e", "").replace("\u200f", "").strip()

def clean_and_tokenize(line):
    """
    Utilise une expression régulière pour diviser la ligne en mots arabes.
    """
    return re.findall(r'[\u0600-\u06FF]+', line)

def analyze_cooccurrences(input_file, keyword, window_size=10):
    """
    Analyse les co-occurrences d'un mot-clé dans un fichier avec une fenêtre de co-occurrence.
    """
    if not os.path.exists(input_file):
        print(f"Erreur : le fichier {input_file} n'existe pas.")
        return Counter(), 0

    cooccurrence_count = Counter()
    total_count = 0

    with open(input_file, 'r', encoding='utf-8') as infile:
        for line in infile:
            line = clean_text(line)  # Nettoyer chaque ligne
            tokens = clean_and_tokenize(line)  # Découper la ligne en mots

            total_count += len(tokens)

            for i, word in enumerate(tokens):
                if word == keyword:
                    # Trouver les co-occurrences dans la fenêtre définie
                    start = max(0, i - window_size)
                    end = min(len(tokens), i + window_size + 1)

                    for j in range(start, end):
                        if i != j:
                            cooccurrence_count[tokens[j]] += 1
    return cooccurrence_count, total_count

def compare_cooccurrences(local_cooccurrences, global_cooccurrences):
    """
    Compare les co-occurrences locales et globales et affiche les résultats.
    """
    comparison = []
    all_keys = set(local_cooccurrences.keys()).union(global_cooccurrences.keys())

    for word in all_keys:
        local_count = local_cooccurrences.get(word, 0)
        global_count = global_cooccurrences.get(word, 0)
        comparison.append((word, local_count, global_count))

    return comparison

def main():
    # Paramètres
    keyword = "\u0627\u0644\u062d\u0631\u064a\u0629"  # Le mot-clé à rechercher
    window_size = 10  # Taille de la fenêtre de co-occurrence
    context_file = 'contextes-arabe.txt'  # Fichier pour l'analyse locale
    dump_file = 'dump-arabe.txt'  # Fichier pour l'analyse globale

    # Analyse locale (co-occurrences dans le fichier contextes-arabe.txt)
    print("Analyse du contexte local...")
    local_cooccurrences, total_local_count = analyze_cooccurrences(context_file, keyword, window_size)
    print(f"Analyse locale terminée : {len(local_cooccurrences)} co-occurrences trouvées.")

    # Analyse globale (co-occurrences dans le fichier dump-arabe.txt)
    print("Analyse du contexte global...")
    global_cooccurrences, total_global_count = analyze_cooccurrences(dump_file, keyword, window_size)
    print(f"Analyse globale terminée : {len(global_cooccurrences)} co-occurrences trouvées.")

    # Comparaison des co-occurrences locales et globales
    print("Comparaison des co-occurrences locales et globales...")
    comparison_results = compare_cooccurrences(local_cooccurrences, global_cooccurrences)

    # Sauvegarde des résultats dans un fichier
    output_file = "comparaison_resultats-arabe.txt"
    with open(output_file, 'w', encoding='utf-8') as outfile:
        for word, local_count, global_count in comparison_results:
            outfile.write(f"{word} | Local: {local_count} | Global: {global_count}\n")

    print(f"Résultats de la comparaison sauvegardés dans : {output_file}")

if __name__ == "__main__":
    main()

