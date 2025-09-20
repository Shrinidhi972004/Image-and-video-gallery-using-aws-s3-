# ---------- Build stage ----------
FROM node:18-alpine AS builder

WORKDIR /usr/src/app

# Install dependencies
COPY package*.json ./
RUN npm install --production

# Copy source code
COPY . .

# ---------- Runtime stage ----------
FROM node:18-alpine

WORKDIR /usr/src/app

# Copy dependencies and app
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app ./

# Expose backend port
EXPOSE 5002

# Run backend
CMD ["node", "app.js"]
