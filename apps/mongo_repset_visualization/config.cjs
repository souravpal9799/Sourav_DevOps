require('dotenv').config();

module.exports = {
  mongodb: {
    connectionString: process.env.ME_CONFIG_MONGODB_URL || "mongodb://127.0.0.1:27017,127.0.0.1:27018,127.0.0.1:27019/?replicaSet=rs0",
  },

  site: {
    baseUrl: "/",
    port: process.env.ME_CONFIG_PORT || process.env.ME_CONFIG_SITE_PORT || 8081,
    host: process.env.ME_CONFIG_HOST || "0.0.0.0",
  },

  useBasicAuth: true,
  basicAuth: {
    username: process.env.ME_CONFIG_BASICAUTH_USERNAME || "admin",
    password: process.env.ME_CONFIG_BASICAUTH_PASSWORD || "pass123",
  },
};
