#!/bin/bash
word="الحرية"
path="/home/habib/Bureau/PPE/Group_Project_PPE1_2024/Group_Project_PPE1_2024/concordances"
name="arab"
contexte="/home/habib/Bureau/PPE/Group_Project_PPE1_2024/Group_Project_PPE1_2024/contextes/ar_contexte/arabe"
nb=1

while [ $nb -lt 51 ];
do
    echo "<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
    table {width: 100%; border-collapse:collapse;}
    th, td {border: 1px solid #ddd; padding: 8px; text-alig:left;}
    th {background-color: #f2f2f2;}
    </style>
</head>
<body>
<h2>Concordance pour le mot: الحرية </h2>
<table>
<thead>
    <tr><th>Contexte gauche</th><th>Mot</th><th>Contexte gauche</th></tr>
</thead>
<tbody>" > $path/$name$nb.html
    grep -io -E '\w+\sالحرية\s\w+' $contexte-$nb.txt | sed -E "s/(.{0,30})($word)(.{0,30})/<tr><td>\1<\/td><td><strong>\2<\/strong><\/td><td>\3<\/td><\/tr>/I" >> $path/$name$nb.html # this (.{0,30}) will also capture whitespace
    echo "</tbody>
</table>
</body>
</html>" >> $path/$name$nb.html
    nb=$(expr $nb + 1)
done < $contexte-$nb.txt
