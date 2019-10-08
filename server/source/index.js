const http = require('http');

const port = process.env.PORT || 8080;
const ci = process.env.CI_NAME || 'local';

http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.write(`Hello World from ${ci}!`);
  res.end();
}).listen(port);
