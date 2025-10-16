## Lectura de librerias ----
source("lectura-dependencias.R")
source("metrics_validation.R")

## Carga de los datos ----
churn_data <- read.csv("churn-analysis.csv",sep=";")

## Análisis exploratorio ----
churn_data %>% head

###Cambiar de carácter a factor ----
churn_data <- churn_data %>%
  mutate_if(is.character,
            as.factor)

churn_data$area.code <- as.factor(churn_data$area.code)

### Principales métricas ----
churn_data %>% summary() 

### Análisis de state y area.code

churn_data %>% group_by(state) %>% 
               summarise(n=n(), porcentaje=n/nrow(churn_data)*100) %>% 
               arrange(-n) 

churn_data %>% group_by(area.code) %>% 
  summarise(n=n(), porcentaje=n/nrow(churn_data)*100) %>% 
  arrange(-n)


### Descarte de variables sin interés
churn_data <- churn_data %>% select(-c(state, phone.number))

### Transformación de las variables numéricas ----
X <- churn_data %>% mutate_if(is.numeric,scale)

### Gráficos de las variables numéricas ----

#### Set de datos solo para churn True
data_churn_true <- X %>% filter(churn == "True")  %>%
  select(-c(area.code,international.plan,voice.mail.plan, churn)) %>%
  pivot_longer(cols = number.vmail.messages:customer.service.calls, names_to = "variable", values_to = "value")

#### Set de datos solo para churn False
data_churn_false <- X %>% filter(churn == "False")  %>%
  select(-c(area.code, international.plan,voice.mail.plan, churn)) %>%
  pivot_longer(cols = number.vmail.messages:customer.service.calls, names_to = "variable", values_to = "value")

#### Set de datos completo
data_long <- X %>% select(-c(area.code, international.plan,voice.mail.plan, churn)) %>%
  pivot_longer(cols = number.vmail.messages:customer.service.calls, names_to = "variable", values_to = "value")

#### Histogramas ----
ggplot(data_long, aes(x = value)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "black", alpha = 0.7) +
  facet_wrap(~ variable, scales = "free") +  # Configura 3 columnas
  theme_minimal() +
  labs(y = "Frecuencia")

#### Boxplots ----

