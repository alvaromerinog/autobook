FROM node:22-alpine AS base
RUN corepack enable && corepack prepare pnpm@10.29.3 --activate


FROM base AS builder

WORKDIR /app

COPY .npmrc package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm run build


FROM base AS runner

WORKDIR /app

COPY .npmrc package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod

COPY prisma ./prisma
COPY prisma.config.ts ./
RUN pnpm exec prisma generate

COPY --from=builder /app/dist ./dist

RUN mkdir -p /data

ENV DATABASE_URL="file:/data/autobook.db"
ENV NODE_ENV="production"

EXPOSE 3000

CMD ["sh", "-c", "pnpm exec prisma migrate deploy && node dist/src/main"]
