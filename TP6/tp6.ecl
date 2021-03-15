:-lib(ic).
:-lib(ic_symbolic).
:-lib(branch_and_bound).


?- local domain(noms(ron, zoe, jim, lou, luc, dan, ted, tom, max, kim)).



/* Q 6.2 */

solve(Places):-
    getData(Poids, Personnes),
    dim(Poids, [Longueur]),
    getVar(Places, Longueur),

    pose_contrainte(Places, Poids, Personnes),
    norme(Places, Poids, Norme),
    labeling(Places),
    affiche(Places, Personnes, Norme).

solve_minimize_v1(Places):-
    getData(Poids, Personnes),
    dim(Poids, [Longueur]),
    getVar(Places, Longueur),

    pose_contrainte(Places, Poids, Personnes),
    norme(Places, Poids, Norme),

    /* Recherche par le plus contraint, dans l'ordre croissant */
    minimize(search(Places, 0, most_constrained, indomain_min, complete, []), Norme),
    affiche(Places, Personnes, Norme).



/* Q 6.1 */

getData(Poids, Personnes):-
    Personnes = [](ron, zoe, jim, lou, luc, dan, ted, tom, max, kim),
    Personnes &:: noms,
    Poids = [](24, 39, 85, 60, 165, 6, 32, 123, 7, 14).
    
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


equilibre(Places, Poids):-
    produitScalaire(Places, Poids, Somme),
    Somme #= 0.

contraindreLouEtTom(Places, Personnes):-
    ic:max(Places, Max), 
    ic:min(Places, Min), 
    indicePersonne(lou, Personnes, IndiceLou),
    indicePersonne(tom, Personnes, IndiceTom),
    Places[IndiceLou] #>= Max or Places[IndiceLou] #=< Min,
    Places[IndiceTom] #>= Max or Places[IndiceTom] #=< Min.


contraindreDanEtMax(Places, Personnes):-
    indicePersonne(dan, Personnes, Dan),
    indicePersonne(max, Personnes, Max),
    indicePersonne(lou, Personnes, Lou),
    indicePersonne(tom, Personnes, Tom),
    (Places[Lou] > 0) => ((Places[Dan] #= Places[Lou] - 1 and Places[Max] #= Places[Tom] + 1) or (Places[Max] #= Places[Lou] - 1 and Places[Dan] #= Places[Tom] + 1)),
    (Places[Lou] < 0) => ((Places[Dan] #= Places[Lou] + 1 and Places[Max] #= Places[Tom] - 1) or (Places[Max] #= Places[Lou] + 1 and Places[Dan] #= Places[Tom] - 1)).

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

/******* REPONSES *********/

/* 6.2 */
/*
  tom    dan    ron                  jim           ted  |  kim                  zoe    luc    max    lou
 -----  -----  -----  -----  -----  -----  -----  -----   -----  -----  -----  -----  -----  -----  -----  -----
  -8     -7     -6     -5     -4     -3     -2     -1   |   1      2      3      4      5      6      7      8

Norme : 2914

*/

/* 6.3 */
/*
Les personnes peuvent s'assoir sur le même siège mais de l'autre côté de la balancoire, entrainant ainsi la même solution mais à l'opposé.
On a alors une symetrie par rapport au milieu. Ainsi, on aura 2 fois moins de solutions, et on ne gardera que les solutions non triviales.
*/

/* 6.4 */
/*
  tom    max    ron    zoe                         ted  |         luc    kim                  jim    dan    lou
 -----  -----  -----  -----  -----  -----  -----  -----   -----  -----  -----  -----  -----  -----  -----  -----
  -8     -7     -6     -5     -4     -3     -2     -1   |   1      2      3      4      5      6      7      8

Norme : 2808
*/