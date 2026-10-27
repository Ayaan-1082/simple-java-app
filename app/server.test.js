const test = require('node:test');
const assert = require('node:assert/strict');
const { once } = require('node:events');
const { createServer } = require('./server');

test('the application serves a page, a health check, and a 404', async () => {
  const server = createServer();
  server.listen(0, '127.0.0.1');
  await once(server, 'listening');
  const address = `http://127.0.0.1:${server.address().port}`;
  try {
    const page = await fetch(address);
    assert.equal(page.status, 200);
    assert.match(await page.text(), /Jenkins to Kubernetes/);
    const health = await fetch(`${address}/health`);
    assert.equal(health.status, 200);
    assert.deepEqual(await health.json(), { status: 'ok' });
    const missing = await fetch(`${address}/missing`);
    assert.equal(missing.status, 404);
  } finally {
    await new Promise((resolve, reject) => server.close(error => error ? reject(error) : resolve()));
  }
});
