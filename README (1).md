# Practica_creativa_IBDN_ Lucía_Martínez__Gabriela_Curto
A continuación mostramos las indicaciones seguidas para la realización de la práctica. La práctica se dividirá en tres escenarios principales, el primero, donde nos limitamos a seguir los pasos propuestos en el GitHub proporcionado, la ejecución del Job de predicción con Spark-Submit, y el apartado opcional de entrenar el modelo propuesto con Apache Airflow.

En el segundo escenario pasaremos a Dockerizar cada uno de los servicios, Mongo, Kafka, Zookeper, Spark y el web server. Para ello, diseñamos un dichero docker-compose para crear las imagenes correspondientes a cada contenedor. Adicionalmente, los contenedores de Mongo y Webserver los creamos mediante un fichero Dockerfile al que luego referenciaremos en el fichero docker compose. Una vez tenemos el escenario completamente dockerizado, y comprobado que se hace correctamente, pasamos a desplegar este mismo escenario completo en la plataforma Google Cloud.

El tercer escenario es el correspondiente a Kubernetes, se nos pide ahora desplegar de nuevo el escenario completo pero en este caso usando Kubernetes.


# Prediccion de vuelos
El objetivo de este proyecto es implementar un sistema que permite realizar predicciones de retraso de vuelos. Dicho sistema de predicción está formado por una serie de módulos los cuales permiten realizar predicciones analíticas y en tiempo real a partir de una serie de trazas y así poder mostrar el retraso del correspondiente vuelo. 
Básicamente el sistema funciona de la siguiente manera:

- Se descarga el dataset de los datos relacionados con los vuelos con información  para  entrenar el modelo y predecir los retrasos.
- Se entrena el modelo de Machine Learning a partir del dataset.
- Se despliega el job de predicción de retrasos de los vuelos Spark, que  las predicciones mediante el modelo creado
- Se introducen los datos del vuelo a predecir en el frontal web y se envían al servidor web de Flask por medio de la cola de mensajería Kafka especificando el tópic.
- Se entrena el modelo predictivo empleando el algoritmo RandomForest con los datos obtenidos.
- El job de Spark en el servidor realiza la predicción de los retrasos de los vuelos por medio de los datos del tópic al que se encuentra suscrito de Kafka.
- La ejecución del job se realiza por medio del fichero jar para Scala generado por medio de spark-submit.
- Se guardan las predicciones en la base de datos de Mongo.
- Se realiza la consulta de los resultados de la predicción a través del uso de polling que flask realiza sobre Mongo y se se muestran en el servidor web.


# Pasos seguidos para el funcionamiento de la práctica
1.	Clonamos el repositorio:
```
git clone https://github.com/Big-Data-ETSIT/practica_creativa.git
```

2. Descargamos los datos:
```
resources/download_data.sh
```
3. Instalamos todos los componentes incluidos en la arquitectura de la práctica

4. Creamos y usamos el entorno de Python:
```
python3 -m venv env
source env/bin/activate
```
5. Instalamos librerías necesarias
```
pip install -r requirements.txt
```
6. Abrimos la consola y vamos al directorio de descarga de Kafka y ejecutamos el siguiente comando para iniciar Zookeeper:
```
bin/zookeeper-server-start.sh config/zookeeper.properties
```
 7. Después, en otra terminal, volvemos a acceder al directorio de descarga y ejecutamos el siguiente comando para iniciar Kafka:
```
bin/kafka-server-start.sh config/server.properties
```

8. En este mismo directorio, creamos un nuevo topic mediante:
```
bin/kafka-topics.sh \
      --create \
      --bootstrap-server localhost:9092 \
      --replication-factor 1 \
      --partitions 1 \
      --topic flight_delay_classification_request
 ```    
 
 Y obtenemos el resultado esperado:

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/1a25ec2d-4bf3-4de4-a2d0-a7bb3786ae9a)


 
También comprobamos que se ha creado correctamente el topic viendo la lista de topics disponible:

 
![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/b720e704-2b8a-43d8-9c39-0921ef421926)


Abrimos una nueva consola con un consumidor para ver los mensajes mandados a ese topic
```
bin/kafka-console-consumer.sh \
    --bootstrap-server localhost:9092 \
    --topic flight_delay_classification_request \
    --from-beginning
```


 ## Import the distance records to MongoDB
 1. Primero comprobamos que tenemos Mongo y que se está ejecutando
![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/4d193d94-e3a3-43b1-8c7d-64a7d5d31cbf)

 
 
 2. Ejecutamos el script import_distances realizando la siguiente modificación para su correcto funcionamiento
 
![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/081f6961-d7a9-4207-98ec-a5ee9bd7be71)

- Obtenemos un resultado diferente al proporcionado en github debido a la versión instalada de mongo, que en nuestro caso ha sido mongosh.
- Podemos comprobar que se importaron 4696 documentos correctamente y se crearon los índices esperados en la colección

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/8e917d0c-6d14-4ec3-bc98-e608e691dbb7)


