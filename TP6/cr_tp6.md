---
author: Julien LETOILE, Romain HUBERT
title: CR TP6 Programmation par contraintes
---







<center style="font-size: xx-large;"><b>CR TP6 Programmation par contraintes</b></center> 

------









<center style="font-size: x-large;">Sur une balançoire</center>















<center>Julien LETOILE, Romain HUBERT</center>

<center>le 17/03/2021</center>

# Table des matières

[TOC]







## I. <u>Réponses rédigées</u>

### Question 6.1

```javascript
/* Pose les contraintes sur les données */
getData(Poids, Personnes):-
    Personnes = [](ron, zoe, jim, lou, luc, dan, ted, tom, max, kim),
    Personnes &:: noms,
    Poids = [](24, 39, 85, 60, 165, 6, 32, 123, 7, 14).

/* Pose les contraintes sur les variables */
getVar(Places, Longueur):-
    dim(Places, [Longueur]),
    Places #:: [-8 .. -1, 1 .. 8].


pose_contrainte(Places, Poids, Personnes):-
    equilibre(Places, Poids),
    contraindreLouEtTom(Places, Personnes),
    contraindreDanEtMax(Places, Personnes),
    cinqDeChaqueCote(Places),
    enleveSymetrie(Places, Personnes),
    ic:alldifferent(Places).

/* Garantit que la balançire est en équilibre */
equilibre(Places, Poids):-
    produitScalaire(Places, Poids, Somme),
    Somme #= 0.

/* Place Lou et Tom aux extrémités */
contraindreLouEtTom(Places, Personnes):-
    ic:max(Places, Max), 
    ic:min(Places, Min), 
    indicePersonne(lou, Personnes, IndiceLou),
    indicePersonne(tom, Personnes, IndiceTom),
    Places[IndiceLou] #>= Max or Places[IndiceLou] #=< Min,
    Places[IndiceTom] #>= Max or Places[IndiceTom] #=< Min.

/* Place Dan et Max devant Lou et Tom */
contraindreDanEtMax(Places, Personnes):-
    indicePersonne(dan, Personnes, Dan),
    indicePersonne(max, Personnes, Max),
    indicePersonne(lou, Personnes, Lou),
    indicePersonne(tom, Personnes, Tom),
    (Places[Lou] > 0) => ((Places[Dan] #= Places[Lou] - 1 and Places[Max] #= Places[Tom] + 1) or (Places[Max] #= Places[Lou] - 1 and Places[Dan] #= Places[Tom] + 1)),
    (Places[Lou] < 0) => ((Places[Dan] #= Places[Lou] + 1 and Places[Max] #= Places[Tom] - 1) or (Places[Max] #= Places[Lou] + 1 and Places[Dan] #= Places[Tom] - 1)).

/* Garantit que 5 persones seront de part de d'autre de la balançoire */
cinqDeChaqueCote(Places):-
    (
        foreachelem(Place, Places),
        fromto(0, AncienCompteGauche, NouveauCompteGauche, 5)
    do
        NouveauCompteGauche #= AncienCompteGauche + (Place #< 0)
    ).

/* Recherche l'indice d'une personne */
indicePersonne(Personne, Personnes, Indice):-
    dim(Personnes, [Longueur]),
    (
        for(I, 1, Longueur),
        param(Personne, Personnes, Indice)
    do
        X is Personnes[I],
        /* Toujours mettre un else dans un if (cond -> true; false) */
        (Personne &= X -> Indice #= I; true)
    ).


getVarList(Places, List):-
    term_variables(Places, List).
```

### Question 6.2

```javascript
/* Prédicat de résolution du problème */
solve:-
    getData(Poids, Personnes),
    dim(Poids, [Longueur]),
    getVar(Places, Longueur),
    pose_contrainte(Places, Poids, Personnes),
    norme(Places, Poids, Norme),
    labeling(Places),
    affiche(Places, Personnes, Norme).
```

Test: 

>  tom     dan    ron                       jim            ted  |  kim                     zoe    luc   max    lou
> .   -8      -7      -6      -5      -4      -3      -2      -1    |    1       2       3       4       5       6       7       8
>
> Norme : 2914

### Question 6.3

