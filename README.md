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
 ┃ ┃ ┣ 📂 data/            # Contiene i dati grezzi dei Case di training
 ┃ ┃ ┣ 📜 label.xlsx       # File Excel con le etichette dei dati di training
 ┃ ┣ 📜 readme.pdf         # Documento con informazioni dettagliate sul dataset
 ┃ ┣ 📜 submission.csv     # File per la sottomissione dei risultati del modello
 ┣ 📂 resources/           # File di supporto
 ┣ 📂 scripts/             # Script principali e di supporto
 ┃ ┣ 📜 all_tasks.m        # Script principale che esegue l'intera pipeline
 ┃ ┣ 📜 import_data.m      # Script per l'importazione dei dati
 ┃ ┣ 📜 test_set.m         # Definizione del test set
 ┣ 📂 task1/
 ┃ ┃ ┣ 📂 results/             # Task 1: Rilevamento guasti
 ┣ 📂 task2/               # Task 2: Classificazione guasti
 ┃ ┣ 📂 1st classifier/
 ┃ ┃ ┣ 📂 results/         # Risultati del primo classificatore
 ┃ ┃ ┣ 📜 task2_1st.m      # Script per il primo classificatore
 ┃ ┣ 📂 2nd classifier/
 ┃ ┃ ┣ 📂 results/         # Risultati del secondo classificatore
 ┃ ┃ ┣ 📜 task2_2nd.m      # Script per il secondo classificatore
 ┣ 📂 task3/
 ┃ ┃ ┣ 📂 results/              # Task 3: Localizzazione guasto
 ┣ 📂 task4/
 ┃ ┃ ┣ 📂 results/             # Task 4: Identificazione della valvola guasta
 ┣ 📂 task5/
 ┃ ┃ ┣ 📂 results/            # Task 5: Stima della percentuale di apertura
 ┗ 📜 PHMAP_23.prj         # File di progetto MATLAB
```

---

## 🚀 Esecuzione del Progetto

Per avviare l'intera pipeline di analisi, apri MATLAB e lancia il seguente comando:

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

## 🔧 Requisiti di Sistema
Per eseguire correttamente il progetto, è necessario avere MATLAB e i seguenti toolbox installati:

1. **MATLAB R2023a**o successivo (ambiente di sviluppo)
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

Se necessario, i toolbox possono essere verificati con il comando:

```matlab
ver
```

Assicurati di averli installati per evitare errori durante l'esecuzione del codice. Se alcuni toolbox non sono disponibili, contatta l'amministratore del sistema o verifica la licenza MATLAB.

---

## 🛠 Personalizzazione e Debug

Se desideri eseguire un task specifico senza avviare l'intero flusso, puoi lanciare direttamente il relativo script:
```matlab
task3;
```

Per rieseguire solo il calcolo delle metriche di un task:

```matlab
accuracy_task3;
```

Se incontri errori o problemi di esecuzione, verifica che tutti i file necessari siano presenti e che MATLAB abbia accesso ai dataset.

---

## 📎 Risorse e Riferimenti

Per ulteriori informazioni sulla competizione PHMAP 2023, visita il sito ufficiale:

🔗 [PHMAP Asia Pacific 2023 - Program Data](https://phmap.jp/program-data/)


---

## ✍🏼 Autori del progetto
- Diego Santarelli (Matricola: 1118746)
- Simone Recinelli (Matricola: 1118757)
- Andrea Marini (Matricola: 1118778)
