#!/bin/bash

# Define the repository and directory
REPO="git@github.com:adebanjo23/PredictLawCode.git"
DIR="predict-law" # Change this to your repository's directory name


# Check if the repository directory exists
if [ ! -d "$DIR" ]; then
    echo "Repository directory does not exist. Cloning repository..."
    git clone $REPO $DIR
    cd $DIR
    git checkout develop
else
    echo "Repository directory exists. Pulling latest changes..."
    cd $DIR
    git checkout develop
    git pull
fi

# Stop any running containers using the 'cleona_backend_image' image
echo "Stopping any running containers..."
docker ps -q --filter "ancestor=cleona_backend_image" | xargs -r docker stop

# Continue with the Docker build and run process...
echo "Building Docker image..."
docker build -t predict_law_image .

# Check for the SERVER_PORT variable in the .env file
SERVER_PORT=$(grep 'SERVER_PORT' .env | cut -d '=' -f2)

# Ensure SERVER_PORT has been extracted correctly
if [ -z "$SERVER_PORT" ]; then
    echo "SERVER_PORT not found in .env file. Please ensure it's defined."
    exit 1
fi

# Run the Docker container, passing all environment variables and mapping ports
echo "Running Docker container on port $SERVER_PORT..."
docker run --env-file .env --network="host" -p 127.0.0.1:$SERVER_PORT:$SERVER_PORT cleona_backend_image