# Stage de build
FROM node:18-alpine AS builder

WORKDIR /app

# Copie des fichiers de dépendances
COPY package*.json ./
RUN npm install

# Copie du reste des fichiers
COPY . .

# Build de l'application
RUN npm run build

# Stage de production
FROM node:18-alpine AS runner

WORKDIR /app

# Copie des fichiers nécessaires depuis le stage de build
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# Exposition du port
EXPOSE 3000

# Variable d'environnement pour la production
ENV NODE_ENV production
ENV PORT 3000

# Démarrage de l'application
CMD ["node", "server"]