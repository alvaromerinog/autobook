FROM node:22-alpine AS base
RUN corepack enable && corepack prepare pnpm@10.29.3 --activate


FROM base AS builder

WORKDIR /app

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm exec prisma generate
RUN pnpm run build


FROM builder AS dev
EXPOSE 3000
CMD ["sh", "-c", "pnpm exec prisma migrate deploy && pnpm start:dev"]


FROM base AS runner

WORKDIR /app

COPY prisma ./prisma
COPY prisma.config.ts ./

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules

RUN mkdir -p /data

EXPOSE 3000

CMD ["sh", "-c", "pnpm exec prisma migrate deploy && pnpm start:prod"]
