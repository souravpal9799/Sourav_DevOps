const express = require('express');
const { MongoClient } = require('mongodb');
require('dotenv').config();

const app = express();
const PORT = process.env.RS_STATUS_PORT || 3000;

// Serve static files
app.use(express.static('public'));

// MongoDB connection
const mongoUrl = process.env.ME_CONFIG_MONGODB_URL;

app.get('/api/rs-status', async (req, res) => {
  let client;
  try {
    client = new MongoClient(mongoUrl);
    await client.connect();
    const db = client.db('admin');
    
    // Get replica set status using runCommand
    const rsStatus = await db.admin().command({ replSetGetStatus: 1 });
    
    // Get replica set configuration
    const rsConfig = await db.admin().command({ replSetGetConfig: 1 });
    
    res.json({
      status: rsStatus,
      config: rsConfig
    });
  } catch (error) {
    console.error('Error fetching replica set status:', error.message);
    res.status(500).json({ error: error.message });
  } finally {
    if (client) await client.close();
  }
});

app.get('/api/db-stats', async (req, res) => {
  let client;
  try {
    client = new MongoClient(mongoUrl);
    await client.connect();
    
    const adminDb = client.db('admin');
    const dbList = await adminDb.admin().listDatabases();
    
    res.json(dbList);
  } catch (error) {
    console.error('Error fetching database stats:', error.message);
    res.status(500).json({ error: error.message });
  } finally {
    if (client) await client.close();
  }
});

app.listen(PORT, () => {
  console.log(`Replica Set Status Dashboard listening at http://0.0.0.0:${PORT}`);
});
