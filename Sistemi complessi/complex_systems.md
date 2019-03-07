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
Definiamo ora il concetto di **distanza** nel caso di AC 1-dimensionali.

> Dati $x,y \in A^{\mathbb{Z}}$ si definisce distanza la funzione $d(x,y):A^{\mathbb{Z}} \times A^{\mathbb{Z}} \rightarrow \mathbb{R}_+$ tale che $$ d(x,y) = \begin{cases} 0\ \ \ \ \ \text{se}\ x = y \\ \frac{1}{2^n}\ \ \ \text{se}\ x \ne y \end{cases} $$ dove $n = \text{min}\{i \in \mathbb{N}|x_i \ne y_i \lor x_{-i} \ne y_{-i}\}$

Si può dimostrare che tale funzione è una [metrica](https://en.wikipedia.org/wiki/Metric_(mathematics)).
Ad esempio, sia A = {0, 1}. Siano $x,y \in A^{\mathbb{Z}}$ tali che:

* $x = (...\ 1_{-3}\ 1_{-2}\ 0_{-1}\ 1_0\ 1_1\ 0_2\ 1_3\ ...)$
* $y = (...\ 0_{-3}\ 1_{-2}\ 0_{-1}\ 1_0\ 1_1\ 0_2\ 1_3\ ...)$

dove al pedice sono rappresentate le posizioni delle celle, allora in questo caso $n = 3$, poiché $i = -3$ è la prima posizione (quella più piccola) in cui le due stringhe bi-infinite differiscono. 

Vale inoltre la seguente proposizione:

> $$\forall x,y \in A^{\mathbb{Z}}, \forall n \in \mathbb{N},\ d(x,y) < \frac{1}{2^n} \Longleftrightarrow x_{[-n,\ n]} = y_{[-n,\ n]}$$ dove con $a_{[-n,\ n]} \subset a \in A^{\mathbb{Z}} = (a_{-n}\ a_{-n+1}\ ...\ a_{-2}\ a_{-1}\ a_0\ a_1\ a_2\ ...\ a_{n-1}\ a_n)$ si indica la "finestra" della stringa bi-infinita $a$, di raggio $n$ e centrata nello 0.

Dimostrazione:

* $\Longrightarrow$
  Infatti se nella finestra di raggio $n$ le stringhe $x$ e $y$ fossero diverse, allora esisterebbe un $m \in \mathbb{N}, m < n : x_{-m} \ne y_{-m} \lor x_m \ne y_m$. Sia $\overline{m}$ il più piccolo tra essi, allora $d(x,y) = \frac{1}{2^{\overline{m}}} > \frac{1}{2^n}$, assurdo.
* $\Longleftarrow$
  Infatti $x_{[-n,\ n]} = y_{[-n,\ n]} \Longrightarrow \exists m \in \mathbb{N}, m > n : x_{-m} \ne y_{-m} \lor x_m \ne y_m$. Sia $\overline{m}$ il più piccolo tra essi, allora $d(x,y) = \frac{1}{2^{\overline{m}}} < \frac{1}{2^n}$
  Se tale $m$ non esiste allora $d(x,y) = 0 < \frac{1}{2^n}$.

>Definiamo dunque un **automa cellulare** come una tripla $\langle A, r, f\rangle$ tale che:
>
>* A è un insieme finito di simboli, rappresentanti i possibili **stati** assumibili dall'AC
>* $r \in \mathbb{N}$ è detto **raggio**
>* $f:A^{2r+1} \rightarrow A$ è detta **regola locale**, che definisce l'aggiornamento di stato locale di una cella sulla base del suo "vicinato"
>
>Dunque il numero massimo di AC differenti è $|A|^{|A^{2r+1}|}$

Una regola locale può essere fornita in forma tabellare (si pensi ad una funzione di transizione di un automa a stati finiti o di una macchina di Turing), ad esempio:

* A = {0, 1}
* r = 1
* $f:A^3 \rightarrow A$ così definita:
    | a | b | c | $f$ |
    |---|---|---|---|
    | 0 | 0 | 0 | 0 |
    | 0 | 0 | 1 | 0 |
    | 0 | 1 | 0 | 0 |
    | 0 | 1 | 1 | 1 |
    | 1 | 0 | 0 | 1 |
    | 1 | 0 | 1 | 1 |
    | 1 | 1 | 0 | 0 |
    | 1 | 1 | 1 | 1 |

Se $A = \{0, 1, 2, ..., n\} \subset \mathbb{N}$ e $A$ è finito, questa stessa regola locale può essere invece fornita come la conversione in base $|A|$ dell'ultima colonna di tale tabella, con la cifra più significativa in ultima posizione. In questo caso avremo: $0 \cdot 2^0 + 0 \cdot 2^1 + 0 \cdot 2^2 + 1 \cdot 2^3 + 1 \cdot 2^4 + 1 \cdot 2^5 + 0 \cdot 2^6 + 1 \cdot 2^7$