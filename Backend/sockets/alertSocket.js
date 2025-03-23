const { Server } = require('socket.io');
let io;
function initSocket(server) {
  io = new Server(server, {
    cors: {
      origin: '*',
    },
  });
  io.on('connection', (socket) => {
    console.log('Client connected:', socket.id);
  });
}
function broadcastAlert(alertData) {
  if (io) io.emit('new_alert', alertData);
}
module.exports = { initSocket, broadcastAlert };