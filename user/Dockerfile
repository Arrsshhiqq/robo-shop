FROM node:14-alpine

EXPOSE 8080

WORKDIR /opt/server

COPY package*.json ./
RUN apk add --no-cache python3 make g++
RUN npm install

COPY server.js .

CMD ["node", "server.js"]
