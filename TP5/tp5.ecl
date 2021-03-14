/*

faire produitVecteur
faire sommeVecteur
faire produitScalaire

(foreacharg ?) ou foreachelem
*/

:-lib(ic).
:-lib(ic_symbolic).
:-lib(branch_and_bound).

/* Question 5.5 */

solve(Fabriquer, NbTechniciensTotal, Profit):-
    poseContraintes(Fabriquer, NbTechniciensTotal, Profit),
    X #= - Profit,
    minimize(labeling(Fabriquer), X).

/*
[eclipse 7]: solve(Fabriquer, NbTechniciensTotal, Profit).
Found a solution with cost 0
Found a solution with cost -495
Found a solution with cost -795
Found a solution with cost -1195
Found a solution with cost -1495
Found a solution with cost -1535
Found a solution with cost -1835
Found a solution with cost -1955
Found a solution with cost -1970
Found a solution with cost -2010
Found a solution with cost -2015
Found a solution with cost -2315
Found a solution with cost -2490
Found a solution with cost -2665
Found no solution with cost -4420.0 .. -2666.0

Fabriquer = [](0, 1, 1, 0, 0, 1, 1, 0, 1)
NbTechniciensTotal = 22
Profit = 2665
Yes (0.02s cpu)
*/

/* Question 5.6 */

solve1000(Fabriquer, NbTechniciensTotal, Profit):-
    poseContraintes1000(Fabriquer, NbTechniciensTotal, Profit),
    minimize(labeling(Fabriquer), NbTechniciensTotal).

poseContraintes1000(Fabriquer, NbTechniciensTotal, Profit):-
    getData(Techniciens, Quantite, Benefices),
    dim(Techniciens, [Longueur]),
    getVar(Fabriquer, Longueur),
    totalOuvriers(Techniciens, Fabriquer, NbTechniciensTotal),
    totalBenefice(Quantite, Benefices, Fabriquer, TotalBenefice),
    totalProfit(TotalBenefice, Profit),
    NbTechniciensTotal #=< 22,
    Profit #>= 1000.

/*
solve1000(Fabriquer, NbTechniciensTotal, Profit).

Found a solution with cost 10
Found a solution with cost 9
Found a solution with cost 8
Found a solution with cost 7
Found no solution with cost 0.0 .. 6.0

Fabriquer = [](1, 0, 1, 0, 0, 0, 0, 0, 0)
NbTechniciensTotal = 7
Profit = 1040
Yes (0.01s cpu)
*/

/* Question 5.3 */

poseContraintes(Fabriquer, NbTechniciensTotal, Profit):-
    getData(Techniciens, Quantite, Benefices),
    dim(Techniciens, [Longueur]),
    getVar(Fabriquer, Longueur),
    totalOuvriers(Techniciens, Fabriquer, NbTechniciensTotal),
    totalBenefice(Quantite, Benefices, Fabriquer, TotalBenefice),
    totalProfit(TotalBenefice, Profit),
    NbTechniciensTotal #=< 22.

/*

5.3:

Fabriquer = [](0, 0, 0, 0, 0, 0, 0, 0, 0)
NbTechniciensTotal = 0
Profit = 0
Yes (0.02s cpu, solution 1, maybe more) ? ;

Fabriquer = [](0, 0, 0, 0, 0, 0, 0, 0, 1)
NbTechniciensTotal = 3
Profit = 495
Yes (0.02s cpu, solution 2, maybe more) ? ;

Fabriquer = [](0, 0, 0, 0, 0, 0, 0, 1, 0)
NbTechniciensTotal = 5
Profit = 300
Yes (0.02s cpu, solution 3, maybe more) ?

=> On ne trouve pas forcément le maximum

*/

getVarlist(Fabriquer, Liste):-
    term_variables(Fabriquer, Liste).

/* Question 5.1 */

getData(Techniciens, Quantite, Benefices):-
    Techniciens = [](5, 7, 2, 6, 9, 3, 7, 5, 3),
    Quantite = [](140, 130, 60, 95, 70, 85, 100, 30, 45),
    Benefices = [](4, 5, 8, 5, 6, 4, 7, 10, 11).
    

getVar(Fabriquer, Longueur):-
    dim(Fabriquer, [Longueur]),
    Fabriquer #:: 0..1.
/*
getData(T, Q, B).

T = [](5, 7, 2, 6, 9, 3, 7, 5, 3)
Q = [](140, 130, 60, 95, 70, 85, 100, 30, 45)
B = [](4, 5, 8, 5, 6, 4, 7, 10, 11)
Yes (0.00s cpu)
*/

/* Question 5.2 */

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
    


/*
[eclipse 12]: X = [](1, 2, 3), Y=[](4, 5, 6), produitVecteur(X, Y, Z).
X = [](1, 2, 3)
Y = [](4, 5, 6)
Z = [](4, 10, 18)
Yes (0.00s cpu)

[eclipse 41]: X = [](1, 2, 3), sommeVecteur(X, R).

X = [](1, 2, 3)
R = 6
Yes (0.00s cpu)

[eclipse 14]: X = [](1, 2, 3), Y=[](4, 5, 6), produitScalaire(X, Y, Z).
X = [](1, 2, 3)
Y = [](4, 5, 6)
Z = 32
Yes (0.00s cpu)
*/

totalOuvriers(Techniciens, Fabriquer, TotalOuvriers):-
    produitScalaire(Techniciens, Fabriquer, TotalOuvriers).

totalBenefice(Quantite, Benefices, Fabriquer, TotalBenefice):-
    produitVecteur(Quantite, Benefices, Temp),
    produitVecteur(Temp, Fabriquer, TotalBenefice).

% Multipliser Quantite x Benefices x Fabriquer

totalProfit(TotalBenefice, TotalProfit):-
    sommeVecteur(TotalBenefice, TotalProfit).


/* Question 5.4 */

minimum(X, Y, Z, W):-
    [X, Y, Z, W] #::[0..10],
    X #= Z+Y+2*W,
    X #\= Z+Y+W,
    minimize(labeling([X, Y, Z, W]), X).

/*
labeling sur le X
Found a solution with cost 1
Found no solution with cost 0.0 .. 0.0

X = 1
Y = Y{[0, 1]}
Z = Z{[0, 1]}
W = 0
Min = Min

Le résultat n'est pas totalement calculé, c'est insuffisant, non consistent
Delayed goals:
        - Z{[0, 1]} - Y{[0, 1]} #= -1
        - Y{[0, 1]} - Z{[0, 1]} - 0 + 1 #\= 0
Yes (0.00s cpu)

Labeling sur [X, Y, Z, W]
Found a solution with cost 2
Found no solution with cost 0.0 .. 1.0

X = 2
Y = 0
Z = 0
W = 1
*/
