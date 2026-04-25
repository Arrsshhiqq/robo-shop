FROM golang:1.17-alpine AS builder

WORKDIR /go/src/app
COPY *.go .
RUN go mod init dispatch && go get && go build -o dispatch

FROM alpine:latest

WORKDIR /app
COPY --from=builder /go/src/app/dispatch .

CMD ["./dispatch"]
