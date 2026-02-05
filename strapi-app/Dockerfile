# Use official Node.js image (Debian Slim is better for Strapi/native deps than Alpine)
FROM node:20-slim

# Set environment variables
ENV NODE_ENV=production
# Increase memory limit for build process
ENV NODE_OPTIONS="--max-old-space-size=4096"

# Create app directory
WORKDIR /app

# Install system dependencies required for native modules
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package*.json ./

# Install dependencies (using install to update lockfile if needed)
RUN npm install --only=production --no-audit --no-fund

# Copy source code
COPY . .

# Build the Strapi admin panel
RUN npm run build

# Expose port
EXPOSE 1337

# Start the application
CMD ["npm", "run", "start"] 