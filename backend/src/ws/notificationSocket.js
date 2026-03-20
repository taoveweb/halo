import { WebSocketServer } from 'ws';

let wss;
// handle -> Set<WebSocket>
const clientsByHandle = new Map();

export function initNotificationSocket(server, options = {}) {
  if (wss) return wss;
  const path = options.path || '/ws/notifications';
  wss = new WebSocketServer({ server, path });

  wss.on('connection', (ws, req) => {
    try {
      const url = new URL(req.url, `http://${req.headers.host}`);
      const handle = url.searchParams.get('handle') || '@you';
      if (!clientsByHandle.has(handle)) clientsByHandle.set(handle, new Set());
      clientsByHandle.get(handle).add(ws);

      ws.on('close', () => {
        const set = clientsByHandle.get(handle);
        if (set) {
          set.delete(ws);
          if (set.size === 0) clientsByHandle.delete(handle);
        }
      });

      ws.on('error', () => {
        // ignore
      });

      // optional: client can send ping or register message
      ws.on('message', (msg) => {
        // no-op for now
      });
    } catch (e) {
      // ignore
    }
  });

  return wss;
}

export function sendNotificationToHandle(handle, notification) {
  const set = clientsByHandle.get(handle);
  if (!set || set.size === 0) return 0;
  const payload = JSON.stringify({ type: 'notification', notification });
  for (const ws of set) {
    if (ws.readyState === ws.OPEN) {
      ws.send(payload);
    }
  }
  return set.size;
}

export default { initNotificationSocket, sendNotificationToHandle };
