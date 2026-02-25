# Mongo Express Setup on WSL with Docker

This is a Mongo Express configuration running in Docker that reads all settings from a `.env` file.

## Files

- **docker-compose.yml** - Docker Compose configuration for mongo-express
- **.env** - Environment variables for configuration
- **package.json** - npm scripts for managing the container
- **start.cjs** - Legacy Node.js startup script (replaced by Docker)

## Environment Variables

The application reads the following variables from `.env`:

- `ME_CONFIG_MONGODB_URL` - MongoDB connection string (required)
- `ME_CONFIG_PORT` - Port number for the web interface (default: 8081)
- `ME_CONFIG_BASICAUTH_USERNAME` - Username for basic auth (default: admin)
- `ME_CONFIG_BASICAUTH_PASSWORD` - Password for basic auth (default: pass123)
- `ME_CONFIG_SITE_COOKIESECRET` - Secret for cookies
- `ME_CONFIG_SITE_SESSIONSECRET` - Secret for session

## Current .env file

```
ME_CONFIG_MONGODB_URL="mongodb://127.0.0.1:27017,127.0.0.1:27018,127.0.0.1:27019/?replicaSet=rs0"
ME_CONFIG_PORT=8081
ME_CONFIG_BASICAUTH_USERNAME=admin
ME_CONFIG_BASICAUTH_PASSWORD=pass123
ME_CONFIG_SITE_COOKIESECRET=your_cookie_secret_here
ME_CONFIG_SITE_SESSIONSECRET=your_session_secret_here
```

## How to Run

Start mongo-express in the foreground (with logs):
```bash
docker-compose up
```

Or start in detached mode (background):
```bash
npm start:detached
```

Or using npm with foreground:
```bash
npm start
```

## View Logs

```bash
npm run logs
```

## Stop

```bash
npm run stop
```

## Access

Once running, open your browser and navigate to:
```
http://localhost:8081
```

Use the credentials from your .env file to log in (admin / pass123).

## Docker Requirements

- Docker and Docker Compose must be installed on your system
- This setup uses the official `mongo-express:latest` Docker image

## Notes

- The MongoDB connection string points to a local replica set (27017, 27018, 27019)
- Update `ME_CONFIG_MONGODB_URL` in the `.env` file to connect to your MongoDB instance
- Change the cookie and session secrets for production use
- The container will automatically restart if it crashes (`restart: always`)
