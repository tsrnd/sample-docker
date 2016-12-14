'use strict';
const express = require("express");
const console = require("console");
const HttpStatus = require("http-status");
const extend_1 = require("../../../extend");
const router = express.Router();
router.use((req, res, next) => {
    console.log(`${req.method} ${req.url} \n ${req.params}`);
    next();
});
router.post('/', (req, res, next) => {
    if (req.params.username && req.params.password) {
        extend_1.response(res, HttpStatus.OK, {
            username: req.params.username,
            password: req.params.password
        });
    }
    else {
        extend_1.response(res, HttpStatus.UNAUTHORIZED);
    }
});
module.exports = router;
