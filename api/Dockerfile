FROM golang:1.25

WORKDIR /app

COPY go.mod ./

COPY *.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -o ./main

EXPOSE 8080

CMD ["/app/main"]
