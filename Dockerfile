# Use the official Node.js runtime as base image
FROM node:lts-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the application file
COPY app.js .

# Expose port 3000 (for the HTTP server version)
EXPOSE 3000

# Command to run the application
CMD ["node", "app.js"]
