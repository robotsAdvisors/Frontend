# Despliegue del backoffice

El backoffice se sirve como contenedor Docker en la misma VM de GCP que el
backend (`34.88.51.238`), bajo el dominio `admin.letdem.net`.

```
VM GCP (34.88.51.238)
├── nginx (host)                    ← TLS y dominios
│    ├── api.letdem.net    → gunicorn / daphne (systemd)
│    └── admin.letdem.net  → 127.0.0.1:8080
├── Docker
│    └── letdem-backoffice → nginx interno sirviendo build/web
└── systemd: gunicorn, daphne, celery
```

El contenedor escucha **solo en `127.0.0.1`**: nunca queda expuesto a internet
directamente, siempre pasa por el nginx del host.

## Desplegar una versión nueva

La compilación se hace **en local**, no dentro del contenedor: el SDK de
Flutter ocupa varios GB y la VM tiene 2 vCPU.

```bash
# 1. Compilar (desde la raíz del repo)
flutter build web --release

# 2. Empaquetar y subir
tar czf /tmp/backoffice.tgz build/web Dockerfile deploy/nginx-container.conf
scp /tmp/backoffice.tgz gcp-letdem:/tmp/

# 3. Reconstruir y relanzar en la VM
ssh gcp-letdem '
  sudo tar xzf /tmp/backoffice.tgz -C /opt/letdem-backoffice && rm /tmp/backoffice.tgz
  cd /opt/letdem-backoffice && sudo docker build -t letdem-backoffice:latest .
  sudo docker rm -f letdem-backoffice
  sudo docker run -d --name letdem-backoffice --restart unless-stopped \
    -p 127.0.0.1:8080:80 letdem-backoffice:latest
'
```

## Comprobaciones

```bash
ssh gcp-letdem "sudo docker ps --filter name=letdem-backoffice"   # debe decir (healthy)
ssh gcp-letdem "sudo docker logs --tail 50 letdem-backoffice"
curl -I https://admin.letdem.net/
```

El contenedor arranca solo tras reiniciar la VM: `--restart unless-stopped`
más `systemctl is-enabled docker` = `enabled`.

## A qué backend apunta

Por defecto a `https://api.letdem.net` (`ApiConfig.baseUrl`). Para cambiarlo hay
que **recompilar**:

```bash
flutter build web --release --dart-define=LETDEM_API_BASE_URL=https://otro.host
```

En Flutter web el valor queda incrustado en el JavaScript. No es una variable
de entorno del contenedor: cambiarla en `docker run` no tiene ningún efecto.

## Dos detalles que costaron un rato

**El healthcheck usa `127.0.0.1`, no `localhost`.** La imagen de nginx activa
IPv6 al arrancar, pero solo sobre el `default.conf` que sustituimos. Con la
configuración propia nginx escuchaba únicamente en IPv4, `localhost` resolvía a
`::1` y el chequeo daba "connection refused": el contenedor quedaba marcado como
`unhealthy` de forma permanente aunque estuviera sirviendo perfectamente. Ahora
`nginx-container.conf` incluye `listen [::]:80` y el chequeo va por IPv4
explícito.

**`index.html` y `flutter_service_worker.js` no se cachean.** El resto de
ficheros llevan hash en el nombre y se cachean un año. Si se cacheara el
`index.html`, un despliegue nuevo no llegaría al navegador hasta que el usuario
forzara la recarga.
