'use strict';

const express = require("express");
const console = require("console");
const HttpStatus = require("http-status");
const rep = require("../../../ext").rep;
const router = express.Router();

router.post('/', (req, res, next) => {
    if (req.params.username && req.params.password) {
        rep(res, HttpStatus.OK, {
            username: req.params.username,
            password: req.params.password
        });
    }
    else {
        rep(res, HttpStatus.UNAUTHORIZED);
    }
});

module.exports = router;
