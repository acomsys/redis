# Redis Image

This redis image contains some of the good plugins that we use.

## Default Versions

```
ARG V_REDIS=6.0.9
ARG V_REDISEARCH=2.0.4
ARG V_REDISJSON=1.0.6
ARG V_OPENSSL=1.1.1h
```

## Example docker-compose

``` yml
version: "3.8"

networks:
  default:
    driver: "bridge"
    name: "dash"

services:

  redis:
    image: "acomsys/redis:latest"
    ports:
      - "6379:6379"
    volumes:
      - "${PWD}/.data/redis:/var/redis/data"
    networks:
      - "default"
    shm_size: "2gb"
    restart: "unless-stopped"
```