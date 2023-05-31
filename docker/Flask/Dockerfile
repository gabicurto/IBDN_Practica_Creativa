# Webserver
FROM python:3.7
WORKDIR /practica_creativa

RUN apt-get update && \
    apt-get upgrade -y && \
    apt install -y nano 

# Clonar repositorio con datos y modelos entrenados
RUN apt-get install git -y && \
    git clone https://github.com/Big-Data-ETSIT/practica_creativa && \
    mv practica_creativa/* . 

# Instalar dependencias de Python
RUN pip3 install -r requirements.txt

ENV PROJECT_HOME=/practica_creativa

RUN sed -i 's/localhost/kafka/g' /practica_creativa/resources/web/predict_flask.py
RUN sed -i 's+MongoClient()+MongoClient(host="mongo",port=27017)+g' /practica_creativa/resources/web/predict_flask.py
RUN chmod +x /practica_creativa/resources/web/predict_flask.py

# Cambiar al directorio del servidor web
WORKDIR /practica_creativa/resources/web

# Ejecutar servidor web
CMD python3 predict_flask.py