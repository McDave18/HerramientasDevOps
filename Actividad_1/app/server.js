const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Validación de deploy de la AMI e instancia desde AWS');
});

app.listen(port, () => {
  console.log(`App escuchando en http://localhost:${port}`);
});
