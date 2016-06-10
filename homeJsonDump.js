import re
import json
 
from datetime import datetime
 
# On hérite simplement de l'encodeur de base pour faire son propre encodeur
class JSONEncoder(json.JSONEncoder):
 
    # Cette méthode est appelée pour serialiser les objets en JSON
    def default(self, obj):
        # Si l'objet est de type datetime, on retourne une chaîne formatée
        # représentant l'instant de manière classique
        # ex: "2014-03-09 19:51:32.7689"
        if isinstance(obj, datetime):
            return obj.strftime('%Y-%m-%d %H:%M:%S.%f')
        return json.JSONEncoder.default(self, obj)
 
 
# On fait l'opération exactement inverse pour le décodeur
class JSONDecoder(json.JSONDecoder):
 
 
    # On écrase la méthode qui permet de décoder les paires clé / valeur
    # du format JSON afin que chaque valeur passe par notre moulinette
    def object_pairs_hook(self, obj):
        return dict((k, self.decode_on_match(v)) for k, v in obj)
 
 
    # notre moulinette
    def decode_on_match(self, obj):
 
        # une petite regex permet de savoir si la chaine est une date
        # sérialisée selon notre format précédent
        match = re.search(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{6}', unicode(obj))
        # si oui, on parse et on retourne le datetime
        if match:
            return datetime.strptime(match.string, self.datetime_format)
 
        # sinon on retourne l'objet tel quel
        return obj
 
# On se fait des raccourcis pour loader et dumper le json
 
def json_dumps(data):
    return JSONEncoder().encode(data)
 
 
def json_loads(string):
    return JSONDecoder().decode(string)