## Train and Save de the model with PySpark mllib
1.Establecemos la variable de entorno JAVA_HOME con la ruta del directorio de instalación de Java, y establecemos la variable de entorno SPARK_HOME con la ruta con la ruta del directorio de instalación de Spark.
![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/e761d560-4090-4f34-9629-a169b93bcc7a)

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/e8904c01-08d5-4275-9759-175dad8a2e76)



2. Por último, ejecutamos el script

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/152c99e3-3359-429c-9a00-96ed67dbee83)




![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/aa04ba1a-6de0-4cb0-bd87-98e6fe08120f)



![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/3110a777-bf3c-4b7b-bbcb-c2ef505bd330)



Y comprobamos los ficheros que se han guardado en la carpeta models:

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/eef6de33-2a75-4a6a-a928-bcbb9fbe75a5)


## Run Flight Predictor con spark-submit
1.Primero debemos cambiar el valor ‘base_path’ en la clase scala MakePrediction, a la ruta donde se encuentra nuestro repositorio de clones:

Modificamos primero en la clase MakePrediction de scala:
![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/9c9a366a-4cf6-42bc-a01b-79bff834f3db)


Ejecutamos el código utilizando spark-submit.
![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/997f9d55-4258-4b80-a391-1a234bab1568)


![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/22685a44-3868-4fdd-a189-e7d804ff0598)

Adicionalmente visualizamos la consola de Kafka, iniciada previamente en apartados anteriores:
![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/81fa7558-d25a-4e0b-81f8-fa24d7420058)

## Start the prediction request Web Application

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/55054925-86fd-4570-8899-85ea3b195a34)

1. Establecemos la variable de entorno PROJECT_HOME con la ruta de nuestro repositorio clonado y vamos al directorio ‘web’ en resources y ejecutamos el archivo de aplicación web flask predict_flask.py. 
2. Visualizamos los resultados que se muestran en el navegador, para ver si se hace la predicción, y efectivamente podemos verlo
![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/b7675e2e-b3cf-4577-8b74-272d758ca464)

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/8c4f353f-1c4c-4ca9-8520-17bd01e5f6b1)

Observamos la salida de depuración en la consola JavaScript mientras el cliente realiza repetidamente consultas o solicitudes a un punto final de respuesta para obtener información actualizada.

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/3ca40b0f-9908-4ce2-9619-dc02b0668ee9)

Como información adicional, podemos visualizar abriendo una nueva consola con un consumidor para ver los mensajes enviado a a ese topic
![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/8c4d8208-43af-488c-a1a1-68a8ecf32a6f)

## Check the predictions records inserted in MongoDB
![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/b670d7f2-f4ad-47b2-b616-584364446bda)

Nuestra salida se ve de la siguiente manera:


![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/1908a318-89b6-4530-ad2f-91607261a247)

# Entrenar el modelo con Apache Airflow
1. Instalamos las depencias de Apache Airflow
```
cd resources/airflow
pip install -r requirements.txt -c constraints.txt
```

2. Establecemos la variable de entorno PROJECT_HOME a :
```
export PROJECT_HOME=/home/lucia/practica_creativa
```

3. Configuramos el entorno de Airflow
```
export AIRFLOW_HOME=/home/lucia/practica_creativa/resources/airflow
mkdir $AIRFLOW_HOME/dags
mkdir $AIRFLOW_HOME/logs
mkdir $AIRFLOW_HOME/plugins
```

4. Copiamos el DAG definido en resources/airflow/setup.py en la carpeta dags creada en el paso anterior
cp setup.py $AIRFLOW_HOME/dags

5. Iniciamos la base de datos de Airflow
```
airflow db init
airflow users create \
    --username admin \
    --firstname Jack \
    --lastname  Sparrow\
    --role Admin \
    --email example@mail.org
    --pass pass
```
6. Inicializamos también el scheduler y el servidor web
```
airflow webserver --port 9090
airflow scheduler
```
7. Por último mostramos un ejemplo de ejecución de un DAG a través de linea de comandos el DAG creado con anterioridad

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/4205ecc5-321b-4530-9a85-f3d5e8338b74)



# Dockerizar cada uno de los servicios que componen la arquitectura completa y desplegar el escenario completo usando docker-compose
Pasamos al segundo escenario de la práctica, en el que dockerizamos los servicios para su posterior despliegue en Google Cloud. 
Creamos un archivo Docker-compose con todos los contenedores asociados a los servicios que vamos a desplegar.

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/a9430f75-9d3d-4af4-8bc1-5ea17ec475df)

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/3cf8f1f1-0e15-4ed3-9aa8-182d78b14775)

Por otro lado, realizamos un dockerfile para los servicios Mongo y Webserver adicionalmente, y los referenciamos dentro del Dockerfile.
*MONGO*

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/3bccdf5f-5bda-4fc6-ac01-7c2c57ce9e6a)
*WEBSERVER*

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/33e24575-c921-44d7-a470-071fdecd1a03)

