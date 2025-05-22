# ----------- Build Stage -----------
FROM node:16.17.0-alpine AS builder

WORKDIR /app

# Copy only dependency files first for better caching
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install

# Copy remaining source files
COPY . .

# Accept the API key as a build argument
ARG TMDB_V3_API_KEY

# Set required Vite environment variables
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"

# Build the project
RUN yarn build

# ----------- Production Stage -----------
FROM nginx:stable-alpine

# Set working directory to nginx default content folder
WORKDIR /usr/share/nginx/html

# Clean default nginx content
RUN rm -rf ./*

# Copy built files from builder stage
COPY --from=builder /app/dist .

# Expose port
EXPOSE 80

# Start nginx
ENTRYPOINT ["nginx", "-g", "daemon off;"]
