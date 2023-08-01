# Use the Official OpenResty Docker image
FROM openresty/openresty:latest
USER root

# Set the working directory
WORKDIR /usr/local/openresty/nginx


RUN groupadd nginx && useradd -r -g nginx nginx

# Remove default configuration
RUN rm -v conf/nginx.conf

# Update package lists
RUN apt-get update

# Install curl
RUN apt-get install -y curl

# Copy your OpenResty configuration and application into the Docker image
COPY conf/nginx.conf conf/nginx.conf
RUN mkdir src
COPY src/*.lua src/

RUN mkdir -p /usr/local/openresty/nginx/client_body_temp && chown -R nginx:nginx /usr/local/openresty/nginx
RUN mkdir -p /usr/local/openresty/nginx/proxy_temp && chown -R nginx:nginx /usr/local/openresty/nginx/proxy_temp

RUN mkdir -p /usr/local/openresty/nginx/proxy_temp && \
    chown -R nginx:nginx /usr/local/openresty/nginx && \
    chmod -R 755 /usr/local/openresty/nginx

RUN mkdir -p /usr/local/openresty/nginx/fastcgi_temp && \
    chown -R nginx:nginx /usr/local/openresty/nginx && \
    chmod -R 755 /usr/local/openresty/nginx

RUN mkdir -p /usr/local/openresty/nginx/uwsgi_temp && \
    chown -R nginx:nginx /usr/local/openresty/nginx && \
    chmod -R 755 /usr/local/openresty/nginx

RUN mkdir -p /usr/local/openresty/nginx/scgi_temp && \
    chown -R nginx:nginx /usr/local/openresty/nginx && \
    chmod -R 755 /usr/local/openresty/nginx

RUN mkdir -p /usr/local/openresty/nginx/scgi_temp && \
    chown -R nginx:nginx /usr/local/openresty/nginx && \
    chmod -R 755 /usr/local/openresty/nginx
RUN touch /usr/local/openresty/nginx/./error.log
RUN touch /usr/local/openresty/nginx/./access.log

RUN chown root:root /usr/local/openresty/nginx/./error.log
RUN chown root:root /usr/local/openresty/nginx/./access.log
RUN chown 755 /usr/local/openresty/nginx/./error.log
RUN chown 755 /usr/local/openresty/nginx/./access.log


# Expose port
EXPOSE 9999


# Start the OpenResty server
CMD ["openresty", "-g", "daemon off;"]
