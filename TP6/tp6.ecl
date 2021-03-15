:-lib(ic).
:-lib(ic_symbolic).
:-lib(branch_and_bound).


?- local domain(noms(ron, zoe, jim, lou, luc, dan, ted, tom, max, kim)).



/* Q 6.2 */

solve(Places):-
    getData(Poids, Personnes),
    dim(Poids, [Longueur]),
    getVar(Places, Longueur),
    contraindreDanEtMax(Personnes, Places),
    getVarList(Places, Liste),
    labeling(Liste),
    pose_contrainte(Places, Poids, Personnes),
    affiche(Places, Personnes).

solveTest(Places):-
    getData(Poids, Personnes),
    dim(Poids, [Longueur]),
    getVar(Places, Longueur),

    contraindreLouEtTom(Places, Personnes),
    
    getVarList(Places, Liste),
    labeling(Liste),
    affiche(Places, Personnes).

/* Q 6.1 */

getData(Poids, Personnes):-
    Personnes = [](ron, zoe, jim, lou, luc, dan, ted, tom, max, kim),
    Personnes &:: noms,
    Poids = [](24, 39, 85, 60, 165, 6, 32, 123, 7, 14).
    
getVar(Places, Longueur):-
    dim(Places, [Longueur]),
    Places #:: [-8 .. -1, 1 .. 8].


pose_contrainte(Places, Poids):-
    equilibre(Places, Poids),
    ic:alldifferent(Places).


equilibre(Places, Poids):-
    produitScalaire(Places, Poids, Somme),
    Somme #= 0.

contraindreLouEtTom(Places, Personnes):-
    ic:max(Places, Max), 
    ic:min(Places, Min), 
    lookForPerson(lou, Personnes, IndiceLou),
    lookForPerson(tom, Personnes, IndiceTom),
    Places[IndiceLou] #> Max or Places[IndiceLou] #< Min,
    Places[IndiceTom] #> Max or Places[IndiceTom] #< Min.


contraindreDanEtMax(Personnes, Places):-
    lookForPerson(dan, Personnes, Dan),
    lookForPerson(max, Personnes, Max),
    lookForPerson(lou, Personnes, Lou),
    lookForPerson(tom, Personnes, Tom),
    (Places[Lou] > 0) => ((Places[Dan] #= Places[Lou] - 1 and Places[Max] #= Places[Tom] + 1) or (Places[Max] #= Places[Lou] - 1 and Places[Dan] #= Places[Tom] + 1)),
    (Places[Lou] < 0) => ((Places[Dan] #= Places[Lou] + 1 and Places[Max] #= Places[Tom] - 1) or (Places[Max] #= Places[Lou] + 1 and Places[Dan] #= Places[Tom] - 1)).



/* Toujours mettre un else dans un if (cond -> true; false) */
/* Recherche l'indice d'une personne */
lookForPerson(Personne, Personnes, Indice):-
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

affiche(Places, Personnes):-
    dim(Places, [Longueur]),
    (
        for(I, 1, Longueur),
        param(Places, Personnes)
    do
        Place is Places[I],
        Personne is Personnes[I],
        write(Personne),
        write(" : "),
        writeln(Place)
    ).


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
        abs(X, Abs),
        Res[I] #= Abs
    ).
