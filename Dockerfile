FROM cgr.dev/chainguard/node

WORKDIR /app

COPY --chown=node:node package.json package-lock.json ./
COPY --chown=node:node src ./src
COPY --chown=node:node nodemon.json ./

RUN npm install --omit=dev

USER node

EXPOSE 3000

ENV NODE_ENV=production
ENV PORT=3000

CMD [ "src/index.js" ]