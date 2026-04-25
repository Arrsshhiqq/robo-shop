FROM node:14-alpine

EXPOSE 8080

WORKDIR /opt/server

COPY package*.json ./
RUN npm install

COPY server.js .

CMD ["node", "server.js"]
