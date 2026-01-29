# FAQ

Pour plus d'informations sur la configuration et la personnalisation de l'atlas, consultez la documentation dédiée : 


### Comment est calculé le statut d'espèce menacée ?

- **Sur une fiche territoire** :  
Le statut de menace affiché est contextualisé en fonction du département sur lequel la fiche territoire se situe. On affiche le niveau de menace le plus local qui concerne cette espèce dans la zone : cela peut être un statut européen, national ou régional selon ce qui est le plus précis pour ce territoire.  
Une espèce est considérée comme menacée si elle possède un statut VU, EN, CR ou CR*.

- **Sur une fiche espèce** :  
Le statut de menace est global : si l’espèce est considérée comme menacée quelque part sur le territoire de l'atlas, elle sera affichée comme menacée sur sa fiche..  
Seuls les statuts "actifs" de la BDC statuts (table `taxonomie.bdc_statut_text`) sont pris en compte.


### Comment est calculé le statut d'espèce protégée ?

- **Sur une fiche territoire** :  
On indique si l’espèce bénéficie d’une protection réglementaire dans le département sur lequel la fiche territoire se situe.

- **Sur une fiche espèce** :  
Si l’espèce est protégée quelquepart sur le territoire de l'atlas, elle sera indiquée comme protégée sur sa fiche, même si ce n’est pas le cas partout.  
Là aussi, seuls les statuts "actifs" de la BDC statuts sont pris en compte.


### Changer l'affichage des labels des "zonage"

La notion de commune a été remplacé par la notion de "zonage". Ce terme s'affiche dans la barre de recherche présente dans la "navbar" et sur les fiche espèces.
Si vous souhaiitez surcoucher ce terme par "commune" ou tout autre terme, referez vous à la documentation sur la [customisation des textes via la surchouche du multilingues](configuration.rst)
Les "clés" à surcoucher sont : `search.area` , `areas` et `area`


    # atlas/static/custom/translations_override/fr/LC_MESSAGES/messages.po
    msgid "search.area"
    msgstr "Recherche par commune"

    msgid "areas"
    msgstr "Communes"

    msgid "area"
    msgstr "Commune"
