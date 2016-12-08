'use strict';
const express = require("express");
const console = require("console");
const HttpStatus = require("http-status");
const router = express.Router();
router.use((req, res, next) => {
    console.log(`${req.method} ${req.url} \n ${req.params}`);
    next();
});
router.post('/', (req, res, next) => {
    if (req.params.username && req.params.password) {
        res.status(HttpStatus.OK).json({
            username: req.params.username,
            password: req.params.password
        });
    }
    else {
        const code = HttpStatus.UNAUTHORIZED;
        const msg = HttpStatus[code];
        res.status(code).json({ error: msg });
    }
});
module.exports = router;
//# sourceMappingURL=auth.js.map