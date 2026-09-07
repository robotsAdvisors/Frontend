# Backoffice de Letdem: sirve la build web de Flutter.
#
# La compilación de Flutter NO se hace aquí. El SDK ocupa varios GB y la VM
# tiene 2 vCPU: compilar dentro del contenedor tardaría mucho más que hacerlo
# donde ya está el SDK. Se copia `build/web`, que hay que generar antes con:
#
#   flutter build web --release
#
# El backend vive en api.letdem.net, que es el valor por defecto de
# ApiConfig.baseUrl. Para apuntar a otro host hay que recompilar con
# --dart-define=LETDEM_API_BASE_URL=..., porque en Flutter web el valor queda
# incrustado en el JavaScript: no es una variable de entorno del contenedor.
FROM nginx:1.31-alpine

# La configuración por defecto de nginx devuelve 404 en cualquier ruta que no
# sea un fichero real. El backoffice usa rutas de GetX (/admin, /login...), que
# no existen en disco, así que se sustituye por una que redirige a index.html.
RUN rm /etc/nginx/conf.d/default.conf
COPY deploy/nginx-container.conf /etc/nginx/conf.d/backoffice.conf

COPY build/web /usr/share/nginx/html

EXPOSE 80

# Comprueba que nginx responde de verdad, no solo que el proceso vive. Docker
# marca el contenedor como unhealthy si deja de servir.
#
# Se usa 127.0.0.1 y no `localhost` a proposito: dentro del contenedor
# `localhost` resuelve primero a ::1, y nginx solo escucha en IPv4 (0.0.0.0:80),
# asi que el chequeo daba "connection refused" y el contenedor quedaba marcado
# como unhealthy de forma permanente aunque estuviera sirviendo bien.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://127.0.0.1/ || exit 1
