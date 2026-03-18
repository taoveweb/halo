import cors from 'cors';
import express from 'express';
import morgan from 'morgan';

import { errorHandler, notFound } from './middleware/errorHandler.js';
import tweetRoutes from './routes/tweetRoutes.js';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

app.get('/health', (_req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.use('/api', tweetRoutes);
app.use(notFound);
app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`Backend running on http://localhost:${PORT}`);
});
