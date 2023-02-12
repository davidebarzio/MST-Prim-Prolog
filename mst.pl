%%%%% -*- Mode: Prolog -*-

%%%% mst.pl
%%%% Davide Barzio 844556
%%%% Federico Benaglia 845138

:- dynamic graph/1.
:- dynamic vertex/2.
:- dynamic arc/4.
:- dynamic heap/2.
:- dynamic heap_entry/4.
:- dynamic vertex_key/3.
:- dynamic vertex_previous/3.


new_graph(G) :-
    nonvar(G),
    graph(G), !.

new_graph(G) :-
    nonvar(G),
    assertz(graph(G)), !.


delete_graph(G) :-
    retract(graph(G)),
    retractall(vertex(G, _)),
    retractall(arc(G, _, _, _)),
    retractall(vertex_previous(G, _, _)),
    retractall(vertex_key(G, _, _)).


new_vertex(G, V) :-
    nonvar(G),
    nonvar(V),
    vertex(G, V), !.

new_vertex(G, V) :-
    nonvar(G),
    nonvar(V),
    graph(G),
    assert(vertex(G, V)), !.


graph_vertices(G, Vs) :-
    nonvar(G),
    findall(vertex(G, X), vertex(G, X), Vs).


list_vertices(G) :-
    graph(G),
    listing(vertex(G, _)).


new_arc(G, U, V, Weight) :-
    nonvar(G),
    nonvar(U),
    nonvar(V),
    nonvar(Weight),
    arc(G, U, V, Weight), !.

new_arc(G, U, V, Weight1) :-
    nonvar(G),
    nonvar(U),
    nonvar(V),
    nonvar(Weight1),
    U \= V,
    arc(G, U, V, Weight2),
    Weight1 \= Weight2,
    Weight1 >= 0,
    retract(arc(G, U, V, Weight2)),
    retract(arc(G, V, U, Weight2)),
    new_arc(G, U, V, Weight1), !.

new_arc(G, U, V, Weight) :-
    nonvar(G),
    nonvar(U),
    nonvar(V),
    nonvar(Weight),
    U \= V,
    graph(G),
    vertex(G, U),
    vertex(G,V),
    Weight >= 0,
    assert(arc(G, U, V, Weight)),
    assert(arc(G, V, U, Weight)), !.


new_arc(G, U, V) :-
    nonvar(G),
    nonvar(U),
    nonvar(V),
    new_arc(G, U, V, 1), !.


graph_arcs(G, Es) :-
    nonvar(G),
    findall([U, V, Weight], arc(G, U, V, Weight), Es).


vertex_neighbors(G, V, Ns) :-
    vertex(G, V),
    findall(arc(G, V, U, Weight), arc(G, V, U, Weight), Ns).


adjs(G, V, Vs) :-
    vertex(G, V),
    findall(vertex(G, U), arc(G, V, U, _), Vs).


list_arcs(G) :-
    graph(G),
    listing(arc(G, _, _, _)).

list_graph(G) :-
    list_vertices(G),
    list_arcs(G).


