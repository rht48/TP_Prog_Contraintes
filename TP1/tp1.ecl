:-lib(ic).


/* Q1.1 */
couleurVoiture(rouge).
couleurVoiture(vert(clair)).
couleurVoiture(gris).
couleurVoiture(blanc).

couleurBateau(vert).
couleurBateau(noir).
couleurBateau(blanc).

choixCouleur(X, X):-
    couleurVoiture(X),
    couleurBateau(X).

test_choixCouleur:-
    choixCouleur(blanc, blanc),
    not choixCouleur(rouge, gris),
    not choixCouleur(fkzgn, faief).

/* Q1.3 */
isBetween(X, _, X).
isBetween(Var, Min, Max):-
    Max =\= Min,
    Max1 is Max - 1,
    isBetween(Var, Min, Max1).

test_isBetween:-
    isBetween(15, 10, 20),
    not isBetween(5, 10, 20),
    not isBetween(25, 10, 20).

/* Q1.4 */
commande(NbResistance, NbCondensateur):-
    NbResistance >= NbCondensateur,
    isBetween(NbResistance, 5000, 10000),
    isBetween(NbCondensateur, 9000, 20000).
    

test_commande:-
    commande(9000, 9000),
    commande(10000, 9500),
    not commande(4000, 9000),
    not commande(5000, 9000).

/* Q1.5 */

/* Q1.6 */

/*
    Instanciation fault X >= Y
    Il sait calculer des nombres mais ne comprend pas forcément les signes mathématiques ?
    On génère les variables avant et puis après on les tests avec les conditions à la fin
*/

/* Q1.7 */

isBetween2(Var, Min, Max):-
    Var #:: Min..Max,
    Max #>= Min.

/* X = X{10 .. 20} */

/* Q1.8 */

commande2(NbRes, NbCondo) :-
    isBetween2(NbRes, 5000, 10000),
    isBetween2(NbCondo, 9000, 20000),
    NbRes #>= NbCondo,
    labeling([NbRes, NbCondo]).

/* solveProblem():- */
    

/* Q1.9 */
chapie1(Chats, Pies, Pattes, Tetes):- 
    [Chats, Pies, Pattes, Tetes] :: 0..20,
    Pattes #= 2 * Pies + 4 * Chats,
    Tetes #= Pies + Chats.

/*
    Pies = 3
    Pattes = 14
*/
    
/* Q1.10 */
chapie2(Chats, Pies, Pattes, Tetes):- 
    [Chats, Pies, Pattes, Tetes] :: 0..20,
    Pattes #= 2 * Pies + 4 * Chats,
    Tetes #= Pies + Chats,
    Pattes #= 3 * Tetes,
    labeling([Chats, Pies, Pattes, Tetes]).

/*
    Chats = 0
    Pies = 0
    Pattes = 0
    Tetes = 0
    Yes (0.00s cpu, solution 1, maybe more) ? ;

    Chats = 1
    Pies = 1
    Pattes = 6
    Tetes = 2
    Yes (0.00s cpu, solution 2, maybe more) ? ;

    Chats = 2
    Pies = 2
    Pattes = 12
    Tetes = 4
    Yes (0.00s cpu, solution 3, maybe more) ? ;

    Chats = 3
    Pies = 3
    Pattes = 18
    Tetes = 6
    Yes (0.00s cpu, solution 4, maybe more) ? ;
*/


/* Q1.11 */

/*
vabs(Val, AbsVal):- 
    Val < 0,
    !,
    AbsVal is -Val.
vabs(Val, Val).
*/

vabs(0, 0).
vabs(Val, AbsVal):-
    AbsVal #> 0,
    (AbsVal #= Val; AbsVal #= -Val),
    labeling([AbsVal, Val]).

vabsOr(0, 0).
vabsOr(Val, AbsVal):- 
    AbsVal #> 0,
    (AbsVal #= Val or AbsVal #= -Val),
    labeling([Val, AbsVal]). /* l'ordre du labeling importe, il faut utiliser dans ce sens sinon ca bloque à la fin */
    

test_vabs:-
    vabs(1, 1),
    vabs(-1, 1).

/* Q1.12 */



/* Q1.13 */

/* faitListe([Max], _, Max, Max). */
 
faitListe([], 0, _, _).
faitListe([X | L], Taille, Min, Max):-
    Taille #> 0,
    X #:: Min..Max,
    Taille1 #= Taille - 1,
    faitListe(L, Taille1, Min, Max).

/*
faitListe(L, Taille, Min, Max):-
    length(L, Taille),
    L #:: Min..Max.
*/  
/* Q1.14 */

st_test(Xi, Xi1, Xi2):-
    vabs(Xi1, VXi1),
    Xi2 #= VXi1 - Xi.

suite([X, X1, X2]):-
    st_test(X, X1, X2).
suite([X, X1, X2 | ListVar]):-
    st_test(X, X1, X2),
    suite([X1, X2 | ListVar]).

/* faitListe(X, 3, 0, 2), suite(X). */

/* Q1.15 */

periodique9([X, _1, _2, _3, _4, _5, _6, _7, _8, X]).
periodique9([X, X1, X2, X3, X4, X5, X6, X7, X8, X | ListVar]):-
    periodique9([X1, X2, X3, X4, X5, X6, X7, X8, X | ListVar]).

non_periodique9([X, _1, _2, _3, _4, _5, _6, _7, _8, W| ListVar]):-
    X #\= W.

suite2([X0, X1], X0, X1, 2).
suite2([X0 | Liste], X0, X1, Taille):-
    st_test(X0, X1, X2),
    Taille1 is Taille - 1,
    suite2(Liste, X1, X2, Taille1).

test_periodique_suite:-
    faitListe(X, 15, 0, 0),
    suite(X),
    periodique9(X).

test_periodique:-
    periodique9([1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7, 8])