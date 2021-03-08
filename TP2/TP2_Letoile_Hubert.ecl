:-lib(ic).
:-lib(ic_symbolic).

/* Question 2.1 */
/* Définition des domaines */

?- local domain(pays(angleterre, espagne, ukraine, norvege, japon)).
?- local domain(couleur(rouge, verte, blanche, bleue, jaune)).
?- local domain(boisson(cafe, the, lait, jus_orange, eau)).
?- local domain(voiture(bmw, toyota, ford, honda, datsun)).
?- local domain(animal(chien, serpent, renard, cheval, zebre)).
?- local domain(numero(1, 2, 3, 4, 5)).

/* Question 2.6 */
/* Prédicat de résolution du problème */

resoudre(Rue):-
    rue(Rue),
    contrainte(Rue),
    ecrit_maisons(Rue),
    getVarlist(Rue, Liste),
    labeling_symbolic(Liste).

    
/* Question 2.2 */
/* Application des domaines définis pécédemment aux maisons */

domaines_maison(maison(Pays, Couleur, Boisson, Voiture, Animal, Numero)):-
    Pays &:: pays,
    Couleur &:: couleur,
    Boisson &:: boisson,
    Voiture &:: voiture,
    Animal &:: animal,
    Numero &:: numero.
    

/* Question 2.3 */
/* Définition d'une rue, ou liste de maisons */

rue(R):-
    R = [maison(P1, C1, B1, V1, A1, 1), 
        maison(P2, C2, B2, V2, A2, 2),
        maison(P3, C3, B3, V3, A3, 3),
        maison(P4, C4, B4, V4, A4, 4),
        maison(P5, C5, B5, V5, A5, 5)],
    ( 
        foreach(M, R)
    do
        domaines_maison(M)
    ),
    ic_symbolic:alldifferent([P1, P2, P3, P4, P5]),
    ic_symbolic:alldifferent([C1, C2, C3, C4, C5]),
    ic_symbolic:alldifferent([B1, B2, B3, B4, B5]),
    ic_symbolic:alldifferent([V1, V2, V3, V4, V5]),
    ic_symbolic:alldifferent([A1, A2, A3, A4, A5]).

/*

R = [maison(_289{[angleterre, espagne, ukraine, norvege, japon]}, _389{[rouge, verte, blanche, bleue, jaune]}, _489{[cafe, the, lait, jus_orange, eau]}, _589{[bmw, toyota, ford, honda, datsun]}, _689{[chien, serpent, renard, cheval, zebre]}, 1), maison(_852{[angleterre, espagne, ukraine, norvege, japon]}, _952{[rouge, verte, blanche, bleue, jaune]}, _1052{[cafe, the, lait, jus_orange, eau]}, _1152{[bmw, toyota, ford, honda, datsun]}, _1252{[chien, serpent, renard, cheval, zebre]}, 2), maison(_1415{[angleterre, espagne, ukraine, norvege, japon]}, _1515{[rouge, verte, blanche, bleue, jaune]}, _1615{[cafe, the, lait, jus_orange, eau]}, _1715{[bmw, toyota, ford, honda, datsun]}, _1815{[chien, serpent, renard, cheval, zebre]}, 3), maison(_1978{[angleterre, espagne, ukraine, norvege, japon]}, _2078{[rouge, verte, blanche, bleue, jaune]}, _2178{[cafe, the, lait, jus_orange, eau]}, _2278{[bmw, toyota, ford, honda, datsun]}, _2378{[chien, serpent, renard, cheval, zebre]}, 4), maison(_2541{[angleterre, espagne, ukraine, norvege, japon]}, _2641{[rouge, verte, blanche, bleue, jaune]}, _2741{[cafe, the, lait, jus_orange, eau]}, _2841{[bmw, toyota, ford, honda, datsun]}, _2941{[chien, serpent, renard, cheval, zebre]}, 5)]

*/


/* Question 2.4 */
/* Affichage d'une rue dans la console */

% ecrit_maisons([]).
% ecrit_maisons([maison(Pays, Couleur, Boisson, Voiture, Animal, Numero) | Rue]):-
%     writeln(-----------------------------------------),
%     writeln(Numero),
%     writeln(Pays),
%     writeln(Couleur),
%     writeln(Boisson),
%     writeln(Voiture),
%     writeln(Animal),
%     ecrit_maisons(Rue).

ecrit_maisons(Rue):-
    (
        foreach(M, Rue)
    do
        writeln(M)
    ).

/* Question 2.5 */

labeling_symbolic([]).
labeling_symbolic([X | Liste]):-
    ic_symbolic:indomain(X),
    labeling_symbolic(Liste).
    
getVarlist(Rue, Liste):-
    term_variables(Rue, Liste).


/* Question 2.7 */
/* Application des contraintes de l'énoncé */

contrainte(R):-
    (
        foreach(M, R),
        param(R)
    do
        contrainte_simple(M),
        (
            foreach(M2, R),
            param(M)
        do
            contrainte_double(M, M2)
        )
    ).

/* Nous avons différencié deux types : 
    Les contraintes simples ne concernent qu une maison.
    Les contraintes doubles concernent deux maisons.
*/

contrainte_simple(maison(Pays, Couleur, Boisson, Voiture, Animal, Numero)):-
    (Pays &= angleterre) #= (Couleur &= rouge),
    (Pays &= espagne) #= (Animal &= chien),
    (Couleur &= verte) #= (Boisson &= cafe),
    (Pays &= ukraine) #= (Boisson &= the),
    (Voiture &= bmw) #= (Animal &= serpent),
    (Couleur &= jaune) #= (Voiture &= toyota),
    (Boisson &= lait) #= (Numero &= 3),
    (Pays &= norvege) #= (Numero &= 1),
    (Voiture &= honda) #= (Boisson &= jus_orange),
    (Pays &= japon) #= (Voiture &= datsun).

contrainte_double(maison(P1, C1, _, V1, _, N1), 
                  maison(_, C2, _, _, A2, N2)):-
    ((V1 &= ford) and (A2 &= renard)) => ((N1+1 #= N2) or (N1-1 #= N2)),
    (V1 &= toyota) and (A2 &= cheval) => ((N1+1 #= N2) or (N1-1 #= N2)),
    ((P1 &= norvege) and (C2 &= bleue)) => ((N1+1 #= N2) or (N1-1 #= N2)),
    ((C1 &= verte) and (C2 &= blanche)) => (N1-1 #= N2).

/* Question 2.8 */

/* Le Japonais possède un zèbre et le Norvégien boit de l'eau.  */

/* Question 2.1 */

/* 
Ne pas fixer les valeurs des numéros de maison n'aurait pas contraint l'ordre, et donc n'aurait pas permis de satisfaire les contraintes (e) et (h) par exemple.
On est obliger de les fixer pour répondre au problème.
*/