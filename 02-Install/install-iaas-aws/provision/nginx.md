# nginx

permet de forwarder le port 443 vers 6443 pour accéder aux clusters même d'un réseau qui bloque le 6443

https://www.cyberciti.biz/faq/configure-nginx-ssltls-passthru-with-tcp-load-balancing/



nginx.conf

```
user  nginx;
worker_processes  1;
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;
    sendfile        on;
    #tcp_nopush     on;
    keepalive_timeout  65;
    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
include /etc/nginx/passthrough.conf;
```


passthrough.conf

```sh
## tcp LB  and SSL passthrough for backend ##
stream {
    upstream k8dapisrv {
        server 127.0.0.1:6443 max_fails=3 fail_timeout=10s;
    }

log_format basic '$remote_addr [$time_local] '
                 '$protocol $status $bytes_sent $bytes_received '
                 '$session_time "$upstream_addr" '
                 '"$upstream_bytes_sent" "$upstream_bytes_received" "$upstream_connect_time"';

    access_log /var/log/nginx/www.cyberciti.biz_access.log basic;
    error_log  /var/log/nginx/wwww.cyberciti.biz_error.log;

    server {
        listen 443;
        proxy_pass k8dapisrv;
        proxy_next_upstream on;
    }
}

```

```sh

docker run -d --name nginx-api-srv -p 443:443 -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro -v $(pwd)/passthrough.conf:/etc/nginx/passthrough.conf:ro nginx

```













/etc/nginx/nginx.conf par défaut
```
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}


```


il faut mettre la conf complémentaire dans /etc/nginx/conf.d/*.conf
nginx-k8s-api-srv.conf
```java
server {
    listen       443;

    location / {
        proxy_pass https://127.0.0.1:6443;
		proxy_set_header Host $host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

lancement de docker
ce mettre dans le répertoire contenant le fichier .conf
```cmd
docker run nginx

docker run -d --name nginx-api-srv -p 443:443 -v $(pwd)/:/etc/nginx/conf.d/:ro nginx
```