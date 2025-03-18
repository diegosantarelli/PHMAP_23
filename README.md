# PHMAP_23 MATLAB Project

Questo progetto implementa una pipeline di analisi per il rilevamento e la classificazione di guasti nei sistemi di propulsione, in linea con la challenge **PHMAP Asia Pacific 2023**. Il codice è strutturato in più task sequenziali che elaborano i dati passo dopo passo.

## 📂 Struttura del Progetto

La cartella del progetto è organizzata nel seguente modo:


📦 PHMAP_Project
 ┣ 📂 dataset/             # Contiene i dati di input
 ┣ 📂 resources/           # File aggiuntivi e supporto
 ┣ 📂 scripts/             # Script principali e di supporto
 ┃ ┣ 📜 all_tasks.m        # Script principale che esegue tutti i task
 ┃ ┣ 📜 import_data.m      # Script per importare i dati
 ┃ ┣ 📜 test_set.m         # Definizione del test set
 ┣ 📂 task1/
 ┣ 📂 task2/
 ┃ ┣ 📂 1st classifier/
 ┃ ┃ ┣ 📂 results/         # Risultati del primo classificatore
 ┃ ┃ ┣ 📜 task2_1st.m      # Script per il primo classificatore
 ┃ ┣ 📂 2nd classifier/
 ┃ ┃ ┣ 📂 results/         # Risultati del secondo classificatore
 ┃ ┃ ┣ 📜 task2_2nd.m      # Script per il secondo classificatore
 ┣ 📂 task3/
 ┣ 📂 task4/
 ┣ 📂 task5/
 ┗ 📜 PHMAP_23.prj         # File di progetto MATLAB


## 🚀 Esecuzione del Progetto

Per eseguire l'intero flusso di lavoro, apri MATLAB e lancia il seguente comando nella Command Window:

all_tasks;


### **Dettaglio delle operazioni eseguite da `all_tasks.m`**
1. **Importazione dati** → `import_data.m`
2. **Esecuzione dei task in cascata**:
   - **Task 1** → `task1.m`
   - **Task 2**:
     - Primo classificatore → `task2_1st.m`
     - Secondo classificatore → `task2_2nd.m`
   - **Task 3** → `task3.m`
   - **Task 4** → `task4.m`
   - **Task 5** → `task5.m`
3. **Valutazione delle prestazioni**:
   - **Task 1** → `accuracy_task1.m`
   - **Task 2 - 1st Classifier** → `accuracy_task2_1st.m`
   - **Task 2 - 2nd Classifier** → `accuracy_task2_2nd.m`
   - **Task 3** → `accuracy_task3.m`
   - **Task 4** → `accuracy_task4.m`
   - **Task 5** → `rmse_mae_task5.m`

---

## 📊 Output del Progetto

Dopo l'esecuzione, i risultati dei task vengono salvati nelle rispettive sottocartelle `results/` di ogni task. Questi includono metriche di accuratezza e valutazione delle prestazioni.

- **Task 1-4**: Metriche di accuratezza.
- **Task 5**: Errori di regressione (RMSE, MAE).

## ⚙️ Requisiti di Sistema

Assicurati di avere installato:
- MATLAB **R2023a** o successivo.
- Toolbox richiesti:
  - **Statistics and Machine Learning Toolbox**
  - **Signal Processing Toolbox**
  - **Deep Learning Toolbox**

## 🛠 Modifiche e Personalizzazioni

Se desideri eseguire un task specifico senza avviare l'intero flusso, puoi lanciare manualmente uno dei seguenti comandi:

```matlab
task3;
```

Se vuoi rieseguire il calcolo delle metriche senza ripetere l'elaborazione:

```matlab
accuracy_task3;
```

---

## 🤝 Contributi e Collaborazione
