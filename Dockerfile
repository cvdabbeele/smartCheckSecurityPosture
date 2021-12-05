FROM ubuntu:18.04
WORKDIR /app
ADD  smartchecksecurityposture.sh /app
RUN apt-get -qq update && apt-get -qq install curl jq

#CMD ["./smartchecksecurityposture.sh"]
ENTRYPOINT [ "/app/smartchecksecurityposture.sh" ] 

