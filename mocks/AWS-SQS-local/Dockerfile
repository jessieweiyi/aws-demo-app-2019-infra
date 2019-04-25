FROM java:8
WORKDIR /opt/app

RUN wget https://s3-eu-west-1.amazonaws.com/softwaremill-public/elasticmq-server-0.12.0.jar
COPY ./sqs.conf /opt/app
ENTRYPOINT ["/usr/bin/java", "-Dconfig.file=sqs.conf", "-jar", "/opt/app/elasticmq-server-0.12.0.jar"]

EXPOSE 6000

CMD ["-help"]
