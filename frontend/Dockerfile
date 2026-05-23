FROM ghcr.io/cirruslabs/flutter:3.41.9 AS flutter_base
FROM flutter_base AS dev
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
EXPOSE 80
CMD ["flutter", "run", "-d", "web-server", "--web-port", "80", "--web-hostname", "0.0.0.0"]


FROM flutter_base AS builder

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release


FROM nginx:alpine AS runner

COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