read_graph(G, FileName) :-
    nonvar(G),
    nonvar(FileName),
    delete_graph(G),
    new_graph(G),
    csv_read_file(FileName, Rows, [functor(arc), arity(3), separator(0'\t)]),
    extract(G, Rows), !.

read_graph(G, FileName) :-
    nonvar(G),
    nonvar(FileName),
    new_graph(G),
    csv_read_file(FileName, Rows, [functor(arc), arity(3), separator(0'\t)]),
    extract(G, Rows), !.


extract(_, []) :- !.

extract(G, [arc(U, V, Weight) | Zs]) :-
    number(Weight),
    new_vertex(G, U),
    new_vertex(G, V),
    new_arc(G, U, V, Weight),
    extract(G, Zs).


write_graph(G, FileName) :-
    write_graph(G, FileName, graph).


write_graph(G, FileName, Type) :-
    Type = graph,
    nonvar(G),
    nonvar(FileName),
    graph(G),
    findall(arc(U, V, Weight), arc(G, U, V, Weight), List),
    csv_write_file(FileName, List, [separator(0'\t)]), !.

write_graph(G, FileName, Type) :-
    Type = edges,
    is_list(G),
    nonvar(FileName),
    double_list(G, DuplicatedList),
    generate_arc3_list(DuplicatedList, List),
    csv_write_file(FileName, List, [separator(0'\t)]), !.


generate_arc3_list([], []) :- !.

generate_arc3_list([arc(Gr, U, V, Weight) | Xs],
                   [arc(U, V, Weight) | Ys]) :-
    arc(Gr, U, V, Weight),
    generate_arc3_list(Xs, Ys), !.


double_list([], []) :- !.

double_list([arc(G, U, V, Weight) | Xs],
            [arc(G, U, V, Weight), arc(G, V, U, Weight) | Ys]) :-
    double_list(Xs, Ys), !.


new_heap(H) :-
    nonvar(H),
    heap(H, _S), !.

new_heap(H) :-
    nonvar(H),
    assert(heap(H, 0)), !.


delete_heap(H) :-
    retract(heap(H, _)),
    retractall(heap_entry(H, _, _, _)).


heap_has_size(H, S) :- heap(H, S).


heap_empty(H) :- heap_has_size(H, 0).


heap_not_empty(H) :-
    heap(H, S),
    S > 0.


heap_head(H, K, V) :-
    heap_not_empty(H),
    heap_entry(H, 1, K, V).


heap_insert(H, K, V) :-
    nonvar(H),
    nonvar(K),
    nonvar(V),
    heap(H, S),
    Inc is S + 1,
    update_heap_size(H, Inc),
    assert(heap_entry(H, Inc, K, V)),
    heap_property_check(H, Inc).


update_heap_size(H, S) :-
    retract(heap(H, _)),
    assert(heap(H, S)).


heap_property_check(_, 1) :- !.

heap_property_check(H, P) :-
    Parent is floor(P / 2),
    heap_entry(H, P, K, _),
    heap_entry(H, Parent, KParent, _),
    KParent =< K, !.

heap_property_check(H, P) :-
    Parent is floor(P / 2),
    heap_entry(H, P, K, V),
    heap_entry(H, Parent, KParent, VParent),
    KParent > K,
    retract(heap_entry(H, P, K, V)),
    retract(heap_entry(H, Parent, KParent, VParent)),
    assert(heap_entry(H, Parent, K, V)),
    assert(heap_entry(H, P, KParent, VParent)),
    heap_property_check(H, Parent), !.


heap_extract(H, K, V) :-
    heap(H, S),
    nonvar(H),
    heap_has_size(H, 1),
    retract(heap_entry(H, 1, K, V)),
    Decrease is S - 1,
    update_heap_size(H, Decrease), !.

heap_extract(H, K, V) :-
    heap(H, S),
    nonvar(H),
    heap_entry(H, S, Kl, Vl),
    retract(heap_entry(H, 1, K, V)),
    retract(heap_entry(H, S, Kl, Vl)),
    assert(heap_entry(H, 1, Kl, Vl)),
    Decrease is S - 1,
    update_heap_size(H, Decrease),
    heapify(H, 1), !.


heapify(H, P) :-
    Left is P * 2,
    Right is P * 2 + 1,
    heap(H, S),
    Left > S,
    Right > S, !.

heapify(H, P) :-
    heap(H, S),
    P >= S, !.

heapify(H, P) :-
    Left is P * 2,
    Right is P * 2 + 1,
    heap_entry(H, P, K, V),
    heap_entry(H, Left, KLeft, _),
    heap_entry(H, Right, KRight, _),
    KLeft =< KRight,
    KLeft < K,
    retract(heap_entry(H, P, K, V)),
    retract(heap_entry(H, Left, KLeft, VLeft)),
    assert(heap_entry(H, Left, K, V)),
    assert(heap_entry(H, P, KLeft, VLeft)),
    heapify(H, Left), !.

heapify(H, P) :-
    Left is P * 2,
    Right is P * 2 + 1,
    heap_entry(H, P, K, V),
    heap_entry(H, Left, KLeft, _),
    heap_entry(H, Right, KRight, _),
    KLeft > KRight,
    KRight < K,
    retract(heap_entry(H, P, K, V)),
    retract(heap_entry(H, Right, KRight, VRight)),
    assert(heap_entry(H, Right, K, V)),
    assert(heap_entry(H, P, KRight, VRight)),
    heapify(H, Right), !.

heapify(H, P) :-
    Left is P * 2,
    Right is P * 2 + 1,
    heap_entry(H, P, K, _),
    heap_entry(H, Left, KLeft, _),
    heap_entry(H, Right, KRight, _),
    Min is min(KLeft, KRight),
    K =< Min, !.

heapify(H, P) :-
    heap(H, S),
    Left is P * 2,
    Right is P * 2 + 1,
    Right > S,
    heap_entry(H, P, K, _),
    heap_entry(H, Left, KLeft, _),
    K < KLeft, !.

heapify(H, P) :-
    heap(H, S),
    Left is P * 2,
    Right is P * 2 + 1,
    Right > S,
    heap_entry(H, P, K, V),
    heap_entry(H, Left, KLeft, VLeft),
    KLeft =< K,
    retract(heap_entry(H, P, K, V)),
    retract(heap_entry(H, Left, KLeft, VLeft)),
    assert(heap_entry(H, Left, K, V)),
    assert(heap_entry(H, P, KLeft, VLeft)),
    heapify(H, Left), !.


modify_key(H, NewKey, OldKey, V) :-
    nonvar(H),
    nonvar(NewKey),
    nonvar(OldKey),
    nonvar(V),
    heap_entry(H, P, OldKey, V),
    retract(heap_entry(H, P, OldKey, V)),
    assert(heap_entry(H, P, NewKey, V)),
    heapify(H, P),
    heap_property_check(H, P).


list_heap(H) :-
    heap(H, _),
    listing(heap_entry(H, _, _, _)).


mst_prim(G, Source) :-
    graph_vertices(G, Vs),
    new_heap(G),
    build_heap(G, Source, Vs),
    decrease_queue(G),
    delete_heap(G).


build_heap(_, _, []) :- !.

build_heap(G, Source, [vertex(G, Source) | Xs]) :-
    assert(vertex_key(G, Source, 0)),
    assert(vertex_previous(G, Source, 0)),
    heap_insert(G, 0, Source),
    build_heap(G, Source, Xs),!.

build_heap(G, Source, [vertex(G, V) | Xs]) :-
    assert(vertex_key(G, V, inf)),
    assert(vertex_previous(G, V, 0)),
    heap_insert(G, inf, V),
    build_heap(G, Source, Xs), !.


decrease_queue(G) :-
    heap_has_size(G, 0), !.

decrease_queue(G) :-
    heap_extract(G, _, U),
    adjs(G, U, Ns),
    check_adjs(G, U, Ns),
    decrease_queue(G), !.


check_adjs(_, _, []) :- !.

check_adjs(G, U, [vertex(G, V) | Ns]) :-
    heap_entry(G, _, K, V),
    arc(G, U, V, Weight),
    Weight < K,
    retract(vertex_key(G, V, K)),
    assert(vertex_key(G, V, Weight)),
    retract(vertex_previous(G, V, _)),
    assert(vertex_previous(G, V, U)),
    modify_key(G, Weight, K, V),
    check_adjs(G, U, Ns), !.

check_adjs(G, U, [vertex(G, V) | Ns]) :-
    heap_entry(G, _, K, V),
    arc(G, U, V, Weight),
    Weight >= K,
    check_adjs(G, U, Ns), !.

check_adjs(G, U, [vertex(G, V) | Ns]) :-
    not(heap_entry(G, _, _, V)),
    check_adjs(G, U, Ns), !.


mst_get(G, Source, PreorderTree) :-
    vertex_key(G, Source, 0),
    lista_figli_previous(G, Source, SonList),
    list_insert(G, Source, SonList, PreorderTree),
    delete_prim(G).


delete_prim(G) :-
    delete_heap(G),
    retractall(vertex_key(G, _, _)),
    retractall(vertex_previous(G, _, _)).


lista_figli_previous(G, Father, SonList) :-
    findall([Son, Weight], (vertex_previous(G, Son, Father),
                            vertex_key(G, Son, Weight)), L),
    sort(1, @=<, L, S),
    sort(2, @=<, S, T),
    transf_list(T, SonList).


transf_list([], []) :- !.

transf_list([[V, _] | L1], [V | L2]) :-
    transf_list(L1, L2), !.


list_insert(_, _, [], []) :- !.

list_insert(G, Father, [V | SonList],
            [arc(G, Father, V, Weight) | PT]) :-
    vertex_key(G, V, Weight),
    lista_figli_previous(G, V, L1),
    list_insert(G, V, L1, PT1),
    list_insert(G, Father, SonList, PT2),
    append(PT1, PT2, PT), !.

%%%%%  end of file -- mst.pl

