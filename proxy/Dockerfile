FROM nginx:1.11.5

ADD . /etc/nginx/
RUN cd /etc/nginx/ssh && bash self-signed.sh

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
