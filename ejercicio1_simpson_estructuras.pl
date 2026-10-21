% Estructura persona(Nombre, Genero)
persona(abraham,    m).
persona(clancy,     m).
persona(herbert,    m).
persona(homero,     m).
persona(bart,       m).
persona(mona,       f).
persona(jacqueline, f).
persona(marge,      f).
persona(patty,      f).
persona(selma,      f).
persona(lisa,       f).
persona(maggie,     f).
persona(ling,       f).

% Estructura familia(Padre, Madre, [ListaHijos])
familia(abraham, mona,       [herbert, homero]).
familia(clancy,  jacqueline, [marge, patty, selma]).
familia(homero,  marge,      [bart, lisa, maggie]).
familia(ninguno, selma,      [ling]).

% Reglas de clasificación
hombre(X) :- persona(X, m).
mujer(X)  :- persona(X, f).

% Progenitores mediante listas
padre(P, H) :- familia(P, _, Hijos), P \= ninguno, member(H, Hijos).
madre(M, H) :- familia(_, M, Hijos), member(H, Hijos).

progenitor(P, H) :- padre(P, H).
progenitor(M, H) :- madre(M, H).

hijo(H, P) :- hombre(H), progenitor(P, H).
hija(H, P) :- mujer(H),  progenitor(P, H).

% Abuelos y nietos
abuelo(A, N) :- hombre(A), progenitor(A, Z), progenitor(Z, N).
abuela(A, N) :- mujer(A),  progenitor(A, Z), progenitor(Z, N).

nieto(N, A)  :- hombre(N), (abuelo(A, N) ; abuela(A, N)).
nieta(N, A)  :- mujer(N),  (abuelo(A, N) ; abuela(A, N)).

% Hermanos procesados sobre la lista familiar
hermanos(X, Y) :-
    familia(_, _, Hijos),
    member(X, Hijos),
    member(Y, Hijos),
    X \= Y.

hermano(X, Y) :- hombre(X), hermanos(X, Y).
hermana(X, Y) :- mujer(X),  hermanos(X, Y).

% Tíos y sobrinos
tio(T, S)     :- hombre(T), hermanos(T, P), progenitor(P, S).
tia(T, S)     :- mujer(T),  hermanos(T, P), progenitor(P, S).
sobrino(S, T) :- hombre(S), progenitor(P, S), hermanos(P, T).
sobrina(S, T) :- mujer(S),  progenitor(P, S), hermanos(P, T).

% Primos
primos(X, Y) :-
    progenitor(P1, X),
    progenitor(P2, Y),
    hermanos(P1, P2),
    X \= Y.

% Ancestros
ancestro(A, D) :- progenitor(A, D).
ancestro(A, D) :- progenitor(A, Z), ancestro(Z, D).