from wordcloud import WordCloud
import matplotlib.pyplot as plt
import os

# Lire contextes-français.txt
with open('/home/seif/Groupe PPE/pals/contextes-français.txt', 'r', encoding='utf-8') as f:
    contextes_text = f.read()

# Créer l'objet de wordcloud sans spécifier de police
wordcloud_contextes = WordCloud(
    width=800,
    height=400,
    background_color='white',
    max_words=200,
    stopwords=None  # Vous pouvez ajouter des mots vides spécifiques ici si nécessaire
).generate(contextes_text)

# Afficher le wordcloud
plt.figure(figsize=(10, 5))
plt.imshow(wordcloud_contextes, interpolation='bilinear')
plt.axis("off")
plt.title("Nuage de mots - Contexte en Français")

# Vérifier l'existence du dossier de sortie
output_folder = "../wordcloud"
os.makedirs(output_folder, exist_ok=True)

# Sauvegarder le wordcloud dans un fichier
output_path = os.path.join(output_folder, "français.png")
wordcloud_contextes.to_file(output_path)

# Afficher un message de réussite
print(f"Le nuage de mots a été sauvegardé dans : {output_path}")

# Afficher le nuage de mots
plt.show()

