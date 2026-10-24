FROM ghcr.io/cirruslabs/flutter:3.44.0 AS flutter_base
FROM flutter_base AS dev
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN dart run build_runner build --delete-conflicting-outputs
EXPOSE 80
CMD flutter run -d web-server --web-port 80 --web-hostname 0.0.0.0 \
    --dart-define=AUTOBOOK_API_URL=${AUTOBOOK_API_URL:-http://localhost:3000}


FROM flutter_base AS builder

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN dart run build_runner build --delete-conflicting-outputs
ARG AUTOBOOK_API_URL=http://localhost:3000
RUN flutter build web --release --source-maps --dart-define=AUTOBOOK_API_URL=${AUTOBOOK_API_URL}

FROM nginx:alpine AS runner

COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
