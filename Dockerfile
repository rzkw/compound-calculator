
#Use official nginx image as base image

FROM nginx:alpine

# Copy HTML files into container
COPY . /usr/share/nginx/html

# Expose port 80 to access app outside of container

EXPOSE 80

# Start nginx server

CMD ["nginx", "-g", "daemon off;"]