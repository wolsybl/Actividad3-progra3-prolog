% Base de conocimiento con estructura arista(Origen, Destino, Costo)
arista(vancouver, edmonton, 16).
arista(vancouver, calgary, 13).
arista(edmonton,  saskatoon, 12).
arista(calgary,   edmonton, 4).
arista(calgary,   regina, 14).
arista(saskatoon, calgary, 9).
arista(saskatoon, winnipeg, 20).
arista(regina,    saskatoon, 7).
arista(regina,    winnipeg, 4).

% Compatibilidad con consultas arco/3
arco(Origen, Destino, Costo) :- arista(Origen, Destino, Costo).

% Regla C: Existencia y lista de aristas salientes
tiene_aristas(Nodo) :- arista(Nodo, _, _).

aristas_salientes(Nodo, ListaDestinos) :-
    findall(destino(Dest, Costo), arista(Nodo, Dest, Costo), ListaDestinos),
    ListaDestinos \= [].

% Regla D: Costo vía nodo intermedio
costo_via_intermedio(X, Y, Z, CostoTotal) :-
    arista(X, Y, C1),
    arista(Y, Z, C2),
    CostoTotal is C1 + C2.

% Recorrido dirigido gestionado con listas de visitados y ruta
camino_dirigido(Origen, Destino, Ruta, Costo) :-
    construir_camino(Origen, Destino, [Origen], RInvertida, Costo),
    reverse(RInvertida, Ruta).

construir_camino(Origen, Destino, Visitados, [Destino|Visitados], Costo) :-
    arista(Origen, Destino, Costo),
    \+ member(Destino, Visitados).

construir_camino(Origen, Destino, Visitados, RutaFinal, CostoTotal) :-
    arista(Origen, Siguiente, C1),
    \+ member(Siguiente, Visitados),
    construir_camino(Siguiente, Destino, [Siguiente|Visitados], RutaFinal, C2),
    CostoTotal is C1 + C2.