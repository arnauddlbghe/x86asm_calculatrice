# L3 INFO - PDM TP02 "`Calculatrice`"


## Compiler le programme.
`Make calculatrice`


## Utilisation.
Les calculs s'écrivent sous forme de [notation polonaise inversée](https://fr.wikipedia.org/wiki/Notation_polonaise_inverse).  
C'est à dire:  
`10 20 30 + -` => `0`
`10 20 + 30 -` => `0`

## Fonctionnement.
1. Saisie du calcul dans l'entrée standard (la console).
2. Mémorisation du calcule donné (sous forme de chaine de caractère) dans un espace mémoire.
3. Lecture de chaque octet stocké dans l'espace mémoire.
4. Analyse de chaque octet lu, selon si c'est un chiffre, un espace, un opérateur ou une fin de chaîne.
5. Opération selon ce qui est lu.
6. Quand tout est analysé, on dépile le résultat construit lors des analyses et on le stocke dans un autre espace mémoire.
7. On écrit le contenu de cet espace mémoire dans l'entrée standard (la console).
