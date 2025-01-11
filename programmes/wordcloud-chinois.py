from wordcloud import WordCloud
import matplotlib.pyplot as plt
import os

# Lire contextes-chinois.txt
with open('../pals/contextes-chinois.txt', 'r', encoding='utf-8') as f:
    contextes_text = f.read()

# Chemin de font chinois
font_path = "/Library/Fonts/Arial Unicode.ttf"

# Créer l'objet de wordcloud
wordcloud_contextes = WordCloud(
    width=800,
    height=400,
    background_color='white',
    font_path=font_path
).generate(contextes_text)

# Afficher wordcloud
plt.figure(figsize=(10, 5))
plt.imshow(wordcloud_contextes, interpolation='bilinear')
plt.axis("off")
plt.title("Wordcloud - Contexte")

# Vérifier l'existence du dossier de sortie
output_folder = "../wordcloud"
os.makedirs(output_folder, exist_ok=True)

# Sauvegarder wordcloud en tant que fichier
output_path = os.path.join(output_folder, "chinois.png")
wordcloud_contextes.to_file(output_path)

# Affichier un message de réussite
print(f"Wordcloud a été sauvegardé dans : {output_path}")

# Montrer wordcloud
plt.show()
