FROM quay.io/projectquay/golang:1.20 as builder

WORKDIR /go/src/app
COPY . .
RUN mkdir -p output
RUN go get
RUN make build
RUN cp kbot output/kbot

FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot", "start"]
