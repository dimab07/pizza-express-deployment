FROM ubuntu:18.04

LABEL maintainer="dmitry.bron@gmail.com"

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.description="The Pizza-Express app deployed on Ububntu 18.04 image"
LABEL org.label-schema.docker.cmd="docker run -d -h pizza-express --name pizza-express --net pizza-net -p 8081:3000 dimab/pizza-express"

ENV PIZZA_WORK_DIR /usr/src/pizza-express

WORKDIR ${PIZZA_WORK_DIR}

COPY ./pizza-express ./

RUN apt-get -yqq update && \
    apt-get -yqq install nodejs npm && \
    npm install

EXPOSE 3000

CMD [ "node", "server.js" ]
