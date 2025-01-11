import os
from collections import Counter

def analyze_cooccurrences(input_file, keyword, window_size=5):
    """
    Analyser les co-occurrences des mots dans le contexte d'un mot-clé.
    Args:
        input_file (str): Chemin vers le fichier d'entrée
        keyword (str): Le mot-clé cible
        window_size (int): Taille de la fenêtre de co-occurrence
    Returns:
        dict: Statistiques de fréquence des mots co-occurrents
    """
    cooccurrence_count = Counter()
    total_count = 0

    with open(input_file, 'r', encoding='utf-8') as infile:
        for line in infile:
            tokens = line.strip().split()
            total_count += len(tokens)
            for i, word in enumerate(tokens):
                if word == keyword:
                    # Comptabiliser les mots co-occurrents dans la fenêtre
                    start = max(0, i - window_size)
                    end = min(len(tokens), i + window_size + 1)
                    for j in range(start, end):
                        if i != j:
                            cooccurrence_count[tokens[j]] += 1
    return cooccurrence_count, total_count


def save_comparison(local_stats, global_stats, local_keyword_count, global_keyword_count, output_file):
    """
    Comparer les co-occurrences locales et globales et calculer le Lafon.
    Args:
        local_stats (dict): Statistiques de co-occurrence locales
        global_stats (dict): Statistiques de co-occurrence globales
        local_keyword_count (int): Nombre total d'apparitions du mot-clé "自由" dans la fenêtre locale
        global_keyword_count (int): Nombre total d'apparitions du mot-clé "自由" dans le corpus global
        output_file (str): Chemin vers le fichier de sortie
    """
    with open(output_file, 'w', encoding='utf-8') as outfile:
        outfile.write("Mot\tCompteLocal\tCompteGlobal\tDifférence\tLafon\n") 
        all_words = set(local_stats.keys()).union(global_stats.keys())
        # Calculer les Lafons et les stocker dans un dictionnaire
        word_lafons = {}
        for word in all_words:
            local_count = local_stats.get(word, 0)
            global_count = global_stats.get(word, 0)
            difference = local_count - global_count
            # Calculer le Lafon
            if local_keyword_count != 0 and global_keyword_count != 0 and global_count != 0:
                lafon = (local_count / local_keyword_count) * (global_keyword_count / global_count)
            else:
                lafon = 0  # Pour éviter la division par zéro
            word_lafons[word] = (local_count, global_count, difference, lafon)

        # Trier les mots par la valeur de Lafon en ordre décroissant
        sorted_words = sorted(
            word_lafons.items(),
            key=lambda item: item[1][3],  # Trier selon la valeur du Lafon
            reverse=True
        )
        
        # Écrire les résultats triés dans le fichier
        for word, (local_count, global_count, difference, lafon) in sorted_words:
            outfile.write(f"{word}\t{local_count}\t{global_count}\t{difference}\t{lafon:.4f}\n")


def main():
    # Chemins des fichiers
    base_dir = os.path.dirname(os.path.abspath(__file__))
    pals_dir = os.path.join(base_dir, "../pals")
    contextes_file = os.path.join(pals_dir, "contextes-chinois.txt")
    dump_file = os.path.join(pals_dir, "dump-chinois.txt")
    output_file = os.path.join(pals_dir, "comparaison_resultats-chinois.txt")

    # Paramètres d'analyse
    keyword = "自由"
    window_size = 5

    # Analyse locale : analyser le contexte du mot-clé
    print("Analyse du contexte local...")
    local_stats, local_total = analyze_cooccurrences(contextes_file, keyword, window_size)
    local_keyword_count = local_stats.get(keyword, 0)  # Nombre d'apparitions du mot-clé "自由" dans la fenêtre locale
    print(f"Analyse locale terminée : {len(local_stats)} co-occurrences trouvées.")

    # Analyse globale : analyser les co-occurrences du mot-clé dans le corpus global
    print("Analyse du contexte global...")
    global_stats, global_total = analyze_cooccurrences(dump_file, keyword, window_size)
    global_keyword_count = global_stats.get(keyword, 0)  # Nombre d'apparitions du mot-clé "自由" dans le corpus global
    print(f"Analyse globale terminée : {len(global_stats)} co-occurrences trouvées.")

    # Comparer les co-occurrences locales et globales et calculer les Lafon
    print("Comparaison des co-occurrences locales et globales...")
    save_comparison(local_stats, global_stats, local_keyword_count, global_keyword_count, output_file)
    print(f"Résultats de la comparaison sauvegardés dans : {output_file}")


if __name__ == "__main__":
    main()
