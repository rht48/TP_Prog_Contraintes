---
author: Julien LETOILE, Romain HUBERT
title: CR TP1 Programmation par contraintes
---







<center style="font-size: xx-large;"><b>CR TP1 Programmation par contraintes</b></center> 

------









<center style="font-size: x-large;">Découverte de la bibliothèque de contraintes à domaines finis</center>















<center>Julien LETOILE, Romain HUBERT</center>

<center>le 26/01/2021</center>

# Table des matières

[TOC]







## I. <u>Réponses rédigées</u>

### Question 1.2

Prolog permet de tester automatiquement les contraintes sur toutes les données en les unifiant sous la forme d'arbres. Cela en fait un solveur de contraintes sur le domaine des arbres.

### Question 1.6

Prolog ne comprend pas les signes mathématiques, mais est capable de calculer de manière très efficace.
Si l'on pose le prédicat *>=* avant les appels à *isBetween*, on obtient un *instanciation fault*.
On parle d'approche "Generate and Test" puisque dans *commande*, on va d'abord générer les valeurs possibles avec les *isBetween*, puis on teste les valeurs générés avec l'inégalité.

### Question 1.7

En remplaçant les prédicats *isBetween* et *>=* par les conraintes *Var #:: Min..Max* et *#>=*, on obtient la réponse suivante:
> isBetween2(X, -2, 5).
> 
> X = X{-2 .. 5}
> Yes (0.00s cpu)

*{-2 .. 5}* correspond à l'intervalle des valeurs possibles de X répondant à la contrainte.

### Question 1.12

Après exécution de la requête ***X #:: -10..10, vabs(X, Y).***, on obtient la réponse suivante:

> X = 0  
> Y = 0  
> Yes (0.00s cpu, solution 1, maybe more) ? ;
>
> X = 1  
> Y = 1  
> Yes (0.00s cpu, solution 2, maybe more) ? ;
>
> X = 2  
> Y = 2  
> Yes (0.00s cpu, solution 3, maybe more) ? ;
>
> ...
>
> X = -9  
> Y = 9  
> Yes (0.02s cpu, solution 20, maybe more) ? ;
>
> X = -10  
> Y = 10  
> Yes (0.02s cpu, solution 21)

Après exécution de la requête ***X #:: -10..10, vabsOr(X, Y).***, on obtient la réponse suivante:

> X = 0  
> Y = 0  
> Yes (0.00s cpu, solution 1, maybe more) ? ;  
>
> X = -10  
> Y = 10  
> Yes (0.00s cpu, solution 2, maybe more) ? ;  
>
> X = -9  
> Y = 9  
> Yes (0.00s cpu, solution 3, maybe more) ? ;  
>
> ...
>
> X = 9  
> Y = 9  
> Yes (0.00s cpu, solution 20, maybe more) ? ;
>
> X = 10  
> Y = 10  
> Yes (0.00s cpu, solution 21)

On remarque que les 2 sorties se ressemblent hormis une inversion des arrivées des valeurs de X. Prolog, dans *vabs*, cherche toutes les solutions de ***AbsVal #= Val*** puis les solutions de ***AbsVal #= -Val***. Alors que dans *vabsOr*, le labeling prend toutes les valeurs dans l'ordre.

### Question 1.15

Pour vérifier que cette suite est périodique de période 9, il suffit de montrer qu'il n'existe pas une suite qui n'est pas de période 9. Ainsi, une requête qui vérifie cela est:

>faitListe(X, 15, -100, 100), suite(X), non_periodique9(X), labeling(X).
>
>No (0.75 cpu)

Donc la suite est de période 9.

## II. <u>Arbres de recherche</u>

### Question 1.5

Après exécution de la requête ***commande(-NbResistance, -NbCondensateur).***, on obtient l'arbre élagué suivant:

```mermaid
graph TB
A(["commande(NbRes, NbCondo)"])
A --> B["isBetween(NbRes, 5000, 10000), isBetween(9000, 20000), NbRes >= NbCondo."]
B -->|"{NbRes\10000}"| C["isBetween(10000, 5000, 10000), isBetween(NbCondo, 9000, 20000), NbRes >= NbCondo."]
C -->|"{NbCondo\20000}"| D["isBetween(10000, 5000, 10000), isBetween(20000, 9000, 20000), 10000 >= 20000."]
D --> E(["Fail"])

B --> F(["..."])
B --> |"{NbRes\9000}"| G["isBetween(9000, 5000, 10000), isBetween(NbCondo, 9000, 20000), NbRes >= NbCondo."]
G -->|"{NbCondo\9000}"| H["isBetween(9000, 5000, 10000), isBetween(20000, 9000, 20000), 9000 >= 9000."]
H --> I(["Yes"])

```


<center><i><u>Figure 1: Arbre de commande(-,-)</u></i></center>

### Question 1.8

Après exécution de la requête ***commande2(-NbResistance, -NbCondensateur).***, on obtient l'arbre élagué suivant :

```mermaid
graph TB
A(["commande2(NbRes, NbCondo)"])
A --> B["isBetween2(NbRes, 5000, 10000), isBetween2(NbCondo, 9000, 20000), <br/> NbRes #>= NbCondo, labeling([NbRes, NbCondo])."]
B -->|"{NbRes\NbRes{5000..10000}}"| C["isBetween2(NbRes{5000, 10000}, 5000, 10000), isBetween2(NbCondo, 9000, 20000), <br/> NbRes{5000, 10000} #>= NbCondo, labeling([NbRes{5000, 10000}, NbCondo])."]
C -->|"{NbCondo\NbCondo{9000..20000}}"| D["isBetween2(NbRes{5000, 10000}, 5000, 10000), isBetween2(NbCondo{9000..20000}, 9000, 20000),<br/> NbRes{5000, 10000} #>= NbCondo{9000..20000}, labeling([NbRes{5000, 10000}, NbCondo{9000..20000}])."]
D -->|"Réduction du domaine: NbCondo{9000, 10000} - NbRes{9000, 10000} #=< 0}"| E["isBetween2(NbRes{5000, 10000}, 5000, 10000), isBetween2(NbCondo{9000..20000}, 9000, 20000),<br/> NbRes{9000, 10000} #>= NbCondo{9000..10000}, labeling([NbRes{9000, 10000}, NbCondo{9000..10000}])."]
E -->|"Le labeling choisit les valeurs de NbRes et NbCondo: {NbRes\9000, NbCondo\9000}"| F["isBetween2(9000, 5000, 10000), isBetween2(9000, 9000, 20000), 9000 #>= 9000, labeling([9000, 9000])."]
F --> G(["Yes"])
E -->|"D'autres valeurs de NbRes et NbCondo"| H["..."]
```

<center><i><u>Figure 2: Arbre de commande2(-,-)</u></i></center>

## III. <u>Annexes</u>

### Code source

```javascript
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
    isBetween(NbResistance, 5000, 10000),
    isBetween(NbCondensateur, 9000, 20000),
    NbResistance >= NbCondensateur.
    
test_commande:-
    commande(9000, 9000),
    commande(10000, 9500),
    not commande(4000, 9000),
    not commande(5000, 9000).

/* Q1.7 */

isBetween2(Var, Min, Max):-
    Var #:: Min..Max,
    Max #>= Min.

/* X = X{10 .. 20} */

/* Q1.8 */

commande2(NbRes, NbCondo):-
    isBetween2(NbRes, 5000, 10000),
    isBetween2(NbCondo, 9000, 20000),
    NbRes #>= NbCondo,
    labeling([NbRes, NbCondo]).
    

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
```
