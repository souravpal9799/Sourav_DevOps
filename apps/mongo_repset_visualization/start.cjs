#!/usr/bin/env node
require('dotenv').config();

// Create a config.js file in mongo-express directory that reads from our .env
const fs = require('fs');
const path = require('path');

const configContent = `
export default {
  mongodb: {
    connectionString: process.env.ME_CONFIG_MONGODB_URL || "mongodb://127.0.0.1:27017,127.0.0.1:27018,127.0.0.1:27019/?replicaSet=rs0",
  },
  site: {
    baseUrl: "/",
    port: process.env.ME_CONFIG_PORT || process.env.ME_CONFIG_SITE_PORT || 8081,
    host: process.env.ME_CONFIG_HOST || "0.0.0.0",
    cookieSecret: process.env.ME_CONFIG_SITE_COOKIESECRET || "changeme",
    sessionSecret: process.env.ME_CONFIG_SITE_SESSIONSECRET || "changeme",
  },
  useBasicAuth: true,
  basicAuth: {
    username: process.env.ME_CONFIG_BASICAUTH_USERNAME || "admin",
    password: process.env.ME_CONFIG_BASICAUTH_PASSWORD || "pass123",
  },
};
`;

const configPath = path.join(__dirname, 'node_modules', 'mongo-express', 'config.js');
fs.writeFileSync(configPath, configContent);

// Run mongo-express
const { spawn } = require('child_process');
const child = spawn('node', ['node_modules/mongo-express/app.js'], {
  cwd: __dirname,
  stdio: 'inherit'
});

child.on('exit', (code) => {
  process.exit(code);
});