Hacemos las modificaciones en MakePrediction.scala porque las demás las automatizamos en los ficheros mencionados justo ahora.
![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/158f75f3-b746-49af-8de3-0f834d5cfc22)

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/eecc422b-d02c-4229-95cd-5a24560e8571)

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/82bbf4fe-b2b5-44c9-b312-8722ddbb3115)

También modificamos el fichero predict_flask.py (localhost cambiamos por kafka)

Accedemos al contenedor de Kafka y creamos el topic

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/2a2d6cf0-04b9-45a0-9721-2b4eb5717d7d)

Y para comprobar que se crea correctamente utilizamos:

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/fbba12ac-7e9e-499b-bbec-9560ac2b5e9c)

Para realizar la predicción mediante spark submit, y enviar las predicciones a mongo utilizamos.

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/e12ef24f-c3a7-444c-af4a-d32f00b58f75)

Y para comprobar su correcto funcionamiento accedemos al servidor que se encuentra en la ruta localhost:5001, de acuerdo con los puertos especificados en el docker-compose.

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/eab4f07c-71ce-4645-baae-d376e7191fda)

Comprobamos la información almacenada en Mongo
![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/a613920e-44e1-4804-ab55-05449af4de85)

Comprobamos también el funcionamiento de Spark
![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/cfc9f567-7b36-4aeb-a330-518fee649366)


# Desplegar el escenario completo en Google Cloud/AWS
Para desplegar el escenario completo en Google Cloud lo primero que hacemos es crear una instancia de máquina virtual en el servicio de Compute Engine

Una vez creada, desde la terminal de nuestra máquina virtual importamos el zip correspondiente a nuestros archivos.
![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/6551b8ec-5741-4b01-ab85-459af0c61747)

Y antes de desplegar el escenario debemos instalar Docker-compose.
Una vez configurado todo lo necesario, seguimos los mismos pasos que seguíamos para dockerizar nuestros servicios
![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/c7fbbe38-0fb7-44f5-b1f7-39f4e511b35d)

Realizamos el siguiente comando para establecer el puerto en el que se visualizaran los resultados en el servidor web.
![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/d2e2a1b3-823e-44c1-8665-4228d66411b5)

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/a8264e72-ec91-40e1-b7af-66044e419db7)

Comprobamos por último que se envían correctamente las predicciones a Mongo y se pueden visualizar en el servidor web.

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/59faca3e-e10c-467a-94df-47434aeabed7)


# Desplegar el escenario completo usando kubernetes

Primero tenemos que crear:
-	Un configmap.yaml: que se utiliza para almacenar la configuración y las variables de entorno que necesitan nuestros contenedores. 

-	Un deployment.yaml: el archivo de despliegue que define cómo se despliegan y se escalan nuestros contenedores en Kubernetes.

-	Un services.yaml: el archivo de servicio se utiliza para exponer nuestros contenedores dentro de Kubernetes. 

Después de crear los ficheros mencionados lo primero que debemos hacer es instalar minikube, siguiendo las indicaciones proporcionadas por la página de minikube. 
Posteriormente realizamos ```minikube start``` para empezar nuestro cluster y para poder observar el funcionamiento de nuestros deployments usaremos
 ```
minikube addons enable metrics-server
minikube dashboard
```

Ahora desplegamos creamos nuestro fichero de configuración y archivo de servicios.
```
kubectl create -f configmap.yaml
```

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/0bf1a6be-de63-4d28-87cf-b75be6b1914c)


```
kubectl create -f services.yaml
```

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/4aec54f3-0bb8-4a0b-bd38-5d301a78ca8f)


Y por último, desplegamos todos nuestros servicios mediante el archivo de despliegue.
```
kubectl apply -f deployment.yaml
```

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/0d3071c3-31b9-4598-b338-ca8d90bfc558)


Podemos visualizar que se han creado mirando nuestro panel de información de minikube. 

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/158227b6-130c-4f7f-ab30-3b862e852266)



#  Modificar el código para que el resultado de la predicción se escriba en Kafka y se presente en la aplicación 
En este apartado lo que haremos será modificar el fichero de predicción MakePrediction.scala para que envíe las predicciones a Kafka en lugar de a Mongo, para ello necesitamos modificar el fichero añadiendo una condición para que lo envíe a Kafka en lugar de a Mongo, que será referenciado a su vez en el fichero docker-compose.
La modificación se ve de la siguiente manera

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/4bf61f4a-7dc9-4baf-9ba9-c8e08e4dea9d)

También tenemos que modificar el fichero 'predict_flask.py' para que de nuevo, el servidor web extraiga la información de Kafka en lugar de Mongo, también se referenciará en el fichero docker-compose mediante una variable de entorno.

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/e1d61ed0-fc3f-46bb-8e7a-9645507bba20)

Y el fichero docker-compose por lo tanto quedaría de la siguiente manera.

![image](https://github.com/gabicurto/Practica_creativa_IBDN/assets/127130231/29ed82d1-e025-4666-9f25-d65c8c67c1ac)








