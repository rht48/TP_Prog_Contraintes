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
