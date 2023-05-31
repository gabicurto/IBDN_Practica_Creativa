#!/bin/bash

#ejecutar master y worker de spark para prediccion
./spark-3.3.0-bin-hadoop3/bin/spark-submit \
  --class es.upm.dit.ging.predictor.MakePrediction \
  --packages org.mongodb.spark:mongo-spark-connector_2.12:10.1.1,org.apache.spark:spark-sql-kafka-0-10_2.12:3.3.0 \
  /main/flight_prediction/target/scala-2.12/flight_prediction_2.12-0.1.jar &

  sleep 123456789