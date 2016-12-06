FROM nginx:1.11.5

COPY . /etc/nginx/

RUN apt-get update; apt-get install -y openssl
RUN mkdir /etc/nginx/ssl
RUN openssl req -x509 -newkey rsa:4086 \
      -subj "/C=XX/ST=XXXX/L=XXXX/O=XXXX/CN=localhost" \
      -keyout "/etc/nginx/ssl/key.pem" \
      -out "/etc/nginx/ssl/cert.pem" \
      -days 3650 -nodes -sha256

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
