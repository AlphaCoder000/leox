FROM node:20-slim

WORKDIR /usr/src/app

RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates \
  && rm -rf /var/lib/apt/lists/*

COPY package*.json ./

RUN npm ci --omit=dev

COPY . .

EXPOSE 3000

ENV PORT=3000
ENV NODE_ENV=production

CMD ["node", "server.js"]
