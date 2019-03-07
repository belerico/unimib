# Sistemi complessi

## Introduzione

Un automa cellulare (AC d'ora in avanti) è un sistema dinamico discreto costituito da una rete regolare di automi a stati finiti (celle), che cambiano i loro stati sulla base dei loro vicini applicando una regola d'aggiornamento locale. Tutte le celle cambiano il loro stato simultaneamente, utilizzando la stessa regola locale; questo processo viene ripetuto iterativamente nel tempo, dove gli istanti di tempo assumono valori discreti.
Dunque, gli AC sono:

* **Discreti** nello spazio e nel tempo
* **Omogenei/Uniformi** nello spazio e nel tempo, in quanto gli stati vengono aggiornati, per ogni istante di tempo, applicando la stessa regola locale a tutte le celle
* **Locali** nelle loro interazioni, in quanto l'aggiornamento di una cella dipende solo ed esclusivamente dai suoi vicini

I motivi principali dell'utilizzo di AC derivano principalmente dal fatto che molti processi in natura sono governati da regole locali ed omogenee, come ad esempio la fluido dinamica (interazione tra particelle in un reticolo regolare, dove la regola locale simula la collisione tra di esse), dunque modellabili utilizzando AC; inoltre essi risultano essere modelli matematici di calcolo parallelo: le semplici regole locali d'aggiornamento li rende computazionalmente universali ([Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life)).

## Automi cellulari

Siano $A, B$ due insiemi, indichiamo con $B^A$ l'insieme di tutte le funzioni dall'insieme $A$ nell'insieme $B$, ovvero $B^A=\{f|f:A \rightarrow B\}$, la cui cardinalità si ricorda essere $|B^A|=|B|^{|A|}$, poiché ogni $a \in A$ posso mapparlo in uno dei $|B|$ elementi di $B$, dunque avrei $|B|\cdot|B|\cdot|B|\cdot...\cdot|B|$, $|A|$ volte.
Essendo gli AC discreti nello spazio e nel tempo, le funzioni che andremo a considerare saranno del tipo $A^{\mathbb{Z}^k} = \{f|f:\mathbb{Z}^k \rightarrow A,\ k \in \mathbb{N},\ k \ge 1\}$, dove $A$ è un insieme finito di simboli, rappresentanti i possibili **stati** dell'AC; dunque un elemento $x \in A^{\mathbb{Z}^k}$, che assegna ad ogni "posizione" di $\mathbb{Z}^k$ uno stato $a \in A$ è detto **configurazione**. Una configurazione può essere vista come uno *snapshot* di tutti gli stati delle celle del sistema ad un certo tempo $t$.
La nostra trattazione verterà principalmente su AC 1- e 2-dimensionali, ovvero tali per cui $1 \le k \in \mathbb{N} \le 2$: in questi casi una configurazione può essere vista come una stringa bi-infinita $(...\ a_{-i}\ a_{-i+1}\ a_{-i+2}\ ...\ a_{-2}\ a_{-1}\ a_{0}\ a_{1}\ a_{2}\ ...\ a_{i-2}\ a_{i-1}\ a_{i}\ ...)$, dove $a_i \in A$ rappresenta lo stato assunto dalla cella $i$, $\forall i \in \mathbb{Z}$, nel caso 1-dimensionale, o come una matrice bi-infinita nel caso 2-dimensionale.
Definiamo ora il concetto di **distanza**.
> Dati $x,y \in A^{\mathbb{Z}^k}$ si definisce distanza la funzione $d(x,y):A \times A \rightarrow \mathbb{R}_+$, tale che $$ d(x,y) = \begin{cases} 0\ \ \ \ \ \text{se}\ x = y \\ \frac{1}{2^n}\ \ \ \text{se}\ x \neq y \end{cases} $$ dove $n = \text{min}\{i \in \mathbb{N}|x_i \neq y_i \lor x_{-i} \neq y_{-i}\}$