# MST-Prim-Prolog

-Descrizione: 
Risolvere il problema MST, su grafi non diretti e connessi con pesi 
non negativi, implementando l'algoritmo di Prim. 


-LIBRERIA PREDICATI:


-legenda:
### prima di un nome di predicato indica che è implementato da noi e
usato nella costruzione dell'API.


INTERFACCIA PER LA MANIPOLAZIONE DEI GRAFI:


new_graph(G).
Questo predicato inserisce un nuovo grafo nella base-dati Prolog a meno
che non esista già. 


delete_graph(G).
Rimuove tutto il grafo (vertici e archi inclusi) dalla base-dati Prolog.
Inoltre, se presenti, elimina i fatti vertex_key e vertex_previous.


new_vertex(G, V).
Aggiunge il vertice V nella base-dati Prolog.
Un vertice V può appartenere a più grafi distinti.


graph_vertices(G, Vs).
Questo predicato è vero quando Vs è una lista contenente tutti i vertici di G.


list_vertices(G).
Questo predicato stampa alla console dell’interprete Prolog una lista dei 
vertici del grafo G.


new_arc(G, U, V, Weight).
Aggiunge un arco del grafo G alla base dati Prolog.
Il predicato aggiunge alla base dati una coppia di archi:
arc(G, U, V, Weight) e arc(G, V, U, Weight) in modo da rappresentare
la bidirezionalità di un grafo non diretto.
Se l'arco che si vuole inserire differisce solamente per il peso da un arco
gia' presente nella base di conoscenza allora quest'ultimo viene aggiornato.


new_arc(G, U, V).
Aggiunge un arco del grafo G alla base dati Prolog con peso uguale a 1.


graph_arcs(G, Es).
Questo predicato è vero quando Es è una lista di tutti gli archi presenti in G.


vertex_neighbors(G, V, Ns).
Questo predicato è vero quando V è un vertice di G e Ns è una lista contenente
gli archi, arc(G, V, N, W) e arc(G, N, V, W), che portano ai vertici N
immediatamente raggiungibili da V.


adjs(G, V, Vs).
Questo predicato è vero quando V è un vertice di G e Vs è una lista contenente
i vertici vertex(G, V) ad esso adiacenti.


list_arcs(G).
Questo predicato stampa alla console dell’interprete Prolog una lista degli 
archi del grafo G.


list_graph(G).
Questo predicato stampa alla console dell’interprete Prolog una lista dei 
vertici e degli archi del grafo G.


read_graph(G, FileName).
Questo predicato legge un grafo G, da un file FileName e lo inserisce nella
base dati di Prolog.
FileName deve essere un file di tipo ".csv".
Ogni riga contiene 3 elementi separati da un carattere di tabulazione.


-predicati d'appoggio di read_graph/2:

### extract(G, Arcs3).
Questo predicato estrae ciascuna riga dal file FileName e, per 
ciacuna di esse, aggiunge al grafo G l'arco letto.  


write_graph(G, FileName, Type).
Questo predicato è vero quando G viene scritto sul file FileName secondo il valore
dell’argomento Type. Type può essere "graph" o "edges". 
Se Type è "graph", allora G è un termine che identifica un grafo nella base di dati Prolog;
In FileName saranno scritti gli archi del grafo secondo il formato descitto per read_graph/2.
Se Type è edges, allora G è una lista di archi unidirezionali, ognuno dei quali viene stampato su FileName,
sempre secondo il formato descritto per read_graph/2.


-predicati d'appoggio di write_graph/3:

### double_list(Arcs4, DoubleArcs4).
Questo predicato è vero quando Arcs4 è una lista di arc/4 e DoubleArcs4 è
una lista che contiene gli archi di Arcs4 con entrambe le direzioni
arc(G, U, V, Weight) e arc(G, V, U, Weight),
per rispettare la scelta implementativa di bidirezionalità. 


### generate_arc3_list(Arcs4, Arcs3).
Questo predicato è vero quando arcs4 è una lista di arc/4 del tipo
arc(G, U, V, Weight), Arcs3 è una lista di arc/3 del tipo arc(U, V, Weight).  


write_graph(G, FileName).
Questo predicato richiama write_graph/3 con Type uguale ad "Edges".


------------------------------------------------------------------------


INTERFACCIA PER LA CREAZIONE E MANIPOLAZIONE DEI MINHEAP:


new_heap(H).
Questo predicato inserisce un nuovo heap nella base-dati Prolog. 


