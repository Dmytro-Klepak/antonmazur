FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install --only=production

FROM node:18-alpine
WORKDIR /app
RUN apk add --no-cache curl postgresql-client
COPY --from=builder /app/node_modules ./node_modules
COPY . .
RUN mkdir -p /app/uploads && chmod 755 /app/uploads
EXPOSE 5000

COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["npm", "start"]
