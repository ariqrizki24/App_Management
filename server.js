const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const PORT = 3000;

app.use(bodyParser.json());
app.use(cors());

const db = new sqlite3.Database(':memory:');
db.serialize(() => {
    db.run("CREATE TABLE products (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, price REAL, jumlah INTEGER, deskripsi TEXT)");
});

app.get('/products', (req, res) => {
    db.all("SELECT * FROM products", [], (err, rows) => {
        if (err) {
            res.status(500).send(err.message);
        } else {
            res.json(rows);
        }
    });
});

app.post('/products', (req, res) => {
    console.log(req.body); 
    const { name, price, jumlah, deskripsi } = req.body;
    db.run("INSERT INTO products (name, price, jumlah, deskripsi) VALUES (?, ?, ?, ?)", [name, price, jumlah, deskripsi], function (err) {
        if (err) {
            res.status(500).send(err.message);
        } else {
            res.json({ id: this.lastID, name, price, jumlah, deskripsi });
        }
    });
});


app.put('/products/:id', (req, res) => {
    const { id } = req.params;
    const { name, price, jumlah, deskripsi } = req.body;
    db.run("UPDATE products SET name = ?, price = ?, jumlah = ?, deskripsi = ? WHERE id = ?", [name, price, jumlah, deskripsi, id], function (err) {
        if (err) {
            res.status(500).send(err.message);
        } else {
            res.json({ message: 'Product updated' });
        }
    });
});

app.delete('/products/:id', (req, res) => {
    const { id } = req.params;
    db.run("DELETE FROM products WHERE id = ?", [id], function (err) {
        if (err) {
            res.status(500).send(err.message);
        } else {
            res.json({ message: 'Product deleted' });
        }
    });
});

app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
