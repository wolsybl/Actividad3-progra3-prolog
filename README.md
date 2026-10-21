# Universidad Tecnológica de Pereira
**Programa:** Desarrollo de Software  
**Asignatura:** Programación III (ProgIIIG101) - Grupo 101  
**Estudiante:** Wilson Andrés Henao  
**Profesor:** Ramiro A. Barrios Valencia  
**Actividad:** Refactorización con Estructuras y Listas en Prolog  

---

## 1. Ejercicio 1: Árbol Genealógico (Familia Simpson con Estructuras y Listas)

### Planteamiento
Refactorizar la base de conocimiento y el motor de inferencia de parentesco familiar sustituyendo los predicados planos individuales por estructuras compuestas (`persona/2` y `familia/3`) y listas de descendencia, preservando la capacidad de resolver las mismas consultas de relaciones familiares sin duplicar resultados.

### Modificaciones Realizadas
* **Estructura de individuo:** Se sustituyen los hechos atómicos `hombre/1` y `mujer/1` por el functor compuesto `persona(Nombre, Genero)`, donde `Genero` es `m` o `f`.
* **Estructura de núcleo familiar:** Se agrupa la paternidad, maternidad y descendencia en una sola estructura:
  $$\text{familia}(\text{Padre}, \text{Madre}, [\text{Hijo}_1, \text{Hijo}_2, \dots])$$
* **Procesamiento de listas:** La pertenencia de hijos se verifica con `member/2`. La hermandad (`hermanos/2`) se resuelve directamente comprobando que dos miembros distintos pertenezcan a la misma lista familiar, eliminando la necesidad de filtros aritméticos o de orden lexicográfico para evitar duplicados.

### Código Prolog
```prolog
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

% Progenitores mediante pertenencia a listas
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

% Ancestros (Recursividad)
ancestro(A, D) :- progenitor(A, D).
ancestro(A, D) :- progenitor(A, Z), ancestro(Z, D).
```

### Consultas de Validación
```prolog
% Abuelos de Bart
?- abuelo(X, bart).
% X = abraham ;
% X = clancy.

% Hermanas de Bart
?- hermana(X, bart).
% X = lisa ;
% X = maggie.

% Relación de primos
?- primos(bart, ling).
% true.

% Ancestros directos e indirectos de Bart
?- ancestro(X, bart).
% X = homero ;
% X = marge ;
% X = abraham ;
% X = mona ;
% X = clancy ;
% X = jacqueline.
```

---

## 2. Ejercicio 2: Grafo Dirigido con Pesos (Ciudades de Canadá con Estructuras y Listas)

### Planteamiento
Rediseñar el modelo del grafo dirigido de transporte entre ciudades canadienses utilizando la estructura `arista(Origen, Destino, Costo)` y dotar las búsquedas de caminos de un control estricto de nodos visitados mediante listas, evitando la posibilidad de bucles infinitos en grafos dirigidos con ciclos.

### Modificaciones Realizadas
* **Estructura de aristas:** Cada arco dirigido se encapsula como un término `arista(Origen, Destino, Costo)`. Se mantiene el predicado adaptador `arco/3` para conservar compatibilidad con consultas anteriores.
* **Colección de adyacencias:** Se introduce la regla `aristas_salientes/2` apoyada en `findall/3` para recolectar las conexiones salientes de un nodo en una lista de subestructuras `destino(Destino, Costo)`.
* **Rastreo con listas:** La búsqueda de caminos dirigidos utiliza acumuladores de visitados (`\+ member(...)`) e inversión final de lista (`reverse/2`) para entregar la ruta ordenada de origen a fin.

### Código Prolog
```prolog
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

% Compatibilidad con predicado original arco/3
arco(Origen, Destino, Costo) :-
    arista(Origen, Destino, Costo).

% c) Regla: Existencia y lista de aristas salientes
tiene_aristas(Nodo) :-
    arista(Nodo, _, _).

aristas_salientes(Nodo, ListaDestinos) :-
    findall(destino(Dest, Costo), arista(Nodo, Dest, Costo), ListaDestinos),
    ListaDestinos \= [].

% d) Regla: Costo de X a Z pasando por nodo intermedio Y
costo_via_intermedio(X, Y, Z, CostoTotal) :-
    arista(X, Y, C1),
    arista(Y, Z, C2),
    CostoTotal is C1 + C2.

% Recorrido dirigido gestionado con listas de visitados y ruta
camino_dirigido(Origen, Destino, Ruta, Costo) :-
    construir_camino(Origen, Destino, [Origen], RInvertida, Costo),
    reverse(RInvertida, Ruta).

% Caso base: Llegada directa
construir_camino(Origen, Destino, Visitados, [Destino|Visitados], Costo) :-
    arista(Origen, Destino, Costo),
    \+ member(Destino, Visitados).

% Caso recursivo: Salto intermedio acumulando en la lista de visitados
construir_camino(Origen, Destino, Visitados, RutaFinal, CostoTotal) :-
    arista(Origen, Siguiente, C1),
    \+ member(Siguiente, Visitados),
    construir_camino(Siguiente, Destino, [Siguiente|Visitados], RutaFinal, C2),
    CostoTotal is C1 + C2.
```

### Respuestas a las Preguntas Guía
a) **¿Existe conexión entre Saskatoon y Vancouver?**
```prolog
?- camino_dirigido(saskatoon, vancouver, Ruta, Costo).
% Resultado: false
```
*Explicación:* Al ser un grafo dirigido, ningún arco orienta el flujo desde Saskatoon hacia Vancouver.

b) **¿Con qué nodos está conectado Regina y cuál es el costo?**
```prolog
?- arco(regina, Destino, Costo).
% Destino = saskatoon, Costo = 7 ;
% Destino = winnipeg,  Costo = 4.

% O mediante lista de estructuras adyacentes:
?- aristas_salientes(regina, Conexiones).
% Conexiones = [destino(saskatoon, 7), destino(winnipeg, 4)].
```

c) **¿Tiene aristas salientes Vancouver?**
```prolog
?- tiene_aristas(vancouver).
% Resultado: true.
```

d) **¿Cuál es el costo de Vancouver a Saskatoon pasando por Edmonton?**
```prolog
?- costo_via_intermedio(vancouver, edmonton, saskatoon, Costo).
% Costo = 28. % (16 + 12)
```

e) **¿Es posible viajar desde Edmonton a Calgary?**
```prolog
?- camino_dirigido(edmonton, calgary, Ruta, Costo).
% Resultado: true.
% Ruta = [edmonton, saskatoon, calgary], Costo = 21.
```
*Explicación:* No hay tramo directo de Edmonton a Calgary, pero la búsqueda recursiva con listas encuentra la ruta a través de Saskatoon ($12 + 9 = 21$).