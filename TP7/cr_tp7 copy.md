---
author: Julien LETOILE, Romain HUBERT
title: CR TP7 Programmation par contraintes
---







<center style="font-size: xx-large;"><b>CR TP7 Programmation par contraintes</b></center> 

------









<center style="font-size: x-large;">Histoire de menteurs</center>















<center>Julien LETOILE, Romain HUBERT</center>

<center>le 18/03/2021</center>

# Table des matières

[TOC]







## I. <u>Réponses rédigées</u>

### Question 7.1

```javascript
affirme(S, A):-
    (S &= femme) => A.
```

Test: 

> X &:: personnes, X &= femme, affirme(X, A).
> X = femme
> A = 1
> Yes (0.00s cpu)
>
> X &:: personnes, X &= homme, affirme(X, A).
> X = homme
> A = A{[0, 1]}
> Yes (0.00s cpu)

### Question 7.2

```javascript
affirme(S, A1, A2):-
    (S &= homme) => ((A1 and neg(A2)) or (neg(A1) and A2)).
```

Test:

> X &:: personnes, X &= homme, affirme(X, A, B).
>
> X = homme
> A = A{[0, 1]}
> B = B{[0, 1]}
>
> Delayed goals:
>         _1711{[0, 1]} + B{[0, 1]} #= 1
>         #=(_1711{[0, 1]} + A{[0, 1]}, 2, _1681{[0, 1]})
>         _1869{[0, 1]} + A{[0, 1]} #= 1
>         #=(_1869{[0, 1]} + B{[0, 1]}, 2, _1854{[0, 1]})
>         - _1854{[0, 1]} - _1681{[0, 1]} #=< -1
> Yes (0.00s cpu)

### Question 7.3


```javascript

?- local domain(sexe(femme, homme)).

solve(Parent1, Parent2, Enfant):-
    pose_domaines(Parent1, Parent2, Enfant),
    pose_contraintes(Parent1, Parent2, Enfant),
    labeling_symbolic([Parent1, Parent2, Enfant]).

pose_domaines(Parent1, Parent2, Enfant):-
    Parent1 &:: sexe,
    Parent2 &:: sexe,
    Enfant &:: sexe.
    
```

Test:

> pose_domaines(Parent1, Parent2, Enfant).
>
> Parent1 = Parent1{[femme, homme]}
> Parent2 = Parent2{[femme, homme]}
> Enfant = Enfant{[femme, homme]}

### Question 7.4

```javascript

pose_contraintes(Parent1, Parent2, Enfant):-
    /* Enfant affirme : Arrheu, arrheu ! */
    AffE #:: 0..1,

    /* Parent1 affirme : Enfant vous dit qu’elle est une femme. */
    AffP1 #= (Enfant &= femme),

    /* Parent2 affirme : Enfant est un homme puis . . . */
    Aff1P2 #= (Enfant &= homme),

    /* Parent2 affirme : Enfant ment. */
    Aff2P2 #= (AffE #= 0),
    
    /* Liaisons entre personnes et affirmations */
    affirme(Enfant, AffE),
    affirme(Parent1, AffP1),
    affirme(Parent2, Aff1P2), 
    affirme(Parent2, Aff2P2), 
    affirme(Parent2, Aff1P2, Aff2P2),

    /* Les 2 parents sont du sexe opposé */
    Parent1 &\= Parent2.

```

Résultat final:

> solve(P1, P2, Enfant).
>
> P1 = homme
> P2 = femme
> Enfant = homme
> Yes (0.00s cpu)


## I. <u>Code source</u>

```javascript
:-lib(ic).
:-lib(ic_symbolic).
:-lib(branch_and_bound).


?- local domain(sexe(femme, homme)).


solve(Parent1, Parent2, Enfant):-
    pose_domaines(Parent1, Parent2, Enfant),
    pose_contraintes(Parent1, Parent2, Enfant),
    labeling_symbolic([Parent1, Parent2, Enfant]).


pose_domaines(Parent1, Parent2, Enfant):-
    Parent1 &:: sexe,
    Parent2 &:: sexe,
    Enfant &:: sexe.


pose_contraintes(Parent1, Parent2, Enfant):-
    /* Enfant affirme : Arrheu, arrheu ! */
    AffE #:: 0..1,

    /* Parent1 affirme : Enfant vous dit qu’elle est une femme. */
    AffP1 #= (Enfant &= femme),

    /* Parent2 affirme : Enfant est un homme puis . . . */
    Aff1P2 #= (Enfant &= homme),

    /* Parent2 affirme : Enfant ment. */
    Aff2P2 #= (AffE #= 0),
    
    /* Liaisons entre personnes et affirmations */
    affirme(Enfant, AffE),
    affirme(Parent1, AffP1),
    affirme(Parent2, Aff1P2), 
    affirme(Parent2, Aff2P2), 
    affirme(Parent2, Aff1P2, Aff2P2),

    /* Les 2 parents sont du sexe opposé */
    Parent1 &\= Parent2.


/* Les femmes disent toujours la vérité */
affirme(S, A):-
    (S &= femme) => A.


/* Les hommes alternent systématiquement entre vérité et mensonge */
affirme(S, A1, A2):-
    (S &= homme) => ((A1 and neg(A2)) or (neg(A1) and A2)).


/* Labeling symbolique */
labeling_symbolic([]).
labeling_symbolic([X | Liste]):-
    ic_symbolic:indomain(X),
    labeling_symbolic(Liste).
```
