const app = require("./app");
const db = require("./config/db");
const UserModel = require('./model/user.model');

const port = 3000;

app.get('/', (req, res) => {
    res.send("Hello World !!!");
});

// Change localhost to 0.0.0.0 to allow external connections
app.listen(port, '0.0.0.0', () => {
    console.log(`Server is running on http://0.0.0.0:${port}`);
    console.log(`Access locally: http://localhost:${port}`);
});