delete_heap(H).
Rimuove tutto lo heap (incluse tutte le “entries”) dalla base-dati Prolog.


heap_has_size(H, S).
Questo predicato è vero quando S è la dimensione corrente dello heap.


heap_empty(H).
Questo predicato è vero quando lo heap H non contiene elementi.


heap_not_empty(H).
Questo predicato è vero quando lo heap H contiene almeno un elemento.


heap_head(H, K, V).
Il predicato è vero quando l’elemento dello heap H con chiave minima K è V.


heap_insert(H, K, V).
Il predicato è vero quando l’elemento V è inserito nello heap H con chiave K.


heap_extract(H, K, V).
Il predicato è vero quando la coppia K, V con K minima, è rimossa dallo heap H. 


modify_key(H, NewKey, OldKey, V).
Il predicato è vero quando la chiave OldKey (associata al valore V) è sostituita da
NewKey. 


list_heap(H).
Il predicato stampa sulla console Prolog lo stato interno dello heap.


-predicati appoggio:

### update_heap_size(H, S).
Questo predicato aggiorna la dimensione dello heap.


### heap_property_check(H, P).
Il predicato mantiene corretta la proprietà del MinHeap H tra il nodo in posizione P
e quello in posizione floor(P/2).


### heapify(H, P).
Questo predicato è vero quando la chiave K dell'elemento in posizione P è minore
della chiave di entrambi i figli in posizione P*2 e (P*2 + 1).


------------------------------------------------------------------------ 


INTERFACCIA PER L'APPLICAZIONE DELL'ALGORITMO DI PRIM


vertex_key(G, V, K).
Questo predicato è vero quando V è un vertice di G e, durante e dopo l’esecuzione dell’algoritmo di
Prim, contiene il peso minimo di un arco che connette V nell’albero minimo; se questo arco non
esiste (ed all’inizio dell’esecuzione) allora K è inf.


vertex_previous(G, V, U).
Questo predicato è vero quando V ed U sono vertici di G e, durante e dopo l’esecuzione
dell’algoritmo di Prim, il vertice U è il vertice “genitore” (“precedente”, o “parent”) di V nel
minimum spanning tree.


mst_prim(G, Source).
Questo predicato implementa l'algoritmo di Prim.
La sua esecuzione inserisce nella base dati di Prolog i predicati vertex_key(G, V, K)
e vertex_previous(G, V, U) per ogni V appartenente a G.
Questi ultimi vengono aggiornati durante l'esecuzione di mst_prim/2 cosi che,
a fine esecuzione, rispettino la soluzione del problema MST.


-predicati d'appoggio di mst_prim/2:

### build_heap(G, V, Vs).
Questo predicato inizializza, per ogni V, i predicati vertex_key(G, V, K) e vertex_previous(G, V, 0)
e aggiunge all'heap creato in precedenza il nodo (K, V).


### decrease_queue(G).
Questo predicato estrae la testa dall'heap di Prim e chiama check_adjs/3 per ogni elemento estratto.


### check_adjs(G, U, Adjs).
Questo predicato aggiorna (se necessario), per ogni vertice V adicente a U, i predicati 
vertex_key(G, V, K) e vertex_previous(G, V, U) e  modifica lo stato dell'heap.


mst_get(G, Source, PeorderTree).
Questo predicato è vero quando PreorderTree è una lista degli archi dell'MST ordinata secondo 
un attraversamento preorder fatta rispetto al peso dell'arco.


-predicati d'appoggio di mst_get/3:

### delete_prim(G).
Questo predicato elimina dalla base dati di Prolog tutti i predicati vertex_key/3 e 
vertex_previous/3 creati durante l'esecuzione di mst_prim(G, Source).


### lista_figli_previous(G, Father, Son_List).
Questo predicato è vero quando Son_List è una lista contenente tutti i figli di Father rispetto
a vertex_previous(G, Son, Father).
In particolare il predicato crea una lista di coppie (Son, Weight) ed esegue prima una sort/4
sui valori Son e poi un'altra sort/4 sui valori Weight.


### transf_list(List1, List2).
Questo predicato è vero quando List2 è una lista che contiene il primo di elemento di ciascuna coppia 
della lista List1.


### list_insert(G, Father, Son_List, PT).
Questo predicato è vero quando PT è una lista contenente gli archi ordinati.
restituisce ricorsivamente PT concatenando le liste PT1 e PT2 ottenute chiamando list_insert(G, V, L1, PT1)   
e list_insert(G, Father, Son_List, PT2).
