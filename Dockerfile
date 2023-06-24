# Use the Official OpenResty Docker image
FROM openresty/openresty:latest

# Set the working directory
WORKDIR /usr/local/openresty/nginx

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

# Expose port
EXPOSE 9999

# Start the OpenResty server
CMD ["openresty", "-g", "daemon off;"]
