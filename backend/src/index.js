import 'dotenv/config';

import cors from 'cors';
import express from 'express';
import morgan from 'morgan';
import path from 'path';
import { fileURLToPath } from 'url';

import { initDb } from './db/initDb.js';
import { errorHandler, notFound } from './middleware/errorHandler.js';
import communityRoutes from './routes/communityRoutes.js';
import tweetRoutes from './routes/tweetRoutes.js';
import topicRoutes from './routes/topicRoutes.js';
import adminRoutes from './routes/adminRoutes.js';
import socialRoutes from './routes/socialRoutes.js';

const app = express();
const PORT = process.env.PORT || 3000;
import http from 'http';
import { initNotificationSocket } from './ws/notificationSocket.js';
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

app.use(cors());
app.use(express.json({ limit: '8mb' }));
app.use(morgan('dev'));
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

app.get('/health', (_req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.use('/api', tweetRoutes);
app.use('/api', topicRoutes);
app.use('/api', communityRoutes);
app.use('/api', adminRoutes);
app.use('/api', socialRoutes);
app.use(notFound);
app.use(errorHandler);

initDb()
  .then(() => {
    const server = http.createServer(app);
    server.listen(PORT, () => {
      console.log(`Backend running on http://localhost:${PORT}`);
    });

    // initialize websocket notification socket
    try {
      initNotificationSocket(server, { path: '/ws/notifications' });
      console.log('WebSocket notification socket initialized at /ws/notifications');
    } catch (e) {
      console.error('Failed to init notification socket:', e);
    }
  })
  .catch((error) => {
    console.error('Failed to initialize database:', error);
    process.exit(1);
  });
