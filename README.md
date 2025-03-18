# 🛰️ PHMAP_23 MATLAB Project

Questo progetto è stato sviluppato per la challenge **PHMAP Asia Pacific 2023** e concerne lo sviluppo di un modulo di diagnosi di guasti nei sistemi di propulsione.

Gli obiettivi di questo progetto sono:  
1. **Rilevare anomalie** nei dati di test, distinguendo tra normali e anomali.  
2. **Classificare il tipo di guasto** per i dati anomali, identificando se è dovuto a contaminazione da bolle, guasto alla valvola solenoide o guasto sconosciuto.  
3. **Localizzare la posizione della bolla** nei casi di contaminazione, assegnandola a una delle otto possibili posizioni (BV1, BP1-BP7).  
4. **Identificare la valvola solenoide guasta** tra le quattro disponibili (SV1-SV4) nei casi di guasto alla valvola.  
5. **Predire la percentuale di apertura della valvola guasta**, fornendo un valore compreso tra 0% e 100%.

Il codice è organizzato in una pipeline sequenziale che elabora i dati passo dopo passo.

## 📚 Contesto Accademico

Il progetto è stato realizzato dagli studenti del **corso di Manutenzione Preventiva per la Robotica e l'Automazione Intelligente** dell’**Università Politecnica delle Marche** (Laurea Magistrale in Ingegneria Informatica e dell'Automazione, secondo anno), sotto la supervisione del **Prof. Alessandro Freddi**.

---

## 📂 Struttura del Progetto

Il repository è organizzato come segue:

```
📦 PHMAP_23_Project
 ┣ 📂 dataset/             # Contiene i dati di input necessari per il training e il test
 ┃ ┣ 📂 test/               # Contiene i dati relativi ai Case di test
 ┃ ┃ ┣ 📂 data/            # Contiene i dati grezzi dei Case di test (numerati da 178 a 223)
 ┃ ┃ ┣ 📜 answer.csv       # File con le etichette corrette per il test set (ground truth)
 ┃ ┃ ┣ 📜 label_spacecraft.xlsx # File Excel con informazioni aggiuntive sulle etichette del test set
 ┃ ┣ 📂 train/             # Contiene i dati relativi ai Case di training
 ┃ ┃ ┣ 📂 data/            # Contiene i dati grezzi dei Case di training (numerati da 1 a 177)
 ┃ ┃ ┣ 📜 label.xlsx       # File Excel con le etichette dei dati di training
 ┃ ┣ 📜 readme.pdf         # Documento con informazioni dettagliate sul dataset
 ┃ ┣ 📜 submission.csv     # File per la sottomissione dei risultati del modello
 ┣ 📂 resources/           # File di supporto
 ┣ 📂 scripts/             # Script principali e di supporto
 ┃ ┣ 📜 all_tasks.m        # Script principale che esegue l'intera pipeline
 ┃ ┣ 📜 import_data.m      # Script per l'importazione dei dati
 ┃ ┣ 📜 test_set.m         # Definizione del test set
 ┣ 📂 task1/               # Task 1: Rilevamento guasti
 ┃ ┃ ┣ 📂 results/         
 ┣ 📂 task2/               # Task 2: Classificazione guasti
 ┃ ┣ 📂 1st classifier/
 ┃ ┃ ┣ 📂 results/         
 ┃ ┃ ┣ 📜 task2_1st.m      # Script per il primo classificatore
 ┃ ┣ 📂 2nd classifier/
 ┃ ┃ ┣ 📂 results/         
 ┃ ┃ ┣ 📜 task2_2nd.m      # Script per il secondo classificatore
 ┣ 📂 task3/               # Task 3: Localizzazione guasto
 ┃ ┣ 📂 results/
 ┃ ┃ ┣ 📜 all_models_second_try.mat   # Modelli testati nella seconda iterazione
 ┃ ┃ ┣ 📜 SubspaceKNN.mat             # Modello finale basato su Subspace KNN
 ┃ ┃ ┣ 📜 accuracy_task3.m            # Script per calcolare l'accuratezza del modello
 ┃ ┃ ┣ 📜 feature_gen_t3.m            # Script di generazione delle feature
 ┃ ┃ ┣ 📜 feature_gen_t3.mat          # Feature generate salvate in formato .mat
 ┃ ┣ 📜 task3.m                       # Script principale per l'esecuzione del Task 3
 ┣ 📂 task4/                   # Task 4: Identificazione della valvola guasta
 ┃ ┣ 📂 results/            
 ┃ ┃ ┣ 📜 baggedTrees_t4.mat   # Modello finale basato su Bagged Trees
 ┃ ┃ ┣ 📜 accuracy_task4.m     # Script per calcolare l'accuratezza del modello
 ┃ ┃ ┣ 📜 prova_t4.m           # Script di test aggiuntivo
 ┃ ┃ ┣ 📜 prova_t4.mat         # Risultati salvati in formato .mat
 ┃ ┣ 📜 task4.m                # Script principale per l'esecuzione del Task 4
 ┣ 📂 task5/                   # Task 5: Stima della percentuale di apertura
 ┃ ┣ 📂 results/
 ┃ ┃ ┣ 📜 baggedTrees_t5.mat   # Modello finale basato su Bagged Trees
 ┃ ┃ ┣ 📜 feature_gen_t5.m     # Script di generazione delle feature
 ┃ ┃ ┣ 📜 feature_gen_t5.mat   # Feature generate salvate in formato .mat
 ┃ ┃ ┣ 📜 rmse_mae_task5.m     # Script per calcolare RMSE e MAE del modello
 ┃ ┣ 📜 task5.m                # Script principale per l'esecuzione del Task 5
 ┗ 📜 PHMAP_23.prj         # File di progetto MATLAB
```

