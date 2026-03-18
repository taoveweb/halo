import 'dotenv/config';

import cors from 'cors';
import express from 'express';
import morgan from 'morgan';

import { initDb } from './db/initDb.js';
import { errorHandler, notFound } from './middleware/errorHandler.js';
import communityRoutes from './routes/communityRoutes.js';
import tweetRoutes from './routes/tweetRoutes.js';
import topicRoutes from './routes/topicRoutes.js';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

app.get('/health', (_req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.use('/api', tweetRoutes);
app.use('/api', topicRoutes);
app.use('/api', communityRoutes);
app.use(notFound);
app.use(errorHandler);

initDb()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`Backend running on http://localhost:${PORT}`);
    });
  })
  .catch((error) => {
    console.error('Failed to initialize database:', error);
    process.exit(1);
  });