Les personnes peuvent s'assoir sur le même siège mais de l'autre côté de la balancoire, entrainant ainsi la même solution mais à l'opposé.
On a alors une symetrie par rapport au milieu. Ainsi, on aura 2 fois moins de solutions, et on ne gardera que les solutions non triviales.

```javascript
/* Pour enlever la symetrie, il suffit de choisir un côté pour soit Lou, soit Tom vu qu'on sait qu'ils sont de part et d'autres de la balancoire */
enleveSymetrie(Places, Personnes):-
    indicePersonne(lou, Personnes, IndiceLou),
    Places[IndiceLou] #> 0. /* Choisit de mettre la place de Lou à droite */
```

### Question 6.4

#### Version de base

```javascript
/* Prédicat de résolution avec Branch and Bound */
solve_minimize_v0:-
    getData(Poids, Personnes),
    dim(Poids, [Longueur]),
    getVar(Places, Longueur),

    pose_contrainte(Places, Poids, Personnes),
    norme(Places, Poids, Norme),

    /* Recherche par le plus contraint, dans l'ordre croissant */
    minimize(labeling(Places), Norme),
    affiche(Places, Personnes, Norme).
```

Test:

> ​                       tom   dan    ted    kim    zoe  |  luc    jim    ron           max    lou
>   -8      -7      -6      -5      -4      -3      -2      -1    |    1       2       3       4       5       6       7       8
>
> Norme : 802
>
>
> P = \[\](3, -1, 2, 6, 1, -4, -3, -5, 5, -2)
> Yes (2.13s cpu)

#### Version 1

```javascript
/* On essaie d'échouer le plus tôt possible pour éviter de développer des branches inutiles */
solve_minimize_v1:-
    getData(Poids, Personnes),
    dim(Poids, [Longueur]),
    getVar(Places, Longueur),

    pose_contrainte(Places, Poids, Personnes),
    norme(Places, Poids, Norme),

    /* Recherche par le plus contraint, dans l'ordre croissant */
    minimize(search(Places, 0, most_constrained, indomain_min, complete, []), Norme),
    affiche(Places, Personnes, Norme).
```

Test:

> ​                       tom   dan    ted    kim    zoe  |  luc    jim    ron           max    lou
>   -8      -7      -6      -5      -4      -3      -2      -1    |    1       2       3       4       5       6       7       8
>
> Norme : 802
>
>
> P = \[\](3, -1, 2, 6, 1, -4, -3, -5, 5, -2)
> Yes (0.23s cpu)

#### Version 2

```javascript
/* Les variables sont triées pour correspondre au problème */
solve_minimize_v2:-
    getData(Poids, Personnes),
    dim(Poids, [Longueur]),
    getVar(Places, Longueur),

    pose_contrainte(Places, Poids, Personnes),
    norme(Places, Poids, Norme),

    minimize(search(Places, 0, input_order, indomain_middle, complete, []), Norme),
    affiche(Places, Personnes, Norme).
```

Test: 

> Found a solution with cost 1277
> Found a solution with cost 1176
> Found a solution with cost 1138
> Found a solution with cost 1053
> Found a solution with cost 972
> Found a solution with cost 933
> Found a solution with cost 875
> Found a solution with cost 852
> Found a solution with cost 802
> Found no solution with cost 30.0 .. 801.0
> ron : 3
> zoe : -1
> jim : 2
> lou : 6
> luc : 1
> dan : -4
> ted : -3
> tom : -5
> max : 5
> kim : -2
>
> ​                        tom   dan    ted    kim    zoe  |  luc    jim    ron           max    lou
>   -8      -7      -6      -5      -4      -3      -2      -1     |     1      2       3       4       5       6       7       8
> 
> Norme : 802
> 
>
> Yes (1.35s cpu)

#### Version 3

```javascript
/* Combinaison des versions 1 et 2 */
solve_minimize_v3:-
    getData(Poids, Personnes),
    dim(Poids, [Longueur]),
    getVar(Places, Longueur),

    pose_contrainte(Places, Poids, Personnes),
    norme(Places, Poids, Norme),
    
    minimize(search(Places, 0, most_constrained, indomain_middle, complete, []), Norme),
    affiche(Places, Personnes, Norme).
```

Test:

