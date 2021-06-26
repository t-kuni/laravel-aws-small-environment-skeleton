FROM nginx:1.20.0-alpine

# Add user
ARG APP_UID=1000
ARG APP_GID=1000
RUN adduser -u $APP_UID -g $APP_GID --disabled-password --gecos "" -s /sbin/nologin app

# Copy configs
COPY site.conf /etc/nginx/conf.d/site.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Import source code
COPY --from=XXXX /var/www/app /var/www/app

CMD exec nginx -g 'daemon off;'
