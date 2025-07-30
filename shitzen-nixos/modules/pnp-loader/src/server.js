const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 3200;

// Configuration paths
const packsDir = '/data/services/pnp-loader/games2/packs';
const gamesDir = '/data/services/pnp-loader/games';
const dllDir = '/data/services/pnp-loader/DLL';
const versionFile = '/data/services/pnp-loader/version/version.txt';
const API_KEY = 'NAHa7TURr4MM4sp7Ejt1bSQscDoE5m';

// Trust proxy (Cloudflare or NGINX)
app.set('trust proxy', true);

// Serve ZIP downloads
app.get('/api/download/:appid', (req, res) => {
  const appid = req.params.appid;
  const zipPath = path.join(packsDir, appid + '.zip');

  if (!fs.existsSync(zipPath)) {
    return res.status(404).json({ error: 'ZIP not found' });
  }

  res.download(zipPath, appid + '.zip', err => {
    if (err) console.error('Error sending ' + appid + '.zip:', err.message);
    else console.log('Sent ', appid + '.zip');
  });
});

// List available ZIPs
app.get('/api/list', (req, res) => {
  const files = fs.readdirSync(packsDir).filter(f => f.endsWith('.zip'));
  res.json({ available: files });
});

// ? Serve version string
app.get('/api/version', (req, res) => {
  if (!fs.existsSync(versionFile)) {
    return res.status(404).json({ error: 'Version file not found' });
  }

  const version = fs.readFileSync(versionFile, 'utf8').trim();
  res.type('text/plain').send(version);
});

// Serve individual game JSON files
app.get('/games/:file', (req, res) => {
  const file = req.params.file;
  const queryKey = req.query.key;
  const headerKey = req.headers['x-api-key'];

  if (
    file === 'games2.json' &&
    queryKey !== API_KEY &&
    headerKey !== API_KEY
  ) {
    return res.status(403).json({ error: 'Forbidden: Invalid or missing API key' });
  }

  if (!file.endsWith('.json')) {
    return res.status(400).json({ error: 'Only JSON files are allowed' });
  }

  const filePath = path.join(gamesDir, file);

  if (!fs.existsSync(filePath)) {
    return res.status(404).json({ error: 'Game file not found' });
  }

  res.sendFile(filePath);
});

// List JSON files
app.get('/games', (req, res) => {
  const files = fs.readdirSync(gamesDir).filter(f => f.endsWith('.json'));
  res.json({ availableGames: files });
});

// Serve hidden DLL under disguised heartbeat path
app.get('/heartbeat/:token', (req, res) => {
  const token = req.params.token;

  const knownToken = '290f21c9f7f0f5ff1eae1ddd0459ea35365198a81990c0cba35322683d51f3c0';
  const dllPath = path.join(dllDir, 'hid.dll');

  if (token !== knownToken) {
    return res.status(403).json({ error: 'Invalid or missing token' });
  }

  if (!fs.existsSync(dllPath)) {
    return res.status(404).json({ error: 'File not found' });
  }

  res.download(dllPath, 'runtime.data', err => {
    if (err) console.error('Error sending disguised DLL:', err.message);
    else console.log('?? Heartbeat route used? Sent runtime.data for token:', token);
  });
});

// Serve beta build ZIP from /download/beta
app.get('/download/beta', (req, res) => {
  const betaPath = '/data/services/pnp-loader/release/beta/PnPLocalBeta.zip';

  if (!fs.existsSync(betaPath)) {
    return res.status(404).json({ error: 'Beta release not found' });
  }

  res.download(betaPath, 'PnPLocalBeta.zip', err => {
    if (err) console.error('Error sending beta ZIP:', err.message);
    else console.log('?? Sent beta release PnPLocalBeta.zip');
  });
});

// Catch-all for undefined routes
app.use((req, res) => {
  res.status(404).send('why you looking here smh');
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log('CDN/API server running at http://0.0.0.0:' + PORT);
});