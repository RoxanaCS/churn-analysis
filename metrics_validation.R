library(caret)
library(ROCR)
library(caret)
library(ROCR)

metrics_class <- function(y_pred, y_ref) {
  
  # Convertir probabilidades a clases
  y_pred_class = as.factor(ifelse(y_pred > 0.5, 1, 0))
  
  # Matriz de confusión
  conf <- confusionMatrix(y_pred_class, y_ref)
  
  # Imprimir matriz de confusión
  print("MATRIZ DE CONFUSIÓN")
  print(conf$table)
  print("")
  
  # Curva ROC
  roc_pred <- prediction(y_pred, y_ref)
  roc_perf <- performance(roc_pred, measure = "tpr", x.measure = "fpr")
  
  # Graficar la curva ROC
  plot(roc_perf,
       colorize = TRUE,
       text.adj = c(-0.2, 1.7),
       print.cutoffs.at = seq(0, 1, 0.1))
  abline(a = 0, b = 1, col = "brown")
  
  # Obtener el área bajo la curva 
  auc = performance(roc_pred, measure = "auc")
  auc = auc@y.values[[1]]
  
  # Extraer métricas para la clase 1
  TP <- conf$table[2, 2]  # True Positives
  FN <- conf$table[1, 2]  # False Negatives
  FP <- conf$table[2, 1]  # False Positives
  
  # Calcular Recall, Precision y F1 Score
  recall <- TP / (TP + FN)
  precision <- TP / (TP + FP)
  f1_score <- 2 * (precision * recall) / (precision + recall)
  
  # Métricas de desempeño
  metrics <- data.frame(
    Accuracy = conf$overall["Accuracy"],
    Balanced_Accuracy = conf$byClass["Balanced Accuracy"],
    Precision = precision,
    Recall = recall,
    F1 = f1_score,
    ROC = auc
  )
  
  return(metrics)
}

