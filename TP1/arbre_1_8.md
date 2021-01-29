```flow
st=>start: commande2(NbRes, NbCondo).
e1=>start: isBetween2(NbRes, 5000, 10000), isBetween2(NbCondo, 9000, 20000), NbRes #>= NbCondo, labeling([nbRes, NbCondo]).
e2=>start: isBetween2(NbRes{5000, 10000}, 5000, 10000), isBetween2(NbCondo, 9000, 20000), NbRes #>= NbCondo, labeling([nbRes, NbCondo]).
e3=>start: isBetween2(NbRes{5000, 10000}, 5000, 10000), isBetween2(NbCondo{9000, 20000}, 9000, 20000), NbRes #>= NbCondo, labeling([nbRes, NbCondo]).
e4=>start: isBetween2(NbRes{5000, 10000}, 5000, 10000), isBetween2(NbCondo{9000, 20000}, 9000, 20000), NbRes{5000, 10000} #>= NbCondo{9000, 20000}, labeling([nbRes, NbCondo]).
e5=>start: isBetween2(NbRes{5000, 10000}, 5000, 10000), isBetween2(NbCondo{9000, 20000}, 9000, 20000), NbRes{5000, 10000} #>= NbCondo{9000, 20000}, labeling([9000, 9000]).
f=>end: Yes: NbRes=9000, NbCondo=9000

st->e1
e1->e2
e2->e3
e3->e4
e4->e5
e5->f
```

