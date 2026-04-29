FROM golang:1.25.0-alpine AS build

RUN apk update && apk add --no-cache git build-base libjpeg-turbo-dev libwebp-dev

WORKDIR /build

# 1. Copiar os arquivos de definição primeiro
COPY go.mod go.sum ./

# 2. GARANTA QUE O NOME ABAIXO SEJA O NOME REAL DA PASTA NO SEU DISCO
# Se a pasta se chamar apenas 'whatsmeow', mude aqui e no go.mod
COPY whatsmeow-lib/ ./whatsmeow-lib/

RUN ls -la /build/whatsmeow-lib/

# 3. Download das dependências
RUN go mod download

# 4. CORREÇÃO DA SINTAXE DE CÓPIA (espaço entre os pontos)
COPY . .

ARG VERSION=dev
RUN CGO_ENABLED=1 go build -ldflags "-X main.version=${VERSION}" -o server ./cmd/evolution-go

FROM alpine:3.19.1 AS final

RUN apk update && apk add --no-cache tzdata ffmpeg libjpeg-turbo libwebp

WORKDIR /app

COPY --from=build /build/server .
COPY --from=build /build/manager/dist ./manager/dist
COPY --from=build /build/VERSION ./VERSION

ENV TZ=America/Sao_Paulo

ENTRYPOINT ["/app/server"]
