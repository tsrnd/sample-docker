'use strict';

const express = require("express");
const console = require("console");
const HttpStatus = require("http-status");
const extend = require("../../../extend");
const router = express.Router();

router.post('/', (req, res, next) => {
    if (req.params.username && req.params.password) {
        extend.response(res, HttpStatus.OK, {
            username: req.params.username,
            password: req.params.password
        });
    }
    else {
        extend.response(res, HttpStatus.UNAUTHORIZED);
    }
});

module.exports = router;
