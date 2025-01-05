FROM docker:27-dind

RUN apk add --update --no-cache bash sshpass

COPY src/main.sh /main.sh

ENTRYPOINT ["bash", "/main.sh"]