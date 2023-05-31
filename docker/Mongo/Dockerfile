FROM mongo:latest

RUN apt-get update && \
    apt-get upgrade -y && \
    apt install -y nano

RUN apt-get install -y curl

# Cloning repository with data and trained models

RUN apt-get install git -y && \
    git clone https://github.com/Big-Data-ETSIT/practica_creativa 

WORKDIR /practica_creativa

RUN ./resources/download_data.sh

RUN sed -i 's/mongo /mongosh /g' /practica_creativa/resources/import_distances.sh
RUN chmod +x /practica_creativa/resources/import_distances.sh

CMD ["/bin/bash", "-c", "mongod --bind_ip_all & ./resources/import_distances.sh & sleep 1234567"]