---

## 🔧 Requisiti di Sistema
Per eseguire correttamente il progetto, è necessario avere MATLAB e i seguenti toolbox installati:

1. **MATLAB R2023a** o successivo (ambiente di sviluppo)
2. **MATLAB Test** (per test e validazione)
3. **Parallel Computing Toolbox** (per elaborazioni parallele e accelerazione del calcolo)
4. **Statistics and Machine Learning Toolbox** (per la classificazione e l'analisi statistica)
5. **Deep Learning Toolbox** (per modelli basati su reti neurali)
6. **Curve Fitting Toolbox** (per il fitting dei dati)
7. **Text Analytics Toolbox** (per l'analisi di testi, se applicabile)
8. **Predictive Maintenance Toolbox** (per l'analisi predittiva dei guasti)
9. **Signal Processing Toolbox** (per l'elaborazione di segnali)
10. **Wavelet Toolbox** (per la trasformata wavelet e analisi di segnali)
11. **Audio Toolbox** (per l'analisi di segnali audio, se applicabile)
12. **DSP System Toolbox** (per l'elaborazione digitale dei segnali)
13. **System Identification Toolbox** (per la modellazione di sistemi dinamici)
14. **Econometrics Toolbox** (per l'analisi econometrica, se necessaria)
15. **Symbolic Math Toolbox** (per il calcolo simbolico)
16. **Optimization Toolbox** (per la risoluzione di problemi di ottimizzazione)
17. **Global Optimization Toolbox** (per ottimizzazioni su larga scala)

Assicurati di averli installati per evitare errori durante l'esecuzione del codice.

---

## 🚀 Esecuzione del Progetto

Per eseguire il progetto, è necessario MATLAB con i toolbox richiesti. Segui questi passaggi:

### **1️⃣ Installazione di MATLAB**
- Se non hai MATLAB installato, scaricalo dal sito ufficiale di **[MathWorks](https://www.mathworks.com/downloads.html)**.
- Segui le istruzioni per l'installazione e attiva la licenza.

### **2️⃣ Verifica della presenza dei toolbox necessari**
Il progetto richiede alcuni toolbox specifici. Per verificare se sono installati, esegui il seguente comando nella Command Window di MATLAB:

```matlab
ver
```

Se un toolbox richiesto manca, installalo aprendo **MATLAB Add-On Explorer** e cercando il nome del toolbox.

### **3️⃣ Clonare o Scaricare il Repository**
Puoi ottenere il codice in due modi:
- **Scaricare il repository come file ZIP**:  
  1. Vai alla pagina GitHub del progetto.
  2. Clicca su **Code > Download ZIP** e estrai il contenuto.
  3. Apri MATLAB e naviga nella cartella estratta.

- **Clonare il repository con Git** (consigliato se lavori con versioni aggiornate):  
  Apri un terminale o il Command Window di MATLAB e usa:
  
  ```bash
  git clone https://github.com/tuo-username/PHMAP_23_Project.git
  cd PHMAP_23_Project
  ```

### **4️⃣ Eseguire il progetto**
Dopo aver aperto MATLAB e impostato la cartella del progetto come directory di lavoro, esegui il file principale:

```matlab
all_tasks;
```

Lo script `all_tasks.m` eseguirà automaticamente i seguenti passaggi:

### **Dettaglio delle operazioni**
1. **Importazione dati** → `import_data.m`
2. **Esecuzione sequenziale dei task**:
   - **Task 1** → Rilevamento guasti (`task1.m`)
   - **Task 2**:
     - Primo classificatore → `task2_1st.m`
     - Secondo classificatore → `task2_2nd.m`
   - **Task 3** → Localizzazione del guasto (`task3.m`)
   - **Task 4** → Identificazione della valvola guasta (`task4.m`)
   - **Task 5** → Stima dell'apertura della valvola (`task5.m`)
3. **Valutazione delle prestazioni**:
   - **Task 1** → `accuracy_task1.m`
   - **Task 2 - 1st Classifier** → `accuracy_task2_1st.m`
   - **Task 2 - 2nd Classifier** → `accuracy_task2_2nd.m`
   - **Task 3** → `accuracy_task3.m`
   - **Task 4** → `accuracy_task4.m`
   - **Task 5** → `rmse_mae_task5.m`

Se desideri eseguire un task specifico senza avviare l'intero flusso, puoi lanciare direttamente il relativo script. Ad esempio, in relazione al task 3:
```matlab
task3;
```

Per rieseguire solo il calcolo delle metriche di un task:

```matlab
accuracy_task3;
```

---

## 📊 Risultati e Output

Le metriche di valutazione principali sono:  

- **Task 1-4**: Accuratezza dei classificatori.  
- **Task 5**: Errori di regressione:  
  - **RMSE (Root Mean Square Error)**: Valore medio quadratico dell'errore.  
  - **MAE (Mean Absolute Error)**: Errore medio assoluto della predizione.  

I risultati finali sono accessibili eseguendo i seguenti script MATLAB, che calcolano e visualizzano le metriche di accuratezza per ciascun task:  

```matlab
accuracy_task1;
accuracy_task2_1st;
accuracy_task2_2nd;
accuracy_task3;
accuracy_task4;
rmse_mae_task5;
```

Questi script possono essere lanciati singolarmente per ottenere i risultati relativi ai rispettivi task.

---


## 📎 Risorse e Riferimenti

Per ulteriori informazioni sulla competizione PHMAP 2023, visita il sito ufficiale:

🔗 [PHMAP Asia Pacific 2023 - Program Data](https://phmap.jp/program-data/)

---

## ✍🏼 Autori del progetto
- Diego Santarelli (Matricola: 1118746)
- Simone Recinelli (Matricola: 1118757)
- Andrea Marini (Matricola: 1118778)

---

## 📌 Licenza

Questo progetto è distribuito sotto la licenza MIT. Puoi utilizzarlo, modificarlo e ridistribuirlo liberamente, a condizione di includere il testo della licenza originale.  