> Found a solution with cost 945
> Found a solution with cost 802
> Found no solution with cost 30.0 .. 801.0
> ron : 3
> zoe : -1
> jim : 2
> lou : 6
> luc : 1
> dan : -4
> ted : -3
> tom : -5
> max : 5
> kim : -2
>
>​                          tom   dan   ted    kim   zoe  |  luc    jim    ron           max    lou
> -8      -7      -6      -5      -4      -3      -2      -1    |    1       2       3       4       5       6       7       8
>   
> Norme : 802
> 
>
>Yes (0.14s cpu)

#### Version 4

```javascript
/* Les variables sont triées selon une heuristique indéfinie our le moment */
solve_minimize_v4:-
    getData(Poids, Personnes),
    dim(Poids, [Longueur]),
    getVar(Places, Longueur),

    pose_contrainte(Places, Poids, Personnes),
    norme(Places, Poids, Norme),

    /* Recherche par le plus contraint, dans l'ordre croissant */
    getVarListOpti(Places, Liste),
    
    minimize(search(Liste, 0, most_constrained, indomain_middle, complete, []), Norme),
    affiche(Places, Personnes, Norme).

/* Tri des données par ordre décroissant des poids */
getVarListOpti(Places, Liste):-
    PlaceRon is Places[1],
    PlaceZoe is Places[2],
    PlaceJim is Places[3],
    PlaceLou is Places[4],
    PlaceLuc is Places[5],
    PlaceDan is Places[6],
    PlaceTed is Places[7],
    PlaceTom is Places[8],
    PlaceMax is Places[9],
    PlaceKim is Places[10],
    Liste = [PlaceLuc, PlaceTom, PlaceJim, PlaceLou, PlaceZoe, PlaceTed, PlaceRon, PlaceKim, PlaceMax, PlaceDan].
```

Test:

> Found a solution with cost 945
> Found a solution with cost 848
> Found a solution with cost 802
> Found no solution with cost 30.0 .. 801.0
> ron : 3
> zoe : -1
> jim : 2
> lou : 6
> luc : 1
> dan : -4
> ted : -3
> tom : -5
> max : 5
> kim : -2
>
> .                       tom   dan    ted    kim    zoe  |  luc    jim    ron           max    lou
>   -8      -7      -6      -5      -4      -3      -2      -1    |    1       2       3       4       5       6       7       8
>
> Norme : 802
>
>
> Yes (0.14s cpu)

### Question de compréhension

Le labeling original prend les variables dans l'ordre de la liste en prenant les valeurs croissantes. En faisant cette technique, on risque de commencer par des variables avec un grand domaine, et donc aggrandi le temps de trouver une solution. Il n'est donc pas efficace puisque, dans notre cas, on commence avec une variable à grand domaine en partant de faibles valeurs. Ainsi, le temps de trouver une solution est plus important qu'avec notre propre labeling.

### Choix des stratégies

<u>Version 2 :</u> Nous avons choisi de chercher les solutions vers le centre des domaines parce qu'il est fort probable qu'une des solutions se trouve vers le milieu.

<u>Version 4 :</u> Nous avons placé les personnes plus lourdes en avant pour augmenter leur priorité. En effet, une personne plus lourde affecte plus le moment qu'une personne légère donc il a moins de choix pour se placer sur la balançoire. On réduit ainsi le domaine pour obtenir plus rapidement une solution.

### Prédicats utilitaires

