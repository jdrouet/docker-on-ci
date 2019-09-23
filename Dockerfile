FROM node:lts-alpine

EXPOSE 8080

ARG CI_NAME=local
ENV CI_NAME=${CI_NAME}
ENV PORT=8080

WORKDIR /code
COPY . /code

CMD ["npm", "start"]
