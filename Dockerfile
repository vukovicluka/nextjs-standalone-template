FROM node:22-alpine AS base
# Install pnpm globally
RUN npm install -g pnpm
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat

# Set the working directory
WORKDIR /app
# Copy package.json and pnpm-lock.yaml to install dependencies first
COPY package.json pnpm-lock.yaml ./
# Install dependencies
RUN pnpm install

FROM base AS builder
# Copy the rest of the application files
COPY . .
# Build the application
RUN pnpm run build

FROM node:22-alpine AS runner
# Install pnpm in the runner stage
RUN npm install -g pnpm
# Set the working directory
WORKDIR /app

# Copy the necessary files from the builder stage for the standalone build
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/static .next/static

# Change ownership of the files to the node user
RUN chown -R node:node /app

# Switch to the non-root user
USER node

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME=0.0.0.0

EXPOSE 3000

CMD ["node", "server.js"]