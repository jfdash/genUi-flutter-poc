# Analisi del flusso chat

## Obiettivo

Valutare il flusso conversazionale attuale di GenuI per capire perche la chat si comporta come un funnel di preventivo auto, quali sono i vantaggi e i limiti di questa struttura, e quale evoluzione architetturale consente di renderla piu aperta senza perdere controllo.

## AS-IS

L'app oggi e organizzata in due aree funzionali separate:

- la home, che mostra i preventivi gia salvati
- la chat, che serve a creare un nuovo preventivo auto

Questa separazione e visibile nel routing in `lib/core/router/app_router.dart`. La home carica i preventivi dal repository e li presenta come elenco o carousel in `lib/features/home/home_screen.dart`. La chat invece apre direttamente il flusso AI di preventivo auto.

All'ingresso della chat, il messaggio iniziale orienta gia l'utente verso il caso d'uso "nuovo preventivo". Quando l'utente scrive, il messaggio viene inoltrato al servizio AI senza un livello intermedio di classificazione dell'intento.

Il comportamento del modello e poi rigidamente definito dal prompt di sistema in `lib/core/service/ai_service.dart`: il modello viene descritto come assistente per preventivi auto, gli vengono indicati i widget da usare, il flusso in step e la regola piu restrittiva, cioe rispondere con lo Step 1 del form.

Il flusso e event-driven:

- il modello genera widget
- i widget emettono eventi
- l'`EventAggregator` raccoglie i dati
- il servizio AI decide se procedere allo step successivo o completare il preventivo
- il preventivo completato viene salvato nello storage

## Punti di forza

Per il caso d'uso "crea un nuovo preventivo auto", il flusso e ben costruito.

La struttura attuale offre:

- forte controllo sull'esperienza utente
- output UI coerente tramite widget vincolati
- raccolta guidata dei dati necessari
- riduzione dell'ambiguita del modello
- persistenza locale semplice e chiara
- passaggio naturale da raccolta dati a conferma finale

Dal punto di vista ingegneristico, il sistema e piu vicino a un workflow engine con componente generativa che a una chat libera. Per un funnel assicurativo questo e un vantaggio: il modello e contenuto dentro un processo prevedibile.

## Limiti strutturali

Il problema emerge quando la chat viene interpretata dall'utente come un punto d'accesso generale ai servizi assicurativi.

L'architettura attuale non distingue tra:

- richiesta informativa
- richiesta di consultazione dati esistenti
- avvio di un nuovo flusso operativo

Di conseguenza, frasi come "quali sono i miei preventivi?" o "spiegami la kasko" vengono trattate nello stesso spazio logico di "voglio fare un preventivo". Non c'e un router di intent prima del prompt del wizard.

Questo comporta:

- scarsa flessibilita conversazionale
- mismatch tra aspettativa utente e comportamento del sistema
- impossibilita di usare la chat come canale di consultazione
- eccessiva dipendenza dal prompt per decisioni che dovrebbero stare nel codice applicativo

In sintesi, la chat non e veramente aperta: e un funnel specialistico rivestito da interfaccia conversazionale.

## Valutazione architetturale

Forzare GenUI a seguire una sequenza di azioni non e di per se un errore. E corretto quando il task e chiuso, ad esempio:

- compilare un preventivo
- raccogliere campi obbligatori
- guidare l'utente in un wizard
- mantenere un formato UI vincolato

Il problema e il livello a cui questa forzatura viene applicata. Oggi la forzatura e posta all'ingresso della chat, quindi l'intera conversazione viene schiacciata su un singolo caso d'uso.

La struttura corretta dovrebbe essere:

- chat aperta a monte
- flow rigido a valle

In altre parole:

- la comprensione dell'intento deve essere ampia
- l'esecuzione del preventivo puo e deve restare strettamente guidata

## TO-BE

L'evoluzione consigliata e separare chiaramente orchestrazione ed esecuzione.

Architettura target:

- `IntentRouter`: intercetta il significato della richiesta utente
- `ChatMode`: mantiene lo stato conversazionale corrente
- `Deterministic handlers`: gestiscono intent che non richiedono generazione AI
- `QuoteFlowController`: governa il flusso del preventivo
- `GenUI`: usato solo all'interno del ramo `quoteFlow`

Esempi di intent iniziali:

- `list_quotes`
- `start_quote`
- `insurance_faq`
- `quote_details`
- `resume_quote`

Con questa struttura:

- "quali sono i miei preventivi?" legge direttamente il repository
- "voglio un nuovo preventivo" entra nel flow GenUI
- "cos'e la kasko?" usa una risposta informativa
- "fammi vedere l'ultimo preventivo" apre un dettaglio

## Principi guida

Le decisioni ad alta affidabilita devono restare nel codice applicativo:

- routing degli intent
- accesso ai dati
- navigation
- gestione dello stato
- policy di business

La parte generativa deve essere confinata dove aggiunge valore:

- rendering di widget
- conduzione del wizard
- formulazione di microcopy contestuale
- adattamento del flusso dentro limiti controllati

Questo riduce il rischio e rende il comportamento piu spiegabile.

## Rischi dell'AS-IS

I principali rischi se il flusso resta invariato sono:

- utenti che percepiscono la chat come limitata su richieste semplici
- aumento della frizione su task non legati alla creazione di un nuovo preventivo
- crescita difficile del prodotto verso casi d'uso multipli
- accumulo di logica conversazionale nel prompt invece che nel codice
- regressioni quando si tenta di ampliare il dominio della chat senza cambiare l'architettura

## Roadmap consigliata

1. Introdurre un `IntentRouter` semplice, inizialmente rule-based.
2. Gestire `list_quotes` direttamente via `QuoteStorageRepository`.
3. Modificare il messaggio iniziale della chat per aprire a piu azioni.
4. Rimuovere dal prompt la regola "alla prima richiesta rispondi sempre con lo Step 1".
5. Introdurre `ChatMode.general` e `ChatMode.quoteFlow`.
6. Lasciare il prompt rigido solo quando il sistema entra esplicitamente in `quoteFlow`.

## Conclusione

Il flusso attuale e valido come funnel di preventivo auto guidato, ma non e adatto a sostenere una chat assicurativa realmente aperta. La criticita non e l'uso di vincoli forti su GenUI, ma il fatto che quei vincoli siano applicati troppo presto, prima dell'identificazione dell'intento utente. La soluzione corretta e introdurre un livello di orchestrazione conversazionale e mantenere GenUI come motore controllato del singolo workflow.
