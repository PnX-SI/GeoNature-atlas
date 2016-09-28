======================
MISE A JOUR DU CONTENU
======================
.. image:: http://pnecrins.github.io/GeoNature/img/logo-pne.jpg
    :target: http://www.ecrins-parcnational.fr

-----

Par défaut, la BDD a été conçue pour s'appuyer sur les données présentes dans GeoNature (https://github.com/PnEcrins/GeoNature). 

Pour cela une BDD fille de GeoNature est créée avec les schémas utiles à l'atlas (``synthese``, ``taxonomie``, ``layers``, ``utilisateurs``), alimentée grace à un Foreign Data Wrapper (http://docs.postgresqlfr.org/9.2/sql-createforeigndatawrapper.html).

Cela permet de créer un lien dynamique entre les 2 bases de données. A chaque fois qu'une requête est éxecutée dans une table de l'atlas (BDD fille), le FWD permet d'interroger directement dans le BDD mère (celle de GeoNature) et ainsi d'avoir les données à jour en temps réel. 

Néanmoins pour plus de généricité et permettre à une structure d'utiliser GeoNature-atlas sans disposer de GeoNature, l'application ne requête jamais directement dans ces schémas liés à GeoNature. 

En effet elle requête uniquement sur des vues créées dans le schéma spécifique ``atlas``.

Ainsi ces vues peuvent être adaptées à volonté pour interroger d'autre sources de données que GeoNature, à partir du moment où elles retournent les mêmes champs. 

Dans un soucis de performance et pour ne pas requêter en permanence sur la base mère GeoNature, nous avons mis en place des vues matérialisées (http://docs.postgresqlfr.org/9.3/rules-materializedviews.html) pour que les données soient précalculées, indéxées et présentes directement dans le schéma ``atlas``. 

**Liste des vues** :

- atlas.vm_taxref qui renvoie toutes les données de taxonomie.taxref.
    Champs à préciser pour ceux qui n'ont pas taxonomie.taxref

- atlas.vm_observations qui renvoie la liste de toutes les observations.
    Champs à renommer et supprimer dans la vue par défaut.

- atlas.vm_taxons qui renvoie la liste des taxons observés au moins une fois sur le territoire (présents dans vm_observations).

- atlas.vm_altitudes qui renvoie le nombre d'observations pour chaque classe d'altitude et chaque taxon.
    Cette vue peut être personnalisée pour adapter les classes d'altitude (Voir ci-dessous : "Personnalisation de l'application").
    
- atlas.vm_mois qui renvoie le nombre d'observations pour chaque mois et chaque taxon.

- atlas.vm_phenologies qui renvoie le nombre d'observations pour chaque mois et chaque taxon.


- atlas.vm_observations_mailles qui renvoie la liste de toute les observations aggrégées par maille
    Pour créer la table vm_observations_mailles, remplacer le fichier ``data/ref/emprise_territoire.sample.shp`` par le fichier SHP de l'emprise de votre territore
    Il est possible de choisir la table des mailles (1, 5 ou 10 km) en modifiant la variable ``taillemaille`` du fichier ``config/settings.ini``

Insérer un schema des BDD.







#################################
 
**Personnaliser les classes d'altitude**

* Pour modifier la vue ``vm_altitudes`` et l'adapter aux altitudes de votre territoire, vous devez modifier le contenu de la table ``atlas.bib_altitudes``.
    
* Le champ ``id_altitude`` ne doit pas comporter de doublons et l'altitude la plus basse doit avoir l'``id_altitude`` = 1.
    
* L'amplitude des tranches altitudinales peut être personnalisée, ainsi que le nombre de tranches.
    
* Le champ ``label_altitude`` ne doit pas commencer par un chiffre. La méthode la plus générique consiste à générer automatiquement le contenu de ce champ grace à la commande SQL suivante :
 
  ::  
  
        UPDATE atlas.bib_altitudes set label_altitude = '_' || altitude_min || '_' || altitude_max+1;
        
Dès que votre table ``atlas.bib_altitudes`` est complétée, vous pouvez mettre à jour la vue ``atlas.vm_altitudes`` grace à la commande SQL suivante :
 
::

    select atlas.create_vm_altitudes();

#################################

Vous pouvez alimenter l'atlas avec une autre source de données que GeoNature à condition de respecter le nom et le typage des champs retournés par la vue.

Ou vous pouvez simplement décider de l'adapter à votre GeoNature par exemple en changeant l'``id_organisme`` dont vous souhaitez afficher les données dans la condition WHERE de la vue ``atlas.vm_observations``.

Modifiez les images dans le répertoire ``/custom/images/``.






Dans un soucis de performance, les données contenues dans les vues matérialisées n'intègrent pas en temps réel les mises à jour faites dans GeoNature. Pour cela ces vues doivent être actualisées grace à la fonction ``REFRESH MATERIALIZED VIEW`` de PostgreSQL.
Une fonction, générée lors de la création de la BDD de GeoNature-atlas permet de mettre à jour toutes les vues matérialisées du schéma ``atlas``.

* Pour lancer manuellement cette fonction, ouvrez une console SQL et exécutez la requête suivante :
    
  ::  
  
        SELECT RefreshAllMaterializedViews('atlas');

* Pour automatiser l'éxecution de cette fonction (chaque nuit à 4 heures dans cet exemple), ajoutez la dans le crontab de l'utilisateur ``root`` :
    
  ::  
  
        sudo crontab -e


Ajouter la ligne suivante en prenant soin de mettre à jour les paramètres de connexion à la base de GeoNature-atlas :
    
::

    0 4 * * * export PGPASSWORD='monpassachanger';psql -h localhost -U geonatatlas -d geonatureatlas -c "SELECT RefreshAllMaterializedViews('atlas');"

Pour enregistrer et sortir : ``Ctrl + O`` puis ``Ctrl + X``
