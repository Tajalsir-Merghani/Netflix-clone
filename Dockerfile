# ---- Build Stage ----
FROM node:16.17.0-alpine as builder

# Set working directory
WORKDIR /app

# Copy dependencies
COPY ./package.json .
COPY ./yarn.lock .
RUN yarn install

# Copy the rest of the app
COPY . .

# Accept TMDB API key as a build argument
ARG TMDB_V3_API_KEY

# Set environment variables for the build process
ENV VITE_APP_TMDB_V3_API_KEY=$TMDB_V3_API_KEY
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"

# Build the app
RUN yarn build

# ---- Production Stage ----
FROM nginx:stable-alpine

# Clean the default nginx public folder
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*

# Copy the built app from the previous stage
COPY --from=builder /app/dist .

# Expose the default nginx port
EXPOSE 80

# Start nginx
ENTRYPOINT ["nginx", "-g", "daemon off;"]
