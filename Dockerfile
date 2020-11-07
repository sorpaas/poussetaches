FROM golang:1.12

WORKDIR /app
COPY . .
RUN mkdir /app/poussetaches_data
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -mod=vendor .
CMD ["/app/poussetaches"]

FROM alpine:latest

# Create the microblogpub user
ARG UID=6995
ARG GID=6995
RUN apt update && \
  echo "Etc/UTC" > /etc/localtime && \
  ln -s /opt/jemalloc/lib/* /usr/lib/ && \
  apt install -y whois wget && \
  addgroup --gid $GID microblogpub && \
  useradd -m -u $UID -g $GID -d /opt/microblogpub microblogpub && \
  echo "microblogpub:`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 | mkpasswd -s -m sha-256`" | chpasswd

WORKDIR /app
RUN mkdir -p /app/poussetaches_data
RUN chown microblogpub:microblogpub /app/poussetaches_data
COPY --from=0 /app/poussetaches /app/poussetaches

USER microblogpub

CMD ["/app/poussetaches"]

