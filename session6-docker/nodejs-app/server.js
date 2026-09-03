const express = require("express");

const app = express();
const port = process.env.PORT || 3000;

app.get("/", (_req, res) => {
  res.type("html").send(`<!DOCTYPE html>
<html>
  <head><title>Node.js Hello World</title></head>
  <body>
    <h1>Hello World from Node.js + Docker</h1>
  </body>
</html>`);
});

app.listen(port, "0.0.0.0", () => {
  console.log(`Node.js app listening on ${port}`);
});