```javascript
/* Calcule la norme d'un vecteur */
norme(Places, Poids, Norme):-
    absVecteur(Places, AbsVecteur),
    produitScalaire(AbsVecteur, Poids, Scalaire),
    Norme #= Scalaire / 2.

/* Calcule le produit cartésien de deux vecteurs */
produitVecteur(Vect1, Vect2, Res):-
    dim(Vect1, [Longueur]),
    dim(Vect2, [Longueur]),
    dim(Res, [Longueur]),
    (
        for(I, 1, Longueur),
        param(Vect1, Vect2, Res)
    do
        Res[I] #= Vect1[I] * Vect2[I]
    ).
    
/* Calcule le produit scalaire de deux vecteurs */
produitScalaire(Vect1, Vect2, Res):-
    produitVecteur(Vect1, Vect2, Vect3),
    sommeVecteur(Vect3, Res).

sommeVecteur(Vect, Res):-
    (
        foreachelem(X, Vect),
        fromto(0, AncienneValeur, NouvelleValeur, Res)
    do
        NouvelleValeur #= AncienneValeur + X
    ).

/* Calcule la valeur absolue de chaque élément du vecteur Vect */
absVecteur(Vect, Res):-
    dim(Vect, [Longueur]),
    dim(Res, [Longueur]),
    (
        for(I, 1, Longueur),
        param(Vect, Res)
    do
        X is Vect[I],
        Res[I] #= abs(X)
    ).

/* Trouve l'indice d'un élément dans un vecteur */
indiceDe(Element, Vecteur, Indice):-
    dim(Vecteur, [Longueur]),
    (
        for(I, 1, Longueur),
        fromto(0, AncienneValeur, NouvelleValeur, Indice),
        param(Element, Vecteur)
    do
        X is Vecteur[I],
        NouvelleValeur #= (Element #= X) * I + AncienneValeur * (Element #\= X)
    ).

/* Affichage des resultats */
affiche(Places, Personnes, Norme):-
    dim(Places, [Longueur]),

    /* Affiche persone : place */
    (
        for(I, 1, Longueur),
        param(Places, Personnes)
    do
        Place is Places[I],
        Personne is Personnes[I],
        write(Personne),
        write(" : "),
        writeln(Place)
    ),
    writeln(""),
    writeln(""),

    /* Affiche les noms des personnes au bon endroit sur la balancoire */
    (
        for(I, -8, 8),
        param(Places, Personnes)
    do
        indiceDe(I, Places, Indice),
        (I #= 0 ->
            write("|")
        ;
            (Indice #> 0 -> 
                Personne is Personnes[Indice],
                write("  "),
                write(Personne),
                write("  ")
            ;
                write("       ")
            )
        )
    ),
    writeln(""),

    /* Affiche la barre de la balancoire */
    (
        for(I, -8, 8)
    do
        (I #= 0 ->
            write(" ")
        ;
            write(" ----- ")
        )
    ),
    writeln(""),

    /* Affiche la place de la balancoire en dessous */
    (
        for(I, -8, 8)
    do
        (I #> 0 -> write("   "), write(I), write("   "); true),
        (I #< 0 -> write("  "), write(I), write("   "); true),
        (I #= 0 -> write("|"); true)
    ),
    writeln(""),
    writeln(""),
    write("Norme : "),
    writeln(Norme),
    writeln("").
```

## II. <u>Code source</u>

On le posera quand il sera fini.