#### Categoria churn true
ggplot(data_churn_true , aes(x = variable, y = value)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#### Categoria churn false
ggplot(data_churn_false, aes(x = variable, y = value)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


#### Variables categoricas ----

#### Gráfico 1: international.plan
p1 <- ggplot(churn_data, aes(x = international.plan, fill = factor(churn))) +
  geom_bar(position = "dodge", show.legend = FALSE) +
  labs(x = "international.plan", y = "Frecuencia") +
  scale_fill_manual(values = c("steelblue", "red"), labels = c("False", "True")) +  
  theme_minimal()

#### Gráfico 2: voice.mail.plan 
p2 <- ggplot(churn_data, aes(x = voice.mail.plan, fill = factor(churn))) +
  geom_bar(position = "dodge", show.legend = FALSE) +  
  labs(x = "voice.mail.plan", y = "Frecuencia") +
  scale_fill_manual(values = c("steelblue", "red"), labels = c("False", "True")) +
  theme_minimal()

#### Gráfico 2: voice.mail.plan sin leyenda
p3 <- ggplot(churn_data, aes(x = area.code, fill = factor(churn))) +
  geom_bar(position = "dodge") +  
  labs(x = "area.code", y = "Frecuencia") +
  scale_fill_manual(values = c("steelblue", "red"), labels = c("False", "True")) +
  theme_minimal()

#### Combinar los gráficos
grid.arrange(p1, p2, p3, ncol = 3)

### Revisar datos nulos ----
sum(is.na(churn_data))

## Transformación de variables ----

churn_data <- churn_data %>%
  mutate(y = as.factor(ifelse(churn == "True", 1, 0)),
         vmail.messages = as.factor(case_when(number.vmail.messages>0~1,
                                                 TRUE ~0))) %>% 
  select(-c(churn, number.vmail.messages))

churn_data %>% summary()

churn_data <- churn_data %>% select(-c(vmail.messages))

### Fijar la semilla para reproducibilidad
set.seed(123)

## Separación del conjunto de entrenamiento y prueba ----

muestra <- sample(nrow(churn_data),nrow(churn_data)*.25)
train <- churn_data[-muestra,]
test  <- churn_data[muestra,]

### Verificación de distribución de conjunto de entrenamiento y prueba ----
train %>% group_by(y) %>% 
  summarise(n=n(),
            porcentaje = (n/nrow(train))*100)

test %>% group_by(y) %>% 
  summarise(n=n(),
            porcentaje = (n/nrow(test))*100)

## Modelo Random forest ----

### Estimar mtry inicial
sqrt(16)

### Entrenamiento ----
modelo = randomForest(y ~ .,
                      data = train,
                      mtry=4,
                      ntree=100,
                      maxnodes=20,
                      sampsize=63,
                      importance=TRUE)


### Gráfica del modelo ----
plot(modelo)

### Importancia de las variables
importancia_pred <- as.data.frame(importance(modelo, scale = TRUE))
importancia_pred <- rownames_to_column(importancia_pred, var = "variable")

p1 <- ggplot(data = importancia_pred, aes(x = reorder(variable, `MeanDecreaseGini`),
                                          y = `MeanDecreaseGini`,
                                          fill = `MeanDecreaseGini`)) +
  labs(x = "variable", title = "Mean Decrease Gini") +
  geom_col() +
  coord_flip() +
  theme_bw() +
  theme(legend.position = "bottom")
p1


### Predicciones rf----

predicciones <- predict(modelo, newdata=test,type="prob")[,2]

metrics_class(y_pred=predicciones,y_ref=test$y)


### Eliminación de variables menos importantes segun el modelo ----
churn_data_2 <- churn_data %>%
  select(-c( area.code, voice.mail.plan))

## Separación del conjunto de entrenamiento y prueba 

muestra2 <- sample(nrow(churn_data_2),nrow(churn_data_2)*.25)
train2 <- churn_data_2[-muestra,]
test2  <- churn_data_2[muestra,]

## Verificación de distribución de conjunto de entrenamiento y prueba
train2 %>% group_by(y) %>% 
  summarise(n=n(),
            porcentaje = (n/nrow(train))*100)

test2 %>% group_by(y) %>% 
  summarise(n=n(),
            porcentaje = (n/nrow(test))*100)

### Tuning de hiperparametros ----

#### Definir rangos para los hiperparámetros
mtry_values <- c(2, 4, 6)        
ntree_values <- c(50, 100, 150)   
maxnodes_values <- c(15, 20, 25)  

#### Crear un data frame vacío para almacenar resultados
results <- data.frame(mtry = integer(),
                      ntree = integer(),
                      maxnodes = integer(),
                      accuracy = numeric())

for (mtry in mtry_values) {
  for (ntree in ntree_values) {
    for (maxnodes in maxnodes_values) {
      
      # Entrenar el modelo
      modelo_3 <- randomForest(
        y ~ .,
        data = train2,
        mtry = mtry,
        ntree = ntree,
        maxnodes = maxnodes,
        sampsize = 63,
        importance = TRUE
      )
      
      # Evaluar accuracy en el conjunto de prueba
      pred_3 <- predict(modelo_3, test2)
      accuracy <- sum(pred_3 == test2$y) / nrow(test2)
      
      # Guardar los resultados
      results <- rbind(results, data.frame(mtry = mtry, ntree = ntree, maxnodes = maxnodes, accuracy = accuracy))
    }
  }
}

#### Ver los resultados y seleccionar la mejor combinación
best_params <- results[which.max(results$accuracy), ]
print(best_params)

### Modelo utlizando los mejores parametros ----
modelo_4 = randomForest(y ~ .,
                      data = train2,
                      mtry=6,
                      ntree=50,
                      maxnodes=15,
                      sampsize=63,
                      importance=TRUE)

predicciones4 <- predict(modelo_4, newdata=test2,type="prob")[,2]

metrics_class(y_pred=predicciones4,y_ref=test2$y)


## Modelo árbol de decisión ----

### Entrenamiento ----
arbol_modelo = rpart(y ~ .,
                  method="class",
                  control = list(cp=0.001))
rpart.plot(arbol_modelo,cex=0.5)

### Importancia de las variables ----
importancia <- as.data.frame(arbol_modelo$variable.importance)
importancia$variable <- rownames(importancia)  
colnames(importancia) <- c("importance_metric", "variable")

#### Visualizar la importancia de las variables
imp_1 <- ggplot(data = importancia, aes(x = reorder(variable, importance_metric), 
                                        y = importance_metric, 
                                        fill = importance_metric)) + 
  labs(x = "Variable", title = "Importancia de las Variables") +
  geom_col() +
  coord_flip() +
  theme_bw() +
  theme(legend.position = "bottom")

#### Mostrar el gráfico
print(imp_1)

### Predicciones y métricas ----
pred_arbol <- predict(arbol_modelo, newdata=test,type="prob")[,2]

metrics_class(y_pred=pred_arbol,y_ref=test$y)

### Guardado del modelo ----
saveRDS(arbol_modelo,file = "arbol_decision_v1.RDS")

### Modelo árbol con poda ----

arbol_modelo_poda <- rpart(y~.,
                    data=train,
                    method="class",
                    parms=list(split="information"),
                    control = rpart.control(cp=0.0000001,
                                            minsplit = 5,
                                            maxdepth = 30))

## Parametro de control
arbol_modelo_poda$cptable

## Parámetros de control
arbol_modelo_poda$control

## predicciones y métricas
pred_arbol_poda <- predict(arbol_modelo_poda, newdata=test,type="prob")[,2]
metrics_class(y_pred=pred_arbol_poda,y_ref=test$y)

### Selección del parámetro de costo óptimo (CP)
cp_opt <- arbol_modelo_poda$cptable[which.min(arbol_modelo_poda$cptable[,"xerror"]),"CP"]

### Poda del arbol ----
model_prune <- prune(arbol_modelo_poda,cp=cp_opt)
rpart.plot(model_prune,cex=0.6)

### Predicciones y métricas ----
pred_model_prune = predict(object = model_prune,
               newdata = test,
               type="prob")[,2]

metrics_class(y_pred=pred_model_prune,y_ref=test$y)

### Guardado del modelo ----
saveRDS(model_prune,file = "arbol_decision_v2.RDS")



