## Análisis de Churn y Modelado Predictivo con Random Forest y Árboles de Decisión en R

Proyecto desarrollado como parte del **Diplomado en Ciencia de Datos e Inteligencia Artificial (PUCV, 2024)**.  
El objetivo principal es aplicar técnicas de **análisis exploratorio y modelado predictivo** para detectar clientes con alta probabilidad de abandono (*churn*) utilizando **R** y algoritmos de **machine learning supervisado**.

---

## 🎯 Objetivos del Proyecto

- Analizar el comportamiento de clientes en un servicio de telecomunicaciones.  
- Identificar patrones que expliquen el abandono del servicio.  
- Entrenar y comparar modelos predictivos (**Random Forest** y **Árbol de Decisión**) para estimar la probabilidad de churn.  
- Evaluar el rendimiento de los modelos mediante métricas de clasificación personalizadas.

---

## 🧩 Dataset

- **Archivo:** `churn-analysis.csv`  
- **Descripción:** datos simulados de clientes, incluyendo variables de uso, planes contratados y comportamiento histórico.  
- **Tamaño:** 3,333 registros (aprox.), 21 variables.  
- **Variable objetivo:** `churn` (cliente que abandona = True).

---

## ⚙️ Metodología

1. **Lectura y limpieza de datos** (`dplyr`, `tidyverse`).  
2. **Análisis exploratorio**:  
   - Estadísticos descriptivos.  
   - Gráficos de distribución e histogramas con `ggplot2`.  
3. **Transformación de variables**:  
   - Codificación de factores.  
   - Escalado de variables numéricas.  
   - Creación de variables binarias derivadas.  
4. **Modelado predictivo**:  
   - **Random Forest:** ajuste de hiperparámetros (`mtry`, `ntree`, `maxnodes`).  
   - **Árbol de Decisión:** creación, poda y visualización con `rpart` y `rpart.plot`.  
5. **Evaluación de modelos:**  
   - Métricas de validación personalizadas (`metrics_class`): accuracy, recall, precision, ROC-AUC.  
   - Comparación de desempeño y análisis de importancia de variables.

---

## 🧰 Librerías utilizadas

```R
tidyverse
ggplot2
dplyr
rpart
rpart.plot
randomForest
gridExtra
```
---

## 📚 Licencia

Este proyecto se publica con fines educativos y demostrativos.  
Los datos utilizados son simulados y no corresponden a información real de clientes.
