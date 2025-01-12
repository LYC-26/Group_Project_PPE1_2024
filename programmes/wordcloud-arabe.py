from wordcloud import WordCloud
import matplotlib.pyplot as plt
import os

# Lire le texte
with open('/home/habib/Bureau/PPE/Group_Project_PPE1_2024/pals/contextes-arabe.txt', 'r', encoding='utf-8') as f:
    contextes_text = f.read()

# Chemin de la police TrueType
font_path = "/usr/share/fonts/truetype/noto/NotoNaskhArabic-Regular.ttf"

# Créer le WordCloud
wordcloud_contextes = WordCloud(
    width=800,
    height=400,
    background_color='white',
    max_words=200,
    font_path=font_path  # Chemin mis à jour
).generate(contextes_text)

# Sauvegarder le fichier
output_folder = "/home/habib/Bureau/PPE/Group_Project_PPE1_2024/pals/wordcloud"
os.makedirs(output_folder, exist_ok=True)
output_path = os.path.join(output_folder, "arabe.png")
wordcloud_contextes.to_file(output_path)

# Afficher le WordCloud
plt.figure(figsize=(10, 5))
plt.imshow(wordcloud_contextes, interpolation='bilinear')
plt.axis("off")
plt.title("Nuage de mots - Contexte en Arabe")
plt.show()

print(f"Le nuage de mots a été sauvegardé dans : {output_path}")

