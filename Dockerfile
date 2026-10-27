FROM node:24-alpine
WORKDIR /app
COPY app/package.json ./
COPY app/server.js app/server.test.js ./
USER node
EXPOSE 3000
CMD ["node", "server.js"]
