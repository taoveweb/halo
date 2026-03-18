import { copyFileSync, existsSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const backendRoot = path.resolve(__dirname, '..');
const envPath = path.join(backendRoot, '.env');
const envExamplePath = path.join(backendRoot, '.env.example');

if (existsSync(envPath)) {
  console.log('✅ .env already exists, skipping generation.');
  process.exit(0);
}

if (!existsSync(envExamplePath)) {
  console.error('❌ .env.example not found, cannot auto-generate .env file.');
  process.exit(1);
}

copyFileSync(envExamplePath, envPath);
console.log('✅ Generated .env from .env.example automatically.');