```javascript
:-lib(ic).
:-lib(ic_symbolic).
:-lib(branch_and_bound).


?- local domain(noms(ron, zoe, jim, lou, luc, dan, ted, tom, max, kim)).


/* minimize(+Goal, ?Cost, +Options) : A solution of the goal Goal is found that minimizes the value of Cost using branch and bound */
/* search(+L, ++Arg, ++Select, +Choice, ++Method, +Option) : */

/* Q 6.2 */
/* Prédicat de résolution du problème */
solve:-
    getData(Poids, Personnes),
    dim(Poids, [Longueur]),
    getVar(Places, Longueur),
    pose_contrainte(Places, Poids, Personnes),
    norme(Places, Poids, Norme),
    labeling(Places),
    affiche(Places, Personnes, Norme).

/* Prédicats de résolution avec Branch and Bound */
solve_minimize_v0:-
    getData(Poids, Personnes),
    dim(Poids, [Longueur]),
    getVar(Places, Longueur),

    pose_contrainte(Places, Poids, Personnes),
    norme(Places, Poids, Norme),

    /* Recherche par le plus contraint, dans l'ordre croissant */
    minimize(labeling(Places), Norme),
    affiche(Places, Personnes, Norme).

solve_minimize_v1:-
    getData(Poids, Personnes),
    dim(Poids, [Longueur]),
    getVar(Places, Longueur),

    pose_contrainte(Places, Poids, Personnes),
    norme(Places, Poids, Norme),

    /* Recherche par le plus contraint, dans l'ordre croissant */
    minimize(search(Places, 0, most_constrained, indomain_min, complete, []), Norme),
    affiche(Places, Personnes, Norme).

solve_minimize_v2:-
    getData(Poids, Personnes),
    dim(Poids, [Longueur]),
    getVar(Places, Longueur),

    pose_contrainte(Places, Poids, Personnes),
    norme(Places, Poids, Norme),

    minimize(search(Places, 0, input_order, indomain_middle, complete, []), Norme),
    affiche(Places, Personnes, Norme).

solve_minimize_v3:-
    getData(Poids, Personnes),
    dim(Poids, [Longueur]),
    getVar(Places, Longueur),

    pose_contrainte(Places, Poids, Personnes),
    norme(Places, Poids, Norme),
    
    minimize(search(Places, 0, most_constrained, indomain_middle, complete, []), Norme),
    affiche(Places, Personnes, Norme).

solve_minimize_v4:-
    getData(Poids, Personnes),
    dim(Poids, [Longueur]),
    getVar(Places, Longueur),

    pose_contrainte(Places, Poids, Personnes),
    norme(Places, Poids, Norme),

    /* Recherche par le plus contraint, dans l'ordre croissant */
    getVarListOpti(Places, Liste),
    
    minimize(search(Liste, 0, most_constrained, indomain_middle, complete, []), Norme),
    affiche(Places, Personnes, Norme).


/* Q 6.1 */
/* Pose les contraintes sur les données */
getData(Poids, Personnes):-
    Personnes = [](ron, zoe, jim, lou, luc, dan, ted, tom, max, kim),
    Personnes &:: noms,
    Poids = [](24, 39, 85, 60, 165, 6, 32, 123, 7, 14).

/* Pose les contraintes sur les variables */
getVar(Places, Longueur):-
    dim(Places, [Longueur]),
    Places #:: [-8 .. -1, 1 .. 8].


pose_contrainte(Places, Poids, Personnes):-
    equilibre(Places, Poids),
    contraindreLouEtTom(Places, Personnes),
    contraindreDanEtMax(Places, Personnes),
    cinqDeChaqueCote(Places),
    enleveSymetrie(Places, Personnes),
    ic:alldifferent(Places).

/* Garantit que la balançire est en équilibre */
equilibre(Places, Poids):-
    produitScalaire(Places, Poids, Somme),
    Somme #= 0.

/* Place Lou et Tom aux extrémités */
contraindreLouEtTom(Places, Personnes):-
    ic:max(Places, Max), 
    ic:min(Places, Min), 
    indicePersonne(lou, Personnes, IndiceLou),
    indicePersonne(tom, Personnes, IndiceTom),
    Places[IndiceLou] #>= Max or Places[IndiceLou] #=< Min,
    Places[IndiceTom] #>= Max or Places[IndiceTom] #=< Min.

/* Place Dan et Max devant Lou et Tom */
contraindreDanEtMax(Places, Personnes):-
    indicePersonne(dan, Personnes, Dan),
    indicePersonne(max, Personnes, Max),
    indicePersonne(lou, Personnes, Lou),
    indicePersonne(tom, Personnes, Tom),
    (Places[Lou] > 0) => ((Places[Dan] #= Places[Lou] - 1 and Places[Max] #= Places[Tom] + 1) or (Places[Max] #= Places[Lou] - 1 and Places[Dan] #= Places[Tom] + 1)),
    (Places[Lou] < 0) => ((Places[Dan] #= Places[Lou] + 1 and Places[Max] #= Places[Tom] - 1) or (Places[Max] #= Places[Lou] + 1 and Places[Dan] #= Places[Tom] - 1)).

/* Garantit que 5 persones seront de part de d'autre de la balançoire */
cinqDeChaqueCote(Places):-
    (
        foreachelem(Place, Places),
        fromto(0, AncienCompteGauche, NouveauCompteGauche, 5)
    do
        NouveauCompteGauche #= AncienCompteGauche + (Place #< 0)
    ).

/* Pour enlever la symetrie, il suffit de choisir un côté pour soit Lou, soit Tom vu qu'on sait qu'ils sont de part et d'autres de la balancoire */
enleveSymetrie(Places, Personnes):-
    indicePersonne(lou, Personnes, IndiceLou),
    Places[IndiceLou] #> 0. /* Choisi de mettre la place de Lou à droite */

/* Calcule la norme d'un vecteur */
norme(Places, Poids, Norme):-
    absVecteur(Places, AbsVecteur),
    produitScalaire(AbsVecteur, Poids, Scalaire),
    Norme #= Scalaire / 2.


/* Toujours mettre un else dans un if (cond -> true; false) */
/* Recherche l'indice d'une personne */
indicePersonne(Personne, Personnes, Indice):-
    dim(Personnes, [Longueur]),
    (
        for(I, 1, Longueur),
        param(Personne, Personnes, Indice)
    do
        X is Personnes[I],
        (Personne &= X -> Indice #= I; true)
    ).


getVarList(Places, List):-
    term_variables(Places, List).


/* Tri des données par ordre décroissant des poids */
getVarListOpti(Places, Liste):-
    PlaceRon is Places[1],
    PlaceZoe is Places[2],
    PlaceJim is Places[3],
    PlaceLou is Places[4],
    PlaceLuc is Places[5],
    PlaceDan is Places[6],
    PlaceTed is Places[7],
    PlaceTom is Places[8],
    PlaceMax is Places[9],
    PlaceKim is Places[10],
    Liste = [PlaceLuc, PlaceTom, PlaceJim, PlaceLou, PlaceZoe, PlaceTed, PlaceRon, PlaceKim, PlaceMax, PlaceDan].

/* Affichage des resultats */
affiche(Places, Personnes, Norme):-
    dim(Places, [Longueur]),

    /* Affiche persone : place */
    (
        for(I, 1, Longueur),
        param(Places, Personnes)
    do
        Place is Places[I],
        Personne is Personnes[I],
        write(Personne),
        write(" : "),
        writeln(Place)
    ),
    writeln(""),
    writeln(""),

    /* Affiche les noms des personnes au bon endroit sur la balancoire */
    (
        for(I, -8, 8),
        param(Places, Personnes)
    do
        indiceDe(I, Places, Indice),
        (I #= 0 ->
            write("|")
        ;
            (Indice #> 0 -> 
                Personne is Personnes[Indice],
                write("  "),
                write(Personne),
                write("  ")
            ;
                write("       ")
            )
        )
    ),
    writeln(""),

    /* Affiche la barre de la balancoire */
    (
        for(I, -8, 8)
    do
        (I #= 0 ->
            write(" ")
        ;
            write(" ----- ")
        )
    ),
    writeln(""),

    /* Affiche la place de la balancoire en dessous */
    (
        for(I, -8, 8)
    do
        (I #> 0 -> write("   "), write(I), write("   "); true),
        (I #< 0 -> write("  "), write(I), write("   "); true),
        (I #= 0 -> write("|"); true)
    ),
    writeln(""),
    writeln(""),
    write("Norme : "),
    writeln(Norme),
    writeln("").


/* Q 6.3 */


/****************** FONCTIONS UTILITAIRES ******************/

/* Calcule le produit cartésien de deux vecteurs */
produitVecteur(Vect1, Vect2, Res):-
    dim(Vect1, [Longueur]),
    dim(Vect2, [Longueur]),
    dim(Res, [Longueur]),
    (
        for(I, 1, Longueur),
        param(Vect1, Vect2, Res)
    do
        Res[I] #= Vect1[I] * Vect2[I]
    ).
    
/* Calcule le produit scalaire de deux vecteurs */
produitScalaire(Vect1, Vect2, Res):-
    produitVecteur(Vect1, Vect2, Vect3),
    sommeVecteur(Vect3, Res).

sommeVecteur(Vect, Res):-
    (
        foreachelem(X, Vect),
        fromto(0, AncienneValeur, NouvelleValeur, Res)
    do
        NouvelleValeur #= AncienneValeur + X
    ).

/* Calcule la valeur absolue de chaque élément du vecteur Vect */
absVecteur(Vect, Res):-
    dim(Vect, [Longueur]),
    dim(Res, [Longueur]),
    (
        for(I, 1, Longueur),
        param(Vect, Res)
    do
        X is Vect[I],
        Res[I] #= abs(X)
    ).

/* Trouve l'indice d'un élément dans un vecteur */
indiceDe(Element, Vecteur, Indice):-
    dim(Vecteur, [Longueur]),
    (
        for(I, 1, Longueur),
        fromto(0, AncienneValeur, NouvelleValeur, Indice),
        param(Element, Vecteur)
    do
        X is Vecteur[I],
        NouvelleValeur #= (Element #= X) * I + AncienneValeur * (Element #\= X)
    ).
```