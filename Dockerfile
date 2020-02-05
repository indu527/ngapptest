# stage 1
FROM node:latest as node
WORKDIR /app
COPY . .
RUN npm set strict-ssl false
RUN npm install
RUN npm run build --prod

### STAGE 2: Setup ###

FROM nginx:1.13.3-alpine

## Copy our default nginx config
COPY default.conf /etc/nginx/conf.d/

## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*
#RUN chmod g+rwx /var/cache/nginx /var/run /var/log/nginx
RUN chmod -R 777 /var/log/nginx /var/cache/nginx/ /etc/nginx /var/run /var/lib /var/opt /var/tmp /var/spool /var/lock /usr
#RUN chmod 777 /etc/nginx/*
# users are not allowed to listen on priviliged ports
#RUN sed -i.bak 's/listen\(.*\)80;/listen 8081;/' /etc/nginx/conf.d/default.conf
EXPOSE 8081
# comment user directive as master process is run as user in OpenShift anyhow
RUN sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf

## From 'builder' stage copy over the artifacts in dist folder to default nginx public folder
COPY --from=node /app/dist/testngapp /usr/share/nginx/html

CMD ["nginx", "-g", "daemon off;"]
